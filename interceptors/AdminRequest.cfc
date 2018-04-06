component extends="coldbox.system.Interceptor" {

	property name="html" inject="HTMLHelper@coldbox";
	property name="settingService" inject="settingService@aggregator";
	property name="helper" inject="helper@aggregator";

	function preProcess( event, interceptData, rc, prc ) eventPattern="^contentbox-admin"  {

		// Helper
		prc.agHelper = helper;

		// Settings
		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		// Portal entry point
		prc.agEntryPoint = prc.agSettings.ag_portal_entrypoint;

		// Admin entry point
		prc.agAdminEntryPoint = "#getModuleConfig('contentbox-admin').entryPoint#.module.#getModuleConfig('contentbox-rss-aggregator').entryPoint#";

		// Feeds
		prc.xehFeeds = "#prc.agAdminEntryPoint#.feeds";
		prc.xehFeedSearch = "#prc.agAdminEntryPoint#.feeds";
		prc.xehFeedTable = "#prc.agAdminEntryPoint#.feeds.table";
		prc.xehFeedStatus = "#prc.agAdminEntryPoint#.feeds.updateStatus";
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
		prc.xehFeedItemStatus = "#prc.agAdminEntryPoint#.feeditems.updateStatus";
		prc.xehFeedItemEditor = "#prc.agAdminEntryPoint#.feeditems.editor";
		prc.xehFeedItemSave = "#prc.agAdminEntryPoint#.feeditems.save";
		prc.xehFeedItemRemove = "#prc.agAdminEntryPoint#.feeditems.remove";
		prc.xehFeedItemResetHits = "#prc.agAdminEntryPoint#.feeditems.resetHits";

		// Settings
		prc.xehAggregatorSettings = "#prc.agAdminEntryPoint#.settings";
		prc.xehAggregatorSettingsSave = "#prc.agAdminEntryPoint#.settings.save";

	}

	function postRender( event, interceptData, buffer, rc, prc ) eventPattern="^contentbox-admin" {

		// Add portal link and create feed to nav bar
		if ( !event.isAjax() ) {
			html.$htmlhead( "<script>$(function() {$('div.user-nav ul li').first().after('<li data-placement=""right auto"" title=""Visit Portal""><a class=""btn btn-default options toggle"" href=""#helper.linkPortal()#"" target=""_blank""><i class=""fa fa-newspaper-o""></i></a></li>');});</script>" );
			if ( prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN,FEEDS_EDITOR" ) ) {
				html.$htmlhead( "<script>$(function() {$('div.user-nav ul.dropdown-menu').first().append('<li><a data-keybinding=""ctrl+shift+f"" href=""#helper.linkFeedForm()#"" title=""ctrl+shift+f""><i class=""fa fa-rss""></i> New Feed</a></li>');});</script>" );
			}
		}

	}

}