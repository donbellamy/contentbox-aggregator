component extends="coldbox.system.Interceptor" {

	property name="settingService" inject="settingService@cb";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";

	function agadmin_preFeedImport( event, interceptData ) {}

	function agadmin_postFeedImport( event, interceptData ) {}

}