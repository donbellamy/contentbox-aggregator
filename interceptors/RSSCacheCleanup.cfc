component extends="coldbox.system.Interceptor" {

	property name="rssService" inject="rssService@aggregator";

	function aggregator_postFeedSave( event, interceptData ) {
		rssService.clearCaches();
	}

	function aggregator_postFeedRemove( event, interceptData ) {
		rssService.clearCaches();
	}

	function aggregator_postFeedItemSave( event, interceptData ) {
		rssService.clearCaches();
	}

	function aggregator_postFeedItemRemove( event, interceptData ) {
		rssService.clearCaches();
	}

	function aggregator_postFeedImports( event, interceptData ) {
		rssService.clearCaches();
	}

	function aggregator_postSettingsSave( event, interceptData ) {
		rssService.clearCaches();
	}

}