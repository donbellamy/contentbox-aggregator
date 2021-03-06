/**
 * ContentBox Aggregator
 * Site handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="contentbox.modules.contentbox-ui.handlers.content" {

	// Dependencies
	property name="contentService" inject="contentService@aggregator";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="rssService" inject="rssService@aggregator";
	property name="mobileDetector" inject="mobileDetector@cb";

	// Around handler exeptions
	this.aroundhandler_except = "onError,notFound";

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

		// Do not allow site access via the module entrypoint
		if ( reFindNoCase( "^aggregator/site", event.getCurrentRoutedUrl() ) ) {
			relocate( url=prc.agHelper.linkFeedItems(), addtoken=false );
		}

		// If UI export is disabled, default to html
		if ( !prc.cbSettings.cb_content_uiexport ) {
			rc.format = "html";
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
			prc.agSettings.site_cache_enable AND
			!event.valueExists("cbCache")
		);

		// Check the cache
		if ( cacheEnabled ) {

			// Set cache and cacheKey
			var cache = cacheBox.getCache( prc.agSettings.site_cache_name );
			var cacheKey = "cb-content-aggregator-#cgi.http_host#-#left( event.getCurrentRoutedURL(), 500 )#";
			cacheKey &= hash( ".#getFWLocale()#.#rc.format#.#event.isSSL()#" & prc.cbox_incomingContextHash );

			// Get cache
			prc.contentCacheData = cache.get( cacheKey );

			// Output cache if defined
			if ( !isNull( prc.contentCacheData ) ) {

				// Set cache headers
				if ( prc.cbSettings.cb_content_cachingHeader ) {
					event.setHTTPHeader(
						statusCode = "203",
						statustext = "ContentBoxCache Non-Authoritative Information"
					).setHTTPHeader(
						name = "x-contentbox-cached-content",
						value = "true"
					);
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
		var data = {
			contentID = "",
			contentType = "text/html",
			isBinary = false
		};

		// Set arguments
		var args = {
			event = arguments.event,
			rc = arguments.rc,
			prc = arguments.prc
		};
		structAppend( args, arguments.eventArguments );

		// Execute the wrapped action
		var data.content = arguments.targetAction( argumentCollection=args );

		// Generate content if needed
		if ( isNull( data.content ) ) {
			// Render the layout
			data.content = renderLayout(
					layout = "#prc.cbTheme#/layouts/#themeService.getThemePrintLayout(
						format = rc.format,
						layout = listLast( event.getCurrentLayout(), '/'
					)
				)#",
				module = prc.cbThemeRecord.module,
				viewModule = prc.cbThemeRecord.module
			);
		}

		// Set the content
		var content = structKeyExists( prc, "feed" ) ? prc.feed : ( structKeyExists( prc, "feedItem" ) ? prc.feedItem : prc.page );

		// Switch on format
		switch ( rc.format ) {
			case "xml": case "json": {
				var results = content.getResponseMemento();
				if ( content.getContentType() == "Page" && structKeyExists( prc, "feeds" ) ) {
					results["feeds"] = [];
					for ( var feed IN prc.feeds ) {
						results["feeds"].append( feed.getResponseMemento() );
					}
				} else if ( content.getContentType() == "Page" && structKeyExists( prc, "feedItems" ) ) {
					results["feedItems"] = [];
					for ( var feedItem IN prc.feedItems ) {
						results["feedItems"].append( feedItem.getResponseMemento() );
					}
				}
				if ( rc.format == "json" ) {
					data.content = dataMarshaller.marshallData( data=results, type="json" );
					data.contentType = "application/json";
					data.isBinary = false;
				} else {
					data.content = dataMarshaller.marshallData(
						data = results,
						type = "xml",
						xmlRootName = lcase( content.getContentType() )
					);
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
		if ( cacheEnabled && content.isLoaded() && content.getCacheLayout() && content.isContentPublished() ) {

			// Set contentID
			data.contentID = content.getContentID();

			// Set the cache
			cache.set(
				cacheKey,
				data,
				prc.agSettings.site_cache_timeout,
				prc.agSettings.site_cache_idle_timeout
			);

		}

	}

	/**
	 * Displays the feed items index
	 */
	function index( event, rc, prc ) {

		// Set params
		event.paramValue( "page", 1 )
			.paramValue( "q", "" )
			.paramValue( "category", "" )
			.paramValue( "feed", "" )
			.paramValue( "sb", "" )
			.paramValue( "type", "" )
			.paramValue( "format", "html" );

		// Grab the feed items page
		getPage( prc, prc.agSettings.feed_items_entrypoint );

		// Make sure page exists
		if ( prc.page.isLoaded() ) {

			// Set vars
			var title = " | " & cbHelper.siteName();
			var sortOrder = "publishedDate DESC";

			// Page check
			if ( !isNumeric( rc.page ) ) rc.page = 1;
			if ( rc.page GT 1 ) {
				title = " - " & "Page " & rc.page & title;
			}

			// XSS Cleanup
			rc.q = antiSamy.clean( rc.q );
			rc.category = antiSamy.clean( rc.category );
			rc.feed = antiSamy.clean( rc.feed );
			rc.type = antiSamy.clean( rc.type );

			// Paging
			prc.oPaging = getModel("paging@aggregator");
			prc.oPaging.setpagingMaxRows( prc.agSettings.paging_max_feed_items );
			prc.pagingBoundaries = prc.oPaging.getBoundaries();
			prc.pagingLink = prc.agHelper.linkFeedItems();

			// Category
			if ( len( rc.category ) ) {
				prc.category = categoryService.findBySlug( rc.category );
				if ( !isNull( prc.category ) ) {
					prc.pagingLink &= "/category/#rc.category#/";
					title = " - " & prc.category.getCategory() & title;
				} else {
					notFound( argumentCollection=arguments );
					return;
				}
			}

			// Paging
			prc.pagingLink &= "?page=@page@";

			// Feed
			if ( len( rc.feed ) ) {
				prc.feed = feedService.findBySlug( rc.feed );
				if ( !isNull( prc.feed ) ) {
					prc.pagingLink &= "&feed=" & rc.feed;
					title = " - " & prc.feed.getTitle() & title;
				} else {
					notFound( argumentCollection=arguments );
					return;
				}
			}

			// Search
			if ( len( rc.q ) ) {
				prc.pagingLink &= "&q=" & rc.q;
				title = " - " & reReplace( rc.q,"(^[a-z])","\U\1","ALL") & title;
			}

			// Sort order
			switch ( rc.sb ) {
				case "hits": {
					prc.pagingLink &= "&sb=hits";
					sortOrder = "numberOfHits DESC";
					break;
				}
				case "title": {
					prc.pagingLink &= "&sb=title";
					sortOrder = "title ASC";
					break;
				}
			}

			// Set template and paging label
			prc.template = "feeditem";
			prc.pagingLabel = "items";
			if ( len( rc.type ) && listFindNoCase( "podcast,video", rc.type ) ) {
				prc.template = rc.type;
				prc.pagingLink &= "&type=" & rc.type;
				if ( rc.type == "video" ) prc.pagingLabel = "videos";
				else if ( rc.type == "podcast" ) prc.pagingLabel = "podcasts";
			} else if ( len( rc.type ) ) {
				notFound( argumentCollection=arguments );
				return;
			}

			// Set title
			title = prc.page.getTitle() & title;

			// Grab the results
			var results = feedItemService.getPublishedFeedItems(
				searchTerm = rc.q,
				category = rc.category,
				feed = rc.feed,
				type = rc.type,
				sortOrder = sortOrder,
				max = prc.agSettings.paging_max_feed_items,
				offset = prc.pagingBoundaries.startRow - 1,
				includeEntries = prc.agSettings.feed_items_include_entries
			);
			prc.feedItems = results.feedItems;
			prc.itemCount = results.count;

			// Announce event
			announceInterception(
				"aggregator_onFeedItemsView",
				{ feedItems = prc.feedItems, feedItemsCount = prc.itemCount }
			);

			// Set the page title
			cbHelper.setMetaTitle( title );

			// Set args
			prc.args = prc.agHelper.getViewArgs();

			// Set layout and view
			event.setLayout(
				name = "#prc.cbTheme#/layouts/#prc.page.getLayout()#",
				module = prc.cbThemeRecord.module
			).setView(
				view = "#prc.cbTheme#/views/aggregator/index",
				module = prc.cbThemeRecord.module
			);

		// Feed items page not published, throw a 404
		} else {

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	/**
	 * Displays the feed items archive
	 */
	function archives( event, rc, prc ) {

		// Set params
		event.paramValue( "page", 1 )
			.paramValue( "year", 0 )
			.paramValue( "month", 0 )
			.paramValue( "day", 0 )
			.paramValue( "format", "html" );

		// Grab the feed items page
		getPage( prc, prc.agSettings.feed_items_entrypoint );

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

		// Make sure page exists and date is valid
		if ( prc.page.isLoaded() AND validDate ) {

			// Set vars
			var title = " | " & cbHelper.siteName();

			// Page check
			if ( !isNumeric( rc.page ) ) rc.page = 1;
			if ( rc.page GT 1 ) {
				title = " - " & "Page " & rc.page & title;
			}

			// Paging
			prc.oPaging = getModel("paging@aggregator");
			prc.oPaging.setpagingMaxRows( prc.agSettings.paging_max_feed_items );
			prc.pagingBoundaries = prc.oPaging.getBoundaries();
			prc.pagingLink = prc.agHelper.linkArchive( rc.year, rc.month, rc.day ) & "?page=@page@";

			// Grab the results
			var results = feedItemService.getPublishedFeedItemsByDate(
				year = rc.year,
				month = rc.month,
				day = rc.day,
				max = prc.agSettings.paging_max_feed_items,
				offset = prc.pagingBoundaries.startRow - 1,
				includeEntries = prc.agSettings.feed_items_include_entries
			);
			prc.feedItems = results.feedItems;
			prc.itemCount = results.count;

			// Announce event
			announceInterception(
				"aggregator_onArchivesView",
				{ feedItems = prc.feedItems, feedItemsCount = prc.itemCount }
			);

			// Set the formatted date and page title
			prc.formattedDate = dateFormat( prc.archiveDate, "yyyy" );
			if ( val( rc.month ) && val( rc.day ) ) {
				prc.formattedDate = dateFormat( prc.archiveDate, "mmmm d, yyyy" );
			} else if ( val( rc.month ) ) {
				prc.formattedDate = dateFormat( prc.archiveDate, "mmmm, yyyy" );
			}
			title = prc.page.getTitle() & " - " & prc.formattedDate & title;

			// Set the page title
			cbHelper.setMetaTitle( title );

			// Set args
			prc.args = prc.agHelper.getViewArgs();

			// Set layout and view
			event.setLayout(
				name = "#prc.cbTheme#/layouts/#prc.page.getLayout()#",
				module = prc.cbThemeRecord.module
			).setView(
				view = "#prc.cbTheme#/views/aggregator/archives",
				module = prc.cbThemeRecord.module
			);

		// Feed items page not published, throw a 404
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

		// Grab the correct page
		if ( event.getCurrentRoutedNamespace() == "aggregator-feeds" ) {
			getPage( prc, prc.agSettings.feeds_entrypoint );
		} else {
			getPage( prc, prc.agSettings.feed_items_entrypoint );
		}

		// Make sure page exists and rss is enabled
		if ( prc.page.isLoaded() && prc.agSettings.rss_enable ) {

			// Set params
			event.paramValue( "category", "" )
				.paramValue( "slug", "" );

			// Set format
			rc.format = "rss";

			// Grab the rss feed
			var rssFeed = rssService.getRSS(
				slug=rc.slug,
				category=rc.category
			);

			// Announce event
			announceInterception(
				"aggregator_onRSSView",
				{ category = rc.category, slug = rc.slug }
			);

			// Render the xml
			event.renderData(
				type = "plain",
				data = rssFeed,
				contentType = "text/xml"
			);

		// Feed items page not published or rss not enabled, throw a 404
		} else {

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	/**
	 * Displays the list of feeds
	 */
	function feeds( event, rc, prc ) {

		// Set params
		event.paramValue( "page", 1 )
			.paramValue( "category", "" )
			.paramValue( "sb", "" )
			.paramValue( "format", "html" );

		// Grab the feeds page
		getPage( prc, prc.agSettings.feeds_entrypoint );

		// Make sure page exists
		if ( prc.page.isLoaded() ) {

			// Set vars
			var title = " | " & cbHelper.siteName();
			var sortOrder = "title ASC";

			// Page check
			if ( !isNumeric( rc.page ) ) rc.page = 1;
			if ( rc.page GT 1 ) {
				title = " - " & "Page " & rc.page & title;
			}

			// Paging
			prc.oPaging = getModel("paging@aggregator");
			prc.oPaging.setpagingMaxRows( prc.agSettings.paging_max_feeds );
			prc.pagingBoundaries = prc.oPaging.getBoundaries();
			prc.pagingLink = prc.agHelper.linkFeeds();

			// Category
			if ( len( rc.category ) ) {
				prc.category = categoryService.findBySlug( rc.category );
				if ( !isNull( prc.category ) ) {
					prc.pagingLink &= "/category/#rc.category#/";
					title = " - " & prc.category.getCategory() & title;
				} else {
					notFound( argumentCollection=arguments );
					return;
				}
			}

			// Paging
			prc.pagingLink &= "?page=@page@";

			// Sort order
			switch ( rc.sb ) {
				case "hits": {
					prc.pagingLink &= "&sb=recent";
					sortOrder = "lastPublishedDate DESC";
					break;
				}
			}

			// Grab the results
			var results = feedService.getPublishedFeeds(
				sortOrder = sortOrder,
				category = rc.category,
				max = prc.agSettings.paging_max_feeds,
				offset = prc.pagingBoundaries.startRow - 1
			);
			prc.feeds = results.feeds;
			prc.itemCount = results.count;

			// Announce event
			announceInterception(
				"aggregator_onFeedsView",
				{ feeds = prc.feeds, feedsCount = prc.itemCount }
			);

			// Set the page title
			title = prc.page.getTitle() & title;
			cbHelper.setMetaTitle( title );

			// Set args
			prc.args = prc.agHelper.getViewArgs();

			// Set layout and view
			event.setLayout(
				name = "#prc.cbTheme#/layouts/#prc.page.getLayout()#",
				module = prc.cbThemeRecord.module
			).setView(
				view = "#prc.cbTheme#/views/aggregator/feeds",
				module = prc.cbThemeRecord.module
			);

		// Feeds page not published, throw a 404
		} else {

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	/**
	 * Displays the feeds rss
	 */
	function feedsRSS( event, rc, prc ) {

		// Grab the feeds page
		getPage( prc, prc.agSettings.feeds_entrypoint );

		// Make sure page exists
		if ( prc.page.isLoaded() && prc.agSettings.rss_enable ) {

			// Set params
			event.paramValue( "category", "" );

			// Set format
			rc.format = "rss";

			// Grab the rss feed
			var rssFeed = rssService.getRSS(
				category=rc.category,
				contentType="Feed"
			);

			// Announce event
			announceInterception(
				"aggregator_onRSSView",
				{ category = rc.category }
			);

			// Render the xml
			event.renderData(
				type = "plain",
				data = rssFeed,
				contentType = "text/xml"
			);

		// Feeds page not published or rss not enabled, throw a 404
		} else {

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

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

		// Grab the feeds page
		getPage( prc, prc.agSettings.feeds_entrypoint );

		// Check if author is viewing
		var showUnpublished = false;
		if ( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ) {
			var showUnpublished = true;
		}

		// Get the feed
		prc.feed = feedService.findBySlug( rc.slug, showUnpublished );

		// Make sure page and feed exists
		if ( prc.page.isLoaded() && prc.feed.isLoaded() ) {

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
			prc.oPaging.setpagingMaxRows( val( prc.feed.getSetting( "paging_max_feed_items", "" ) ) ? val( prc.feed.getSetting( "paging_max_feed_items", "" ) ) : prc.agSettings.paging_max_feed_items );
			prc.pagingBoundaries = prc.oPaging.getBoundaries();
			prc.pagingLink = prc.agHelper.linkFeed( prc.feed ) & "?page=@page@";

			// Author filter
			if ( len( trim( rc.author ) ) ) {
				prc.pagingLink &= "&author=" & rc.author;
				title = " - " & rc.author & title;
			}

			// Set template and paging label
			prc.template = "feeditem";
			prc.pagingLabel = "items";
			if ( !prc.feed.isArticleFeed() ) {
				if ( prc.feed.isPodcastFeed() ) {
					prc.template = "podcast";
					prc.pagingLabel = "podcasts";
				} else {
					prc.template = "video";
					prc.pagingLabel = "videos";
				}
			}

			// Grab the feed items
			var results = feedItemService.getPublishedFeedItems(
				feed = prc.feed.getContentID(),
				author = rc.author,
				max = val( prc.feed.getSetting( "paging_max_feed_items", "" ) ) ? val( prc.feed.getSetting( "paging_max_feed_items", "" ) ) : prc.agSettings.paging_max_feed_items,
				offset = prc.pagingBoundaries.startRow - 1,
				includeEntries = false
			);
			prc.feedItems = results.feedItems;
			prc.itemCount = results.count;

			// Record hit
			feedService.updateHits( prc.feed.getContentID() );

			// Announce event
			announceInterception(
				"aggregator_onFeedView",
				{ feed = prc.feed }
			);

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

			// Set args
			prc.args = prc.agHelper.getViewArgs();

			// Set layout and view
			event.setLayout(
				name = "#prc.cbTheme#/layouts/#prc.page.getLayout()#",
				module = prc.cbThemeRecord.module
			).setView(
				view = "#prc.cbTheme#/views/aggregator/feed",
				module = prc.cbThemeRecord.module
			);

		// Feeds page off, forward directly to the feed source
		} else if ( !prc.page.isLoaded() && prc.feed.isLoaded() ) {

			// Relocate
			relocate(
				url = prc.feed.getWebsiteUrl(),
				addToken = false,
				statusCode = "307"
			);

		// Feed not published, throw a 404
		} else {

			// Announce event
			announceInterception(
				"aggregator_onFeedNotFound",
				{ slug = rc.slug }
			);

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
			prc.linkBehavior = len( prc.feedItem.getFeed().getSetting( "feed_items_link_behavior", "" ) ) ? prc.feedItem.getFeed().getSetting( "feed_items_link_behavior", "" ) : prc.agSettings.feed_items_link_behavior;

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

		// Grab the feed items page
		getPage( prc, prc.agSettings.feed_items_entrypoint );

		// Make sure page and feed item are loaded
		if ( prc.page.isLoaded() && prc.feedItem.isLoaded() ) {

			// Record hit
			feedItemService.updateHits( prc.feedItem.getContentID() );

			// Announce event
			announceInterception(
				"aggregator_onFeedItemView",
				{ feedItem = prc.feedItem }
			);

			// Disply feed item based on setting
			switch( prc.linkBehavior ) {

				// Forward/link user to feed item
				case "forward":
				case "link": {

					relocate(
						url = prc.feedItem.getItemUrl(),
						addToken = false,
						statusCode = "302"
					);
					break;

				}

				// Use interstitial page to forward user to feed item
				case "interstitial": {

					cbHelper.setMetaTitle( "Leaving #cbHelper.siteName()#..." );

					// Set args
					prc.args = prc.agHelper.getViewArgs();

					// Set layout and view
					event.setLayout(
						name = "#prc.cbTheme#/layouts/#prc.page.getLayout()#",
						module = prc.cbThemeRecord.module
					).setView(
						view = "#prc.cbTheme#/views/aggregator/interstitial",
						module = prc.cbThemeRecord.module
					);

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

					// Set args
					prc.args = prc.agHelper.getViewArgs();

					// Set layout and view
					event.setLayout(
						name = "#prc.cbTheme#/layouts/#prc.page.getLayout()#",
						module = prc.cbThemeRecord.module
					).setView(
						view = "#prc.cbTheme#/views/aggregator/feeditem",
						module = prc.cbThemeRecord.module
					);

					break;

				}

			}

		// Feed items page off, forward directly to the feed item
		} else if ( !prc.page.isLoaded() && prc.feedItem.isLoaded()  ) {

			// Relocate
			relocate(
				url = prc.feedItem.getItemUrl(),
				addToken = false,
				statusCode = "307"
			);

		// Feed item not published, throw a 404
		} else {

			// Announce event
			announceInterception(
				"aggregator_onFeedItemNotFound",
				{ slug = rc.slug }
			);

			// Not found
			notFound( argumentCollection=arguments );
			return;

		}

	}

	/**
	 * Updates hits to a feed item via ajax
	 */
	function hit( event, rc, prc ) {

		// Set params
		event.paramValue( "slug", "" );

		// Grab the feed items page
		getPage( prc, prc.agSettings.feed_items_entrypoint );

		// Get the feed item
		var feedItem = feedItemService.findBySlug( rc.slug );

		// Make sure we are using ajax and the page and feed item are loaded
		if ( event.isAjax() && prc.page.isLoaded() && feedItem.isLoaded() ) {

			// Record hit
			feedItemService.updateHits( feedItem.getContentID() );

			// Set json response
			var data = { "suceess" = true };
			rc.format = "json";
			event.renderData(
				type = "json",
				data = data
			);

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
				faultAction = arguments.faultAction,
				exception = arguments.exception,
				eventArguments = arguments.eventArguments
			}
		);

		// Set layout and view
		event.setLayout(
			name = "#prc.cbTheme#/layouts/pages",
			module = prc.cbThemeRecord.module
		).setView(
			view = "#prc.cbTheme#/views/error",
			module = prc.cbThemeRecord.module
		);

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Gets the current page
	 */
	private function getPage( prc, string slug ) {

		// Check author
		var showUnpublished = false;
		if ( prc.oCurrentAuthor.isLoaded() AND prc.oCurrentAuthor.isLoggedIn() ) {
			var showUnpublished = true;
		}

		// Grab the page
		prc.page = contentService.findBySlug( arguments.slug, showUnpublished );

		// Make sure page exists
		if ( prc.page.isLoaded() ) {

			// Set meta tags
			if ( len( trim( prc.page.getHTMLDescription() ) ) ) {
				cbHelper.setMetaDescription( prc.page.getHTMLDescription() );
			}
			if ( len( trim( prc.page.getHTMLKeywords() ) ) ) {
				cbHelper.setMetaKeywords( prc.page.getHTMLKeywords() );
			}

			// Update hits
			contentService.updateHits( prc.page.getContentID() );

			// Comments
			if ( prc.page.getAllowComments() ) {
				var commentResults = commentService.findApprovedComments( contentID = prc.page.getContentID(), sortOrder = "asc" );
				prc.comments = commentResults.comments;
				prc.commentsCount = commentResults.count;
			} else {
				prc.comments = [];
				prc.commentsCount = 0;
			}

			// Check mobile and layout
			var isMobile = mobileDetector.isMobile();
			var layout = isMobile ? prc.page.getMobileLayoutWithInheritance() : prc.page.getLayoutWithInheritance();
			if ( layout != "-no-layout-" && !fileExists( expandPath( cbHelper.themeRoot() & "/layouts/#layout#.cfm" ) ) ) {
				throw(
					message	= "The layout of the page: '#layout#' does not exist in the current theme.",
					detail= "Please verify your page layout settings",
					type = "ContentBox.InvalidPageLayout"
				);
			}

			// Reset the layout if needed
			if ( prc.page.getLayout() != layout ) {
				prc.page.setLayout( layout );
			}

			// Announce event
			announceInterception(
				"cbui_onPage",
				{ page = prc.page, isMobile = isMobile }
			);

		}

	}

	/**
	 * Displays page not found error
	 */
	private function notFound( event, rc, prc ) {

		// Grab page and url
		prc.missingPage = event.getCurrentRoutedURL();
		prc.missingRoutedURL = event.getCurrentRoutedURL();

		// Set layout and view
		event.setLayout(
			name = "#prc.cbTheme#/layouts/pages",
			module = prc.cbThemeRecord.module
		).setView(
			view = "#prc.cbTheme#/views/notfound",
			module = prc.cbThemeRecord.module
		).setHTTPHeader(
			"404",
			"Page not found"
		);

	}

}