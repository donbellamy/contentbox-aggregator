component extends="coldbox.system.EventHandler" {

	property name="settingService" inject="settingService@cb";
	property name="cbMessagebox" inject="messagebox@cbmessagebox";
	property name="cbHelper" inject="CBHelper@cb";

	function preHandler( event, rc, prc, action, eventArguments ) {

		CBHelper.prepareUIRequest(); // TODO: Move to interceptor

		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( !prc.agSettings.ag_portal_enable ) {
			event.overrideEvent( "contentbox-aggregator:news.disabled" );
		}

		// TODO Portal Page Title

	}

	function disabled( event, rc, prc ) {

		prc.missingPage = event.getCurrentRoutedURL();
		prc.missingRoutedURL = event.getCurrentRoutedURL();

		// TODO: Page Title - 404 etc...

		event.setHTTPHeader( "404", "Page not found" );

		event.setLayout( name="#prc.cbTheme#/layouts/pages", module="contentbox" ).setView( view="#prc.cbTheme#/views/notfound", module="contentbox" );

	}

	function index( event, rc, prc ) {
		event.setView( "news/index" );
	}

	function item( event, rc, prc ) {
		event.setView( "news/item" );
	}

	function feeds( event, rc, prc ) {
		event.setView( "news/feeds" );
	}

	function feed( event, rc, prc ) {
		event.setView( "news/feed" );
	}

}