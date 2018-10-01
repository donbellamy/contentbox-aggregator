/**
 * Portal cache cleanup interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="cachebox" inject="cachebox";
	property name="contentService" inject="contentService@cb";
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
	 * Fired after feed status update
	 */
	function aggregator_onFeedStatusUpdate( event, interceptData ) {
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
	 * Fired after feed item status update
	 */
	function aggregator_onFeedItemStatusUpdate( event, interceptData ) {
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

	/**
	 * Fired after clear cache
	 */
	function aggregator_onClearCache( event, interceptData ) {
		doCacheCleanup();
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Clears the portal content cache
	 */
	private function doCacheCleanup() {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var cache = cacheBox.getCache( settings.ag_portal_cache_name );
		var cacheKey = "cb-content-aggregator";

		// Clear portal cache
		cache.clearByKeySnippet( keySnippet=cacheKey, async=false );

		// Clear content caches
		contentService.clearAllCaches();

		return this;

	}

}