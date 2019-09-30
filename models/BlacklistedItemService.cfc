/**
 * ContentBox Aggregator
 * BlacklistedItem Service
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="cborm.models.VirtualEntityService" singleton {

	/**
	 * Constructor
	 * @return BlacklistedItemService
	 */
	BlacklistedItemService function init() {

		super.init( entityName="cbBlacklistedItem", useQueryCaching=true );

		return this;

	}

	/**
	 * Returns a struct of blacklisted items and count based upon the passed parameters
	 * @searchTerm The search term to filter on
	 * @feed The feed to filter on, defaults to "all"
	 * @sortOrder The field to sort the results on, defaults to "title"
	 * @max The maximum number of blacklisted items to return
	 * @offset The offset of the pagination
	 * @return struct - {blacklistedItems,count}
	 */
	struct function getBlacklistedItems(
		string searchTerm="",
		string feed="",
		string sortOrder="createdDate DESC",
		boolean countOnly=false,
		numeric max=0,
		numeric offset=0 ) {

		// Set vars
		var results = {};
		var c = newCriteria();

		// Check search term
		if ( len( trim( arguments.searchTerm ) ) ) {
			c.or(
				c.restrictions.like( "title", "%#arguments.searchTerm#%" ),
				c.restrictions.like( "itemUrl", "%#arguments.searchTerm#%" )
			);
		}

		// Check feed
		if ( isNumeric( arguments.feed ) ) {
			c.eq( "feed.contentID", javaCast( "int", arguments.feed ) );
		} else if ( len( trim( arguments.feed ) ) ) {
			c.createCriteria( "feed" ).isEq( "slug", arguments.feed );
		}

		// Get the count
		results.count = c.count();

		// Check count only
		if ( arguments.countOnly ) {
			results.blacklistedItems = [];
		// Grab the blacklisted items
		} else {
			results.blacklistedItems = c.list(
				offset = arguments.offset,
				max = arguments.max,
				sortOrder = arguments.sortOrder,
				asQuery = false
			);
		}

		return results;

	}

	/**
	 * Determines if a blacklisted item already exists
	 * @uniqueId The itemUrl to check
	 * @return Whether or not the blacklisted item exists
	 */
	boolean function itemExists( required string itemUrl ) {
		return newCriteria().isEq( "itemUrl", arguments.itemUrl ).count();
	}

}