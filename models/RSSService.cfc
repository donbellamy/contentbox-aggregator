component singleton {

	property name="cachebox" inject="cachebox";
	property name="feedGenerator" inject="feedGenerator@cbfeeds";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="helper" inject="helper@aggregator";
	property name="settingService" inject="settingService@cb";

	RSSService function init() {
		return this;
	}

	string function getRSS( string category="", string slug="" ) {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var cache = cacheBox.getCache( settings.ag_rss_cache_name );
		var cacheKey = "cb-feeds-aggregator-#cgi.http_host#-#hash( arguments.category & arguments.slug & "FeedItem" )#";
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

	private string function buildFeed( string category="", string slug="" ) {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting("aggregator") );
		var feedStruct = {};

		// Get results
		var results = feedItemService.getPublishedFeedItems(
			category=arguments.category,
			feed=arguments.slug,
			max=settings.ag_rss_max_items
		);
		var feedItems = results.feedItems;
		var items = queryNew("title,description,content_encoded,link,pubDate,dcmiterm_creator,category_tag,guid_permalink,guid_string,source_title,source_url");

		// Build the items query
		for ( var item IN feedItems ) {
			queryAddRow( items, 1 );
			querySetCell( items, "title", item.getTitle() );
			var description = item.getContentExcerpt();
			if ( item.hasExcerpt() ) {
				description = item.renderExcerpt();
			}
			querySetCell( items, "description", "<![CDATA[" & description & "]]>" );
			if ( settings.ag_rss_content_enable ) {
				querySetCell( items, "content_encoded", "<![CDATA[" & item.renderContent() & "]]>" );
			}
			querySetCell( items, "link", helper.linkFeedItem( item ) );
			querySetCell( items, "pubDate", item.getPublishedDate() );
			querySetCell( items, "dcmiterm_creator", "<![CDATA[" & item.getItemAuthor() & "]]>" );
			if ( item.hasCategories() ) {
				querySetCell( items, "category_tag", item.getCategoriesList() );
			}
			querySetCell( items, "guid_permalink", false );
			querySetCell( items, "guid_string", helper.linkFeedItem( item ) );
			querySetCell( items, "source_title", item.getFeed().getTitle() );
			querySetCell( items, "source_url", item.getFeed().getFeedUrl() );
		}

		// Populate the feedStruct
		if ( len( arguments.slug ) ) {
			var feed = feedService.findBySlug( arguments.slug );
			feedStruct.title = feed.getTitle();
			feedStruct.description = feed.getTagLine();
			feedStruct.link = helper.linkFeed( feed );
		} else {
			feedStruct.title = settings.ag_rss_title;
			feedStruct.description = settings.ag_rss_description;
			feedStruct.link = helper.linkPortal();
		}
		feedStruct.generator = settings.ag_rss_generator;
		feedStruct.copyright = settings.ag_rss_copyright;
		if ( len( settings.ag_rss_webmaster ) ) {
			feedStruct.webmaster = settings.ag_rss_webmaster;
		}
		feedStruct.pubDate = now();
		feedStruct.lastBuildDate = now();

		feedStruct.items = items;

		// Return the generated the feed
		return feedGenerator.createFeed( feedStruct );

	}

}