component extends="coldbox.system.EventHandler" {

	property name="settingService" inject="settingService@cb";
	property name="cbMessageBox" inject="messagebox@cbmessagebox";
	property name="cbHelper" inject="cbHelper@cb";
	property name="agHelper" inject="helper@aggregator";
	property name="authorService" inject="authorService@cb";

	function preHandler( event, rc, prc, action, eventArguments ) {

		prc.cbHelper = cbHelper;
		prc.agHelper = agHelper;

		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		prc.agAdminEntryPoint = "#prc.cbAdminEntryPoint#.module.#getModuleConfig('contentbox-aggregator').entryPoint#";

		prc.xehFeeds = "#prc.agAdminEntryPoint#.feeds";
		prc.xehFeedSearch = "#prc.agAdminEntryPoint#.feeds";
		prc.xehFeedTable = "#prc.agAdminEntryPoint#.feeds.table";
		prc.xehFeedStatus = "#prc.agAdminEntryPoint#.feeds.status";
		prc.xehFeedState = "#prc.agAdminEntryPoint#.feeds.state";
		prc.xehFeedEditor = "#prc.agAdminEntryPoint#.feeds.editor";
		prc.xehFeedSave = "#prc.agAdminEntryPoint#.feeds.save";
		prc.xehFeedRemove = "#prc.agAdminEntryPoint#.feeds.remove";
		prc.xehFeedImport = "#prc.agAdminEntryPoint#.feeds.import";
		prc.xehFeedResetHits = "#prc.agAdminEntryPoint#.feeds.resetHits";

		prc.xehFeedItems = "#prc.agAdminEntryPoint#.items";
		prc.xehFeedItemSearch = "#prc.agAdminEntryPoint#.items";
		prc.xehFeedItemEditor = "#prc.agAdminEntryPoint#.items.editor";

		prc.xehImportExport = "#prc.agAdminEntryPoint#.importexport";

		prc.xehSettings = "#prc.agAdminEntryPoint#.settings";
		prc.xehSettingsSave = "#prc.agAdminEntryPoint#.settings.save";

	}

}