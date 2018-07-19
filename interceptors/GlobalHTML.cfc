component extends="coldbox.system.Interceptor" {

	property name="helper" inject="helper@aggregator";

	function aggregator_preIndexDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_pre_index_display );
	}

	function aggregator_postIndexDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_post_index_display );
	}

	function aggregator_preFeedsDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_pre_feeds_display );
	}

	function aggregator_postFeedsDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_post_feeds_display );
	}

	function aggregator_preFeedDisplay( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		var html = len( feed.getPreFeedDisplay() ) ? feed.getPreFeedDisplay() : getSettings( event ).ag_html_pre_feed_display;
		appendToBuffer( parseFeedTokens( feed, html ) );
	}

	function aggregator_postFeedDisplay( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		var html = len( feed.getPostFeedDisplay() ) ? feed.getPostFeedDisplay() : getSettings( event ).ag_html_post_feed_display;
		appendToBuffer( parseFeedTokens( feed, html ) );
	}

	function aggregator_preFeedItemDisplay( event, interceptData ) {
		var feedItem = arguments.interceptData.feedItem;
		var html = len( feedItem.getFeed().getPreFeedItemDisplay() ) ? feedItem.getFeed().getPreFeedItemDisplay() : getSettings( event ).ag_html_pre_feeditem_display;
		appendToBuffer( parseFeedItemTokens( feedItem, html ) );
	}

	function aggregator_postFeedItemDisplay( event, interceptData ) {
		var feedItem = arguments.interceptData.feedItem;
		var html = len( feedItem.getFeed().getPostFeedItemDisplay() ) ? feedItem.getFeed().getPostFeedItemDisplay() : getSettings( event ).ag_html_post_feeditem_display;
		appendToBuffer( parseFeedItemTokens( feedItem, html ) );
	}

	function aggregator_preArchivesDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_pre_archives_display );
	}

	function aggregator_postArchivesDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_post_archives_display );
	}

	function aggregator_preSideBarDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_pre_sidebar_display );
	}

	function aggregator_postSideBarDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_post_sidebar_display );
	}

	/************************************** PRIVATE *********************************************/

	private function getSettings( event ) {
		return event.getValue( name="agSettings", private=true );
	}

	private function parseFeedTokens( required Feed feed, required string html ) {

		// Set vars
		var tokenMarker = "@";
		var tokens = {
			"feed_title" = arguments.feed.getTitle(),
			"feed_url" = helper.linkFeed( arguments.feed ),
			"feed_rss_url" = arguments.feed.getFeedUrl(),
			"feed_site_url" = arguments.feed.getSiteUrl()
		};

		// Search and replace tokens
		for ( var key IN tokens ) {
			arguments.html = replaceNoCase( arguments.html, "#tokenMarker##key##tokenMarker#", tokens[key], "ALL" );
		}

		// Return updated html
		return arguments.html;

	}

	private function parseFeedItemTokens( required FeedItem feedItem, required string html ) {

		// Set vars
		var tokenMarker = "@";
		var tokens = {
			"feed_item_title" = arguments.feedItem.getTitle(),
			"feed_item_url" = helper.linkFeedItem( arguments.feedItem ),
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