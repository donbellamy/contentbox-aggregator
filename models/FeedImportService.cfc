component extends="cborm.models.VirtualEntityService" singleton {

	property name="feedReader" inject="feedReader@cbfeeds";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="settingService" inject="settingService@aggregator";
	property name="moduleSettings" inject="coldbox:setting:modules";
	property name="htmlHelper" inject="HTMLHelper@coldbox";
	property name="jsoup" inject="jsoup@cbjsoup";
	property name="log" inject="logbox:logger:{this}";

	FeedImportService function init() {

		super.init( entityName="cbFeedImport", useQueryCaching=true );

		return this;

	}

	FeedImportService function import( required Feed feed, required Author author ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		try {

			// Grab the remote feed
			var remoteFeed = feedReader.retrieveFeed( arguments.feed.getFeedUrl() );

			// Save the feed image if enabled and not already populated
			// TODO: Check setting for this?
			if ( len( remoteFeed.image.url ) && !len( arguments.feed.getFeaturedImage() ) ) {

				var imageName = downloadImage( remoteFeed.image.url, getFeedFolderPath(), feed.getSlug() );

				if ( len( imageName ) ) {
					arguments.feed.setFeaturedImage( getFeedFolderPath() & imageName );
					arguments.feed.setFeaturedImageUrl( getFeedFolderUrl() & imageName );
					feedService.save( arguments.feed );
				}

			}

			// Check for items in feed
			if ( arrayLen( remoteFeed.items ) ) {

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

							// Check keyword filters
							var passesFilters = checkKeywordFilters( arguments.feed, item.title, item.body );

							// Import only if item passes the filters
							if ( passesFilters ) {

								// Check age limits
								var passesAgeLimits = checkAgeLimits( arguments.feed, item.datePublished );

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
										var now = now();
										if ( isDate( item.datePublished ) ) {
											feedItem.setDatePublished( item.datePublished );
										} else {
											feedItem.setDatePublished( now );
										}
										if ( isDate( item.dateUpdated ) ) {
											feedItem.setDateUpdated( item.dateUpdated );
										} else {
											feedItem.setDateUpdated( now );
										}
										feedItem.setMetaInfo( serializeJSON( item ) );
										feedItem.setParent( arguments.feed );

										// BaseContent properties
										feedItem.setTitle( item.title );
										feedItem.setSlug( htmlHelper.slugify( item.title ) );
										feedItem.setCreator( arguments.author );

										// TODO: Clean out non utf-8 stuff
										// https://stackoverflow.com/questions/13653712/java-sql-sqlexception-incorrect-string-value-xf0-x9f-x91-xbd-xf0-x9f
										// insert content
										feedItem.addNewContentVersion( 
											content=item.body,
											changelog="Item imported.",
											author=arguments.author
										);
										if ( feedItem.getDatePublished() GT now ) {
											feedItem.setPublishedDate( feedItem.getDatePublished() );
										} else {
											feedItem.setPublishedDate( now );
										}
										if ( arguments.feed.autoPublishItems() ) {
											feedItem.setIsPublished( true );
										} else {
											feedItem.setIsPublished( false );
										}

										// Save item
										feedItemService.save( feedItem );

										// Check for images
										// TODO: setting here
										var images = jsoup.parse( item.body ).getElementsByTag("img");
										if ( arrayLen( images ) ) {

											// Download and set the image name
											var imageName = downloadImage( images[1].attr("src"), getFeedItemFolderPath(), feedItem.getSlug() );

											// Set featured image, if download was successful
											if ( len( imageName ) ) {
												feedItem.setFeaturedImage( getFeedItemFolderPath() & imageName );
												feedItem.setFeaturedImageUrl( getFeedItemFolderUrl() & imageName );
												feedItemService.save( feedItem );
											}

										}

										// Increase item count
										itemCount++;

										// Log item saved
										if ( log.canInfo() ) {
											log.info("Feed item ('#uniqueId#') saved for feed '#arguments.feed.getTitle()#'.");
										}

									} catch( any e ) {

										// Log error
										if ( log.canError() ) {
											log.error( "Error saving feed item ('#uniqueId#') for feed '#arguments.feed.getTitle()#'.", e );
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
			feedImport.setNumberImported( itemCount );
			feedImport.setMetaInfo( serializeJSON( remoteFeed ) );
			save( feedImport );

		} catch ( any e ) {

			if ( log.canError() ) { 
				log.error( "Error importing feed '#arguments.feed.getTitle()#'.", e );
			}

		}

		return this;

	}

	private boolean function checkKeywordFilters( required Feed feed, required string title, required string body ) {

		// Set vars
		var passes = true;
		var text = arguments.title & " " & arguments.body;
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var matchAnyFilter = listToArray( len( trim( arguments.feed.getMatchAnyFilter() ) ) ? arguments.feed.getMatchAnyFilter() : trim( settings.ag_general_match_any_filter ) );
		var matchAllFilter = listToArray( len( trim( arguments.feed.getMatchAllFilter() ) ) ? arguments.feed.getMatchAllFilter() : trim( settings.ag_general_match_all_filter ) );
		var matchNoneFilter = listToArray( len( trim( arguments.feed.getMatchNoneFilter() ) ) ? arguments.feed.getMatchNoneFilter() : trim( settings.ag_general_match_none_filter ) );

		// Check match any
		if ( arrayLen( matchAnyFilter ) ) {
			passes = false;
			for ( var filter IN matchAnyFilter ) {
				if ( findNoCase( filter, text ) ) {
					passes = true;
					break;
				}
			}
		}

		// Check match all
		if ( arrayLen( matchAllFilter ) && passes ) {
			for ( var filter IN matchAllFilter ) {
				if ( !findNoCase( filter, text ) ) {
					passes = false;
					break;
				}
			}
		}

		// Check match none
		if ( arrayLen( matchNoneFilter ) && passes ) {
			for ( var filter IN matchNoneFilter ) {
				if ( findNoCase( filter, text ) ) {
					passes = false;
					break;
				}
			}
		}

		return passes;

	}

	private boolean function checkAgeLimits( required Feed feed, required any datePublished ) {
	
		var passes = true;
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var maxAge = val( arguments.feed.getMaxAge() ) ? val( arguments.feed.getMaxAge() ) : val( settings.ag_general_max_age );
		var maxAgeUnit = val( arguments.feed.getMaxAge() ) ? arguments.feed.getMaxAgeUnit() : settings.ag_general_max_age_unit;

		if ( maxAge && isDate( arguments.datePublished ) ) {
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
			if ( dateCompare( maxDate, arguments.datePublished ) EQ 1 ) {
				passes = false;
			}
		}

		return passes
	
	}

	private string function getFeedFolderPath() {
		return getFolderPath("feeds");
	}

	private string function getFeedItemFolderPath() {
		return getFolderPath("feeditems");
	}

	private string function getFolderPath( required string type ) {

		var folderPath = expandPath( settingService.getSetting( "cb_media_directoryRoot" ) ) & "\aggregator\#arguments.type#\";

		if ( !directoryExists( folderPath ) ) {
			directoryCreate( folderPath );
			if ( log.canInfo() ) {
				log.info("Created #arguments.type# image folder.");
			}
		}

		return folderPath;

	}

	private string function getFeedFolderUrl() {
		return getFolderUrl("feeds");
	}

	private string function getFeedItemFolderUrl() {
		return getFolderUrl("feeditems");
	}

	private string function getFolderUrl( required string type ) {

		var entryPoint = moduleSettings["contentbox-ui"].entryPoint;

		return folderUrl = ( len( entryPoint ) ? "/" & entryPoint : "" ) & "/__media/aggregator/#arguments.type#/";

	}

	private string function downloadImage( required string url, required string folderPath, required string slug ) {

		var mimeTypes = "image/gif,image/png,image/bmp,image/jpeg";
		var imageName = "";
		var ext = "";

		try {

			var result = new http( url=arguments.url, method="GET" ).send().getPrefix();
			if ( result.status_code == "200" && listFindNoCase( mimeTypes, result.mimeType ) ) {

				switch ( result.mimeType ) {
					case "image/gif":
						ext = "gif";
						break;
					case "image/png":
						ext = "png";
						break;
					case "image/bmp":
						ext = "bmp";
						break;
					default:
						ext = "jpg";
				}

				imageName = arguments.slug & "." & ext;

				fileWrite( arguments.folderPath & imageName, result.fileContent );

			}

		} catch( any e ) {

			if ( log.canError() ) {
				log.error( "Error retrieving and saving image '#arguments.url#' to path '#arguments.imagePath#'.", e );
			}

		}

		return imageName;

	}

	private string function getImageType( required string url ) {

	}

}