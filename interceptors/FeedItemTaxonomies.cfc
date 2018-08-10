component extends="coldbox.system.Interceptor" {

	function aggregator_postFeedImport( event, interceptData ) {
		var feed = arguments.interceptData.feed;
	}

	function aggregator_postFeedSave( event, interceptData ) {
		var feed = arguments.interceptData.feed;
	}

	function aggregator_postSettingsSave( event, interceptData ) {

	}

}