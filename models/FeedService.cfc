/**
 * ContentBox Aggregator
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
	 * @publishedFeedItems Used only when the feed status is "published", will only return feeds with published feed items when true
	 * @sortOrder The field to sort the results on, defaults to "title"
	 * @searchActiveContent Whether or not to search active content
	 * @countOnly Whether or not to return the count only
	 * @max The maximum number of feeds to return
	 * @offset The offset of the pagination
	 * @return struct - {feeds,count}
	 */
	struct function getFeeds(
		string searchTerm="",
		string state="",
		string category="",
		string status="",
		string sortOrder="title ASC",
		boolean hasPublishedFeedItems=false,
		boolean searchActiveContent=true,
		boolean countOnly=false,
		numeric max=0,
		numeric offset=0 ) {

		// Set vars
		var results = {};
		var c = newCriteria();

		// Check search term or sort
		if ( len( trim( arguments.searchTerm ) ) || findNoCase( "modifiedDate", arguments.sortOrder ) ) {
			c.createAlias( "activeContent", "ac" );
		}

		// Check search term
		if ( len( trim( arguments.searchTerm ) ) ) {
			if ( arguments.searchActiveContent ) {
				c.or(
					c.restrictions.like( "title", "%#arguments.searchTerm#%" ),
					c.restrictions.like( "slug", "%#arguments.searchTerm#%" ),
					c.restrictions.like( "ac.content", "%#arguments.searchTerm#%" )
				);
			} else {
				c.or(
					c.restrictions.like( "title", "%#arguments.searchTerm#%" ),
					c.restrictions.like( "slug", "%#arguments.searchTerm#%" )
				);
			}
		}

		// Check state
		if ( len( trim( arguments.state ) ) ) {
			if ( arguments.state EQ "failing" ) {
				c.eq( "isFailing", "1" );
			} else {
				c.eq( "isActive", javaCast( "boolean", arguments.state ) );
			}
		}

		// Check category
		if ( isNumeric( arguments.category ) ) {
			c.createAlias( "categories", "cats" ).isIn( "cats.categoryID", javaCast( "java.lang.Integer[]", [ arguments.category ] ) );
		} else if ( len( trim( arguments.category ) ) ) {
			if ( arguments.category == "none" ) {
				c.isEmpty( "categories" );
			} else {
				c.createAlias( "categories", "cats" ).eq( "cats.slug", trim( arguments.category ) );
			}

		}

		// Check status
		if ( len( trim( arguments.status ) ) ) {
			if ( arguments.status EQ "published" ) {
				c.isTrue("isPublished")
					.isLT( "publishedDate", now() )
					.or( c.restrictions.isNull("expireDate"), c.restrictions.isGT( "expireDate", now() ) );
					// Check for published feed items if needed
					if ( arguments.hasPublishedFeedItems ) {
						c.gt( "numberOfPublishedFeedItems", "0" );
					}
			} else if ( arguments.status EQ "expired" ) {
				c.isTrue("isPublished").isLT( "expireDate", now() );
			} else {
				c.isFalse("isPublished");
			}
		}

		// Get the feed count
		results.count = c.count( "contentID" );

		// Check count only
		if ( arguments.countOnly ) {
			results.feeds = [];
		// Grab the feed items
		} else {
			results.feeds = c.resultTransformer( c.DISTINCT_ROOT_ENTITY ).list(
				offset = arguments.offset,
				max = arguments.max,
				sortOrder = arguments.sortOrder,
				asQuery = false
			);
		}

		return results;

	}

	/**
	 * Returns a struct of published feeds and count based upon the passed parameters
	 * @max The maximum number of feeds to return
	 * @offset The offset of the pagination
	 * @return struct - {feeds,count}
	 */
	struct function getPublishedFeeds( numeric max=0, numeric offset=0 ) {
		return getFeeds( argumentCollection=arguments, status="published", hasPublishedFeedItems=true );
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
		var params = { "now" = now() };

		return executeQuery(
			query = hql,
			params = params,
			asQuery = false
		);

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