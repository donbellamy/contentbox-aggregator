component extends="cborm.models.VirtualEntityService" singleton {

	property name="feedReader" inject="feedReader@cbfeeds";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="settingService" inject="settingService@cb";
	property name="moduleSettings" inject="coldbox:setting:modules";
	property name="htmlHelper" inject="HTMLHelper@coldbox";
	property name="jsoup" inject="jsoup@cbjsoup";
	property name="log" inject="logbox:logger:{this}";

	FeedImportService function init() {

		super.init( entityName="cbFeedImport", useQueryCaching=true );

		return this;

	}

	FeedImportService function import( required Feed feed, required Author author ) {

		// Grab the settings
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		try {

			// Grab the remote feed
			var remoteFeed = feedReader.retrieveFeed( arguments.feed.getFeedUrl() );

			// Check for items in feed
			if ( arrayLen( remoteFeed.items ) ) {

				// Set an item counter
				var itemCount = 0;

				// Check if we are importing images
				var importImages = len( arguments.feed.getImportImages() ) ? arguments.feed.getImportImages() : settings.ag_importing_image_import_enable;
				var importFeaturedImages = len( arguments.feed.getImportFeaturedImages() ) ? arguments.feed.getImportFeaturedImages() : settings.ag_importing_featured_image_enable;

				// Loop over items
				for ( var item IN remoteFeed.items ) {

					// Create a unique id to track this item
					var uniqueId = item.id;
					if ( !len( uniqueId ) ) {
						uniqueId = item.url;
					}

					// Validate url, title and body
					if ( len( item.url ) && len( item.title ) && len( item.body ) ) {

						// Check if item already exists
						var itemExists = feedItemService.newCriteria().isEq( "uniqueId", uniqueId ).count();

						// Doesn't exist, so try and import
						if ( !itemExists ) {

							// Check keyword filters
							var passesFilters = true;
							var itemText = item.title & " " & item.body;
							var matchAnyFilter = listToArray( len( trim( arguments.feed.getMatchAnyFilter() ) ) ? arguments.feed.getMatchAnyFilter() : trim( settings.ag_importing_match_any_filter ) );
							var matchAllFilter = listToArray( len( trim( arguments.feed.getMatchAllFilter() ) ) ? arguments.feed.getMatchAllFilter() : trim( settings.ag_importing_match_all_filter ) );
							var matchNoneFilter = listToArray( len( trim( arguments.feed.getMatchNoneFilter() ) ) ? arguments.feed.getMatchNoneFilter() : trim( settings.ag_importing_match_none_filter ) );

							// Check match any
							if ( arrayLen( matchAnyFilter ) ) {
								passesFilters = false;
								for ( var filter IN matchAnyFilter ) {
									if ( findNoCase( filter, itemText ) ) {
										passesFilters = true;
										break;
									}
								}
							}

							// Check match all - if not already failed
							if ( arrayLen( matchAllFilter ) && passesFilters ) {
								for ( var filter IN matchAllFilter ) {
									if ( !findNoCase( filter, itemText ) ) {
										passesFilters = false;
										break;
									}
								}
							}

							// Check match none - if not already failed
							if ( arrayLen( matchNoneFilter ) && passesFilters ) {
								for ( var filter IN matchNoneFilter ) {
									if ( findNoCase( filter, itemText ) ) {
										passesFilters = false;
										break;
									}
								}
							}

							// Import only if item passes the filters
							if ( passesFilters ) {

								// Check age limits
								var passesAgeLimits = true;
								var maxAge = val( arguments.feed.getMaxAge() ) ? val( arguments.feed.getMaxAge() ) : val( settings.ag_importing_max_age );
								var maxAgeUnit = val( arguments.feed.getMaxAge() ) ? arguments.feed.getMaxAgeUnit() : settings.ag_importing_max_age_unit;

								if ( maxAge && isDate( item.datePublished ) ) {
									var maxDate = now();
									switch( maxAgeUnit ) {
										case "weeks": {
											maxDate = dateAdd( "ww", -maxAge, maxDate );
											break;
										}
										case "months": {
											maxDate = dateAdd( "m", -maxAge, maxDate );
											break;
										}
										case "years": {
											maxDate = dateAdd( "yyyy", -maxAge, maxDate );
											break;
										}
										default: {
											maxDate = dateAdd( "d", -maxAge, maxDate );
										}
									}
									if ( dateCompare( maxDate, item.datePublished ) EQ 1 ) {
										passesAgeLimits = false;
									}
								}

								// Import only if item passes age limits
								if ( passesAgeLimits ) {

									try {

										// Create feed item
										var feedItem = feedItemService.new();

										// FeedItem properties
										feedItem.setUniqueId( uniqueId );
										feedItem.setItemUrl( item.url );
										if ( len( trim( item.author ) ) ) {
											feedItem.setItemAuthor( item.author );
										}
										feedItem.setMetaInfo( serializeJSON( item ) );
										feedItem.setParent( arguments.feed );

										// BaseContent properties
										feedItem.setTitle( item.title );
										feedItem.setSlug( htmlHelper.slugify( item.title ) );
										feedItem.setCreator( arguments.author );
										var datePublished = now();
										if ( isDate( item.datePublished ) ) {
											datePublished = item.datePublished;
										}
										feedItem.setPublishedDate( datePublished );
										var dateUpdated = now();
										if ( isDate( item.dateUpdated ) ) {
											dateUpdated = item.dateUpdated;
										}
										feedItem.setModifiedDate( dateUpdated );
										if ( arguments.feed.autoPublishItems() ) {
											feedItem.setIsPublished( true );
										} else {
											feedItem.setIsPublished( false );
										}

										// Set whitelist
										var whitelist = jsoup.getWhiteList();
										// Add rel, target to a tag
										whitelist.addAttributes( "a", javacast( "string[]", ["rel","target"] ) );
										// Add iframe tag and attributes
										whitelist.addTags( javacast( "string[]", ["iframe"] ) );
										whitelist.addAttributes( "iframe", javacast( "string[]", ["src","width","height","frameborder","allow","allowfullscreen"] ) );

										// Clean
										var feedBody = jsoup.clean( item.body, whitelist );

										// Are we importing images?
										if ( importImages || importFeaturedImages ) {

											// Set array to hold all image paths
											var imagePaths = [];

											// Parse the html and get the images
											var doc = jsoup.parseBodyFragment( feedBody );
											var images = doc.getElementsByTag("img");

											// Make sure we have some images
											if ( arrayLen( images ) ) {

												// Reset images array if only importing featured image
												if ( !importImages && importFeaturedImages ) {
													images = [ images[1] ];
												}

												// Loop over images
												for ( var idx=1; idx LTE arrayLen( images ); idx++ ) {

													try {

														// Grab the image
														var result = new http( url=images[idx].attr("src"), method="GET" ).send().getPrefix();

														// Check for error and valid image
														if ( result.status_code == "200" && listFindNoCase( "image/gif,image/jpeg,image/png", result.mimeType ) ) {

															// Set the extension
															var ext = "";
															switch ( result.mimeType ) {
																case "image/gif":
																	ext = "gif";
																	break;
																case "image/jpeg":
																	ext = "jpg";
																	break;
																default:
																	ext = "png";
															}

															// Set the folder path and create if needed
															var folderPath = expandPath( settingService.getSetting( "cb_media_directoryRoot" ) ) & "\aggregator\feeditems\" & dateformat( datePublished, "yyyy\mm\" );
															if ( !directoryExists( folderPath ) ) {
																directoryCreate( folderPath );
																if ( log.canInfo() ) {
																	log.info("Created aggregator feeditems image folder - #folderPath#.");
																}
															}

															// Set image name and path (using _ to differentiate identical slugs)
															var imageName = feedItem.getSlug() & "_" & idx & "." & ext;
															var imagePath = folderPath & imageName;

															// Save the image
															fileWrite( imagePath, result.fileContent );

															// Grab the image object
															var img = imageRead( imagePath );

															// Save the image if it is valid
															if ( img.getWidth() GTE val( settings.ag_importing_image_minimum_width ) &&
																img.getHeight() GTE val( settings.ag_importing_image_minimum_height ) ) {

																// Set the image url
																var entryPoint = moduleSettings["contentbox-ui"].entryPoint;
																var folderUrl = ( len( entryPoint ) ? "/" & entryPoint : "" ) & "/__media/aggregator/feeditems/" & dateformat( datePublished, "yyyy/mm/" );
																var imageUrl = folderUrl & imageName;

																// Set featured image
																if ( importFeaturedImages && !len( feedItem.getFeaturedImage() ) ) {
																	feedItem.setFeaturedImage( imagePath );
																	feedItem.setFeaturedImageUrl( imageUrl );
																}

																// Update image
																images[idx].attr( "src", imageUrl );

																// Add to image path array
																arrayAppend( imagePaths, imagePath );

															} else {

																// Delete the image
																fileDelete( imagePath );

																if ( log.canInfo() ) {
																	log.info("Invalid image size for feed item ('#uniqueId#').");
																}

															}

														}

													} catch( any e ) {

														if ( log.canError() ) {
															log.error( "Error retrieving and saving image for feed item ('#uniqueId#').", e );
														}

													}

												}

												// Reset the content
												feedBody = doc.body().html();

											}

										}

										// Add the content version
										feedItem.addNewContentVersion(
											content=feedBody,
											changelog="Item imported.",
											author=arguments.author
										);

										// Save item
										feedItemService.save( feedItem );

										// Increase item count
										itemCount++;

										// Log item saved
										if ( log.canInfo() ) {
											log.info("Feed item ('#uniqueId#') saved for feed '#arguments.feed.getTitle()#'.");
										}

									} catch( any e ) {

										// Log the error
										if ( log.canError() ) {
											log.error( "Error saving feed item ('#uniqueId#') for feed '#arguments.feed.getTitle()#'.", e );
											// Delete any images
											// TODO: delete empty folders?
											for ( var imagePath IN imagePaths  ) {
												if ( fileExists( imagePath ) ) {
													fileDelete( imagePath );
												}
											}
										}

									}

								} else {

									// Log item too old
									if ( log.canInfo() ) {
										log.info("Feed item ('#uniqueId#') filtered out using age limits for feed '#arguments.feed.getTitle()#'.");
									}

								}

							} else {

								// Log item filtered out
								if ( log.canInfo() ) {
									log.info("Feed item ('#uniqueId#') filtered out using keywords for feed '#arguments.feed.getTitle()#'.");
								}

							}

						} else {

							// Log item exists
							if ( log.canInfo() ) {
								log.info("Feed item ('#uniqueId#') already exists for feed '#arguments.feed.getTitle()#'.");
							}

						}

					} else {

						// Log invalid item in feed
						if ( log.canWarn() ) {
							log.warn("Invalid feed item ('#uniqueId#') found for feed '#arguments.feed.getTitle()#'.");
						}

					}
				}

				// Log import
				if ( log.canInfo() ) {
					log.info("There were #itemCount# feed item(s) imported for feed '#arguments.feed.getTitle()#'.");
				}

			} else {

				// Log empty feed
				if ( log.canInfo() ) {
					log.info("There were no feed items found for feed '#arguments.feed.getTitle()#'.");
				}

			}

			// Create feed import and save
			var feedImport = new();
			feedImport.setFeed( arguments.feed );
			feedImport.setImporter( arguments.author );
			feedImport.setImportedCount( itemCount );
			feedImport.setMetaInfo( serializeJSON( remoteFeed ) );
			save( feedImport );

		} catch ( any e ) {

			if ( log.canError() ) {
				log.error( "Error importing feed '#arguments.feed.getTitle()#'.", e );
			}

		}

		return this;

	}

}