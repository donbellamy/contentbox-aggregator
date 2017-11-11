component extends="BaseService" singleton {

	property name="feedReader" inject="feedReader@cbfeeds";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="htmlHelper" inject="HTMLHelper@coldbox";

	FeedService function init() {

		super.init( entityName="cbFeed", useQueryCaching=true );

		return this;

	}

	struct function search( 
		string search="",
		string state="any",
		string category="all",
		string status="any",
		numeric max=0,
		numeric offset=0,
		string sortOrder=""
	) {

		var results = {};
		var c = newCriteria();

		if ( len( trim( arguments.search ) ) || findNoCase( "modifiedDate", arguments.sortOrder ) ) {
			c.createAlias( "activeContent", "ac" );
		}

		if ( len( trim( arguments.search ) ) ) {
			c.or( c.restrictions.like( "title", "%#arguments.search#%" ), c.restrictions.like( "ac.content", "%#arguments.search#%" ) );
		}

		if ( arguments.state NEQ "any" ) {
			c.eq( "isActive", javaCast( "boolean", arguments.state ) );
		}

		if ( arguments.category NEQ "all" ) {
			if( arguments.category EQ "none" ) {
				c.isEmpty( "categories" );
			} else{
				c.createAlias( "categories", "cats" ).isIn( "cats.categoryID", javaCast( "java.lang.Integer[]", [ arguments.category ] ) );
			}
		}

		if ( arguments.status NEQ "any" ) {
			c.eq( "isPublished", javaCast( "boolean", arguments.status ) );
		}

		if ( !len( arguments.sortOrder ) ) {
			//arguments.sortOrder = "title ASC";
		}

		results.count = c.count( "contentID" );
		results.feeds = c.resultTransformer( c.DISTINCT_ROOT_ENTITY ).list( 
			offset=arguments.offset, 
			max=arguments.max, 
			sortOrder=arguments.sortOrder, 
			asQuery=false 
		);

		return results;

	}

	FeedService function bulkActiveState( required any contentID, required string status ) {

		var active = false;

		if( arguments.status EQ "active" ) {
			active = true;
		}

		var feeds = getAll( id=arguments.contentID );
		
		if ( arrayLen( feeds ) ) {
			for ( var x=1; x LTE arrayLen( feeds ); x++ ) {
				feeds[ x ].setisActive( active );
			}
			saveAll( feeds );
		}

		return this;

	}

	// TODO: Move to FeedImportService
	FeedService function import( required Feed feed, required Author author ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		try {

			var threadName = "retrieve_feed_#hash( arguments.feed.getContentID() & now() )#";
			thread action="run" name="#threadName#" url="#arguments.feed.getUrl()#" {
				variables.feed = feedReader.retrieveFeed( attributes.url );
			}

			thread action="join" name="#threadName#" timeout="6000";

			// Check for items in feed
			if ( arrayLen( variables.feed.items ) ) {

				// Set an item counter
				var itemCount = 0;

				for ( var item IN variables.feed.items ) {

					// Create a unique id to track this item
					var uniqueId = item.id;
					if ( !len( uniqueId ) ) {
						uniqueId = item.url;
					}

					// Validate title, url and body
					if ( len( item.title ) && len( item.url ) && len( item.body ) ) {

						// Did item pass the filters? Default to true
						var passedFilters = true;

						// Create filters
						var matchAnyFilter = listToArray( len( trim( arguments.feed.getMatchAnyFilter() ) ) ? arguments.feed.getMatchAnyFilter() : trim( settings.ag_general_match_any_filter ) );
						var matchAllFilter = listToArray( len( trim( arguments.feed.getMatchAllFilter() ) ) ? arguments.feed.getMatchAllFilter() : trim( settings.ag_general_match_all_filter ) );
						var matchNoneFilter = listToArray( len( trim( arguments.feed.getMatchNoneFilter() ) ) ? arguments.feed.getMatchNoneFilter() : trim( settings.ag_general_match_none_filter ) );

						// Do filter checks
						if ( arrayLen( matchAnyFilter ) ) {
							passedFilters = false;
							for ( var filter IN matchAnyFilter ) {
								if ( findNoCase( filter, item.title & " " & item.body ) ) {
									passedFilters = true;
									break;
								}
							}
						}
						if ( arrayLen( matchAllFilter ) && passedFilters ) {
							for ( var filter IN matchAllFilter ) {
								if ( !findNoCase( filter, item.title & " " & item.body ) ) {
									passedFilters = false;
									break;
								}
							}
						}
						if ( arrayLen( matchNoneFilter ) && passedFilters ) {
							for ( var filter IN matchNoneFilter ) {
								if ( findNoCase( filter, item.title & " " & item.body ) ) {
									passedFilters = false;
									break;
								}
							}
						}

						// Import only if item passes the filters
						if ( passedFilters ) {

							// Check if item already exists
							var itemExists = feedItemService.newCriteria().isEq( "uniqueId", uniqueId ).count();

							// Doesn't exist, so try and import
							if ( !itemExists ) {

								try {

									// Create feed item
									var feedItem = feedItemService.new();

									// FeedItem properties
									feedItem.setUrl( item.url );
									feedItem.setUniqueId( uniqueId );
									if ( len( trim( item.author ) ) ) {
										feedItem.setAuthor( item.author );
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
									feedItem.setSlug( htmlHelper.slugify( item.title ) ); //TODO: Check for unique slug
									feedItem.setCreator( arguments.author );
									// TODO: Rip out image
									// TODO: Clean html
									// TODO: Validate feedItem, so add contentversion as last step after validating the body
									feedItem.addNewContentVersion( 
										content=left( item.body, 8000 ), //TODO: Move this to validate()
										changelog="Item imported.",
										author=arguments.author
									);
									if ( feedItem.getDatePublished() GT now ) {
										feedItem.setpublishedDate( feedItem.getDatePublished() );
									} else {
										feedItem.setpublishedDate( now );
									}
									if ( arguments.feed.autoPublishItems() ) {
										feedItem.setisPublished( true );
									} else {
										feedItem.setisPublished( false );
									}

									// Save item
									feedItemService.save( feedItem );

									// Increase item count
									itemCount++;

								} catch( any e ) {

									// Log error
									log.error( "Error saving item ('#uniqueId#') for feed '#arguments.feed.getTitle()#'.", e );

								}
								
								// Log item saved
								log.info("Item ('#uniqueId#') saved for feed '#arguments.feed.getTitle()#'.");

							} else {

								// Log item exists
								log.info("Item ('#uniqueId#') already exists for feed '#arguments.feed.getTitle()#'.");

							}
						} else {

							// Log item filtered out
							log.info("Item ('#uniqueId#') filtered out for feed '#arguments.feed.getTitle()#'.");

						}

					} else {
						
						// Log invalid item in feed
						log.warn("Invalid item ('#uniqueId#') found for feed '#arguments.feed.getTitle()#'.");

					}
				}

				// Log import
				log.info("There were #itemCount# item(s) imported for feed '#arguments.feed.getTitle()#'.");

			} else {
				
				// Log empty feed
				log.info("There were no items found for feed '#arguments.feed.getTitle()#'.");

			}

			// TODO: Remove outdated items - limit by age setting

			// TODO: Remove based on number limit - limit items by number setting
			//if ( val( settings.ag_general_limit_by_number ) && 
			//	arguments.feed.getNumberOfChildren() GT val( settings.ag_general_limit_by_number ) ) {
			//}

			// Set metadata, last import date and save
			// TODO: Change this to use a log table? like cb_feed_log - table,  cbFeedLog - entity name
			// id, feedId, importDate, itemCount, metaInfo
			// lastImportDate property of feed comes by selecting top 1 calculated field
			//structDelete( variables.feed, "items" );
			//arguments.feed.setMetaInfo( serializeJSON( variables.feed ) );
			//arguments.feed.setLastImportedDate( now() );
			//save( arguments.feed );

			var feedImport = feedImportService.new();
			feedImport.setFeed( arguments.feed );
			feedImport.setMetaInfo( serializeJSON( variables.feed ) );
			feedImportService.save( feedImport );

		} catch ( any e ) {

			log.error( "Error importing feed '#arguments.feed.getTitle()#'.", e );

		}

		return this;

	}

}