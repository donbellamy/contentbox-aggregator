/**
 * ContentBox RSS Aggregator
 * Portal handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="contentbox.modules.contentbox-ui.handlers.content" {

	// Dependencies
	property name="contentService" inject="contentService@aggregator";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="rssService" inject="rssService@aggregator";
	property name="authorService" inject="authorService@cb";
	property name="roleService" inject="roleService@cb";

	// Around handler exeptions
	this.aroundhandler_except = "rss,import,importFeed,onError,notFound";

	/**
	 * Pre handler
	 */
	function preHandler( event, rc, prc, action, eventArguments ) {

		// Are we in maintenance mode?
		if ( prc.cbSettings.cb_site_maintenance ) {
			if ( prc.oCurrentAuthor.isLoggedIn() && prc.oCurrentAuthor.checkPermission( "MAINTENANCE_MODE_VIEWER" ) ) {
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

	/**
	 * Around handler
	 */
	function aroundHandler( event, rc, prc, targetAction, eventArguments ) {

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
				layout = "#prc.cbTheme#/layouts/#themeService.getThemePrintLayout( format=rc.format, layout=listLast( event.getCurrentLayout(), '/' ) )#",
				module = "contentbox",
				viewModule = "contentbox"
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
			} else if (  structKeyExists( prc, "feedItem" ) && prc.feedItem.isLoaded() ) {
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

	/**
	 * Displays the portal index
	 */
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
		prc.oPaging = getModel("paging@aggregator");
		prc.oPaging.setpagingMaxRows( prc.agSettings.ag_portal_paging_max_items );
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink = prc.agHelper.linkPortal() & "?page=@page@";

		// Search
		if ( len( trim( rc.q ) ) ) {
			prc.pagingLink &= "&q=" & rc.q;
			title = " - " & reReplace( rc.q,"(^[a-z])","\U\1","ALL") & title;
		}

		// Category
		if ( len( trim( rc.category ) ) ) {
			prc.category = categoryService.findBySlug( rc.category );
			if ( !isNull( prc.category ) ) {
				prc.pagingLink = prc.agHelper.linkPortal() & "/category/#rc.category#/?page=@page@";
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
			offset=prc.pagingBoundaries.startRow - 1,
			includeEntries=prc.agSettings.ag_portal_display_entries
		);

		prc.feedItems = results.feedItems;
		prc.itemCount = results.count;

		// Announce event
		announceInterception( "aggregator_onIndexView", { feedItems=prc.feedItems, feedItemsCount=prc.itemCount } );

		// Set the page title
		title = prc.agSettings.ag_portal_name & title;
		cbHelper.setMetaTitle( title );

		// Set layout and view
		event.setLayout( name="#prc.cbTheme#/layouts/portal", module="contentbox" )
			.setView( view="#prc.cbTheme#/views/feedindex", module="contentbox" );

	}

	/**
	 * Displays the portal archive
	 */
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
			prc.archiveDate = createDate( rc.year );
			if ( val( rc.month ) && val( rc.day )  ) {
				prc.archiveDate = createDate( rc.year, rc.month, rc.day );
			} else if ( val( rc.month ) ) {
				prc.archiveDate = createDate( rc.year, rc.month );
			}
			if ( prc.archiveDate GT now() ) {
				validDate = false;
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
			prc.oPaging = getModel("paging@aggregator");
			prc.oPaging.setpagingMaxRows( prc.agSettings.ag_portal_paging_max_items );
			prc.pagingBoundaries = prc.oPaging.getBoundaries();
			prc.pagingLink = prc.agHelper.linkArchive( rc.year, rc.month, rc.day ) & "?page=@page@";

			// Grab the results
			var results = feedItemService.getPublishedFeedItemsByDate(
				year=rc.year,
				month=rc.month,
				day=rc.day,
				max=prc.agSettings.ag_portal_paging_max_items,
				offset=prc.pagingBoundaries.startRow - 1,
				includeEntries=prc.agSettings.ag_portal_display_entries
			);
			prc.feedItems = results.feedItems;
			prc.itemCount = results.count;

			// Announce event
			announceInterception( "aggregator_onArchivesView", { feedItems=prc.feedItems, feedItemsCount=prc.itemCount } );

			// Set the formatted date and page title
			prc.formattedDate = dateFormat( prc.archiveDate, "yyyy" );
			if ( val( rc.month ) && val( rc.day ) ) {
				prc.formattedDate = dateFormat( prc.archiveDate, "mmmm d, yyyy" );
			} else if ( val( rc.month ) ) {
				prc.formattedDate = dateFormat( prc.archiveDate, "mmmm, yyyy" );
			}
			title = " - " & prc.formattedDate & title;
			title = prc.agSettings.ag_portal_name & title;
			cbHelper.setMetaTitle( title );

			// Set layout and view
			event.setLayout( name="#prc.cbTheme#/layouts/portal", module="contentbox" )
				.setView( view="#prc.cbTheme#/views/feedarchives", module="contentbox" );

		} else {

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	/**
	 * Displays the rss feed
	 */
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
			slug=rc.slug
		);

		// Announce event
		announceInterception( "aggregator_onRSSView", { category=rc.category, slug=rc.slug } );

		// Render the xml
		event.renderData( type="plain", data=rssFeed, contentType="text/xml" );

	}

	/**
	 * Displays the list of feeds
	 */
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
		prc.oPaging = getModel("paging@aggregator");
		prc.oPaging.setpagingMaxRows( prc.agSettings.ag_portal_paging_max_feeds );
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink = prc.agHelper.linkFeeds() & "?page=@page@";

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
		event.setLayout( name="#prc.cbTheme#/layouts/portal", module="contentbox" )
			.setView( view="#prc.cbTheme#/views/feeds", module="contentbox" );

	}

	/**
	 * Displays the feed
	 */
	function feed( event, rc, prc ) {

		// Set params
		event.paramValue( "slug", "" )
			.paramValue( "page", 1 )
			.paramValue( "author", "" )
			.paramValue( "format", "html" );

		// Check if author is viewing
		var showUnpublished = false;
		if ( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ) {
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
			prc.oPaging = getModel("paging@aggregator");
			prc.oPaging.setpagingMaxRows( val( prc.feed.getPagingMaxItems() ) ? val( prc.feed.getPagingMaxItems() ) : prc.agSettings.ag_portal_paging_max_items );
			prc.pagingBoundaries = prc.oPaging.getBoundaries();
			prc.pagingLink = prc.agHelper.linkFeed( prc.feed ) & "?page=@page@";

			// Author filter
			if ( len( trim( rc.author ) ) ) {
				prc.pagingLink &= "&author=" & rc.author;
				title = " - " & rc.author & title;
			}

			// Grab the feed items
			var results = feedItemService.getPublishedFeedItems(
				feed=prc.feed.getContentID(),
				author=rc.author,
				max=val( prc.feed.getPagingMaxItems() ) ? val( prc.feed.getPagingMaxItems() ) : prc.agSettings.ag_portal_paging_max_items,
				offset=prc.pagingBoundaries.startRow - 1,
				includeEntries=false
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
			event.setLayout( name="#prc.cbTheme#/layouts/portal", module="contentbox" )
				.setView( view="#prc.cbTheme#/views/feed", module="contentbox" );

		} else {

			// Announce event
			announceInterception( "aggregator_onFeedNotFound", { slug=rc.slug } );

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	/**
	 * Pre feed item
	 */
	function preFeedItem( event, rc, prc, action, eventArguments ) {

		// Set params
		event.paramValue( "slug", "" );

		// Check if author is viewing
		var showUnpublished = false;
		if ( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ) {
			var showUnpublished = true;
		}

		// Get the feed item
		prc.feedItem = feedItemService.findBySlug( rc.slug, showUnpublished );

		// If loaded, else not found
		if ( prc.feedItem.isLoaded() ) {

			// Calculate link behavior
			prc.linkBehavior = len( prc.feedItem.getFeed().getLinkBehavior() ) ? prc.feedItem.getFeed().getLinkBehavior() : prc.agSettings.ag_portal_item_link_behavior;

			// Turn off cache if forwarding user to feed item
			if ( prc.linkBehavior == "forward" ) {
				rc.cbCache = true;
			}

		}

	}

	/**
	 * Displays the feed item
	 */
	function feeditem( event, rc, prc ) {

		// Set params
		event.paramValue( "slug", "" )
			.paramValue( "format", "html" );

		// If loaded, else not found
		if ( prc.feedItem.isLoaded() ) {

			// Record hit
			feedItemService.updateHits( prc.feedItem.getContentID() );

			// Announce event
			announceInterception( "aggregator_onFeedItemView", { feedItem=feedItem } );

			// Disply feed item based on setting
			switch( prc.linkBehavior ) {

				// Forward user to feed item
				case "forward": {

					relocate( url=prc.feedItem.getItemUrl(), addToken=false, statusCode="302" );
					break;

				}

				// Use interstitial page to forward user to feed item
				case "interstitial": {

					cbHelper.setMetaTitle( "Leaving #cbHelper.siteName()#..." );

					event.setLayout( name="#prc.cbTheme#/layouts/portal", module="contentbox" )
						.setView( view="#prc.cbTheme#/views/interstitial", module="contentbox" );

					break;

				}

				// Display the feed item
				case "display": {

					// Set the page title
					var title = ( len( trim( prc.feedItem.getHTMLTitle() ) ) ? prc.feedItem.getHTMLTitle() : prc.feedItem.getTitle() ) & " | " & cbHelper.siteName();
					cbHelper.setMetaTitle( title );

					// Description and keywords
					if ( len( trim( prc.feedItem.getHTMLDescription() ) ) ) {
						cbHelper.setMetaDescription( prc.feedItem.getHTMLDescription() );
					}
					if ( len( trim( prc.feedItem.getHTMLKeywords() ) ) ) {
						cbHelper.setMetaKeywords( prc.feedItem.getHTMLKeywords() );
					}

					event.setLayout( name="#prc.cbTheme#/layouts/portal", module="contentbox" )
						.setView( view="#prc.cbTheme#/views/feeditem", module="contentbox" );

					break;

				}

			}

		} else {

			// Announce event
			announceInterception( "aggregator_onFeedItemNotFound", { slug=rc.slug } );

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	/**
	 * Runs the feed import routine for all active feeds
	 */
	function import( event, rc, prc ) {

		// Set params
		event.paramValue( name="key", value="" );

		// Only import if the keys match
		if ( rc.key EQ prc.agSettings.ag_importing_secret_key ) {

			// Set timeout
			setting requestTimeout="999999";

			// Grab the feeds
			var feeds = feedService.getFeedsForImport();

			// Grab the author
			if ( len( prc.agSettings.ag_importing_item_author ) ) {
				var author = authorService.get( prc.agSettings.ag_importing_item_author );
			} else if ( structKeyExists( prc, oCurrentAuthor ) ) {
				var author = prc.oCurrentAuthor;
			} else {
				var adminRole = roleService.findWhere( { role="Administrator" } );
				var author = authorService.findWhere( { role=adminRole } );
			}

			// Prepare return data
			var data = { error=false, messages=[] }

			// Import feeds
			if ( arrayLen( feeds ) && !isNull( author ) ) {
				announceInterception( "aggregator_preFeedImports", { feeds=feeds } );
				for ( var feed IN feeds ) {
					try {
						var result = new http( method="get", url=prc.agHelper.linkImportFeed( feed, author ) ).send().getPrefix();
						if ( result.status_code == "200" ) {
							var returnData = deserializeJson( result.fileContent );
							arrayAppend( data.messages, returnData.message );
						} else {
							data.error=true;
							arrayAppend( data.messages, "Error importing feed items for '#feed.getTitle()#'." );
						}
					} catch ( any e ) {
						data.error=true;
						arrayAppend( data.messages, "Fatal error importing feed items for '#feed.getTitle()#'."  & " " & e.message & " " & e.detail );
					}
				}
				announceInterception( "aggregator_postFeedImports", { feeds=feeds } );
			}

			if ( event.isAjax() ) {
				event.renderData( type="json", data=data );
			} else {
				setNextEvent( prc.xehPortalHome );
			}

		} else {

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	/**
	 * Runs the feed import routine for a single feed
	 */
	function importFeed( event, rc, prc ) {

		// Set params
		event.paramValue( name="key", value="" )
			.paramValue( name="contentID", value="" )
			.paramValue( name="authorID", value="" );

		// Check key, contentID and authorID
		if ( rc.key EQ prc.agSettings.ag_importing_secret_key && len( rc.contentID ) && len( rc.authorID ) ) {

			// Set format
			rc.format = "json";

			// Grab feed and author
			var feed = feedService.get( rc.contentID );
			var author = authorService.get( rc.authorID );

			// Run the import routine and return json
			if ( !isNull( feed ) && !isNull( author ) ) {
				try {
					feedImportService.import( feed, author );
					event.renderData( type="json", data={
						error=false,
						message="Feed items imported for '#feed.getTitle()#'."
					});
				} catch ( any e ) {
					event.renderData( type="json", data={
						error=true,
						message="Error importing feed items for '#feed.getTitle()#'." & " " & e.message & " " & e.detail
					});
				}
			} else {
				event.renderData( type="json", data={
					error=true,
					message="Invalid feed and/or author passed to importFeed function."
				});
			}

		} else {

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	/**
	 * Displays a friendly error message
	 */
	function onError( event, rc, prc, faultAction, exception, eventArguments ) {

		// Exceptions
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

	/**
	 * Displays page not found error
	 */
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