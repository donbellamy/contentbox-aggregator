/**
 * ContentBox Aggregator
 * RSS Service
 * @author Don Bellamy <don@perfectcode.com>
 */
component singleton {

	// Dependencies
	property name="cachebox" inject="cachebox";
	property name="feedGenerator" inject="feedGenerator@cbfeeds";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="settingService" inject="settingService@cb";
	property name="agHelper" inject="helper@aggregator";
	property name="cbHelper" inject="cbHelper@cb";

	/**
	 * Constructor
	 * @return RSSServicce
	 */
	RSSService function init() {
		return this;
	}

	/**
	 * Gets the feed items feed from cache or build
	 * @slug The feed slug to filter on
	 * @category The category slug to filter on
	 * @contentType The content type to build the rss feed on
	 * @return The feed xml string
	 */
	string function getRSS(
		string slug="",
		string category="",
		string contentType="FeedItem" ) {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var cache = cacheBox.getCache( settings.rss_cache_name );
		var cacheKey = "cb-feeds-aggregator-#cgi.http_host#-#hash( arguments.category & arguments.slug & arguments.contentType )#";
		var rssFeed = "";

		// Check cache
		if ( settings.rss_cache_enable ) {
			rssFeed = cache.get( cacheKey );
			if ( !isNull( rssFeed ) ) {
				return rssFeed;
			}
		}

		// Build the feed
		if ( arguments.contentType == "Feed" ) {
			rssFeed = buildFeedFeed( argumentCollection=arguments );
		} else {
			rssFeed = buildFeedItemFeed( argumentCollection=arguments );
		}

		// Cache the feed
		if ( settings.rss_cache_enable ) {
			cache.set( cacheKey, rssFeed, settings.rss_cache_timeout, settings.rss_cache_idle_timeout );
		}

		return rssFeed;

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Builds the feed items feed
	 * @slug The feed slug to filter on
	 * @category The category slug to filter on
	 * @return The feed xml string
	 */
	private string function buildFeedItemFeed(
		string slug="",
		string category="" ) {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var feedStruct = {};

		// Get results
		var results = feedItemService.getPublishedFeedItems(
			category=arguments.category,
			feed=arguments.slug,
			max=settings.rss_max_feed_items,
			includeEntries=settings.feed_items_include_entries
		);
		var feedItems = results.feedItems;
		var items = queryNew("title,description,content_encoded,link,pubDate,dcmiterm_creator,category_tag,guid_permalink,guid_string,source_title,source_url,enclosure_url,enclosure_length,enclosure_type");

		// Build the items query
		for ( var item IN feedItems ) {
			queryAddRow( items, 1 );
			querySetCell( items, "title", "<![CDATA[" & item.getTitle() & "]]>" );
			var description = "";
			if ( item.hasExcerpt() ) {
				description = item.renderExcerpt();
			} else if ( item.getContentType() == "FeedItem"  ) {
				description = item.getContentExcerpt();
			}
			if ( len( description ) ) {
				querySetCell( items, "description", "<![CDATA[" & description & "]]>" );
			}
			if ( settings.rss_content_enable ) {
				querySetCell( items, "content_encoded", "<![CDATA[" & item.renderContent() & "]]>" );
			}
			querySetCell( items, "link", agHelper.linkContent( item ) );
			querySetCell( items, "pubDate", item.getPublishedDate() );
			querySetCell( items, "dcmiterm_creator", "<![CDATA[" & ( item.getContentType() IS "FeedItem" ? item.getItemAuthor() : item.getAuthorName() ) & "]]>" );
			if ( item.hasCategories() ) {
				querySetCell( items, "category_tag", item.getCategoriesList() );
			}
			querySetCell( items, "guid_permalink", false );
			querySetCell( items, "guid_string", agHelper.linkContent( item ) );
			querySetCell( items, "source_title", item.getContentType() IS "FeedItem" ? item.getFeed().getTitle() : cbHelper.siteName() );
			querySetCell( items, "source_url", item.getContentType() IS "FeedItem" ? item.getFeed().getFeedUrl() : cbHelper.linkRSS() );
			// Enclosures
			var enclosure_url = "";
			var enclosure_length = "";
			var enclosure_type = "";
			// Featured image
			var imagePath = item.getFeaturedOrAltImage();
			var imageUrl = item.getFeaturedOrAltImageURL();
			if ( len( imageUrl ) ) {
				try {
					var image = fileopen( imagePath );
					enclosure_url = cbHelper.siteBaseURL() & replace( imageUrl, "/", "" );
					enclosure_length = listFirst( image.size, " " );
					enclosure_type = fileGetMimeType( image );
					fileClose( image );
				} catch ( any e ) {
					enclosure_url = "";
					enclosure_length = "";
					enclosure_type = "";
				}
			}
			// Attachments
			if ( item.getContentType() IS "FeedItem" && item.hasAttachment() ) {
				for ( attachment IN item.getAttachments() ) {
					if ( len( attachment.getSize() ) && len( attachment.getMimeType() ) &&
						isValid( "url", attachment.getAttachmentUrl() ) &&
						!listFind( enclosure_url, attachment.getAttachmentUrl() ) ) {
						enclosure_url = listAppend( enclosure_url, attachment.getAttachmentUrl() );
						enclosure_length = listAppend( enclosure_length, attachment.getSize() );
						enclosure_type = listAppend( enclosure_type, attachment.getMimeType() );
					}
				}
			}
			// Set enclosure values
			querySetCell( items, "enclosure_url", enclosure_url );
			querySetCell( items, "enclosure_length", enclosure_length );
			querySetCell( items, "enclosure_type", enclosure_type );
		}

		// Populate the feedStruct
		if ( len( arguments.slug ) ) {
			var feed = feedService.findBySlug( arguments.slug );
			feedStruct.title = feed.getTitle();
			feedStruct.description = feed.getTagLine();
			feedStruct.link = agHelper.linkFeed( feed );
			// Featured image
			var imageUrl = feed.getFeaturedOrAltImageURL();
			if ( len( imageUrl ) ) {
				feedStruct.image = {
					"url" = cbHelper.siteBaseURL() & replace( imageUrl, "/", "" ),
					"title" = feed.getTitle(),
					"link" = agHelper.linkFeed( feed )
				};
			}
		} else {
			feedStruct.title = settings.rss_title;
			feedStruct.description = settings.rss_description;
			feedStruct.link = cbHelper.linkHome();
		}
		feedStruct.generator = settings.rss_generator;
		feedStruct.copyright = settings.rss_copyright;
		if ( len( settings.rss_webmaster ) ) {
			feedStruct.webmaster = settings.rss_webmaster;
		}
		feedStruct.pubDate = now();
		feedStruct.lastBuildDate = now();
		feedStruct.items = items;

		// Return the generated feed
		return feedGenerator.createFeed( feedStruct );

	}

	/**
	 * Builds the feeds feed
	 * @category The category slug to filter on
	 * @return The feed xml string
	 */
	private string function buildFeedFeed( string category="" ) {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var feedStruct = {};

		// Get results
		var results = feedService.getPublishedFeeds(
			category=arguments.category,
			max=settings.rss_max_feeds
		);
		var feeds = results.feeds;
		var items = queryNew("title,description,content_encoded,link,pubDate,dcmiterm_creator,category_tag,guid_permalink,guid_string,source_title,source_url,enclosure_url,enclosure_length,enclosure_type");

		// Build the items query
		for ( var item IN feeds ) {
			queryAddRow( items, 1 );
			querySetCell( items, "title", item.getTitle() );
			querySetCell( items, "link", agHelper.linkContent( item ) );
			querySetCell( items, "pubDate", item.getPublishedDate() );
			if ( item.hasCategories() ) {
				querySetCell( items, "category_tag", item.getCategoriesList() );
			}
			querySetCell( items, "guid_permalink", false );
			querySetCell( items, "guid_string", agHelper.linkFeed( item ) );
			// Featured image
			var imagePath = item.getFeaturedOrAltImage();
			var imageUrl = item.getFeaturedOrAltImageURL();
			if ( len( imageUrl ) ) {
				try {
					var image = fileopen( imagePath );
					querySetCell( items, "enclosure_url", cbHelper.siteBaseURL() & replace( imageUrl, "/", "" ) );
					querySetCell( items, "enclosure_length", listFirst( image.size, " " ) );
					querySetCell( items, "enclosure_type", fileGetMimeType( image ) );
					fileClose( image );
				} catch ( any e ) {
					querySetCell( items, "enclosure_url", "" );
					querySetCell( items, "enclosure_length", "" );
					querySetCell( items, "enclosure_type", "" );
				 }
			}
		}

		// Populate the feedStruct
		feedStruct.title = settings.rss_title;
		feedStruct.description = settings.rss_description;
		feedStruct.link = cbHelper.linkHome();
		feedStruct.generator = settings.rss_generator;
		feedStruct.copyright = settings.rss_copyright;
		if ( len( settings.rss_webmaster ) ) {
			feedStruct.webmaster = settings.rss_webmaster;
		}
		feedStruct.pubDate = now();
		feedStruct.lastBuildDate = now();
		feedStruct.items = items;

		// Return the generated feed
		return feedGenerator.createFeed( feedStruct );

	}

}