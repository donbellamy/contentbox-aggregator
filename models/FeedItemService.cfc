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
	 * @year The year to filter on
	 * @month The month to filter on
	 * @day The day to filter on
	 * @sortOrder The field to sort the results on, defaults to "publishedDate"
	 * @searchActiveContent Whether or not to search active content
	 * @countOnly Whether or not to return the count only
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
		numeric year=0,
		numeric month=0,
		numeric day=0,
		string sortOrder="publishedDate DESC",
		boolean searchActiveContent=true,
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
			// TODO: if entries are included, do not include the related feeditem to an entry if one exists (dont want dupes)
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
			if ( arguments.searchActiveContent ) {
				selectHql &= " JOIN cb.activeContent AS ac";
				whereHql &= " AND ( cb.title LIKE :searchTerm OR cb.slug LIKE :searchTerm OR ac.content LIKE :searchTerm )";
			} else {
				whereHql &= " AND ( cb.title LIKE :searchTerm OR cb.slug LIKE :searchTerm )";
			}
			params["searchTerm"] = "%" & trim( arguments.searchTerm ) & "%";
		}

		// Check category
		if ( isNumeric( arguments.category ) ) {
			selectHql &= " JOIN cb.categories AS cats";
			whereHql &= " AND cats.categoryID = :category";
			params["category"] = javaCast( "int", arguments.category );
		} else if ( len( trim( arguments.category ) ) ) {
			if ( arguments.category == "none" ) {
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
			whereHql &= " AND p.slug = :feed";
			params["feed"] = arguments.feed;
		}

		// Check year
		if ( val( arguments.year ) ) {
			whereHql &= " AND YEAR( cb.publishedDate ) = :year";
			params["year"] = arguments.year;
		}

		// Check month
		if ( val( arguments.month ) ) {
			whereHql &= " AND MONTH( cb.publishedDate ) = :month";
			params["month"] = arguments.month;
		}

		// Check day
		if ( val( arguments.day ) ) {
			whereHql &= " AND DAY( cb.publishedDate ) = :day";
			params["day"] = arguments.day;
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

		// Check count only
		if ( arguments.countOnly ) {
			results.feedItems = [];
		// Grab the feed items
		} else {
			results.feedItems = executeQuery(
				query="SELECT cb #hql#",
				params=params,
				max=arguments.max,
				offset=arguments.offset,
				asQuery=false
			);
		}

		return results;

	}

	/**
	 * Returns a struct of published feeditems and count based upon the passed parameters
	 * @includeEntries Whether or not to include entries in the feed item results
	 * @searchTerm The search term to filter on
	 * @category The category to filter on, defaults to "all"
	 * @feed The feed to filter on, defaults to "all"
	 * @year The year to filter on
	 * @month The month to filter on
	 * @day The day to filter on
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
		numeric year=0,
		numeric month=0,
		numeric day=0,
		string sortOrder="publishedDate DESC",
		boolean countOnly=false,
		numeric max=0,
		numeric offset=0 ) {

		return getFeedItems( argumentCollection=arguments, status="published" );

	}

	/**
	 * Gets the archive report by date and number of feed items
	 * @includeEntries Whether or not to include entries in the feed item results
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

		// Set params
		var params = {};
		params[ "now" ] = now();

		// Return results
		return executeQuery( query=hql, params=params, asQuery=false );

	}

	/**
	 * Returns a struct of published feeditems and count based upon the passed date
	 * @includeEntries Whether or not to include entries in the feed item results
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
		numeric offset=0  ) {

		return getPublishedFeedItems( argumentCollection=arguments );

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