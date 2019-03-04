/**
 * ContentBox RSS Aggregator
 * Global HTML interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="agHelper" inject="helper@aggregator";

	/**
	 * Fired before portal index display
	 */
	function aggregator_preIndexDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).ag_html_pre_index_display );
	}

	/**
	 * Fired after portal index display
	 */
	function aggregator_postIndexDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).ag_html_post_index_display );
	}

	/**
	 * Fired before feeds display
	 */
	function aggregator_preFeedsDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).ag_html_pre_feeds_display );
	}

	/**
	 * Fired after feeds display
	 */
	function aggregator_postFeedsDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).ag_html_post_feeds_display );
	}

	/**
	 * Fired before feed display
	 */
	function aggregator_preFeedDisplay( event, interceptData, buffer ) {
		var feed = arguments.interceptData.feed;
		var html = len( feed.getPreFeedDisplay() ) ? feed.getPreFeedDisplay() : getSettings( event ).ag_html_pre_feed_display;
		arguments.buffer.append( parseFeedTokens( feed, html ) );
	}

	/**
	 * Fired after feed display
	 */
	function aggregator_postFeedDisplay( event, interceptData, buffer ) {
		var feed = arguments.interceptData.feed;
		var html = len( feed.getPostFeedDisplay() ) ? feed.getPostFeedDisplay() : getSettings( event ).ag_html_post_feed_display;
		arguments.buffer.append( parseFeedTokens( feed, html ) );
	}

	/**
	 * Fired before feed item display
	 */
	function aggregator_preFeedItemDisplay( event, interceptData, buffer ) {
		var feedItem = arguments.interceptData.feedItem;
		var html = len( feedItem.getFeed().getPreFeedItemDisplay() ) ? feedItem.getFeed().getPreFeedItemDisplay() : getSettings( event ).ag_html_pre_feeditem_display;
		arguments.buffer.append( parseFeedItemTokens( feedItem, html ) );
	}

	/**
	 * Fired after feeed item display
	 */
	function aggregator_postFeedItemDisplay( event, interceptData, buffer ) {
		var feedItem = arguments.interceptData.feedItem;
		var html = len( feedItem.getFeed().getPostFeedItemDisplay() ) ? feedItem.getFeed().getPostFeedItemDisplay() : getSettings( event ).ag_html_post_feeditem_display;
		arguments.buffer.append( parseFeedItemTokens( feedItem, html ) );
	}

	/**
	 * Fired before archives display
	 */
	function aggregator_preArchivesDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).ag_html_pre_archives_display );
	}

	/**
	 * Fired after archives display
	 */
	function aggregator_postArchivesDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).ag_html_post_archives_display );
	}

	/**
	 * Fired before sidebar display
	 */
	function aggregator_preSideBarDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).ag_html_pre_sidebar_display );
	}

	/**
	 * Fired after sidebar display
	 */
	function aggregator_postSideBarDisplay( event, interceptData, buffer ) {
		arguments.buffer.append( getSettings( event ).ag_html_post_sidebar_display );
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Grabs the aggregator settings
	 * @return The aggregator settings
	 */
	private struct function getSettings( event ) {
		return event.getValue( name="agSettings", private=true );
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