component extends="coldbox.system.EventHandler" {
	//TODO: inherit from content ?
	//contentbox.modules.contentbox-ui.handlers.content

	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="settingService" inject="settingService@aggregator";
	property name="authorService" inject="authorService@cb";
	property name="roleService" inject="roleService@cb";
	property name="messagebox" inject="messagebox@cbmessagebox";

	function preHandler( event, rc, prc, action, eventArguments ) {

		if ( !prc.agSettings.ag_portal_enable && event.getCurrentEvent() NEQ "contentbox-aggregator:portal.import" ) {
			event.overrideEvent( "contentbox-aggregator:portal.disabled" );
		}

		// TODO: Site maintenance check?  or inherit from content handler?

	}

	function disabled( event, rc, prc ) {

		prc.missingPage = event.getCurrentRoutedURL();
		prc.missingRoutedURL = event.getCurrentRoutedURL();

		event.setHTTPHeader( "404", "Page not found" );

		event.setLayout( name="#prc.cbTheme#/layouts/pages", module="contentbox" )
			.setView( view="#prc.cbTheme#/views/notfound", module="contentbox" );

	}

	function index( event, rc, prc ) {

		prc.oPaging = getModel( "Paging@cb" );		

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

		event.paramValue( name="key", value="" );

		if ( len( prc.agSettings.ag_general_default_creator ) ) {
			var author = authorService.get( prc.agSettings.ag_general_default_creator );
		} else if ( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ) {
			var author = prc.oCurrentAuthor;
		} else {
			var adminRole = roleService.findWhere( { role="Administrator" } );
			var author = authorService.findWhere( { role=adminRole } );
		}

		if ( rc.key EQ prc.agSettings.ag_general_secret_key  && !isNull( author ) ) {

			// Thread this?
			setting requestTimeout="999999";

			var feeds = feedService.findAllWhere( { isActive=true } );

			for ( var feed IN feeds ) {
				announceInterception( "agadmin_preFeedImport", { feed=feed } );
				feedImportService.import( feed, author );
				announceInterception( "agadmin_postFeedImport", { feed=feed } );
			}

			event.setView( "portal/import" );

		} else {

			prc.missingPage = event.getCurrentRoutedURL();
			prc.missingRoutedURL = event.getCurrentRoutedURL();
	
			event.setHTTPHeader( "404", "Page not found" );
	
			event.setLayout( name="#prc.cbTheme#/layouts/pages", module="contentbox" )
				.setView( view="#prc.cbTheme#/views/notfound", module="contentbox" );

		}

	}

}