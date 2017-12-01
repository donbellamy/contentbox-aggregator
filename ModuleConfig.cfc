component {

	this.title = "RSS Aggregator";
	this.author = "Perfect Code, LLC";
	this.webURL = "https://perfectcode.com";
	this.description = "RSS feed aggregator for ContentBox";
	this.version = "1.0.0";
	this.viewParentLookup = true;
	this.layoutParentLookup = true;
	this.entryPoint	= "aggregator";
	this.cfMapping = "aggregator";

	function configure() {

		settings = {

			// TODO: remove ag_ from names, unneeded imo
			"ag_general_import_interval" = "",
			"ag_general_import_start_date" = "",
			"ag_general_import_start_time" = "",
			"ag_general_default_creator" = "",
			"ag_general_max_age" = "",
			"ag_general_max_age_unit" = "days",
			"ag_general_max_items" = "",
			"ag_general_match_any_filter" = "",
			"ag_general_match_all_filter" = "",
			"ag_general_match_none_filter" = "",
			"ag_general_log_level" = "ERROR",
			"ag_general_log_file_name" = "aggregator",

			"ag_display_title_link" = "true",
			"ag_display_author_show" = "true",
			"ag_display_source_show" = "true",
			"ag_display_source_link" = "true",
			"ag_display_link_new_window" = "true",
			"ag_display_link_as_nofollow" = "true",
			"ag_display_video_link" = "true",

			"ag_display_excerpt_show" = "true",
			"ag_display_excerpt_word_limit" = "",
			"ag_display_excerpt_ending" = "...",
			"ag_display_read_more_show" = "true",
			"ag_display_read_more_text" = "Read more...",

			"ag_display_thumbnail_enable" = "true",
			"ag_display_thumbnail_link" = "true",
			"ag_display_thumbnail_width" = "150",
			"ag_display_thumbnail_height" = "150",

			"ag_display_paging_max_rows" = "10",
			"ag_display_paging_type" = "paging", 

			"ag_portal_enable" = "true",
			"ag_portal_title" = "RSS Aggregator News",
			"ag_portal_entrypoint" = "news",
			"ag_portal_layout" = "pages",
			"ag_portal_hits_track" = "true",
			"ag_portal_hits_ignore_bots" = "false",
			"ag_portal_hits_bot_regex" = "Google|msnbot|Rambler|Yahoo|AbachoBOT|accoona|AcioRobot|ASPSeek|CocoCrawler|Dumbot|FAST-WebCrawler|GeonaBot|Gigabot|Lycos|MSRBOT|Scooter|AltaVista|IDBot|eStyle|Scrubby", // Get setting from cb?
			"ag_portal_cache_enable" = "true",
			"ag_portal_cache_name" = "Template",
			"ag_portal_cache_timeout" = "60",
			"ag_portal_cache_timeout_idle" = "15",

			"ag_rss_enable" = "true",
			"ag_rss_title" = "RSS Aggregator Feed",
			"ag_rss_description" = "RSS Aggregator Feed",
			"ag_rss_generator" = "RSS Aggregator by Perfect Code",
			"ag_rss_copyright" = "Perfect Code, LCC (perfectcode.com)",
			"ag_rss_webmaster" = "",
			"ag_rss_max_items" = "10",
			"ag_rss_cache_enable" = "true",
			"ag_rss_cache_name" = "Template",
			"ag_rss_cache_timeout" = "60",
			"ag_rss_cache_timeout_idle" = "15"

		};

		permissions = [ 
			{ permission="FEEDS_ADMIN", description="Ability to manage feeds", editor="false" },
			{ permission="FEEDS_EDITOR", description="Ability to manage feeds but not publish them", editor="true" },
			{ permission="FEEDS_IMPORT", description="Ability to import feeds", editor="true" },
			{ permission="FEED_ITEMS_ADMIN", description="Ability to manage feed items", editor="false" },
			{ permission="FEED_ITEMS_EDITOR", description="Ability to manage feed items but not publish them", editor="true" },
			{ permission="AGGREGATOR_SETTINGS", description="Ability to manage the rss aggregator module settings", editor="false" }
		];

		routes = [
			{ pattern="/:handler/:action?" }
		];

		aggregatorRoutes = [
			{ pattern="/feeds/:slug", handler="portal", action="feed", namespace="aggregator" },
			{ pattern="/feeds", handler="portal", action="feeds", namespace="aggregator" },
			{ pattern="/import", handler="portal", action="import", namespace="aggregator" }, // TODO: research coldboox ways to do sched tasks
			{ pattern="/:slug", handler="portal", action="item", namespace="aggregator" },
			{ pattern="/", handler="portal", action="index", namespace="aggregator" }
		];

		interceptorSettings = {
			customInterceptionPoints = arrayToList([
				"agadmin_preSettingsSave","agadmin_postSettingsSave",
				"agadmin_preFeedSave","agadmin_postFeedSave",
				"agadmin_preFeedRemove","agadmin_postFeedRemove",
				"agadmin_onFeedStatusUpdate","agadmin_onFeedStateUpdate",
				"agadmin_preFeedImport","agadmin_postFeedImport",
				"agadmin_preFeedItemSave","agadmin_postFeedItemSave",
				"agadmin_preFeedItemRemove","agadmin_postFeedItemRemove",
				"agadmin_onFeedItemStatusUpdate"
			])
		};

		interceptors = [
			{ class = "#moduleMapping#.interceptors.AdminRequest", name="adminRequest@aggregator" },
			{ class = "#moduleMapping#.interceptors.FeedItemCleanup", name="feedItemCleanup@aggregator" },
			{ class = "#moduleMapping#.interceptors.PortalCacheCleanup", name="portalCacheCleanup@aggregator" },
			{ class = "#moduleMapping#.interceptors.PortalRequest", name="portalRequest@aggregator" },
			{ class = "#moduleMapping#.interceptors.RSSCacheCleanup", name="rssCacheCleanup@aggregator" }
		];

		binder.map("feedService@aggregator").to("#moduleMapping#.models.FeedService");
		binder.map("feedItemService@aggregator").to("#moduleMapping#.models.FeedItemService");
		binder.map("feedImportService@aggregator").to("#moduleMapping#.models.FeedImportService");
		binder.map("settingService@aggregator").to("#moduleMapping#.models.SettingService");

	}

	function onLoad() {

		// Add menu items
		addMenuItems();

		// Register namespace
		registerNameSpace();

		// Configure LogBox
		configureLogBox();

	}

	function onUnload() {

		// Remove admin menu items
		var menuService = controller.getWireBox().getInstance("adminMenuService@cb");
		menuService.removeTopMenu("aggregator");

		// TODO: Unregister namespace

		// TODO: Remove logger

	}

	function onActivate() {

		// Save settings
		var settingService = controller.getWireBox().getInstance("settingService@cb");
		var setting = settingService.findWhere( criteria = { name="aggregator" } );

		if ( isNull( setting ) ) {
			var agSettings = settingService.new( properties = { name="aggregator", value=serializeJSON( settings ) } );
			settingService.save( agSettings );
		}

		settingService.flushSettingsCache();

		// Save permissions
		var permissionService = controller.getWireBox().getInstance("permissionService@cb");
		var roleService= controller.getWireBox().getInstance("roleService@cb");
		var adminRole = roleService.findWhere( criteria = { role="Administrator" } );
		var editorRole = roleService.findWhere( criteria = { role="Editor" } );

		for ( var item IN permissions ) {
			var permission = permissionService.findWhere( criteria = { permission=item["permission"] } );
			if ( isNull( permission ) ) {
				permission = permissionService.new();
				permission.setPermission( item["permission"] );
				permission.setDescription( item["description"] );
				permissionService.save( permission );
				if ( !isNull( editorRole ) && item["editor"] ) {
					editorRole.addPermission( permission );
					roleService.save( editorRole );
				}
				if ( !isNull( adminRole ) ) {
					adminRole.addPermission( permission );
					roleService.save( adminRole );
				}
			}
		}

	}

	function onDeactivate() {

		// Delete settings
		var settingService = controller.getWireBox().getInstance("settingService@cb");
		var setting = settingService.findWhere( criteria = { name="aggregator" } );

		if( !isNull( setting ) ){
			settingService.delete( setting );
		}

		settingService.flushSettingsCache();

		// Delete permissions
		var permissionService = controller.getWireBox().getInstance("permissionService@cb");

		for ( var item IN permissions ) {
			var permission = permissionService.findWhere( criteria = { permission=item["permission"] } );
			if ( !isNull( permission ) ) {
				permissionService.deletePermission( permission.getPermissionID() );
			}
		}

		// Delete scheduled task
		cfschedule( action="delete", task="aggregator-import" );
	}

	function addMenuItems() {

		var menuService = controller.getWireBox().getInstance("adminMenuService@cb");

		menuService.addTopMenu(
			name="aggregator",
			label="<i class='fa fa-rss'></i> RSS Aggregator"
		);

		menuService.addSubMenu(
			topMenu="aggregator",
			name="feeds",
			label="Feeds",
			href="#menuService.buildModuleLink('aggregator','feeds')#",
			permissions="FEEDS_ADMIN,FEEDS_EDITOR"
		);

		menuService.addSubMenu(
			topMenu="aggregator",
			name="feeditems",
			label="Feed Items",
			href="#menuService.buildModuleLink('aggregator','feeditems')#",
			permissions="FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR"
		);

		menuService.addSubMenu(
			topMenu="aggregator",
			name="settings",
			label="Settings",
			href="#menuService.buildModuleLink('aggregator','settings')#",
			permissions="AGGREGATOR_SETTINGS"
		);

	}

	function registerNameSpace() {

		var ses = controller.getInterceptorService().getInterceptor( "SES", true );
		var settingService = controller.getWireBox().getInstance( "settingService@cb" );
		var cbEntryPoint = controller.getConfigSettings().modules["contentbox-ui"].entryPoint;
		var agEntryPoint = settings.ag_portal_entrypoint;

		var setting = settingService.findWhere( criteria = { name="aggregator" } );
		if ( !isNull( setting ) ) {
			var agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );  // setting.getValue() ?
			agEntryPoint = agSettings.ag_portal_entrypoint;
		}

		if ( len( cbEntryPoint ) ) {
			ses.addNamespace( pattern="#cbEntryPoint#/#agEntryPoint#", namespace="aggregator", append=false );
		} else {
			ses.addNamespace( pattern=agEntryPoint, namespace="aggregator", append=false );
		}

		for( var x=1; x LTE arrayLen( aggregatorRoutes ); x++ ){
			var args = duplicate( aggregatorRoutes[ x ] );
			if ( structKeyExists( args, "handler" ) ) {
				args.handler = "contentbox-aggregator:#args.handler#";
			}
			ses.addRoute(argumentCollection=args);
		}

	}

	function configureLogBox() {

		var logLevel = settings.ag_general_log_level;
		var fileName = settings.ag_general_log_file_name;
		var logBox = controller.getLogBox();
		var logBoxConfig = logBox.getConfig();
		var settingService = controller.getWireBox().getInstance( "settingService@cb" );

		var setting = settingService.findWhere( criteria = { name="aggregator" } );
		if ( !isNull( setting ) ) {
			var agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );
			logLevel = agSettings.ag_general_log_level;
			fileName = agSettings.ag_general_log_file_name;
		}

		logBoxConfig.appender( name="aggregator", class="coldbox.system.logging.appenders.CFAppender", levelMax=logLevel, properties={ fileName=fileName } );
		logBoxConfig.category( name="aggregator", levelMax=logLevel, appenders="aggregator" );
		logBox.configure( logBoxConfig );

	}

}