component extends="coldbox.system.Interceptor" {

	property name="settingService" inject="settingService@cb";
	property name="feedService" inject="feedService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";

	function agadmin_postFeedImport( event, interceptData ) {

		// Remove filtered items
		// Remove outdated items

	}

	function agadmin_postFeedSave( event, interceptData ) {

		// Remove filtered items
		// Remove outdated items

	}

	function agadmin_postSettingsSave( event, interceptData ) {

		// Remove filtered items
		// Remove outdated items

	}

}