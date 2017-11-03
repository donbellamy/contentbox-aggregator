component extends="coldbox.system.EventHandler" {

	property name="settingService" inject="settingService@cb";
	property name="cbMessageBox" inject="messagebox@cbmessagebox";
	property name="cbHelper" inject="cbHelper@cb";
	property name="agHelper" inject="helper@aggregator";

	// TODO: rename to baseAdminHandler ?  That way we can move a lot of common things here that wont be used on public side of things
	// TODO: baseContentHandler ?  Move stuff like slugunique, slugify, defaulteditor, etc... to it

	function preHandler( event, rc, prc, action, eventArguments ) {

		prc.cbHelper = cbHelper;
		prc.agHelper = agHelper;

		// TODO: Move to interceptor?
		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		prc.agAdminEntryPoint = "#prc.cbAdminEntryPoint#.module.#getModuleConfig('contentbox-aggregator').entryPoint#";

		// TODO: Move to interceptor like cbadmin?  a reason to do so?

		// Feeds
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

		// Feeditems
		prc.xehFeedItems = "#prc.agAdminEntryPoint#.feeditems";
		prc.xehFeedItemSearch = "#prc.agAdminEntryPoint#.feeditems";
		prc.xehFeedItemTable = "#prc.agAdminEntryPoint#.feeditems.table";
		prc.xehFeedItemStatus = "#prc.agAdminEntryPoint#.feeditems.status";
		prc.xehFeedItemEditor = "#prc.agAdminEntryPoint#.feeditems.editor";
		prc.xehFeedItemSave = "#prc.agAdminEntryPoint#.feeditems.save";
		prc.xehFeedItemRemove = "#prc.agAdminEntryPoint#.feeditems.remove";
		prc.xehFeedItemResetHits = "#prc.agAdminEntryPoint#.feeditems.resetHits";

		prc.xehImportExport = "#prc.agAdminEntryPoint#.importexport";

		prc.xehSettings = "#prc.agAdminEntryPoint#.settings";
		prc.xehSettingsSave = "#prc.agAdminEntryPoint#.settings.save";

	}

	// TODO: Move to baseAdminHandler ?  Or use cbadmins?
	private function getUserDefaultEditor( required author ) {

		var userEditor = arguments.author.getPreference( "editor", editorService.getDefaultEditor() );

		if ( editorService.hasEditor( userEditor ) ) {
			return userEditor;
		}

		arguments.author.setPreference( "editor", editorService.getDefaultEditor() );
		authorService.save( arguments.author );

		return editorService.getDefaultEditor();

	}

}