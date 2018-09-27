/**
 * Feed import cleanup interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="settingService" inject="settingService@cb";
	property name="feedService" inject="feedService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";

	/**
	 * Clean up old import records after feed import
	 */
	function aggregator_postFeedImport( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		doFeedImportCleanup( feed );
	}

	/**
	 * Clean up old import records after settings save
	 */
	function aggregator_postSettingsSave( event, interceptData ) {
		doFeedImportCleanup();
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Delete old import records based upon global setting
	 * @feed any
	 */
	private function doFeedImportCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var feed IN feeds ) {
			var maxFeedImports = val( settings.ag_importing_max_feed_imports );
			var feedImports = feed.getFeedImports();
			if ( maxFeedImports && ( arrayLen( feedImports ) GT maxFeedImports ) ) {
				var importsToDelete = arraySlice( feedImports, maxFeedImports + 1 );
				for ( var feedImport IN importsToDelete ) {
					var feedImportID = feedImport.getFeedImportID();
					feedImportService.deleteByID( feedImportID );
					if ( log.canInfo() ) {
						log.info("Feed import ('#feedImportID#') deleted for feed '#feed.getTitle()#' using general setting for 'Import history limit'.");
					}
				}
			}
		}

	}

}