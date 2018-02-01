component extends="contentbox.modules.contentbox-ui.handlers.content" {

	property name="settingService" inject="settingService@aggregator";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="helper" inject="helper@aggregator";
	property name="roleService" inject="roleService@cb";

	function preHandler( event, rc, prc, action, eventArguments ) {

		// Check if portal is enabled
		if ( !prc.agSettings.ag_portal_enable && event.getCurrentEvent() NEQ "contentbox-rss-aggregator:portal.import" ) {
			event.overrideEvent( "contentbox-rss-aggregator:portal.disabled" );
		}

		// Call super (check maint mode, etc.)
		super.preHandler( argumentCollection=arguments );

	}

	function index( event, rc, prc ) {

		// Incoming params
		event.paramValue( "page", 1 );

		// Page numeric check
		if( !isNumeric( rc.page ) ) { 
			rc.page = 1; 
		}

		// Paging
		prc.oPaging = getModel("paging@cb");
		prc.pagingBoundaries = prc.oPaging.getBoundaries( pagingMaxRows=10 ); // TODO: setting indexmaxrows
		prc.pagingLink = helper.linkPortal() & "?page=@page@";

		var results = feedItemService.getPublishedFeedItems(
			offset=prc.pagingBoundaries.startRow - 1,
			max=10 // TODO: Setting
		);

		prc.feedItems = results.feedItems;
		prc.feedItemsCount = results.count;

		announceInterception( 
			"aggregator_onPortalIndex", {
				feedItems = prc.feedItems,
				feedItemsCount = prc.feedItemsCount
			} 
		);

		event.setLayout( "../themes/default/layouts/aggregator/portal" )
			.setView( "../themes/default/views/aggregator/index" );

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
			announceInterception( "aggregator_onFeedItemView", { feedItem=feedItem, slug=rc.slug } );
			// Relocate to item url
			location( feedItem.getItemUrl() );

		} else {

			// Announce event
			announceInterception( "aggregator_onFeedItemNotFound", { feedItem=feedItem, slug=rc.slug } );
			// Not found
			notFound( argumentCollection=arguments );

		}

	}

	function feeds( event, rc, prc ) {
		event.setLayout( "../themes/default/layouts/aggregator/portal" )
			.setView( "../themes/default/views/aggregator/feeds" );
	}

	function feed( event, rc, prc ) {
		event.setLayout( "../themes/default/layouts/aggregator/portal" )
			.setView( "../themes/default/views/aggregator/feed" );
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
				announceInterception( "aggregator_preFeedImport", { feed=feed } );
				feedImportService.import( feed, author );
				announceInterception( "aggregator_postFeedImport", { feed=feed } );
			}

			// Relocate
			setNextEvent( prc.xehPortalHome );

		} else {

			// Not found
			notFound( argumentCollection=arguments );

		}

	}

	function disabled( event, rc, prc ) {
		notFound( argumentCollection=arguments );
	}

	private function notFound( event, rc, prc ) {

		prc.missingPage = event.getCurrentRoutedURL();
		prc.missingRoutedURL = event.getCurrentRoutedURL();

		event.setHTTPHeader( "404", "Page not found" );

		event.setLayout( name="#prc.cbTheme#/layouts/pages", module="contentbox" )
			.setView( view="#prc.cbTheme#/views/notfound", module="contentbox" );

	}

}