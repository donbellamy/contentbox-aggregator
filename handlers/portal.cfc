component extends="contentbox.modules.contentbox-ui.handlers.content" {

	property name="settingService" inject="settingService@aggregator";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="roleService" inject="roleService@cb";

	function preHandler( event, rc, prc, action, eventArguments ) {

		super.preHandler( argumentCollection=arguments );

		if ( !prc.agSettings.ag_portal_enable && event.getCurrentEvent() NEQ "contentbox-rss-aggregator:portal.import" ) {
			event.overrideEvent( "contentbox-rss-aggregator:portal.disabled" );
		}

	}

	function disabled( event, rc, prc ) {

		// Not found
		notFound( argumentCollection=arguments );

	}

	function index( event, rc, prc ) {

		prc.oPaging = getModel( "Paging@cb" );		

		event.setView( "portal/index" );
	}

	function feeditem( event, rc, prc ) {
		
		event.paramValue( "slug", "" );

		// Get the feed item
		var feedItem = feedItemService.findBySlug( rc.slug );

		// If loaded, else not found
		if ( feedItem.isLoaded() ) {

			// Record hit
			feedItemService.updateHits( feedItem.getContentID() );
			// Announce event
			announceInterception( "agportal_onFeedItemView", { feedItem=feedItem, slug=rc.slug } );
			// Relocate to item url
			location( feedItem.getItemUrl() );

		} else {

			// Announce event
			announceInterception( "agportal_onFeedItemNotFound", { feedItem=feedItem, slug=rc.slug } );
			// Not found
			notFound( argumentCollection=arguments );

		}

	}

	function feeds( event, rc, prc ) {
		event.setView( "portal/feeds" );
	}

	function feed( event, rc, prc ) {
		event.setView( "portal/feed" );
	}

	function import( event, rc, prc ) {

		// Secret key in settings
		event.paramValue( name="key", value="" );

		// To import we must have an author, so check for one first
		if ( len( prc.agSettings.ag_general_default_creator ) ) {
			var author = authorService.get( prc.agSettings.ag_general_default_creator );
		} else if ( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ) {
			var author = prc.oCurrentAuthor;
		} else {
			var adminRole = roleService.findWhere( { role="Administrator" } );
			var author = authorService.findWhere( { role=adminRole } );
		}

		// Only import if the keys match and an author is defined
		if ( rc.key EQ prc.agSettings.ag_general_secret_key  && !isNull( author ) ) {

			// Thread this instead? - in a future version yes
			setting requestTimeout="999999";

			var feeds = feedService.getFeedsForImport();

			for ( var feed IN feeds ) {
				announceInterception( "agadmin_preFeedImport", { feed=feed } );
				feedImportService.import( feed, author );
				announceInterception( "agadmin_postFeedImport", { feed=feed } );
			}

			event.setView( "portal/import" );

		} else {

			// Not found
			notFound( argumentCollection=arguments );

		}

	}

	private function notFound( event, rc, prc ) {

		prc.missingPage = event.getCurrentRoutedURL();
		prc.missingRoutedURL = event.getCurrentRoutedURL();

		event.setHTTPHeader( "404", "Page not found" );

		// Should be layout in settings?
		event.setLayout( name="#prc.cbTheme#/layouts/pages", module="contentbox" )
			.setView( view="#prc.cbTheme#/views/notfound", module="contentbox" );

	}

}