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
	property name="authorService" inject="authorService@cb";
	property name="roleService" inject="roleService@cb";
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
	 * @feed The feed to import, if one is not passed then all feeds that are active will be will be imported
	 * @author The author to use when importing
	 * @return FeedImportService
	 */
	FeedImportService function import( any feed, any author ) {

		// Grab the settings
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		// Check for feed
		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.getFeedsForImport();
		}

		// Check for author
		if ( !structKeyExists( arguments, "author" ) ) {
			if ( len( settings.ag_importing_item_author ) ) {
				arguments.author = authorService.get( settings.ag_importing_item_author );
			} else {
				var adminRole = roleService.findWhere( { role="Administrator" } );
				arguments.author = authorService.findWhere( { role=adminRole } );
			}
		}

		// Validate author
		if ( !isNull( arguments.author ) ) {

			// Loop over feeds
			for ( var feed IN feeds ) {

				// Announce interception
				interceptorService.processState( "aggregator_preFeedImport", { feed=feed } );

				try {

					// Grab the remote feed
					var remoteFeed = feedReader.retrieveFeed( feed.getFeedUrl() );

					// Check for items in feed
					if ( arrayLen( remoteFeed.items ) ) {

						// Grab item settings
						var itemStatus = len( feed.getItemStatus() ) ? feed.getItemStatus() : settings.ag_importing_item_status;
						var ItemPubDate = len( feed.getItemPubDate() ) ? feed.getItemPubDate() : settings.ag_importing_item_pub_date;

						// Grab image settings
						var importImages = len( feed.getImportImages() ) ? feed.getImportImages() : settings.ag_importing_image_import_enable;
						var importFeaturedImages = len( feed.getImportFeaturedImages() ) ? feed.getImportFeaturedImages() : settings.ag_importing_featured_image_enable;

						// Set an item counter
						var itemCount = 0;

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
										feedItem.setParent( feed );
										feedItem.setTitle( item.title );
										feedItem.setSlug( htmlHelper.slugify( item.title ) );
										feedItem.setCreator( arguments.author );
										var datePublished = now();
										if ( isDate( item.datePublished ) && ItemPubDate == "original" ) {
											datePublished = item.datePublished;
										}
										feedItem.setPublishedDate( datePublished );
										var dateUpdated = now();
										if ( isDate( item.dateUpdated ) && ItemPubDate == "original" ) {
											dateUpdated = item.dateUpdated;
										}
										feedItem.setModifiedDate( dateUpdated );
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
															var directoryPath = expandPath( settingService.getSetting( "cb_media_directoryRoot" ) ) & "\aggregator\feeditems\" & dateformat( datePublished, "yyyy\mm\" );
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
											log.info("Feed item ('#uniqueId#') saved for feed '#feed.getTitle()#'.");
										}

									} catch ( any e ) {

										// Log the error
										if ( log.canError() ) {
											log.error( "Error saving feed item ('#uniqueId#') for feed '#feed.getTitle()#'.", e );
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

									// Log item exists
									if ( log.canInfo() ) {
										log.info("Feed item ('#uniqueId#') already exists for feed '#feed.getTitle()#'.");
									}

								}

							} else {

								// Log invalid item in feed
								if ( log.canWarn() ) {
									log.warn("Invalid feed item ('#uniqueId#') found for feed '#feed.getTitle()#'.");
								}

							}
						}

						// Log import
						if ( log.canInfo() ) {
							log.info("There were #itemCount# feed item(s) imported for feed '#feed.getTitle()#'.");
						}

					} else {

						// Log empty feed
						if ( log.canInfo() ) {
							log.info("There were no feed items found for feed '#feed.getTitle()#'.");
						}

					}

					// Create feed import and save
					var feedImport = new();
					feedImport.setFeed( feed );
					feedImport.setImporter( arguments.author );
					feedImport.setImportedCount( itemCount );
					feedImport.setMetaInfo( remoteFeed );
					save( feedImport );

				} catch ( any e ) {

					if ( log.canError() ) {
						log.error( "Error importing feed '#feed.getTitle()#'.", e );
					}

					// Save the error as a feed import
					try {
						var feedImport = new();
						feedImport.setFeed( feed );
						feedImport.setImporter( arguments.author );
						feedImport.setImportedCount( 0 );
						feedImport.setImportFailed( true );
						feedImport.setMetaInfo( e );
						save( feedImport );
					} catch ( any e ) {
						log.error( "Error saving failed feed import for '#feed.getTitle()#'.", e );
					}

				}

				// Announce interception
				interceptorService.processState( "aggregator_postFeedImport", { feed=feed } );

			}

		} else {

			if ( log.canInfo() ) {
				log.info("Invalid author passed to import routine.");
			}

		}

		return this;

	}

	/**
	 * Deletes the directory path only if it is empty
	 * @directoryPath The directory path to delete
	 * @return FeedImportService
	 */
	private function deleteDirectoryIfEmpty( required string directoryPath ) {
		var files = directoryList( arguments.directoryPath );
		if ( !arrayLen( files ) ) {
			try { directoryDelete( arguments.directoryPath ); } catch( any e ) {}
		}
	}

}