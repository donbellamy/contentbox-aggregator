component extends="coldbox.system.Interceptor" {

	property name="cachebox" inject="cachebox";
	property name="contentService" inject="contentService@cb";
	property name="settingService" inject="settingService@cb";

	function aggregator_postFeedSave( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_postFeedRemove( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_onFeedStatusUpdate( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_postFeedItemSave( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_postFeedItemRemove( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_onFeedItemStatusUpdate( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_postFeedImports( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_postSettingsSave( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_onClearCache( event, interceptData ) {
		doCacheCleanup();
	}

	/************************************** PRIVATE *********************************************/

	private function doCacheCleanup() {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var cache = cacheBox.getCache( settings.ag_rss_cache_name );
		var cacheKey = "cb-content-aggregator";

		// Clear portal cache
		cache.clearByKeySnippet( keySnippet=cacheKey, async=false );

		// Clear content caches
		contentService.clearAllCaches();

		return this;

	}

}