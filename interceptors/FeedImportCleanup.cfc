component extends="coldbox.system.Interceptor" {

	property name="settingService" inject="settingService@aggregator";
	property name="feedService" inject="feedService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";

	function aggregator_postFeedImport( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		doFeedImportCleanup( feed );
	}

	function aggregator_postSettingsSave( event, interceptData ) {
		doFeedImportCleanup();
	}

	/************************************** PRIVATE *********************************************/

	private function doFeedImportCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var item IN feeds ) {
			var maxFeedImports = val( settings.ag_importing_max_feed_imports );
			var feedImports = item.getFeedImports();
			if ( maxFeedImports && ( arrayLen( feedImports ) GT maxFeedImports ) ) {
				var importsToDelete = arraySlice( feedImports, maxFeedImports + 1 );
				for ( var feedImport IN importsToDelete ) {
					var feedImportID = feedImport.getFeedImportID();
					feedImportService.deleteByID( feedImportID );
					if ( log.canInfo() ) {
						log.info("Feed import ('#feedImportID#') deleted for feed '#item.getTitle()#' using general setting for 'Import history limit'.");
					}
				}
			}
		}

	}

}