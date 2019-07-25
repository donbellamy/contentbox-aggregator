/**
 * ContentBox RSS Aggregator
 * FeedImport Service
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="cborm.models.VirtualEntityService" singleton {

	// Dependencies
	property name="feedReader" inject="feedReader@cbfeeds";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="settingService" inject="settingService@cb";
	property name="moduleSettings" inject="coldbox:setting:modules";
	property name="htmlHelper" inject="HTMLHelper@coldbox";
	property name="interceptorService" inject="coldbox:interceptorService";
	property name="systemUtil" inject="systemUtil@cb";
	property name="jsoup" inject="jsoup@cbjsoup";
	property name="log" inject="logbox:logger:{this}";

	/**
	 * Constructor
	 * @return FeedImportService
	 */
	FeedImportService function init() {

		super.init( entityName="cbFeedImport", useQueryCaching=true );

		return this;

	}

	/**
	 * The main feed import routine
	 * @feed The feed to import
	 * @author The author to use when importing
	 * @return FeedImportService
	 */
	FeedImportService function import( required Feed feed, required Author author ) {

		// Grab the settings
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		// Announce interception
		interceptorService.processState( "aggregator_preFeedImport", { feed=arguments.feed } );

		try {

			// Set an item counter
			var itemCount = 0;

			// Grab the remote feed
			var remoteFeed = feedReader.retrieveFeed( arguments.feed.getFeedUrl() );

			// Check for items in feed
			/*
			if ( arrayLen( remoteFeed.items ) ) {

				// Grab item settings
				var itemStatus = len( arguments.feed.getItemStatus() ) ? arguments.feed.getItemStatus() : settings.ag_importing_item_status;
				var itemPubDate = len( arguments.feed.getItemPubDate() ) ? arguments.feed.getItemPubDate() : settings.ag_importing_item_pub_date;

				// Grab image settings
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

						// Doesn't exist
						if ( !itemExists ) {

							// Check keywords
							var passesKeywordFilters = checkKeywordFilters( item, arguments.feed );

							// Passes keywords
							if ( passesKeywordFilters ) {

								// Set published and updated dates
								if ( !isDate( item.datePublished ) || itemPubDate == "imported" ) {
									item.datePublished = now();
								}
								if ( !isDate( item.dateUpdated ) || itemPubDate == "imported" ) {
									item.dateUpdated = item.datePublished;
								}

								// Check age
								var passesAgeFilter = checkAgeFilter( item, arguments.feed );

								// Passes age
								if ( passesAgeFilter ) {

									try {

										// Create feed item
										var feedItem = feedItemService.new();

										// FeedItem properties
										feedItem.setUniqueId( uniqueId );
										feedItem.setItemUrl( item.url );
										if ( len( trim( item.author ) ) ) {
											feedItem.setItemAuthor( item.author );
										}
										feedItem.setMetaInfo( item );

										// BaseContent properties
										feedItem.setParent( arguments.feed );
										feedItem.setTitle( item.title );
										feedItem.setSlug( htmlHelper.slugify( item.title ) );
										feedItem.setCreator( arguments.author );
										feedItem.setPublishedDate( item.datePublished );
										feedItem.setModifiedDate( item.dateUpdated );
										if ( itemStatus == "published" ) {
											feedItem.setIsPublished( true );
										} else {
											feedItem.setIsPublished( false );
										}

										// Set whitelist
										var whitelist = jsoup.getWhiteList();
										// Add rel, target to a tag
										whitelist.addAttributes( "a", javacast( "string[]", ["rel","target"] ) );
										// Add iframe tag and attributes (youtube, etc.)
										whitelist.addTags( javacast( "string[]", ["iframe"] ) );
										whitelist.addAttributes( "iframe", javacast( "string[]", ["src","width","height","frameborder","allow","allowfullscreen"] ) );

										// Clean
										var feedBody = jsoup.clean( item.body, whitelist );

										// Are we importing images?
										if ( importImages || importFeaturedImages ) {

											// TODO: Check attachments first and set featured image from that
											// TODO: If an attachment is valid, only import body images if importall is flagged

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
															var directoryPath = expandPath( settingService.getSetting( "cb_media_directoryRoot" ) ) & "\aggregator\feeditems\" & dateformat( item.datePublished, "yyyy\mm\" );
															if ( !directoryExists( directoryPath ) ) {
																directoryCreate( directoryPath );
																if ( log.canInfo() ) {
																	log.info("Created aggregator feeditems image folder - #directoryPath#.");
																}
															}

															// Set image name and path (using _ to differentiate identical slugs)
															var imageName = feedItem.getSlug() & "_" & idx & "." & ext;
															var imagePath = directoryPath & imageName;

															// Save the image
															fileWrite( imagePath, result.fileContent );

															// Grab the image object
															var img = imageRead( imagePath );

															// Save the image if it is valid
															if ( img.getWidth() GTE val( settings.ag_importing_image_minimum_width ) &&
																img.getHeight() GTE val( settings.ag_importing_image_minimum_height ) ) {

																// Set the image url
																var entryPoint = moduleSettings["contentbox-ui"].entryPoint;
																var folderUrl = ( len( entryPoint ) ? "/" & entryPoint : "" ) & "/__media/aggregator/feeditems/" & dateformat( item.datePublished, "yyyy/mm/" );
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

																// Delete directory if empty
																deleteDirectoryIfEmpty( directoryPath );

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

									} catch ( any e ) {

										// Log the error
										if ( log.canError() ) {
											log.error( "Error saving feed item ('#uniqueId#') for feed '#arguments.feed.getTitle()#'.", e );
											// Delete any images
											if ( importImages || importFeaturedImages ) {
												for ( var imagePath IN imagePaths  ) {
													if ( fileExists( imagePath ) ) {
														fileDelete( imagePath );
													}
												}
												// Delete directory if empty and defined
												if ( isDefined("directoryPath") ) {
													deleteDirectoryIfEmpty( directoryPath );
												}
											}
										}

									}

								} else {

									// Log item filtered out by age
									if ( log.canInfo() ) {
										log.info("Feed item ('#uniqueId#') filtered out using age filtering for feed '#arguments.feed.getTitle()#'");
									}

								}

							} else {

								// Log item filtered out by keywords
								if ( log.canInfo() ) {
									log.info("Feed item ('#uniqueId#') filtered out using keyword filtering for feed '#arguments.feed.getTitle()#'");
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
			*/

			// Create feed import and save
			var feedImport = new();
			feedImport.setFeed( arguments.feed );
			feedImport.setImporter( arguments.author );
			feedImport.setImportedCount( itemCount );
			feedImport.setMetaInfo( remoteFeed );
			save( feedImport );

		} catch ( any e ) {

			if ( log.canError() ) {
				log.error( "Error importing feed '#arguments.feed.getTitle()#'.", e );
			}

			// Save the error as a feed import
			try {

				var metaInfo = { "Error" = e };
				if ( isDefined( "feedItem" ) ) {
					metaInfo["FeedItem"] = feedItem.getMemento();
				}

				var feedImport = new();
				feedImport.setFeed( arguments.feed );
				feedImport.setImporter( arguments.author );
				feedImport.setImportedCount( 0 );
				feedImport.setImportFailed( true );
				feedImport.setMetaInfo( metaInfo );
				save( feedImport );

			} catch ( any e ) {
				if ( log.canError() ) {
					log.error( "Error saving failed feed import for '#arguments.feed.getTitle()#'.", e );
				}
			}

		}

		// Announce interception
		interceptorService.processState( "aggregator_postFeedImport", { feed=arguments.feed } );

		return this;

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Checks to see if an item passes the keyword filters
	 * @item The item to check
	 * @feed The feed we are importing
	 * @return Whether or not the item passes the keyword filters
	 */
	private boolean function checkKeywordFilters( required struct item, required Feed feed ) {

		// Set vars
		var passes = true;
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var matchAnyFilter = listToArray( len( trim( arguments.feed.getMatchAnyFilter() ) ) ? arguments.feed.getMatchAnyFilter() : trim( settings.ag_importing_match_any_filter ) );
		var matchAllFilter = listToArray( len( trim( arguments.feed.getMatchAllFilter() ) ) ? arguments.feed.getMatchAllFilter() : trim( settings.ag_importing_match_all_filter ) );
		var matchNoneFilter = listToArray( len( trim( arguments.feed.getMatchNoneFilter() ) ) ? arguments.feed.getMatchNoneFilter() : trim( settings.ag_importing_match_none_filter ) );

		// Filter out if any filters exist
		if ( arrayLen( matchAnyFilter ) || arrayLen( matchAllFilter ) || arrayLen( matchNoneFilter ) ) {

			// Check keyword filters
			var itemText = arguments.item.title & " " & arguments.item.body;

			// Check match any
			if ( arrayLen( matchAnyFilter ) ) {
				passes = false;
				for ( var filter IN matchAnyFilter ) {
					if ( findNoCase( filter, itemText ) ) {
						passes = true;
						break;
					}
				}
			}

			// Check match all - if not already failed
			if ( arrayLen( matchAllFilter ) && passes ) {
				for ( var filter IN matchAllFilter ) {
					if ( !findNoCase( filter, itemText ) ) {
						passes = false;
						break;
					}
				}
			}

			// Check match none - if not already failed
			if ( arrayLen( matchNoneFilter ) && passes ) {
				for ( var filter IN matchNoneFilter ) {
					if ( findNoCase( filter, itemText ) ) {
						passes = false;
						break;
					}
				}
			}

		}

		return passes;

	}

	/**
	 * Checks to see if an item passes the age filter
	 * @item The item to check
	 * @feed The feed we are importing
	 * @return Whether or not the item passes the age filter
	 */
	private boolean function checkAgeFilter( required struct item, required Feed feed ) {

		// Set vars
		var passes = true;
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var maxAge = val( arguments.feed.getMaxAge() ) ? val( arguments.feed.getMaxAge() ) : val( settings.ag_importing_max_age );
		var maxAgeUnit = val( arguments.feed.getMaxAge() ) ? arguments.feed.getMaxAgeUnit() : settings.ag_importing_max_age_unit;

		// Check date
		if ( maxAge ) {
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
			// Compare dates, fails if too old
			if ( arguments.item.datePublished LT maxDate ) {
				passes = false;
			}
		}

		return passes;

	}

	/**
	 * Deletes the directory path only if it is empty
	 * @directoryPath The directory path to delete
	 * @return FeedImportService
	 */
	private FeedImportService function deleteDirectoryIfEmpty( required string directoryPath ) {
		var files = directoryList( arguments.directoryPath );
		if ( !arrayLen( files ) ) {
			try { directoryDelete( arguments.directoryPath ); } catch( any e ) {}
		}
		return this;
	}

}