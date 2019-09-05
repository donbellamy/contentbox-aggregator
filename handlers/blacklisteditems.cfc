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

		super.preHandler( argumentCollection=arguments );

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
		prc.feeds = feedService.getAll( sortOrder = "title" );

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
			searchTerm = rc.search,
			feed = rc.feed,
			max = ( rc.showAll ? 0 : prc.cbSettings.cb_paging_maxrows ),
			offset = ( rc.showAll ? 0 : prc.paging.startRow - 1 )
		);
		prc.blacklistedItems = results.blacklistedItems;
		prc.itemCount = results.count;

		event.setView(
			view = "blacklisteditems/table",
			layout = "ajax"
		);

	}

	/**
	 * Saves blacklisted item
	 */
	function save( event, rc, prc ) {

		event.paramValue( "blacklistedItemID", 0 )
			.paramValue( "title", "" )
			.paramValue( "itemUrl", "" )
			.paramValue( "feedId", "" );

		// Grab the feed
		var blacklistedItem = blacklistedItemService.get( rc.blacklistedItemID );

		// Populate item
		populateModel( blacklistedItem );
		blacklistedItem.setFeed( feedService.get( rc.feedId ) );
		if ( !val(blacklistedItem.getBlacklistedItemID()) ) blacklistedItem.setCreator( prc.oCurrentAuthor );

		announceInterception(
			"aggregator_preBlacklistedItemSave",
			{ blacklistedItem = blacklistedItem }
		);

		// Save the item
		blacklistedItemService.save( blacklistedItem );

		announceInterception(
			"aggregator_postBlacklistedItemSave",
			{ blacklistedItem = blacklistedItem }
		);

		if ( event.isAjax() ) {
			var data = { "blacklistedItemID" = prc.blacklistedItem.getBlacklistedItemID() };
			event.renderData(
				type = "json",
				data = data
			);
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

		// Remove selected feed
		if ( len( rc.blacklistedItemID ) ) {
			rc.blacklistedItemID = listToArray( rc.blacklistedItemID );
			var messages = [];
			for ( var blacklistedItemID in rc.blacklistedItemID ) {
				var blacklistedItem = blacklistedItemService.get( blacklistedItemID, false );
				if ( !isNull( blacklistedItem ) ) {
					var title = blacklistedItem.getTitle();
					announceInterception(
						"aggregator_preBlacklistedItemRemove",
						{ blacklistedItem = blacklistedItem }
					);
					blacklistedItemService.deleteByID( blacklistedItem.getBlacklistedItemID() );
					announceInterception(
						"aggregator_postBlacklistedItemRemove",
						{ blacklistedItemID = blacklistedItemID }
					);
					arrayAppend( messages, "Blacklisted item '#title#' deleted." );
				} else {
					arrayAppend( messages, "Invalid blacklisted item selected: #blacklistedItemID#." );
				}
			}
			cbMessagebox.info( messageArray=messages );
		} else {
			cbMessagebox.warn( "No blacklisted items selected!" );
		}

		setNextEvent(
			event = prc.xehBlacklistedItems,
			persistStruct = getFilters( rc )
		);

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Creates the blacklisted item filter struct
	 * @return The the blacklisted item filter struct
	 */
	private struct function getFilters( rc ) {

		var filters = {};

		// Check for filters and add to struct
		if ( structKeyExists( rc, "page" ) ) filters.page = rc.page;
		if ( structKeyExists( rc, "search" ) ) filters.search = rc.search;
		if ( structKeyExists( rc, "feed" ) ) filters.feed = rc.feed;

		return filters;

	}

}