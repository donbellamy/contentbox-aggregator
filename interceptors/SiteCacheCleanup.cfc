/**
 * ContentBox Aggregator
 * Site cache cleanup interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="cachebox" inject="cachebox";
	property name="contentService" inject="contentService@aggregator";
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

	/**
	 * Fired after entry save
	 */
	function cbadmin_postEntrySave( event, interceptData ) {
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		if ( settings.ag_site_feed_items_include_entries ) doCacheCleanup();
	}

	/**
	 * Fired after entry delete
	 */
	function cbadmin_postEntryRemove( event, interceptData ) {
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		if ( settings.ag_site_feed_items_include_entries ) doCacheCleanup();
	}

	/**
	 * Fired after entry status update
	 */
	function cbadmin_onEntryStatusUpdate( event, interceptData ) {
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		if ( settings.ag_site_feed_items_include_entries ) doCacheCleanup();
	}

	/**
	 * Fired after page save
	 */
	function cbadmin_postPageSave( event, interceptData ) {
		var page = arguments.interceptData.page;
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		if ( settings.ag_site_feed_items_entrypoint == page.getslug() || settings.ag_site_feeds_entryPoint == page.getslug() ) {
			doCacheCleanup();
		}
	}

	/**
	 * Fired before page delete
	 */
	function cbadmin_prePageRemove( event, interceptData ) {
		var page = arguments.interceptData.page;
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		if ( settings.ag_site_feed_items_entrypoint == page.getslug() || settings.ag_site_feeds_entryPoint == page.getslug() ) {
			doCacheCleanup();
		}
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Clears the site content cache
	 * @return SiteCacheCleanup
	 */
	private SiteCacheCleanup function doCacheCleanup() {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var cache = cacheBox.getCache( settings.ag_site_cache_name );
		var cacheKey = "cb-content-aggregator";

		// Clear site cache
		cache.clearByKeySnippet( keySnippet=cacheKey, async=false );

		// Clear content caches
		contentService.clearAllCaches();

		return this;

	}

}