/**
 * ContentBox RSS Aggregator
 * Feed Service
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="ContentService" singleton {

	/**
	 * Constructor
	 * @return FeedService
	 */
	FeedService function init() {

		super.init( entityName="cbFeed" );

		return this;

	}

	/**
	 * Returns a struct of feeds and count based upon the passed parameters
	 * @searchTerm The search term to filter on
	 * @state The state to filter on, defaults to "any"
	 * @category The category to filter on, defaults to "all"
	 * @status The status to filter on, defaults to "any"
	 * @sortOrder The field to sort the results on, defaults to "title"
	 * @max The maximum number of feeds to return
	 * @offset The offset of the pagination
	 * @return struct - {feeds,count}
	 */
	struct function search(
		string searchTerm="",
		string state="any",
		string category="all",
		string status="any",
		string sortOrder="title ASC",
		numeric max=0,
		numeric offset=0 ) {

		// Vars
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

		// Get the results
		results.count = c.count( "contentID" );
		results.feeds = c.resultTransformer( c.DISTINCT_ROOT_ENTITY ).list(
			offset=arguments.offset,
			max=arguments.max,
			sortOrder=arguments.sortOrder,
			asQuery=false
		);

		return results;

	}

	/**
	 * Returns a struct of published feeds and count based upon the passed parameters
	 * @max The maximum number of feeds to return
	 * @offset The offset of the pagination
	 * @return struct - {feeds,count}
	 */
	struct function getPublishedFeeds( numeric max=0, numeric offset=0 ) {
		return search( status="published", max=arguments.max, offset=arguments.offset );
	}

	/**
	 * Gets the feeds that are enabled for import
	 * @return An array of feeds
	 */
	array function getFeedsForImport() {

		// Grab the active feeds
		var hql = "SELECT f FROM cbFeed f
			WHERE f.isActive = true
			AND ( f.startDate IS NULL OR f.startDate >= :now )
			AND ( f.stopDate IS NULL OR f.stopDate <= :now )";
		var params = { "now"=now() };

		return executeQuery( query=hql, params=params, asQuery=false );

	}

	/**
	 * Sets the import state on multiple feeds
	 * @contentID The contentID(s) to set the state on
	 * @status The state to set on the feed(s)
	 * @return FeedService
	 */
	FeedService function bulkActiveState( required any contentID, required string state ) {

		// Set active state
		var active = false;
		if ( arguments.state EQ "active" ) {
			active = true;
		}

		// Grab the feeds
		var feeds = getAll( id=arguments.contentID );

		// Set the state
		if ( arrayLen( feeds ) ) {
			for ( var x=1; x LTE arrayLen( feeds ); x++ ) {
				feeds[ x ].setisActive( active );
			}
			saveAll( feeds );
		}

		return this;

	}

}