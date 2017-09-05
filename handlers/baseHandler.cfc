component extends="coldbox.system.EventHandler" {

	property name="settingService" inject="settingService@cb";
	property name="cbMessagebox" inject="messagebox@cbmessagebox";
	property name="cbHelper" inject="cbHelper@cb";
	property name="agHelper" inject="helper@aggregator";

	function preHandler( event, rc, prc, action, eventArguments ) {

		prc.cbHelper = cbHelper;
		prc.agHelper = agHelper;

		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		prc.agAdminEntryPoint = "#prc.cbAdminEntryPoint#.module.#getModuleConfig('contentbox-aggregator').entryPoint#";

		prc.xehFeeds = "#prc.agAdminEntryPoint#.feeds";
		prc.xehFeedEditor = "#prc.agAdminEntryPoint#.feeds.editor";
		prc.xehFeedSave = "#prc.agAdminEntryPoint#.feeds.save";

		prc.xehFeedItems = "#prc.agAdminEntryPoint#.items";

		prc.xehImportExport = "#prc.agAdminEntryPoint#.import-export";
		
		prc.xehSettings = "#prc.agAdminEntryPoint#.settings";
		prc.xehSettingsSave = "#prc.agAdminEntryPoint#.settings.save";

	}

}