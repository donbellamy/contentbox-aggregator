/**
 * The feed service
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="ContentService" singleton {

	/**
	 * Constructor
	 */
	FeedService function init() {

		super.init( entityName="cbFeed" );

		return this;

	}

	struct function search(
		string searchTerm="",
		string state="any",
		string category="all",
		string status="any",
		string sortOrder="title ASC",
		numeric max=0,
		numeric offset=0
	) {

		var results = {};
		var c = newCriteria();

		if ( len( trim( arguments.searchTerm ) ) || findNoCase( "modifiedDate", arguments.sortOrder ) ) {
			c.createAlias( "activeContent", "ac" );
		}

		if ( len( trim( arguments.searchTerm ) ) ) {
			c.or( c.restrictions.like( "title", "%#arguments.searchTerm#%" ), c.restrictions.like( "ac.content", "%#arguments.searchTerm#%" ) );
		}

		if ( arguments.state NEQ "any" ) {
			if ( arguments.state EQ "failing" ) {
				c.createAlias( "feedImports", "fi" ).isTrue( "fi.importFailed" );
			} else {
				c.eq( "isActive", javaCast( "boolean", arguments.state ) );
			}
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
		results.feeds = c.resultTransformer( c.DISTINCT_ROOT_ENTITY ).list(
			offset=arguments.offset,
			max=arguments.max,
			sortOrder=arguments.sortOrder,
			asQuery=false
		);

		return results;

	}

	struct function getPublishedFeeds( numeric max=0, numeric offset=0 ) {
		return search( status="published", max=arguments.max, offset=arguments.offset );
	}

	array function getFeedsForImport() {

		var hql = "SELECT f FROM cbFeed f
			WHERE f.isActive = true
			AND ( f.startDate IS NULL OR f.startDate >= :now )
			AND ( f.stopDate IS NULL OR f.stopDate <= :now )";
		var params = { "now"=now() };

		return executeQuery( query=hql, params=params, asQuery=false );

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

}