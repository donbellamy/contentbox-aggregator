component extends="coldbox.system.EventHandler" {
	//TODO: inherit from content ?
	//contentbox.modules.contentbox-ui.handlers.content

	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="settingService" inject="settingService@aggregator";
	property name="messagebox" inject="messagebox@cbmessagebox";

	function preHandler( event, rc, prc, action, eventArguments ) {

		if ( !prc.agSettings.ag_portal_enable && event.getCurrentEvent() NEQ "contentbox-aggregator:portal.import" ) {
			event.overrideEvent( "contentbox-aggregator:portal.disabled" );
		}

		// TODO: Site maintenance check

		// TODO: Portal Page Title

	}

	function disabled( event, rc, prc ) {

		prc.missingPage = event.getCurrentRoutedURL();
		prc.missingRoutedURL = event.getCurrentRoutedURL();

		// TODO: Page Title - 404 etc...

		event.setHTTPHeader( "404", "Page not found" );

		event.setLayout( name="#prc.cbTheme#/layouts/pages", module="contentbox" ).setView( view="#prc.cbTheme#/views/notfound", module="contentbox" );

	}

	function index( event, rc, prc ) {
		event.setView( "portal/index" );
	}

	function item( event, rc, prc ) {
		event.setView( "portal/item" );
	}

	function feeds( event, rc, prc ) {
		event.setView( "portal/feeds" );
	}

	function feed( event, rc, prc ) {
		event.setView( "portal/feed" );
	}

	function import( event, rc, prc ) {
		// TODO: Check for matching key
		// TODO: Run import
		event.setView( "portal/import" );
	}

}