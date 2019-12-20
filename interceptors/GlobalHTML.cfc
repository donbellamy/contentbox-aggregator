/**
 * ContentBox Aggregator
 * Global HTML interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="agHelper" inject="helper@aggregator";

	/**
	 * Fired before feed items display
	 */
	function aggregator_preFeedItemsDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).html_pre_feed_items_display );
	}

	/**
	 * Fired after feed items display
	 */
	function aggregator_postFeedItemsDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).html_post_feed_items_display );
	}

	/**
	 * Fired before feeds display
	 */
	function aggregator_preFeedsDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).html_pre_feeds_display );
	}

	/**
	 * Fired after feeds display
	 */
	function aggregator_postFeedsDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).html_post_feeds_display );
	}

	/**
	 * Fired before feed display
	 */
	function aggregator_preFeedDisplay( event, interceptData, buffer ) {
		var feed = arguments.interceptData.feed;
		var html = len( feed.getSetting( "html_pre_feed_display", "" ) ) ? feed.getSetting( "html_pre_feed_display", "" ) : getSettings( event ).html_pre_feed_display;
		arguments.buffer.append( parseFeedTokens( feed, html ) );
	}

	/**
	 * Fired after feed display
	 */
	function aggregator_postFeedDisplay( event, interceptData, buffer ) {
		var feed = arguments.interceptData.feed;
		var html = len( feed.getSetting( "html_post_feed_display", "" ) ) ? feed.getSetting( "html_post_feed_display", "" ) : getSettings( event ).html_post_feed_display;
		arguments.buffer.append( parseFeedTokens( feed, html ) );
	}

	/**
	 * Fired before feed item display
	 */
	function aggregator_preFeedItemDisplay( event, interceptData, buffer ) {
		var feedItem = arguments.interceptData.feedItem;
		var html = len( feedItem.getFeed().getSetting( "html_pre_feeditem_display", "" ) ) ? feedItem.getFeed().getSetting( "html_pre_feeditem_display", "" ) : getSettings( event ).html_pre_feeditem_display;
		arguments.buffer.append( parseFeedItemTokens( feedItem, html ) );
	}

	/**
	 * Fired after feeed item display
	 */
	function aggregator_postFeedItemDisplay( event, interceptData, buffer ) {
		var feedItem = arguments.interceptData.feedItem;
		var html = len( feedItem.getFeed().getSetting( "html_post_feeditem_display", "" ) ) ? feedItem.getFeed().getSetting( "html_post_feeditem_display", "" ) : getSettings( event ).html_post_feeditem_display;
		arguments.buffer.append( parseFeedItemTokens( feedItem, html ) );
	}

	/**
	 * Fired before archives display
	 */
	function aggregator_preArchivesDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).html_pre_archives_display );
	}

	/**
	 * Fired after archives display
	 */
	function aggregator_postArchivesDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).html_post_archives_display );
	}

	/**
	 * Fired before sidebar display
	 */
	function aggregator_preSideBarDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).html_pre_sidebar_display );
	}

	/**
	 * Fired after sidebar display
	 */
	function aggregator_postSideBarDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).html_post_sidebar_display );
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Grabs the aggregator settings
	 * @return The aggregator settings
	 */
	private struct function getSettings( event ) {
		return event.getValue( name = "agSettings", private = true );
	}

	/**
	 * Parses the feed tokens
	 * @feed The feed to use
	 * @html The html to parse
	 * @return The parsed html
	 */
	private string function parseFeedTokens( required Feed feed, required string html ) {

		// Set vars
		var tokenMarker = "@";
		var tokens = {
			"feed_title" = arguments.feed.getTitle(),
			"feed_url" = agHelper.linkFeed( arguments.feed ),
			"feed_rss_url" = arguments.feed.getFeedUrl(),
			"feed_website_url" = arguments.feed.getWebsiteUrl()
		};

		// Search and replace tokens
		for ( var key IN tokens ) {
			arguments.html = replaceNoCase( arguments.html, "#tokenMarker##key##tokenMarker#", tokens[key], "ALL" );
		}

		// Return updated html
		return arguments.html;

	}

	/**
	 * Parses the feed item tokens
	 * @feedItem The feed item to use
	 * @html The html to parse
	 * @return The parsed html
	 */
	private string function parseFeedItemTokens( required FeedItem feedItem, required string html ) {

		// Set vars
		var tokenMarker = "@";
		var tokens = {
			"feed_item_title" = arguments.feedItem.getTitle(),
			"feed_item_url" = agHelper.linkFeedItem( arguments.feedItem ),
			"feed_item_original_url" = arguments.feedItem.getItemUrl(),
			"feed_item_import_date" = arguments.feedItem.getDisplayCreatedDate(),
			"feed_item_publish_date" = arguments.feedItem.getDisplayPublishedDate(),
			"feed_item_author_name" = arguments.feedItem.getItemAuthor()
		};

		// Search and replace tokens
		for ( var key IN tokens ) {
			arguments.html = replaceNoCase( arguments.html, "#tokenMarker##key##tokenMarker#", tokens[key], "ALL" );
		}

		// Parse feed tokens
		arguments.html = parseFeedTokens( arguments.feedItem.getFeed(), arguments.html );

		// Return updated html
		return arguments.html;

	}

}