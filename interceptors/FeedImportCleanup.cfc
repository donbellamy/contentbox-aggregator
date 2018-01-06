component extends="coldbox.system.Interceptor" {

	property name="settingService" inject="settingService@aggregator";
	property name="feedService" inject="feedService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="log" inject="logbox:logger:aggregator";

	function agadmin_postFeedImport( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		doFeedImportCleanup( feed );
	}

	function agadmin_postSettingsSave( event, interceptData ) {
		doFeedImportCleanup();
	}

	private function doFeedImportCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var item IN feeds ) {
			var maxFeedImports = val( settings.ag_general_max_feed_imports );
			var feedImports = item.getFeedImports();
			if ( maxFeedImports && arrayLen( feedImports ) GT maxFeedImports ) {
				var importsToDelete = arraySlice( feedImports, maxFeedImports + 1 );
				for ( var feedImport IN importsToDelete ) {
					var id = feedImport.getFeedImportID();
					feedImportService.delete( feedImport );
					if ( log.canInfo() ) {
						log.info("Feed import ('#id#') deleted by general setting 'Import history limit'.");
					}
				}
			}
		}

	}
}