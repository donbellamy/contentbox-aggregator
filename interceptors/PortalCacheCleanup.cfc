component extends="coldbox.system.Interceptor" {

	property name="cachebox" inject="cachebox";
	property name="settingService" inject="settingService@aggregator";

	function aggregator_postFeedSave( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		//doCacheCleanup( feed.buildContentCacheKey(), feed );
	}

	function aggregator_postFeedItemSave( event, interceptData ) {
		var feedItem = arguments.interceptData.feedItem;
		//doCacheCleanup( feedItem.buildContentCacheKey(), feedItem );
	}

	function aggregator_preFeedRemove( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		//doCacheCleanup( feed.buildContentCacheKey(), feed );
	}

	function aggregator_preFeedItemRemove( event, interceptData ) {
		var feedItem = arguments.interceptData.feedItem;
		//doCacheCleanup( feedItem.buildContentCacheKey(), feedItem );
	}

	private function doCacheCleanup() {}

}