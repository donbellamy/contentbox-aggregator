component extends="coldbox.system.EventHandler" {

	property name="settingService" inject="settingService@cb";
	property name="cbMessagebox" inject="messagebox@cbmessagebox";
	property name="cbHelper" inject="cbHelper@cb";

	function preHandler( event, rc, prc, action, eventArguments ) {

		prc.cbHelper = cbHelper;

		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		prc.agAdminEntryPoint = "#prc.cbAdminEntryPoint#.module.#getModuleConfig('contentbox-aggregator').entryPoint#";

		prc.xehAgFeeds = "#prc.agAdminEntryPoint#.feeds";
		prc.xehAgFeedForm = "#prc.agAdminEntryPoint#.feeds.form";
		prc.xehAgFeedSave = "#prc.agAdminEntryPoint#.feeds.save";

		prc.xehAgFeedItems = "#prc.agAdminEntryPoint#.items";

		prc.xehAgImportExport = "#prc.agAdminEntryPoint#.import-export";

		prc.xehAgSettings = "#prc.agAdminEntryPoint#.settings";
		prc.xehAgSettingsSave = "#prc.agAdminEntryPoint#.settings.save";

	}

}