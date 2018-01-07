component extends="coldbox.system.Interceptor" {

	property name="settingService" inject="settingService@aggregator";
	property name="cbHelper" inject="CBHelper@cb";

	function configure() {}

	function preProcess( event, interceptData, rc, prc ) eventPattern="^contentbox-rss-aggregator:portal" {

		// Prepare UI Request
		CBHelper.prepareUIRequest();

		// Settings
		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		// Entry points

	}

}