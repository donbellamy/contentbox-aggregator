/**
 * ContentBox RSS Aggregator
 * Module Config
 * @author Don Bellamy <don@perfectcode.com>
 */
component {

	// Module properties
	this.title = "ContentBox Aggregator Module";
	this.author = "Perfect Code, LLC";
	this.webURL = "https://perfectcode.com";
	this.description = "RSS aggregator module for ContentBox";
	this.version = "1.0.0";
	this.viewParentLookup = true;
	this.layoutParentLookup = true;
	this.entryPoint	= "aggregator";
	this.cfmapping = "aggregator";
	this.dependencies = ["cbjsoup"];

	/**
	 * Configure module properties
	 */
	function configure() {

		// Settings
		settings = {

			// Portal
			"ag_portal_name" = "News",
			"ag_portal_tagline" = "The Latest News",
			"ag_portal_entrypoint" = "news",
			"ag_portal_description" = "",
			"ag_portal_keywords" = "",
			"ag_portal_feeds_title" = "Feeds",
			"ag_portal_display_entries" = "false",
			"ag_portal_item_link_behavior" = "forward",
			"ag_portal_item_featured_image_behavior" = "default",
			"ag_portal_item_featured_image_default" = "",
			"ag_portal_item_featured_image_default_url" = "",
			"ag_portal_paging_max_items" = "20",
			"ag_portal_paging_max_feeds" = "20",
			"ag_portal_cache_enable" = "true",
			"ag_portal_cache_name" = "Template",
			"ag_portal_cache_timeout" = "60",
			"ag_portal_cache_timeout_idle" = "15",

			// Importing
			"ag_importing_import_interval" = "",
			"ag_importing_import_start_date" = "",
			"ag_importing_import_start_time" = "",
			"ag_importing_secret_key" = hash( getCurrentTemplatePath() ),
			"ag_importing_max_feed_imports" = "25",
			"ag_importing_item_author" = "",
			"ag_importing_item_status" = "draft",
			"ag_importing_item_pub_date" = "original",
			"ag_importing_max_age" = "",
			"ag_importing_max_age_unit" = "days",
			"ag_importing_max_items" = "",
			"ag_importing_match_any_filter" = "",
			"ag_importing_match_all_filter" = "",
			"ag_importing_match_none_filter" = "",
			"ag_importing_featured_image_enable" = "true",
			"ag_importing_all_images_enable" = "false",
			"ag_importing_image_minimum_width" = "100",
			"ag_importing_image_minimum_height" = "100",
			"ag_importing_taxonomies" = [],

			// Global html
			"ag_html_pre_index_display" = "",
			"ag_html_post_index_display" = "",
			"ag_html_pre_feeds_display" = "",
			"ag_html_post_feeds_display" = "",
			"ag_html_pre_feed_display" = "",
			"ag_html_post_feed_display" = "",
			"ag_html_pre_feeditem_display" = "",
			"ag_html_post_feeditem_display" = "",
			"ag_html_pre_archives_display" = "",
			"ag_html_post_archives_display" = "",
			"ag_html_pre_sidebar_display" = "",
			"ag_html_post_sidebar_display" = "",

			// RSS
			"ag_rss_enable" = "true",
			"ag_rss_title" = "RSS Aggregator Feed",
			"ag_rss_description" = "RSS Aggregator Feed",
			"ag_rss_generator" = "RSS Aggregator by Perfect Code, LLC",
			"ag_rss_copyright" = "Perfect Code, LCC (perfectcode.com)",
			"ag_rss_webmaster" = "",
			"ag_rss_max_items" = "20",
			"ag_rss_content_enable" = "true",
			"ag_rss_cache_enable" = "true",
			"ag_rss_cache_name" = "Template",
			"ag_rss_cache_timeout" = "60",
			"ag_rss_cache_timeout_idle" = "15"

		};

		// Permissions
		permissions = [
			{ permission="FEEDS_ADMIN", description="Ability to manage feeds", level="admin" },
			{ permission="FEEDS_EDITOR", description="Ability to manage feeds but not publish them", level="editor" },
			{ permission="FEEDS_IMPORT", description="Ability to import feeds", level="editor" },
			{ permission="FEED_ITEMS_ADMIN", description="Ability to manage feed items", level="admin" },
			{ permission="FEED_ITEMS_EDITOR", description="Ability to manage feed items but not publish them", level="editor" },
			{ permission="AGGREGATOR_SETTINGS", description="Ability to manage the rss aggregator module settings", level="admin" }
		];

		// Default routes
		routes = [
			{ pattern="/:handler/:action?" }
		];

		// Aggregator portal routes
		aggregatorRoutes = [
			{ pattern="/archives/:year-numeric{4}?/:month-numeric{1,2}?/:day-numeric{1,2}?", handler="portal", action="archives", namespace="aggregator" },
			{ pattern="/category/:category", handler="portal", action="index", namespace="aggregator" },
			{ pattern="/rss/:category?", handler="portal", action="rss", namespace="aggregator" },
			{ pattern="/feeds/:slug/rss/:category?", handler="portal", action="rss", namespace="aggregator" },
			{ pattern="/feeds/:slug", handler="portal", action="feed", namespace="aggregator" },
			{ pattern="/feeds", handler="portal", action="feeds", namespace="aggregator" },
			{ pattern="/:slug", handler="portal", action="feeditem", namespace="aggregator" },
			{ pattern="/", handler="portal", action="index", namespace="aggregator" }
		];

		// Interception points
		interceptorSettings = {
			customInterceptionPoints = arrayToList([
				"aggregator_preSettingsSave","aggregator_postSettingsSave",
				"aggregator_feedEditorInBody","aggregator_feedEditorFooter",
				"aggregator_feedEditorSidebarAccordion","aggregator_feedEditorSidebar",
				"aggregator_feedEditorSidebarFooter",
				"aggregator_preFeedSave","aggregator_postFeedSave",
				"aggregator_preFeedRemove","aggregator_postFeedRemove",
				"aggregator_onFeedStatusUpdate","aggregator_onFeedStateUpdate",
				"aggregator_preFeedImport","aggregator_postFeedImport",
				"aggregator_preFeedImports","aggregator_postFeedImports",
				"aggregator_feedItemEditorInBody","aggregator_feedItemEditorFooter",
				"aggregator_feedItemEditorSidebarAccordion","aggregator_feedItemEditorSidebar",
				"aggregator_feedItemEditorSidebarFooter",
				"aggregator_preFeedItemSave","aggregator_postFeedItemSave",
				"aggregator_preFeedItemRemove","aggregator_postFeedItemRemove",
				"aggregator_onFeedItemStatusUpdate",
				"aggregator_preBlacklistedItemSave","aggregator_postBlacklistedItemSave",
				"aggregator_preBlacklistedItemRemove","aggregator_postBlacklistedItemRemove",
				"aggregator_onIndexView",
				"aggregator_preIndexDisplay","aggregator_postIndexDisplay",
				"aggregator_onFeedsView",
				"aggregator_preFeedsDisplay","aggregator_postFeedsDisplay",
				"aggregator_onFeedView","aggregator_onFeedNotFound",
				"aggregator_preFeedDisplay","aggregator_postFeedDisplay",
				"aggregator_onFeedItemView","aggregator_onFeedItemNotFound",
				"aggregator_preFeedItemDisplay", "aggregator_postFeedItemDisplay",
				"aggregator_onArchivesView",
				"aggregator_preArchivesDisplay","aggregator_postArchivesDisplay",
				"aggregator_preSideBarDisplay","aggregator_postSideBarDisplay",
				"aggregator_onRSSView",
				"aggregator_onClearCache"
			])
		};

		// Interceptors
		interceptors = [
			{ class = "#moduleMapping#.interceptors.AdminRequest", name="adminRequest@aggregator" },
			{ class = "#moduleMapping#.interceptors.FeedCleanup", name="feedCleanup@aggregator" },
			{ class = "#moduleMapping#.interceptors.FeedImportCleanup", name="feedImportCleanup@aggregator" },
			{ class = "#moduleMapping#.interceptors.FeedItemCleanup", name="feedItemCleanup@aggregator" },
			{ class = "#moduleMapping#.interceptors.FeedItemTaxonomies", name="feedItemTaxonomies@aggregator" },
			{ class = "#moduleMapping#.interceptors.GlobalHTML", name="globalHTML@aggregator" },
			{ class = "#moduleMapping#.interceptors.PortalCacheCleanup", name="portalCacheCleanup@aggregator" },
			{ class = "#moduleMapping#.interceptors.PortalRequest", name="portalRequest@aggregator" },
			{ class = "#moduleMapping#.interceptors.RSSCacheCleanup", name="rssCacheCleanup@aggregator" }
		];

		// Bindings
		binder.map("contentService@aggregator").to("#moduleMapping#.models.ContentService");
		binder.map("feedService@aggregator").to("#moduleMapping#.models.FeedService");
		binder.map("feedItemService@aggregator").to("#moduleMapping#.models.FeedItemService");
		binder.map("blacklistedItemService@aggregator").to("#moduleMapping#.models.BlacklistedItemService");
		binder.map("feedImportService@aggregator").to("#moduleMapping#.models.FeedImportService");
		binder.map("helper@aggregator").to("#moduleMapping#.models.Helper");
		binder.map("paging@aggregator").to("#moduleMapping#.models.Paging");
		binder.map("rssService@aggregator").to("#moduleMapping#.models.RSSService");

	}

	/**
	 * Fired when module is loaded
	 */
	function onLoad() {

		// Add menus
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
			name="blacklisteditems",
			label="Blacklisted Items",
			href="#menuService.buildModuleLink('aggregator','blacklisteditems')#",
			permissions="FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR"
		);
		menuService.addSubMenu(
			topMenu="aggregator",
			name="settings",
			label="Settings",
			href="#menuService.buildModuleLink('aggregator','settings')#",
			permissions="AGGREGATOR_SETTINGS"
		);

		// Get settings
		var settingService = controller.getWireBox().getInstance( "settingService@cb" );
		var setting = settingService.findWhere( criteria = { name="aggregator" } );

		// Add routes
		var ses = controller.getInterceptorService().getInterceptor( "SES", true );
		var cbEntryPoint = controller.getConfigSettings().modules["contentbox-ui"].entryPoint;
		var agEntryPoint = settings.ag_portal_entrypoint;
		if ( !isNull( setting ) ) {
			var agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );
			agEntryPoint = agSettings.ag_portal_entrypoint;
		}
		if ( len( cbEntryPoint ) ) {
			ses.addNamespace( pattern="#cbEntryPoint#/#agEntryPoint#", namespace="aggregator", append=false );
		} else {
			ses.addNamespace( pattern=agEntryPoint, namespace="aggregator", append=false );
		}
		for ( var x=1; x LTE arrayLen( aggregatorRoutes ); x++ ) {
			var args = duplicate( aggregatorRoutes[ x ] );
			if ( structKeyExists( args, "handler" ) ) {
				args.handler = "contentbox-aggregator:#args.handler#";
			}
			ses.addRoute(argumentCollection=args);
		}

	}

	/**
	 * Fired when module is unloaded
	 */
	function onUnload() {

		// Remove menus
		var menuService = controller.getWireBox().getInstance("adminMenuService@cb");
		menuService.removeTopMenu("aggregator");

		// Remove routes
		var ses = controller.getInterceptorService().getInterceptor( "SES", true );
		ses.removeNamespaceRoutes("aggregator");

	}

	/**
	 * Fired when module is activated
	 */
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
		var adminRole = roleService.findWhere( { role="Administrator" } );
		var editorRole = roleService.findWhere( { role="Editor" } );
		for ( var item IN permissions ) {
			var permission = permissionService.findWhere( criteria = { permission=item["permission"] } );
			if ( isNull( permission ) ) {
				permission = permissionService.new();
				permission.setPermission( item["permission"] );
				permission.setDescription( item["description"] );
				permissionService.save( permission );
				if ( !isNull( editorRole ) && item["level"] EQ "editor" ) {
					editorRole.addPermission( permission );
					roleService.save( editorRole );
				}
				if ( !isNull( adminRole ) ) {
					adminRole.addPermission( permission );
					roleService.save( adminRole );
				}
			}
		}

		// Create media directories if needed
		var feedFolderPath = expandPath( settingService.getSetting( "cb_media_directoryRoot" ) ) & "\aggregator\feeds\";
		if ( !directoryExists( feedFolderPath ) ) {
			directoryCreate( feedFolderPath );
		}
		var feedItemFolderPath = expandPath( settingService.getSetting( "cb_media_directoryRoot" ) ) & "\aggregator\feeditems\";
		if ( !directoryExists( feedItemFolderPath ) ) {
			directoryCreate( feedItemFolderPath );
		}

	}

	/**
	 * Fired when module is deactivated
	 */
	function onDeactivate() {

		// Delete settings
		var settingService = controller.getWireBox().getInstance("settingService@cb");
		var setting = settingService.findWhere( criteria = { name="aggregator" } );
		if ( !isNull( setting ) ) {
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

		// Delete scheduled task (will delete if one exists)
		cfschedule( action="delete", task="aggregator-import" );

	}

}