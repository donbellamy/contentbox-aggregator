component extends="coldbox.system.Interceptor" {

	property name="cachebox" inject="cachebox";
	property name="settingService" inject="settingService@cb";
	property name="log" inject="logbox:logger:aggregator";

	function agadmin_postFeedSave( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		//doCacheCleanup( feed.buildContentCacheKey(), feed );
	}

	function agadmin_postFeedItemSave( event, interceptData ) {
		var feedItem = arguments.interceptData.feedItem;
		//doCacheCleanup( feedItem.buildContentCacheKey(), feedItem );
	}

	function agadmin_preFeedRemove( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		//doCacheCleanup( feed.buildContentCacheKey(), feed );
	}

	function agadmin_preFeedItemRemove( event, interceptData ) {
		var feedItem = arguments.interceptData.feedItem;
		//doCacheCleanup( feedItem.buildContentCacheKey(), feedItem );
	}

	private function doCacheCleanup() {}

}