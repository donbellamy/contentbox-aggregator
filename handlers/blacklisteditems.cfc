/**
 * ContentBox RSS Aggregator
 * Blacklisted items handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="contentHandler" {

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
	 * Displays the blacklisted item index
	 */
	function index( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "feed", "" );
		event.paramValue( "showAll", false );

		// Grab blacklised items and feeds
		prc.blacklistedItems = blacklistedItemService.getAll( sortOrder="title" );
		prc.feeds = feedService.getAll( sortOrder="title" );

		event.setView( "blacklisteditems/index" );

	}

}