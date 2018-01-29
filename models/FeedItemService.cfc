component extends="BaseService" singleton {

	FeedItemService function init() {

		super.init( entityName="cbFeedItem", useQueryCaching=true );

		return this;

	}

	struct function search( 
		string search="",
		string feed="all",
		string category="all",
		string status="any",
		numeric max=0,
		numeric offset=0,
		string sortOrder=""
	) {

		var results = {};
		var c = newCriteria();

		if 

		if ( len( trim( arguments.search ) ) || findNoCase( "modifiedDate", arguments.sortOrder ) ) {
			c.createAlias( "activeContent", "ac" );
		}

		if ( len( trim( arguments.search ) ) ) {
			c.or( c.restrictions.like( "title", "%#arguments.search#%" ), c.restrictions.like( "ac.content", "%#arguments.search#%" ) );
		}

		if ( arguments.feed NEQ "all" ) {
			c.eq( "parent.contentID", javaCast( "int", arguments.feed ) );
		}

		if ( arguments.category NEQ "all" ) {
			if( arguments.category EQ "none" ) {
				c.isEmpty( "categories" );
			} else{
				c.createAlias( "categories", "cats" ).isIn( "cats.categoryID", javaCast( "java.lang.Integer[]", [ arguments.category ] ) );
			}
		}

		if ( arguments.status NEQ "any" ) {
			if ( arguments.status EQ "published" ) {
				c.isTrue("isPublished")
					.isLT( "publishedDate", now() )
					.or( c.restrictions.isNull("expireDate"), c.restrictions.isGT( "expireDate", now() ) );
			} else if ( arguments.status EQ "expired" ) {
				c.isTrue("isPublished").isLT( "expireDate", now() );
			} else {
				c.isFalse("isPublished");
			}
		}

		if ( !len( arguments.sortOrder ) ) {
			arguments.sortOrder = "datePublished DESC";
		}

		results.count = c.count( "contentID" );
		results.feedItems = c.resultTransformer( c.DISTINCT_ROOT_ENTITY ).list( 
			offset=arguments.offset, 
			max=arguments.max, 
			sortOrder=arguments.sortOrder, 
			asQuery=false 
		);

		return results;

	}

	array function getFeedItems( required Feed feed ) {
		var results = search( feed=arguments.feed.getContentID() );
		return results.feedItems;
	}

	array function getLatestFeedItems( required Feed feed, numeric max=5 ) {
		var results = search( feed=arguments.feed.getContentID(), max=arguments.max );
		return results.feedItems;
	}

	struct function getPublishedFeedItems() {
		var results = search( status="published" );
		return results;
	}

}