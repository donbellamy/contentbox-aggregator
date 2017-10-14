component extends="BaseService" singleton {

	property name="feedReader" inject="feedReader@cbfeeds";
	property name="feedItemService" inject="feedItemService@aggregator";
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
			arguments.sortOrder = "title ASC";
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

	FeedService function import( required Feed feed, required Author author ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		try {

			var threadName = "retrieve_feed_#hash( arguments.feed.getContentID() & now() )#";
			thread action="run" name="#threadName#" url="#arguments.feed.getUrl()#" {
				variables.feed = feedReader.retrieveFeed( attributes.url );
			}

			thread action="join" name="#threadName#" timeout="6000";

			if ( arrayLen( variables.feed.items ) ) {

				for ( var item IN variables.feed.items ) {

					// Validate title, url and body
					if ( len( item.title ) && len( item.url ) && len( item.body ) ) {

						// Did item pass the filters? Default to true
						var passedFilters = true;

						// Combine filters
						var filterByAny = listToArray( listAppend( settings.ag_general_filter_by_any, arguments.feed.getFilterByAny() ) );
						var filterByAll = listToArray( listAppend( settings.ag_general_filter_by_all, arguments.feed.getFilterByAll() ) );
						var filterByNone = listToArray( listAppend( settings.ag_general_filter_by_none, arguments.feed.getFilterByNone() ) );

						// Do filter checks
						if ( arrayLen( filterByAny ) ) {
							passedFilters = false;
							for ( var filter IN filterByAny ) {
								if ( findNoCase( filter, item.title & " " & item.body ) ) {
									passedFilters = true;
									break;
								}
							}
						}
						if ( arrayLen( filterByAll ) && passedFilters ) {
							for ( var filter IN filterByAll ) {
								if ( !findNoCase( filter, item.title & " " & item.body ) ) {
									passedFilters = false;
									break;
								}
							}
						}
						if ( arrayLen( filterByNone ) && passedFilters ) {
							for ( var filter IN filterByNone ) {
								if ( findNoCase( filter, item.title & " " & item.body ) ) {
									passedFilters = false;
									break;
								}
							}
						}

						if ( passedFilters ) {

							var itemId = item.id;
							if ( !len( itemId ) ) {
								itemId = item.url;
							}

							var itemExists = feedItemService.newCriteria().isEq( "id", itemId ).count();

							if ( !itemExists ) {

								try {

									var feedItem = feedItemService.new();

									feedItem.setId( itemId );
									feedItem.setTitle( item.title );
									feedItem.setSlug( htmlHelper.slugify( item.title ) );
									feedItem.setCreator( arguments.author );

									// TODO: Rip out image
									// TODO: Clean html
									// TODO: Validate feedItem, so add contentversion as last step after validating the body

									feedItem.addNewContentVersion( 
										content=left( item.body, 8000 ), //TODO: Move this to validate()
										changelog="Item imported.",
										author=arguments.author
									);

									feedItem.setUrl( item.url );

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

									if ( feedItem.getDatePublished() GT now ) {
										feedItem.setpublishedDate( feedItem.getDatePublished() );
									} else {
										feedItem.setpublishedDate( now );
									}
									if ( arguments.feed.getAutoPublishItems() ) {
										feedItem.setisPublished( true );
									} else {
										feedItem.setisPublished( false );
									}

									feedItem.setMetaInfo( serializeJSON( item ) );
									feedItem.setParent( arguments.feed );

									feedItemService.save( feedItem );

								} catch( any e ) {
									log.error( "Error saving feed item #arguments.feed.getTitle()# - #item.title# - #itemId#", e );
								}
								
								// TODO: Log here - item saved

							} else {
								// TODO: Log here - item already exists
							}
						} else {
							// TODO: Log here - item filtered out
						}
					} else {
						// TODO: Log here - invalid item 
					}
				}
				// TODO: Log here - Feed imported (x items imported for feed)
				log.info("Feed #arguments.feed.getTitle()# (#arguments.feed.getContentID()#) imported.");
			} else {
				// TODO: Log here - Feed empty
			}

			// TODO: Remove outdated items - limit by age setting
			// TODO: Remove based on number limit - limit items by number setting

			// Set metadata, last import date and save
			structDelete( variables.feed, "items" );
			arguments.feed.setMetaInfo( serializeJSON( variables.feed ) );
			arguments.feed.setLastImportedDate( now() );
			save( arguments.feed );

		} catch ( any e ) {
			log.error( "Error importing feed #arguments.feed.getTitle()#.", e );
		}

		return this;

	}

}