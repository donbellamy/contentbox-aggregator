component extends="coldbox.system.EventHandler" {

	property name="cbHelper" inject="CBHelper@cb";
	property name="antiSamy" inject="antisamy@cbantisamy";
	property name="authorService" inject="authorService@cb";
	property name="categoryService" inject="categoryService@cb";
	property name="roleService" inject="roleService@cb";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="helper" inject="helper@aggregator";
	property name="rssService" inject="rssService@aggregator";
	property name="settingService" inject="settingService@aggregator";
	property name="themeService" inject="themeService@cb";
	property name="dataMarshaller" inject="dataMarshaller@coldbox";
	property name="contentService" inject="contentService@cb";

	// Around handler exeptions
	this.aroundhandler_except = "rss,import,onError,notFound";

	function preHandler( event, rc, prc, action, eventArguments ) {

		// Maintenance mode?
		if ( prc.cbSettings.cb_site_maintenance ) {
			if ( prc.oCurrentAuthor.isLoggedIn() && prc.oCurrentAuthor.checkPermission( "MAINTENANCE_MODE_VIEWER" )  ){
				addAsset( "#prc.cbRoot#/includes/js/maintenance.js" );
			} else {
				event.overrideEvent( "contentbox-ui:page.maintenance" );
				return;
			}
		}

		// If UI export is disabled, default to html
		if ( !prc.cbSettings.cb_content_uiexport ) {
			rc.format = "html";
		}

		// Default description and keywords
		if ( len( trim( prc.agSettings.ag_portal_description ) ) ) {
			cbHelper.setMetaDescription( prc.agSettings.ag_portal_description );
		}
		if ( len( trim( prc.agSettings.ag_portal_keywords ) ) ) {
			cbHelper.setMetaKeywords( prc.agSettings.ag_portal_keywords );
		}

	}

	function aroundHandler( event, targetAction, eventArguments, rc, prc ) {

		// Set params
		event.paramValue( "format", "html" );

		// Set vars
		var cacheEnabled = (
			prc.agSettings.ag_portal_cache_enable AND
			!event.valueExists("cbCache")
		);

		// Check the cache
		if ( cacheEnabled ) {

			// Set cache and cacheKey
			var cache = cacheBox.getCache( prc.agSettings.ag_portal_cache_name );
			var cacheKey = "cb-content-aggregator-#cgi.http_host#-#left( event.getCurrentRoutedURL(), 500 )#";
			cacheKey &= hash( ".#getFWLocale()#.#rc.format#.#event.isSSL()#" & prc.cbox_incomingContextHash );

			// Get cache
			prc.contentCacheData = cache.get( cacheKey );

			// Output cache if defined
			if ( !isNull( prc.contentCacheData ) ) {

				// Set cache headers
				if ( prc.cbSettings.cb_content_cachingHeader ) {
					event.setHTTPHeader( statusCode="203", statustext="ContentBoxCache Non-Authoritative Information" )
						.setHTTPHeader( name="x-contentbox-cached-content", value="true" );
				}

				// Update hits
				if ( val( prc.contentCacheData.contentID ) ) {
					contentService.updateHits( prc.contentCacheData.contentID );
				}

				// Render the cached data
				event.renderData(
					data = prc.contentCacheData.content,
					contentType = prc.contentCacheData.contentType,
					isBinary = prc.contentCacheData.isBinary
				);

				// Return
				return;

			}

		}

		// Prepare data
		var data = { contentID = "", contentType = "text/html", isBinary = false };

		// Set arguments
		var args = { event = arguments.event, rc = arguments.rc, prc = arguments.prc };
		structAppend( args, arguments.eventArguments );

		// Execute the wrapped action
		var data.content = arguments.targetAction( argumentCollection=args );

		// Generate content if needed
		if ( isNull( data.content ) ) {
			// Render the layout
			data.content = renderLayout(
				// TODO: Do this
				//layout = "#prc.cbTheme#/layouts/#themeService.getThemePrintLayout( format=rc.format, layout=listLast( event.getCurrentLayout(), '/' ) )#",
				//module = "contentbox",
				//viewModule = "contentbox"
				layout = "../themes/default/layouts/aggregator",
				module = "contentbox-rss-aggregator",
				viewmodule = "contentbox-rss-aggregator"
			);
		}

		// Switch on format
		switch ( rc.format ) {
			case "xml": case "json": {
				var results = [];
				var xmlRootName = "";
				if ( structKeyExists( prc, "feed" ) ) {
					xmlRootName = "feed";
					results = prc.feed.getResponseMemento();
					var feedItems = [];
					for ( var feedItem in prc.feedItems ) {
						feedItems.append( feedItem.getResponseMemento() );
					}
					results["feedItems"] = feedItems;
				} else if ( structKeyExists( prc, "feedItems" ) ) {
					xmlRootName = "feeditems"
					for ( var feedItem IN prc.feedItems ) {
						results.append( feedItem.getResponseMemento() );
					}
				}
				if ( structKeyExists( prc, "feeds" ) ) {
					xmlRootName = "feeds";
					for ( var feed IN prc.feeds ) {
						results.append( feed.getResponseMemento() );
					}
				}
				if ( structKeyExists( prc, "feedItem" ) ) {
					xmlRootName = "feeditem";
					results = prc.feedItem.getResponseMemento();
				}
				if ( rc.format == "json" ) {
					data.content = dataMarshaller.marshallData( data=results, type="json" );
					data.contentType = "application/json";
					data.isBinary = false;
				} else {
					data.content = dataMarshaller.marshallData( data=results, type="xml", xmlRootName=xmlRootName );
					data.contentType = "text/xml";
					data.isBinary = false;
				}
				break;
			}
			case "pdf": {
				data.content = dataMarshaller.marshallData( data=data.content, type="pdf" );
				data.contentType = "application/pdf";
				data.isBinary = true;
				break;
			}
			case "doc": {
				data.contentType = "application/msword";
				data.isBinary = false;
				break;
			}
			default: {
				data.contentType = "text/html";
				data.isBinary = false;
			}
		}

		// Render the data
		event.renderData(
			data = data.content,
			contentType = data.contentType,
			isBinary = data.isBinary
		);

		// Save cache
		if ( cacheEnabled ) {

			// Check for feed/feed item
			if ( structKeyExists( prc, "feed" ) && prc.feed.isLoaded() ) {
				data.contentID = prc.feed.getContentID();
			} else if ( structKeyExists( prc, "feedItem" ) && prc.feedItem.isLoaded() ) {
				data.contentID = prc.feedItem.getContentID();
			}

			// Set the cache
			cache.set(
				cacheKey,
				data,
				prc.agSettings.ag_portal_cache_timeout,
				prc.agSettings.ag_portal_cache_timeout_idle
			);

		}

	}

	function index( event, rc, prc ) {

		// Set params
		event.paramValue( "page", 1 )
			.paramValue( "q", "" )
			.paramValue( "category", "" )
			.paramValue( "format", "html" );

		// Set vars
		var title = " | " & cbHelper.siteName();

		// Page check
		if ( !isNumeric( rc.page ) ) rc.page = 1;
		if ( rc.page GT 1 ) {
			title = " - " & "Page " & rc.page & title;
		}

		// XSS Cleanup
		rc.q = antiSamy.clean( rc.q );
		rc.category = antiSamy.clean( rc.category );

		// Paging
		prc.oPaging = getModel("paging@cb");
		prc.oPaging.setpagingMaxRows( prc.agSettings.ag_portal_paging_max_items );
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink = helper.linkPortal() & "?page=@page@";

		// Search
		if ( len( trim( rc.q ) ) ) {
			prc.pagingLink &= "&q=" & rc.q;
			title = " - " & reReplace( rc.q,"(^[a-z])","\U\1","ALL") & title;
		}

		// Category
		if ( len( trim( rc.category ) ) ) {
			prc.category = categoryService.findBySlug( rc.category );
			if ( !isNull( prc.category ) ) {
				prc.pagingLink = helper.linkPortal() & "/category/#rc.category#/?page=@page@";
				title = " - " & prc.category.getCategory() & title;
			} else {
				notFound( argumentCollection=arguments );
				return;
			}
		}

		// Grab the results
		var results = feedItemService.getPublishedFeedItems(
			searchTerm=rc.q,
			category=rc.category,
			max=prc.agSettings.ag_portal_paging_max_items,
			offset=prc.pagingBoundaries.startRow - 1
		);
		prc.feedItems = results.feedItems;
		prc.itemCount = results.count;

		// Announce event
		announceInterception( "aggregator_onIndexView", { feedItems=prc.feedItems, feedItemsCount=prc.itemCount } );

		// Set the page title
		title = prc.agSettings.ag_portal_title & title;
		cbHelper.setMetaTitle( title );

		// Set layout and view
		event.setLayout( name="../themes/default/layouts/aggregator" )
			.setView( view="../themes/default/views/feedindex" );

	}

	function archives( event, rc, prc ) {

		// Set params
		event.paramValue( "page", 1 )
			.paramValue( "year", 0 )
			.paramValue( "month", 0 )
			.paramValue( "day", 0 )
			.paramValue( "format", "html" );

		// Validate the passed date
		var validDate = true;
		try {
			var archiveDate = createDate( rc.year );
			if ( val( rc.month ) && val( rc.day )  ) {
				archiveDate = createDate( rc.year, rc.month, rc.day );
			} else if ( val( rc.month ) ) {
				archiveDate = createDate( rc.year, rc.month );
			}
		} catch ( any e ) {
			validDate = false;
		}

		// Make sure we are passing in a valid date
		if ( validDate ) {

			// Set vars
			var title = " | " & cbHelper.siteName();

			// Page check
			if ( !isNumeric( rc.page ) ) rc.page = 1;
			if ( rc.page GT 1 ) {
				title = " - " & "Page " & rc.page & title;
			}

			// Paging
			prc.oPaging = getModel("paging@cb");
			prc.oPaging.setpagingMaxRows( prc.agSettings.ag_portal_paging_max_items );
			prc.pagingBoundaries = prc.oPaging.getBoundaries();
			prc.pagingLink = helper.linkArchive( rc.year, rc.month, rc.day ) & "?page=@page@";

			// Grab the results
			var results = feedItemService.getPublishedFeedItemsByDate(
				year=rc.year,
				month=rc.month,
				day=rc.day,
				max=prc.agSettings.ag_portal_paging_max_items,
				offset=prc.pagingBoundaries.startRow - 1
			);
			prc.feedItems = results.feedItems;
			prc.itemCount = results.count;

			// Announce event
			announceInterception( "aggregator_onArchivesView", { feedItems=prc.feedItems, feedItemsCount=prc.itemCount } );

			// Set the formatted date and page title
			prc.formattedDate = dateFormat( archiveDate, "yyyy" );
			if ( val( rc.month ) && val( rc.day ) ) {
				prc.formattedDate = dateFormat( archiveDate, "mmmm d, yyyy" );
			} else if ( val( rc.month ) ) {
				prc.formattedDate = dateFormat( archiveDate, "mmmm, yyyy" );
			}
			title = " - " & prc.formattedDate & title;
			title = prc.agSettings.ag_portal_title & title;
			cbHelper.setMetaTitle( title );

			// Set layout and view
			event.setLayout( "../themes/default/layouts/aggregator" )
				.setView( "../themes/default/views/feedarchives" );

		} else {

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

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

		// Announce event
		announceInterception( "aggregator_onRSSView", { category=rc.category, slug=rc.slug } );

		// Render the xml
		event.renderData( type="plain", data=rssFeed, contentType="text/xml" );

	}

	function feeds( event, rc, prc ) {

		// Set params
		event.paramValue( "page", 1 )
			.paramValue( "format", "html" );

		// Set vars
		var title = " | " & cbHelper.siteName();

		// Page check
		if ( !isNumeric( rc.page ) ) rc.page = 1;
		if ( rc.page GT 1 ) {
			title = " - " & "Page " & rc.page & title;
		}

		// Paging
		prc.oPaging = getModel("paging@cb");
		prc.oPaging.setpagingMaxRows( prc.agSettings.ag_portal_paging_max_feeds );
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink = helper.linkFeeds() & "?page=@page@";

		// Grab the results
		var results = feedService.getPublishedFeeds(
			max=prc.agSettings.ag_portal_paging_max_feeds,
			offset=prc.pagingBoundaries.startRow - 1
		);
		prc.feeds = results.feeds;
		prc.itemCount = results.count;

		// Announce event
		announceInterception( "aggregator_onFeedsView", { feeds=prc.feeds, feedsCount=prc.itemCount } );

		// Set the page title
		title = prc.agSettings.ag_portal_feeds_title & title;
		cbHelper.setMetaTitle( title );

		// Set layout and view
		event.setLayout( "../themes/default/layouts/aggregator" )
			.setView( "../themes/default/views/feeds" );

	}

	function feed( event, rc, prc ) {

		// Set params
		event.paramValue( "slug", "" )
			.paramValue( "page", 1 )
			.paramValue( "author", "" )
			.paramValue( "format", "html" );

		// Check if author is viewing
		var showUnpublished = false;
		if ( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ){
			var showUnpublished = true;
		}

		// Get the feed
		prc.feed = feedService.findBySlug( rc.slug, showUnpublished );

		// If loaded, else not found
		if ( prc.feed.isLoaded() ) {

			// Set vars
			var title = " | " & cbHelper.siteName();

			// Page numeric check
			if ( !isNumeric( rc.page ) ) rc.page = 1;
			if ( rc.page GT 1 ) {
				title = " - " & "Page " & rc.page & title;
			}

			// XSS Cleanup
			rc.author = antiSamy.clean( rc.author );

			// Paging
			prc.oPaging = getModel("paging@cb");
			prc.oPaging.setpagingMaxRows( prc.agSettings.ag_portal_paging_max_items );
			prc.pagingBoundaries = prc.oPaging.getBoundaries();
			prc.pagingLink = helper.linkFeed( prc.feed ) & "?page=@page@";

			// Author filter
			if ( len( trim( rc.author ) ) ) {
				prc.pagingLink &= "&author=" & rc.author;
				title = " - " & rc.author & title;
			}

			// Grab the feed items
			var results = feedItemService.getPublishedFeedItems(
				feed=prc.feed.getContentID(),
				author=rc.author,
				max=prc.agSettings.ag_portal_paging_max_items,
				offset=prc.pagingBoundaries.startRow - 1
			);
			prc.feedItems = results.feedItems;
			prc.itemCount = results.count;

			// Record hit
			feedService.updateHits( prc.feed.getContentID() );

			// Announce event
			announceInterception( "aggregator_onFeedView", { feed=prc.feed } );

			// Set the page title
			title = ( len( trim( prc.feed.getHTMLTitle() ) ) ? prc.feed.getHTMLTitle() : prc.feed.getTitle() ) & title;
			cbHelper.setMetaTitle( title );

			// Description and keywords
			if ( len( trim( prc.feed.getHTMLDescription() ) ) ) {
				cbHelper.setMetaDescription( prc.feed.getHTMLDescription() );
			}
			if ( len( trim( prc.feed.getHTMLKeywords() ) ) ) {
				cbHelper.setMetaKeywords( prc.feed.getHTMLKeywords() );
			}

			// Set layout and view
			event.setLayout( "../themes/default/layouts/aggregator" )
				.setView( "../themes/default/views/feed" );

		} else {

			// Announce event
			announceInterception( "aggregator_onFeedNotFound", { slug=rc.slug } );

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	function feeditem( event, rc, prc ) {

		// Set params
		event.paramValue( "slug", "" )
			.paramValue( "format", "html" );

		// Check if author is viewing
		var showUnpublished = false;
		if ( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ){
			var showUnpublished = true;
		}

		// Get the feed item
		prc.feedItem = feedItemService.findBySlug( rc.slug, showUnpublished );

		// If loaded, else not found
		if ( prc.feedItem.isLoaded() ) {

			// Record hit
			feedItemService.updateHits( prc.feedItem.getContentID() );

			// Announce event
			announceInterception( "aggregator_onFeedItemView", { feedItem=feedItem } );

			// Set layout and view
			event.setLayout( "../themes/default/layouts/aggregator" )
				.setView( "../themes/default/views/feeditem" );

		} else {

			// Announce event
			announceInterception( "aggregator_onFeedItemNotFound", { slug=rc.slug } );

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	function import( event, rc, prc ) {

		// Secret key in settings
		event.paramValue( name="key", value="" );

		// To import we must have an author, so check for one first
		if ( len( prc.agSettings.ag_importing_default_creator ) ) {
			var author = authorService.get( prc.agSettings.ag_importing_default_creator );
		} else if ( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ) {
			var author = prc.oCurrentAuthor;
		} else {
			var adminRole = roleService.findWhere( { role="Administrator" } );
			var author = authorService.findWhere( { role=adminRole } );
		}

		// Only import if the keys match and an author is defined
		if ( rc.key EQ prc.agSettings.ag_importing_secret_key  && !isNull( author ) ) {

			// Thread this instead? - in a future version yes
			setting requestTimeout="999999";

			var feeds = feedService.getFeedsForImport();

			for ( var feed IN feeds ) {
				announceInterception( "aggregator_preFeedImport", { feed=feed } );
				feedImportService.import( feed, author );
				announceInterception( "aggregator_postFeedImport", { feed=feed } );
			}

			// Post feed imports
			announceInterception( "aggregator_postFeedImports" );

			// Relocate
			setNextEvent( prc.xehPortalHome );

		} else {

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	function onError( event, rc, prc, faultAction, exception, eventArguments ) {

		// Excceptions
		prc.faultAction = arguments.faultAction;
		prc.exception = arguments.exception;

		// Announce event
		announceInterception(
			"cbui_onError", {
				faultAction=arguments.faultAction,
				exception=arguments.exception,
				eventArguments=arguments.eventArguments
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