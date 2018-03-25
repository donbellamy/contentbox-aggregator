component singleton {

	property name="cachebox" inject="cachebox";
	property name="feedGenerator" inject="feedGenerator@cbfeeds";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="helper" inject="helper@aggregator";
	property name="settingService" inject="settingService@aggregator";
	property name="log" inject="logbox:logger:{this}";

	RSSService function init() {
		return this;
	}

	RSSService function clearCaches() {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var cache = cacheBox.getCache( settings.ag_rss_cache_name );
		var cacheKey = "cb-feeds-#cgi.http_host#-feeditems";

		// Clear cache
		cache.clearByKeySnippet(keySnippet=cacheKey,async=false);

		return this;

	}

	string function getRSS( string category="", string feed="" ) {

		// Set vars, ( we use cb-feeds so cache can be cleared in admin )
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var cache = cacheBox.getCache( settings.ag_rss_cache_name );
		var cacheKey = "cb-feeds-#cgi.http_host#-feeditems-#hash( arguments.category & arguments.feed & "FeedItem" )#";
		var rssFeed = "";

		// Check cache
		if ( settings.ag_rss_cache_enable ) {
			rssFeed = cache.get( cacheKey );
			if ( !isNull( rssFeed ) ){
				return rssFeed;
			}
		}

		// Build the feed
		rssFeed = buildFeed( argumentCollection=arguments );

		// Cache the feed
		if ( settings.ag_rss_cache_enable ) {
			cache.set( cacheKey, rssFeed, settings.ag_rss_cache_timeout, settings.ag_rss_cache_timeout_idle );
		}

		return rssFeed;

	}

	/************************************** PRIVATE *********************************************/

	private string function buildFeed( string category="", string feed="" ) {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting("aggregator") );
		var feedStruct = {};

		// Get results
		var results = feedItemService.getPublishedFeedItems(
			category=arguments.category,
			feed=arguments.feed,
			max=settings.ag_rss_max_items
		);
		var feedItems = results.feedItems;
		var items = queryNew("title,description,link,pubDate,dcmiterm_creator,category_tag,guid_permalink,guid_string,source_title,source_url");

		// Build the items query
		for ( var item IN feedItems ) {
			queryAddRow( items, 1 );
			querySetCell( items, "title", item.getTitle() );
			var description = helper.renderContentExcerpt( item );
			if ( item.hasExcerpt() ) {
				description = item.renderExcerpt();
			}
			querySetCell( items, "description", helper.stripHtml( description ) );
			querySetCell( items, "link", helper.linkFeedItem( item ) );
			querySetCell( items, "pubDate", item.getPublishedDate() );
			querySetCell( items, "dcmiterm_creator", item.getItemAuthor() );
			if ( item.hasCategories() ) {
				querySetCell( items, "category_tag", item.getCategoriesList() );
			}
			querySetCell( items, "guid_permalink", false );
			querySetCell( items, "guid_string", helper.linkFeedItem( item ) );
			querySetCell( items, "source_title", item.getFeed().getTitle() );
			querySetCell( items, "source_url", item.getFeed().getFeedUrl() );
		}

		// Populate the feedStruct
		// TODO: If feed is passed in then adjust the title and?
		feedStruct.title = settings.ag_rss_title;
		feedStruct.description = settings.ag_rss_description;
		feedStruct.generator = settings.ag_rss_generator;
		feedStruct.copyright = settings.ag_rss_copyright;
		if( len( settings.ag_rss_webmaster ) ) {
			feedStruct.webmaster = settings.ag_rss_webmaster;
		}
		feedStruct.pubDate = now();
		feedStruct.lastBuildDate = now();
		feedStruct.link = helper.linkPortal();
		feedStruct.items = items;

		// Return the generated the feed
		return feedGenerator.createFeed( feedStruct );

	}

}