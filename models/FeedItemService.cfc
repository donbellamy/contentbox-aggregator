component extends="ContentService" singleton {

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
		string sortOrder="datePublished DESC"
	) {

		var results = {};
		var c = newCriteria();

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
			} else {
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

		results.count = c.count( "contentID" );
		results.feedItems = c.resultTransformer( c.DISTINCT_ROOT_ENTITY ).list( 
			offset=arguments.offset, 
			max=arguments.max, 
			sortOrder=arguments.sortOrder, 
			asQuery=false 
		);

		return results;

	}

	struct function getPublishedFeedItems( 
		numeric max=0,
		numeric offset=0,
		string searchTerm="",
		string category="",
		string author="",
		string feed="",
		string sortOrder="datePublished DESC"
	) {

		var results = {};
		var c = newCriteria();

		// Only published feed items and parent feed must also be published
		c.isTrue( "isPublished" )
			.isLT( "publishedDate", now() )
			.or( c.restrictions.isNull( "expireDate" ), c.restrictions.isGT( "expireDate", now() ) );
		c.createAlias( "parent", "p" )
			.isTrue( "p.isPublished" )
			.isLT( "p.publishedDate", now() )
			.or( c.restrictions.isNull( "p.expireDate" ), c.restrictions.isGT( "p.expireDate", now() ) );


		// Search filter
		if ( len( trim( arguments.searchTerm ) ) ) {
			c.createAlias( "activeContent", "ac" );
			c.or( c.restrictions.like( "title", "%#arguments.searchTerm#%" ),
				  c.restrictions.like( "ac.content", "%#arguments.searchTerm#%" ) );
		}

		// Category filter
		if ( len( trim( arguments.category ) ) ) {
			c.createAlias( "categories", "cats" ).isIn( "cats.slug", listToArray( arguments.category ) );
		}

		// Author filter
		if ( len( trim( arguments.author ) ) ) {
			c.eq( "itemAuthor", "#arguments.author#" );
		}

		// Feed filter
		if ( isNumeric( arguments.feed ) ) {
			c.eq( "p.contentID", javaCast( "int", arguments.feed ) );
		} else if ( len( trim( arguments.feed ) ) ) {
			c.eq( "p.slug", "#arguments.feed#" );
		}

		// Set the results
		results.count = c.count( "contentID" );
		results.feedItems = c.resultTransformer( c.DISTINCT_ROOT_ENTITY ).list( 
			offset=arguments.offset, 
			max=arguments.max, 
			sortOrder=arguments.sortOrder, 
			asQuery=false 
		);

		return results;

	}

}