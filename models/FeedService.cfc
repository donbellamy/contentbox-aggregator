component extends="BaseService" singleton {

	property name="feedReader" inject="feedReader@cbfeeds";
	property name="itemService" inject="itemService@aggregator";

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

		for ( var x=1; x LTE arrayLen( feeds ); x++ ){
			feeds[ x ].setisActive( active );
		}

		saveAll( feeds );

		return this;

	}

	// Working out the logic, placing here for now
	FeedService function fetchItems( required Feed feed ) {

		try {

			//if ( isValid( arguments.feed.getUrl(), "url" ) ) {

				writedump( feedReader.retrieveFeed( arguments.feed.getUrl() ) );
				abort;

			//}

		} catch ( any e ) {

			writedump(e);

		}

		return this;

	}

}