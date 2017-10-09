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
		string creator="all",
		string category="all",
		string status="any",
		string state="any",
		numeric max=0,
		numeric offset=0,
		string sortOrder="",
		boolean searchActiveContent=true,
		boolean showInSearch=false
	) {

		var results = {};
		var c = newCriteria();

		if ( len( trim( arguments.search ) ) || findNoCase( "modifiedDate", arguments.sortOrder ) ) {
			c.createAlias( "activeContent", "ac" );
		}

		if ( len( trim( arguments.search ) ) ) {
			if( arguments.searchActiveContent ) {
				c.or( c.restrictions.like( "title", "%#arguments.search#%" ), c.restrictions.like( "ac.content", "%#arguments.search#%" ) );
			} else {
				c.like( "title", "%#arguments.search#%" );
			}
		}

		if ( arguments.creator NEQ "all" ) {
			c.isEq( "creator.authorID", javaCast( "int", arguments.creator ) );
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

		if ( arguments.state NEQ "any" ) {
			c.eq( "isActive", javaCast( "boolean", arguments.state ) );
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

	// Working out the logic, placing here for now
	FeedService function import( required Feed feed, required Author author ) {

		try {

			//if ( isValid( arguments.feed.getUrl(), "url" ) ) {

				var feed = feedReader.retrieveFeed( arguments.feed.getUrl() );

				// TODO: Filters

				if ( arrayLen( feed.items ) ) {

					for ( var item IN feed.items ) {

						// TODO: Make sure it doesnt already exist

						// Validate title, url and body
						if ( len( trim( item.title ) ) &&
							len( trim( item.url ) ) &&
							len( trim( item.body ) ) ) {

							var feedItem = feedItemService.new();

							feedItem.setTitle( item.title );
							feedItem.setSlug( htmlHelper.slugify( item.title ) ); //Gets uniqued on save
							feedItem.setCreator( arguments.author );
							feedItem.addNewContentVersion( 
								content=item.body,
								changelog="Item imported.",
								author=arguments.author
							);

							feedItem.setUrl( item.url );

							if ( len( trim( item.id ) ) ) {
								feedItem.setId( item.id );
							} else {
								feedItem.setId( item.url );
							}

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

							feedItem.setMetaData( serializeJSON( item ) );

							feedItem.setParent( arguments.feed ); //TODO: we need to add to parent? feed.addChild() ?

							// Log here

						} else {
							// Log here
						}

						writedump( item );
						writedump( feedItem );
						abort;

					}

				}

			//}

		} catch ( any e ) {

			// TODO: log.();
			writedump(e);
			abort;

		}

		return this;

	}

}