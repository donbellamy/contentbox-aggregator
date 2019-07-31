/**
 * ContentBox RSS Aggregator
 * Blacklisted items handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="baseHandler" {

	// Dependencies
	property name="blacklistedItemService" inject="blacklistedItemService@aggregator";
	property name="feedService" inject="feedService@aggregator";

	/**
	 * Pre handler
	 */
	function preHandler( event, rc, prc, action, eventArguments ) {

		// Check permissions
		if ( !prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR" ) ) {
			cbMessagebox.error( "You do not have permission to access the aggregator blacklisted items." );
			setNextEvent( prc.cbAdminEntryPoint );
			return;
		}

	}

	/**
	 * Displays the blacklisted item index
	 */
	function index( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "feed", "" );
		event.paramValue( "showAll", false );

		// Grab the feeds
		prc.feeds = feedService.getAll( sortOrder="title" );

		event.setView( "blacklisteditems/index" );

	}

	/**
	 * Displays the feed item table
	 */
	function table( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "feed", "" );
		event.paramValue( "showAll", false );

		// Paging
		prc.oPaging = getModel("paging@aggregator");
		prc.paging = prc.oPaging.getBoundaries();
		prc.pagingLink = "javascript:contentPaginate(@page@)";

		// Grab results
		var results = blacklistedItemService.getBlacklistedItems(
			searchTerm=rc.search,
			feed=rc.feed,
			max=( rc.showAll ? 0 : prc.cbSettings.cb_paging_maxrows ),
			offset=( rc.showAll ? 0 : prc.paging.startRow - 1 )
		);
		prc.blacklistedItems = results.blacklistedItems;
		prc.itemCount = results.count;

		event.setView( view="blacklisteditems/table", layout="ajax" );

	}

}