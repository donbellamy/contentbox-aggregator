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
		appendToBuffer( getSettings( event ).ag_html_pre_feed_display );
	}

	function aggregator_postFeedDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_post_feed_display );
	}

	function aggregator_preFeedItemDisplay( event, interceptData ) {
		var feedItem = arguments.interceptData.feedItem;
		var html = len( feedItem.getFeed().getHtmlPrepend() ) ? feedItem.getFeed().getHtmlPrepend() : getSettings( event ).ag_html_pre_feeditem_display;
		appendToBuffer( parseTokens( feedItem, html ) );
	}

	function aggregator_postFeedItemDisplay( event, interceptData ) {
		var feedItem = arguments.interceptData.feedItem;
		var html = len( feedItem.getFeed().getHtmlAppend() ) ? feedItem.getFeed().getHtmlAppend() : getSettings( event ).ag_html_post_feeditem_display;
		appendToBuffer( parseTokens( feedItem, html ) );
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

	private function parseTokens( required FeedItem feedItem, required string html ) {

		// Set vars
		var feed = arguments.feedItem.getFeed();
		var tokenMarker = "@";
		var tokens = {
			"feed_title" = feed.getTitle(),
			"feed_url" = helper.linkFeed( feed ),
			"feed_rss_url" = feed.getFeedUrl(),
			"site_url" = feed.getSiteUrl(),
			"feed_item_title" = arguments.feedItem.getTitle(),
			"feed_item_url" = helper.linkFeedItem( arguments.feedItem ),
			"feed_item_original_url" = arguments.feedItem.getItemUrl(),
			"feed_item_import_date" = arguments.feedItem.getDisplayCreatedDate(),
			"feed_item_publish_date" = arguments.feedItem.getDisplayPublishedDate(),
			"feed_item_author_name" = arguments.feedItem.getItemAuthor()
		};

		// Search and replace tokens
		for ( var key IN tokens ) {
			arguments.html = replaceNoCase(  arguments.html, "#tokenMarker##key##tokenMarker#", tokens[key], "ALL" );
		}

		// Return updated html
		return arguments.html;

	}

}