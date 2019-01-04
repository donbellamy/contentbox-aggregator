/**
 * ContentBox RSS Aggregator
 * FeedItem Service
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="ContentService" singleton {

	/**
	 * Constructor
	 * @return FeedItemService
	 */
	FeedItemService function init() {

		super.init( entityName="cbFeedItem" );

		return this;

	}

	/**
	 * Returns a struct of feeditems and count based upon the passed parameters
	 * @includeEntries Whether or not to include entries in the feed item results
	 * @status The status to filter on, defaults to "all"
	 * @searchTerm The search term to filter on
	 * @category The category to filter on, defaults to "all"
	 * @feed The feed to filter on, defaults to "all"
	 * @sortOrder The field to sort the results on, defaults to "publishedDate"
	 * @max The maximum number of feed items to return
	 * @offset The offset of the pagination
	 * @return struct - {feedItems,count}
	 */
	struct function getFeedItems(
		boolean includeEntries=false,
		string status="",
		string searchTerm="",
		string category="",
		string author="",
		string feed="",
		string sortOrder="publishedDate DESC",
		boolean countOnly=false,
		numeric max=0,
		numeric offset=0 ) {

		// Set vars
		var results = {};
		var params = {};

		// Check for author
		if ( len( trim( arguments.author ) ) ) {
			arguments.includeEntries = false;
		}

		// Select hql
		var selectHql = ( arguments.includeEntries ? "FROM cbContent AS cb" : "FROM cbFeedItem AS cb" );

		// Where hql
		var whereHql = " WHERE cb.contentType = 'FeedItem'";
		if ( arguments.includeEntries ) {
			whereHql = " WHERE ( cb.contentType = 'FeedItem' OR cb.contentType = 'Entry' )";
		}

		// Join parent (feed) table if published or feed is passed
		if ( arguments.status == "published" || ( len( trim( arguments.feed ) ) ) ) {
			selectHql &= " LEFT JOIN cb.parent AS p";
		}

		// Check status
		if ( len( trim( arguments.status ) ) ) {
			if ( arguments.status == "published" ) {
				whereHql &= " AND cb.isPublished = true AND cb.publishedDate <= :now AND ( cb.expireDate IS NULL OR cb.expireDate >= :now )";
				whereHql &= " AND ( ( cb.contentType = 'FeedItem' AND p.isPublished = true AND p.publishedDate <= :now AND ( p.expireDate IS NULL OR p.expireDate >= :now ) )";
				if ( arguments.includeEntries ) {
					whereHql &= " OR ( cb.contentType = 'Entry' )";
				}
				whereHql &= " )";
				params["now"] = now();
			} else if ( arguments.status == "expired" ) {
				whereHql &= " AND cb.isPublished = true AND cb.expireDate <= :now";
				params["now"] = now();
			} else {
				whereHql &= " AND cb.isPublished = false";
			}
		}

		// Check search term
		if ( len( trim( arguments.searchTerm ) ) ) {
			selectHql &= " JOIN cb.activeContent AS ac";
			whereHql &= " AND ( cb.title LIKE :searchTerm OR ac.content LIKE :searchTerm )";
			params["searchTerm"] = trim( arguments.searchTerm );
		}

		// Check category
		if ( isNumeric( arguments.category ) ) {
			selectHql &= " JOIN cb.categories AS cats";
			whereHql &= " AND cats.categoryID = :category";
			params["category"] = javaCast( "int", arguments.category );
		} else if ( len( trim( arguments.category ) ) ) {
			if( arguments.category == "none" ) {
				selectHql &= " LEFT JOIN cb.categories AS cats";
				whereHql &= " AND cats.categoryID = NULL";
			} else {
				selectHql &= " JOIN cb.categories AS cats";
				whereHql &= " AND cats.slug = :category";
				params["category"] = trim( arguments.category );
			}
		}

		// Check author
		if ( len( trim( arguments.author ) ) ) {
			whereHql &= " AND cb.itemAuthor = :author";
			params["author"] = trim( arguments.author );
		}

		// Check feed
		if ( isNumeric( arguments.feed ) ) {
			whereHql &= " AND p.contentID = :feed";
			params["feed"] = javaCast( "int", arguments.feed );
		} else if ( len( trim( arguments.feed ) ) ) {
			//c.eq( "p.slug", "#arguments.feed#" );
			whereHql &= " AND p.slug = :feed";
			params["feed"] = arguments.feed;
		}

		// Sort order
		var orderHql = " ORDER BY cb.#arguments.sortOrder#";

		// Set hql
		var hql = selectHql & whereHql & orderHql

		// Get the feed item count
		results.count = executeQuery(
			query="SELECT COUNT(*) #hql#",
			params=params,
			max=1,
			asQuery=false
		)[1];

		// Grab the feed items
		results.feedItems = executeQuery(
			query="SELECT cb #hql#",
			params=params,
			max=arguments.max,
			offset=arguments.offset,
			asQuery=false
		);

		return results;

	}

	/**
	 * Returns a struct of published feeditems and count based upon the passed parameters
	 * @includeEntries Whether or not to include entries in the feed item results
	 * @searchTerm The search term to filter on
	 * @category The category to filter on, defaults to "all"
	 * @feed The feed to filter on, defaults to "all"
	 * @sortOrder The field to sort the results on, defaults to "publishedDate"
	 * @max The maximum number of feed items to return
	 * @offset The offset of the pagination
	 * @return struct - {feedItems,count}
	 */
	struct function getPublishedFeedItems(
		boolean includeEntries=false,
		string searchTerm="",
		string category="",
		string author="",
		string feed="",
		string sortOrder="publishedDate DESC",
		boolean countOnly=false,
		numeric max=0,
		numeric offset=0 ) {

		return getFeedItems( argumentCollection=arguments, status="published" );

	}

	/**
	 * Gets the archive report by date and number of feed items
	 * @return An array of month and feed item counts per month
	 */
	array function getArchiveReport( boolean includeEntries=false ) {

		// Set hql
		var hql = "SELECT new map( count(*) AS count, YEAR(cb.publishedDate) AS year, MONTH(cb.publishedDate) AS month )";
		if ( arguments.includeEntries ) {
			hql &= " FROM cbContent AS cb LEFT JOIN cb.parent AS p WHERE ( cb.contentType = 'FeedItem' OR cb.contentType = 'Entry' )";
		} else {
			hql &= " FROM cbFeedItem AS cb LEFT JOIN cb.parent AS p WHERE cb.contentType = 'FeedItem'";
		}
		hql &= " AND cb.isPublished = true AND cb.publishedDate <= :now AND ( cb.expireDate IS NULL OR cb.expireDate >= :now )";
		hql &= " AND ( ( cb.contentType = 'FeedItem' AND p.isPublished = true AND p.publishedDate <= :now AND ( p.expireDate IS NULL OR p.expireDate >= :now ) )";
		if ( arguments.includeEntries ) {
			hql &= " OR ( cb.contentType = 'Entry' )";
		}
		hql &= " )";
		hql &= "GROUP BY YEAR(cb.publishedDate), MONTH(cb.publishedDate) ORDER BY 2 DESC, 3 DESC";

		/*
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
		*/

		// Set params
		var params = {};
		params[ "now" ] = now();

		// Return results
		return executeQuery( query=hql, params=params, asQuery=false );

	}

	/**
	 * Returns a struct of published feeditems and count based upon the passed date
	 * @year The year to filter on
	 * @month The month to filter on
	 * @day The day to filter on
	 * @max The maximum number of feed items to return
	 * @offset The offset of the pagination
	 * @return struct - {feedItems,count}
	 */
	struct function getPublishedFeedItemsByDate(
		boolean includeEntries=false,
		numeric year=0,
		numeric month=0,
		numeric day=0,
		numeric max=0,
		numeric offset=0 ) {

		// TODO: Include entries

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

		// Get the count
		results.count = executeQuery(
			query="select count(*) #hql#",
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
	 * Sets the publish status on multiple feed items
	 * @contentID The contentID(s) to set the status on
	 * @status The status to set on the feed items
	 * @return FeedItemService
	 */
	FeedItemService function bulkPublishStatus( required string contentID, required string status ) {

		var publish = false;
		if ( arguments.status == "publish" ) {
			publish = true;
		}

		var contentObjects = getAll( id=arguments.contentID );

		for ( var x=1; x LTE arrayLen( contentObjects ); x++ ) {
			contentObjects[x].setisPublished( publish );
		}

		saveAll( contentObjects );

		return this;

	}

}