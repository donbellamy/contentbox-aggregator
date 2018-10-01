/**
 * RSS cache cleanup interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="cachebox" inject="cachebox";
	property name="settingService" inject="settingService@cb";

	/**
	 * Fired after feed save
	 */
	function aggregator_postFeedSave( event, interceptData ) {
		doCacheCleanup();
	}

	/**
	 * Fired after feed delete
	 */
	function aggregator_postFeedRemove( event, interceptData ) {
		doCacheCleanup();
	}

	/**
	 * Fired after feed item save
	 */
	function aggregator_postFeedItemSave( event, interceptData ) {
		doCacheCleanup();
	}

	/**
	 * Fired after feed item delete
	 */
	function aggregator_postFeedItemRemove( event, interceptData ) {
		doCacheCleanup();
	}

	/**
	 * Fired after feed imports
	 */
	function aggregator_postFeedImports( event, interceptData ) {
		doCacheCleanup();
	}

	/**
	 * Fired after settings save
	 */
	function aggregator_postSettingsSave( event, interceptData ) {
		doCacheCleanup();
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Clears the rss cache
	 */
	private function doCacheCleanup() {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var cache = cacheBox.getCache( settings.ag_rss_cache_name );
		var cacheKey = "cb-feeds-aggregator";

		// Clear cache
		cache.clearByKeySnippet( keySnippet=cacheKey, async=false );

		return this;

	}

}