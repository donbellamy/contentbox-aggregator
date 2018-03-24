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
		string sortOrder="publishedDate DESC",
		numeric max=0,
		numeric offset=0,
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

		// Get the results
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
		string searchTerm="",
		string category="",
		string author="",
		string feed="",
		string sortOrder="publishedDate DESC",
		boolean countOnly=false,
		numeric max=0,
		numeric offset=0
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

		// Get the results
		results.count = c.count( "contentID" );
		if ( arguments.countOnly ) {
			results.feedItems = [];
		} else {
			results.feedItems = c.resultTransformer( c.DISTINCT_ROOT_ENTITY ).list(
				offset=arguments.offset,
				max=arguments.max,
				sortOrder=arguments.sortOrder,
				asQuery=false
			);
		}

		return results;

	}

	function getArchiveReport() {

		// Set hql
		var hql = "SELECT new map( count(*) AS count, YEAR(fi.publishedDate) AS year, MONTH(fi.publishedDate) AS month )
				FROM cbFeedItem fi
				WHERE fi.isPublished = true
					AND fi.publishedDate <= :now
					AND ( fi.expireDate IS NULL OR fi.expireDate >= :now )
					AND fi.parent.isPublished = true
					AND fi.parent.publishedDate <= :now
					AND ( fi.parent.expireDate IS NULL OR fi.parent.expireDate >= :now )
				GROUP BY YEAR(fi.publishedDate), MONTH(fi.publishedDate)
				ORDER BY 2 DESC, 3 DESC";

		// Set params
		var params = {};
		params[ "now" ] = now();

		// Return results
		return executeQuery( query=hql, params=params, asQuery=false );

	}

	function getPublishedFeedItemsByDate(
		numeric year=0,
		numeric month=0,
		numeric day=0,
		numeric max=0,
		numeric offset=0
	) {

		var results = {};

		// Set hql
		var hql = "FROM cbFeedItem fi
			WHERE fi.isPublished = true
				AND fi.publishedDate <= :now
				AND ( fi.expireDate IS NULL OR fi.expireDate >= :now )
				AND fi.parent.isPublished = true
				AND fi.parent.publishedDate <= :now
				AND ( fi.parent.expireDate IS NULL OR fi.parent.expireDate >= :now )";
		var params = {};
		params[ "now" ] = now();

		// Year
		if( val( arguments.year ) ){
			params["year"] = arguments.year;
			hql &= " AND YEAR(fi.publishedDate) = :year";
		}

		// Month
		if( val( arguments.month ) ){
			params["month"] = arguments.month;
			hql &= " AND MONTH(fi.publishedDate) = :month";
		}

		// Day
		if( val( arguments.day ) ){
			params["day"] = arguments.day;
			hql &= " AND DAY(fi.publishedDate ) = :day";
		}

		// Count
		results.count = executeQuery(
			query="select count( * ) #hql#",
			params=params,
			max=1,
			asQuery=false
		)[1];

		// Order by
		hql &= " ORDER BY fi.publishedDate DESC";

		// Get the results
		results.feedItems = executeQuery(
			query=hql,
			params=params,
			max=arguments.max,
			offset=arguments.offset,
			asQuery=false
		);

		return results;

	}

}