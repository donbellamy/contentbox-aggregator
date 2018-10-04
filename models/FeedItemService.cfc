/**
 * The feed item service
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="ContentService" singleton {

	/**
	 * Constructor
	 */
	FeedItemService function init() {

		super.init( entityName="cbFeedItem" );

		return this;

	}

	/**
	 * Returns a struct of feeditems and count based upon the passed parameters
	 * @searchTerm The search term to filter on
	 * @feed The feed to filter on, defaults to "all"
	 * @category The category to filter on, defaults to "all"
	 * @status The status to filter on, defaults to "any"
	 * @sortOrder The field to sort the results on, defaults to "publishedDate"
	 * @max The maximum number of feed items to return
	 * @offset The offset of the pagination
	 *
	 * @return struct - {feedItems,count}
	 */
	struct function search(
		string searchTerm="",
		string feed="all",
		string category="all",
		string status="any",
		string sortOrder="publishedDate DESC",
		numeric max=0,
		numeric offset=0,
	) {

		// Vars
		var results = {};
		var c = newCriteria();

		if ( len( trim( arguments.searchTerm ) ) || findNoCase( "modifiedDate", arguments.sortOrder ) ) {
			c.createAlias( "activeContent", "ac" );
		}

		if ( len( trim( arguments.searchTerm ) ) ) {
			c.or( c.restrictions.like( "title", "%#arguments.searchTerm#%" ), c.restrictions.like( "ac.content", "%#arguments.searchTerm#%" ) );
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

	/**
	 * Returns a struct of published feeditems and count based upon the passed parameters
	 * @searchTerm The search term to filter on
	 * @category The category to filter on
	 * @author The author to filter on
	 * @feed The feed to filter on
	 * @sortOrder The field to sort the results on, defaults to "publishedDate"
	 * @countOnly When true will only return count of feed items found
	 * @max The maximum number of feed items to return
	 * @offset The offset of the pagination
	 *
	 * @return struct - {feedItems,count}
	 */
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

		// Vars
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

	/**
	 *
	 */
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

	/**
	 *
	 */
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

	/**
	 *
	 */
	FeedItemService function bulkPublishStatus( required string contentID, required string status ) {

		var publish = false;
		if ( arguments.status EQ "publish" ) {
			publish = true;
		}

		var contentObjects = getAll( id=arguments.contentID );

		for ( var x=1; x LTE arrayLen( contentObjects ); x++ ) {
			// NOTE - Need to preserve published date for feed items when bulk updating
			//contentObjects[x].setpublishedDate( now() );
			contentObjects[x].setisPublished( publish );
		}

		saveAll( contentObjects );

		return this;
	}

}