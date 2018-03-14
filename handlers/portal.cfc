component extends="coldbox.system.EventHandler" {

	property name="antiSamy" inject="antisamy@cbantisamy";
	property name="authorService" inject="authorService@cb";
	property name="roleService" inject="roleService@cb";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="helper" inject="helper@aggregator";
	property name="rssService" inject="rssService@aggregator";
	property name="settingService" inject="settingService@aggregator";

	function preHandler( event, rc, prc, action, eventArguments ) {

		// Maintenance mode?
		if ( prc.cbSettings.cb_site_maintenance ) {
			if( prc.oCurrentAuthor.isLoggedIn() && prc.oCurrentAuthor.checkPermission( "MAINTENANCE_MODE_VIEWER" )  ){
				addAsset( "#prc.cbRoot#/includes/js/maintenance.js" );
			} else {
				event.overrideEvent( "contentbox-ui:page.maintenance" );
				return;
			}
		}

		// Portal enabled?
		if ( !prc.agSettings.ag_portal_enable && event.getCurrentEvent() NEQ "contentbox-rss-aggregator:portal.import" ) {
			notFound( argumentCollection=arguments );
			return;
		}

		// If UI export is disabled, default to contentbox
		if ( !prc.cbSettings.cb_content_uiexport ) {
			rc.format = "html";
		}

	}

	function index( event, rc, prc ) {

		// Set params
		event.paramValue( "page", 1 )
			.paramValue( "q", "" )
			.paramValue( "category", "" );

		// Page check
		if( !isNumeric( rc.page ) ) rc.page = 1;

		// XSS Cleanup
		rc.q = antiSamy.clean( rc.q );
		rc.category = antiSamy.clean( rc.category );

		// Paging
		prc.oPaging = getModel("paging@cb");
		prc.pagingBoundaries = prc.oPaging.getBoundaries( pagingMaxRows=prc.agSettings.ag_display_paging_max_rows );
		prc.pagingLink = helper.linkPortal() & "?page=@page@";

		// Search paging
		if ( len( trim( rc.q ) ) ) {
			prc.pagingLink &= "&q=" & rc.q;
		}

		// Category paging
		if ( len( trim( rc.category ) ) ) {
			prc.pagingLink = helper.linkPortal() & "/category/#rc.category#/?page=@page@";
		}

		// Grab the results
		var results = feedItemService.getPublishedFeedItems(
			searchTerm=rc.q,
			category=rc.category,
			max=prc.agSettings.ag_display_paging_max_rows,
			offset=prc.pagingBoundaries.startRow - 1
		);
		prc.feedItems = results.feedItems;
		prc.itemCount = results.count;

		// Announce event
		announceInterception( "aggregator_onPortalIndex", { feedItems = prc.feedItems, feedItemscount = prc.itemCount } );

		// Set layout and view
		event.setLayout( "../themes/default/layouts/aggregator" )
			.setView( "../themes/default/views/feeditems" );

	}

	function archives( event, rc, prc ) {

		// Set params
		event.paramValue( "page", 1 )
			.paramValue( "year", 0 )
			.paramValue( "month", 0 )
			.paramValue( "day", 0 );

		// Page check
		if( !isNumeric( rc.page ) ) rc.page = 1;

		// Paging
		prc.oPaging = getModel("paging@cb");
		prc.pagingBoundaries = prc.oPaging.getBoundaries( pagingMaxRows=prc.agSettings.ag_display_paging_max_rows );
		prc.pagingLink = helper.linkArchive( rc.year, rc.month, rc.day ) & "?page=@page@";

		// Grab the results
		var results = feedItemService.getPublishedFeedItemsByDate(
			year=rc.year,
			month=rc.month,
			day=rc.day,
			max=prc.agSettings.ag_display_paging_max_rows,
			offset=prc.pagingBoundaries.startRow - 1
		);
		prc.feedItems = results.feedItems;
		prc.itemCount = results.count;

		// Announce event
		announceInterception( "aggregator_onArchives", { feedItems = prc.feedItems, feedItemscount = prc.itemCount } );

		// Set layout and view
		event.setLayout( "../themes/default/layouts/aggregator" )
			.setView( "../themes/default/views/feeditems" );

	}

	function rss( event, rc, prc ) {

		// RSS enabled?
		if ( !prc.agSettings.ag_rss_enable ) {
			notFound( argumentCollection=arguments );
			return;
		}

		// Set params
		event.paramValue( "category", "" )
			.paramValue( "slug", "" );

		// Set format
		rc.format = "rss";

		// Grab the rss feed
		var rssFeed = rssService.getRSS(
			category=rc.category,
			feed=rc.slug
		);

		// Render the xml
		event.renderData( type="plain", data=rssFeed, contentType="text/xml" );

	}

	function feeditem( event, rc, prc ) {

		// Set params
		event.paramValue( "slug", "" );

		// Check if author is viewing
		var showUnpublished = false;
		if( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ){
			var showUnpublished = true;
		}

		// Get the feed item
		var feedItem = feedItemService.findBySlug( rc.slug, showUnpublished );

		// If loaded, else not found
		if ( feedItem.isLoaded() ) {

			// Record hit
			feedItemService.updateHits( feedItem.getContentID() );

			// Announce event
			announceInterception( "aggregator_onFeedItemView", { feedItem=feedItem, slug=rc.slug } );

			// Relocate to item url
			location( url=feedItem.getItemUrl(), addToken="no" );

		} else {

			// Announce event
			announceInterception( "aggregator_onFeedItemNotFound", { feedItem=feedItem, slug=rc.slug } );

			// Not found
			notFound( argumentCollection=arguments );

		}

	}

	function feeds( event, rc, prc ) {

		// Set layout and view
		event.setLayout( "../themes/default/layouts/aggregator" )
			.setView( "../themes/default/views/feeds" );

	}

	function feed( event, rc, prc ) {

		// Set params
		event.paramValue( "slug", "" )
			.paramValue( "page", 1 )
			.paramValue( "author", "" );

		// Check if author is viewing
		var showUnpublished = false;
		if( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ){
			var showUnpublished = true;
		}

		// Get the feed
		prc.feed = feedService.findBySlug( rc.slug, showUnpublished );

		// If loaded, else not found
		if ( prc.feed.isLoaded() ) {

			// Page numeric check
			if( !isNumeric( rc.page ) ) rc.page = 1;

			// XSS Cleanup
			rc.author = antiSamy.clean( rc.author );

			// Paging
			prc.oPaging = getModel("paging@cb");
			prc.pagingBoundaries = prc.oPaging.getBoundaries( pagingMaxRows=prc.agSettings.ag_display_paging_max_rows );
			prc.pagingLink = helper.linkFeed( prc.feed ) & "?page=@page@";

			// Author filter
			if ( len( trim( rc.author ) ) ) {
				prc.pagingLink &= "&author=" & rc.author;
			}

			// Grab the feed items
			var results = feedItemService.getPublishedFeedItems(
				feed=prc.feed.getContentID(),
				author=rc.author,
				max=prc.agSettings.ag_display_paging_max_rows,
				offset=prc.pagingBoundaries.startRow - 1
			);
			prc.feedItems = results.feedItems;
			prc.itemCount = results.count;

			// Record hit
			feedService.updateHits( prc.feed.getContentID() );

			// Announce event
			announceInterception( "aggregator_onFeedView", { feed=prc.feed, slug=rc.slug } );

			event.setLayout( "../themes/default/layouts/aggregator" )
				.setView( "../themes/default/views/feed" );

		} else {

			// Announce event
			announceInterception( "aggregator_onFeedNotFound", { feed=prc.feed, slug=rc.slug } );

			// Not found
			notFound( argumentCollection=arguments );

		}

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

	function onError( event, rc, prc, faultAction, exception, eventArguments ) {

		// Excceptions
		prc.faultAction = arguments.faultAction;
		prc.exception   = arguments.exception;

		// Announce event
		announceInterception(
			"cbui_onError", {
				faultAction = arguments.faultAction,
				exception = arguments.exception,
				eventArguments = arguments.eventArguments
			}
		);

		// Set layout and view
		event.setLayout( name="#prc.cbTheme#/layouts/pages", module="contentbox" )
			.setView( view="#prc.cbTheme#/views/error", module="contentbox" );

	}

	/************************************** PRIVATE *********************************************/

	private function notFound( event, rc, prc ) {

		// Grab page and url
		prc.missingPage = event.getCurrentRoutedURL();
		prc.missingRoutedURL = event.getCurrentRoutedURL();

		// Set header
		event.setHTTPHeader( "404", "Page not found" );

		// Set layout and view
		event.setLayout( name="#prc.cbTheme#/layouts/pages", module="contentbox" )
			.setView( view="#prc.cbTheme#/views/notfound", module="contentbox" );

	}

}