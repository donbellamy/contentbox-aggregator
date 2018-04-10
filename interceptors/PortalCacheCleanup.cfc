component extends="coldbox.system.Interceptor" {

	property name="contentService" inject="contentService@aggregator";
	property name="settingService" inject="settingService@aggregator";

	function aggregator_postFeedSave( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_postFeedRemove( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_postFeedItemSave( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_postFeedItemRemove( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_postFeedImports( event, interceptData ) {
		doCacheCleanup();
	}

	function aggregator_postSettingsSave( event, interceptData ) {
		doCacheCleanup();
	}

	/************************************** PRIVATE *********************************************/

	private function doCacheCleanup() {

		// Clear content caches
		contentService.clearAllCaches();

		return this;

	}

}