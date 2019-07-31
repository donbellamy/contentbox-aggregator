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
	 * Displays blacklisted item index
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
	 * Displays blacklisted item table
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

	/**
	 * Displays blacklisted item editor
	 */
	function editor( event, rc, prc ) {

		event.paramValue( "blacklistedItemID", 0 );

		// Grab the blacklisted item
		if ( !structKeyExists( prc, "blacklistedItem" ) ) {
			prc.blacklistedItem = blacklistedItemService.get( rc.blacklistedItemID );
		}

		// Grab the feeds
		prc.feeds = feedService.getAll( sortOrder="title" );

		event.setView( "blacklisteditems/editor" );

	}

	/**
	 * Saves blacklisted item
	 */
	function save( event, rc, prc ) {

		if ( event.isAjax() ) {
			var data = { "blacklistedItemID" = prc.blacklistedItem.getBlacklistedItemID() };
			event.renderData( type="json", data=data );
		} else {
			cbMessagebox.info( "Blacklisted Item Saved!" );
			setNextEvent( prc.xehBlacklistedItems );
		}

	}

	/**
	 * Removes blacklisted item
	 */
	function remove( event, rc, prc ) {

		event.paramValue( "blacklistedItemID", "" );

	}

}