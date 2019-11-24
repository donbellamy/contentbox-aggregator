/**
 * ContentBox Aggregator
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

			// Site Options

			// Feed items
			"ag_site_items_entrypoint" = "news",
			"ag_site_items_include_entries" = "false",
			"ag_site_items_link_behavior" = "forward",
			"ag_site_items_show_featured_image" = "true",
			"ag_site_items_featured_image_behavior" = "feed",
			"ag_site_items_featured_image_default" = "",
			"ag_site_items_featured_image_default_url" = "",
			"ag_site_items_group_by_date" = "false",
			"ag_site_items_open_new_window" = "true",
			"ag_site_items_show_video_player" = "true",
			"ag_site_items_show_audio_player" = "true",
			"ag_site_items_show_source" = "true",
			"ag_site_items_show_author" = "false",
			"ag_site_items_show_excerpt" = "true",
			"ag_site_items_excerpt_limit" = "255",
			"ag_site_items_excerpt_ending" = "...",
			"ag_site_items_show_read_more" = "true",
			"ag_site_items_read_more_text" = "Read More...",
			"ag_site_items_show_categories" = "false",

			// Feeds
			"ag_site_feeds_entrypoint" = "feeds",
			"ag_site_feeds_show_featured_image" = "true",
			"ag_site_feeds_show_website" = "true",
			"ag_site_feeds_show_rss" = "true",
			"ag_site_feeds_include_items" = "false",

			// Paging
			"ag_site_paging_max_items" = "20",
			"ag_site_paging_max_feeds" = "20",

			// Caching
			"ag_site_cache_enable" = "true",
			"ag_site_cache_name" = "Template",
			"ag_site_cache_timeout" = "60",
			"ag_site_cache_timeout_idle" = "15",

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
			"ag_html_pre_feed_items_display" = "",
			"ag_html_post_feed_items_display" = "",
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
			"ag_rss_max_items" = "30",
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

		// Site routes
		siteRoutes = [
			{ pattern="/category/:category", handler="site", action="feeds", namespace="aggregator-feeds" },
			{ pattern="/rss/:category?", handler="site", action="feedsRSS", namespace="aggregator-feeds" },
			{ pattern="/:slug/rss/:category?", handler="site", action="rss", namespace="aggregator-feeds" },
			{ pattern="/:slug", handler="site", action="feed", namespace="aggregator-feeds" },
			{ pattern="/", handler="site", action="feeds", namespace="aggregator-feeds" },
			{ pattern="/archives/:year-numeric{4}?/:month-numeric{1,2}?/:day-numeric{1,2}?", handler="site", action="archives", namespace="aggregator-news" },
			{ pattern="/category/:category", handler="site", action="index", namespace="aggregator-news" },
			{ pattern="/rss/:category?", handler="site", action="rss", namespace="aggregator-news" },
			{ pattern="/:slug", handler="site", action="feeditem", namespace="aggregator-news" },
			{ pattern="/", handler="site", action="index", namespace="aggregator-news" }
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
				"aggregator_onFeedItemsView",
				"aggregator_preFeedItemsDisplay","aggregator_postFeedItemsDisplay",
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
			{ class="#moduleMapping#.interceptors.AdminRequest", name="adminRequest@aggregator" },
			{ class="#moduleMapping#.interceptors.FeedCleanup", name="feedCleanup@aggregator" },
			{ class="#moduleMapping#.interceptors.FeedImportCleanup", name="feedImportCleanup@aggregator" },
			{ class="#moduleMapping#.interceptors.FeedItemCleanup", name="feedItemCleanup@aggregator" },
			{ class="#moduleMapping#.interceptors.FeedItemTaxonomies", name="feedItemTaxonomies@aggregator" },
			{ class="#moduleMapping#.interceptors.GlobalHTML", name="globalHTML@aggregator" },
			{ class="#moduleMapping#.interceptors.PageListener", name="pageListener@aggregator" },
			{ class="#moduleMapping#.interceptors.RSSCacheCleanup", name="rssCacheCleanup@aggregator" },
			{ class="#moduleMapping#.interceptors.SiteCacheCleanup", name="siteCacheCleanup@aggregator" },
			{ class="#moduleMapping#.interceptors.SiteRequest", name="siteRequest@aggregator" }
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
			name = "aggregator",
			label = "<i class='fa fa-rss'></i> RSS Aggregator"
		);
		menuService.addSubMenu(
			topMenu = "aggregator",
			name = "feeds",
			label = "Feeds",
			href = "#menuService.buildModuleLink('aggregator','feeds')#",
			permissions = "FEEDS_ADMIN,FEEDS_EDITOR"
		);
		menuService.addSubMenu(
			topMenu = "aggregator",
			name = "feeditems",
			label = "Feed Items",
			href = "#menuService.buildModuleLink('aggregator','feeditems')#",
			permissions = "FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR"
		);
		menuService.addSubMenu(
			topMenu = "aggregator",
			name = "blacklisteditems",
			label = "Blacklisted Items",
			href = "#menuService.buildModuleLink('aggregator','blacklisteditems')#",
			permissions = "FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR"
		);
		menuService.addSubMenu(
			topMenu = "aggregator",
			name = "settings",
			label = "Settings",
			href = "#menuService.buildModuleLink('aggregator','settings')#",
			permissions = "AGGREGATOR_SETTINGS"
		);

		// Get settings
		var settingService = controller.getWireBox().getInstance( "settingService@cb" );
		var setting = settingService.findWhere(
			criteria = {
				name = "aggregator"
			}
		);

		// Add site routes
		var routingService = controller.getRoutingService();
		var cbEntryPoint = controller.getConfigSettings().modules["contentbox-ui"].entryPoint;
		var newsEntryPoint = settings.ag_site_items_entrypoint;
		var feedsEntryPoint = settings.ag_site_feeds_entrypoint;
		if ( !isNull( setting ) ) {
			var agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );
			newsEntryPoint = agSettings.ag_site_items_entrypoint;
			feedsEntryPoint = agSettings.ag_site_feeds_entrypoint;
		}
		if ( len( cbEntryPoint ) ) {
			routingService.addNamespace(
				pattern = "#cbEntryPoint#/#newsEntryPoint#",
				namespace = "aggregator-news",
				append = false
			);
			routingService.addNamespace(
				pattern = "#cbEntryPoint#/#feedsEntryPoint#",
				namespace = "aggregator-feeds",
				append = false
			);
		} else {
			routingService.addNamespace(
				pattern = "#newsEntryPoint#",
				namespace = "aggregator-news",
				append = false
			);
			routingService.addNamespace(
				pattern = "#feedsEntryPoint#",
				namespace = "aggregator-feeds",
				append = false
			);
		}
		siteRoutes.each( function( item ) {
			if ( structKeyExists( item, "handler" ) ) {
				item.handler = "contentbox-aggregator:#item.handler#";
			}
			routingService.addRoute( argumentCollection=item );
		});

	}

	/**
	 * Fired when module is activated
	 */
	function onActivate() {

		// Set vars
		var settingService = controller.getWireBox().getInstance("settingService@cb");

		// Save search adapter setting
		var setting = settingService.findWhere(
			criteria = {
				name = "cb_search_adapter"
			}
		);
		if ( isNull( setting ) ) {
			setting = settingService.new(
				properties = {
					name = "cb_search_adapter",
					value = "#moduleMapping#.models.DBSearch"
				}
			);
		} else {
			setting.setValue( "#moduleMapping#.models.DBSearch" );
		}
		settingService.save( setting );

		// Save the aggregator settings if needed
		var setting = settingService.findWhere(
			criteria = {
				name = "aggregator"
			}
		);
		if ( isNull( setting ) ) {
			settingService.save(
				settingService.new(
					properties = {
						name = "aggregator",
						value = serializeJSON( settings )
					}
				)
			);
		}

		// Flush settings cache
		settingService.flushSettingsCache();

		// Grab the settings
		var agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		// Create pages if needed
		var pageService = controller.getWireBox().getInstance("pageService@cb");
		var authorService = controller.getWireBox().getInstance("authorService@cb");
		var roleService = controller.getWireBox().getInstance("roleService@cb");
		if ( len( agSettings.ag_importing_item_author ) ) {
			var author = authorService.get( prc.agSettings.ag_importing_item_author );
		} else {
			var adminRole = roleService.findWhere( { role="Administrator" } );
			var author = authorService.findWhere( { role=adminRole } );
		}
		var newsPage = pageService.findBySlug( agSettings.ag_site_items_entrypoint );
		if ( newsPage.isLoaded() ) {
			newsPage.setLayout( "aggregator" );
			pageService.savePage( newsPage );
		} else {
			newsPage.setTitle( "News" );
			newsPage.setSlug( agSettings.ag_site_items_entrypoint );
			newsPage.setPublishedDate( now() );
			newsPage.setCreator( author );
			newsPage.setLayout( "aggregator" );
			newsPage.addNewContentVersion(
				content = "News page placeholder content.",
				changelog = "Page created by ContentBox Aggregator Module.",
				author = author
			);
			pageService.savePage( newsPage );
		}
		var feedsPage = pageService.findBySlug( agSettings.ag_site_feeds_entrypoint );
		if ( feedsPage.isLoaded() ) {
			feedsPage.setLayout("aggregator");
			pageService.savePage( feedsPage );
		} else {
			feedsPage.setTitle( "Feeds" );
			feedsPage.setSlug( agSettings.ag_site_feeds_entrypoint );
			feedsPage.setPublishedDate( now() );
			feedsPage.setCreator( author );
			feedsPage.setLayout( "aggregator" );
			feedsPage.addNewContentVersion(
				content = "Feeds page placeholder content.",
				changelog = "Page created by ContentBox Aggregator Module.",
				author = author
			);
			pageService.savePage( feedsPage );
		}

		// Save permissions
		var permissionService = controller.getWireBox().getInstance("permissionService@cb");
		var roleService= controller.getWireBox().getInstance("roleService@cb");
		var adminRole = roleService.findWhere( { role = "Administrator" } );
		var editorRole = roleService.findWhere( { role = "Editor" } );
		for ( var item IN permissions ) {
			var permission = permissionService.findWhere(
				criteria = {
					permission=item["permission"]
				}
			);
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

		// Delete aggregator settings
		var settingService = controller.getWireBox().getInstance("settingService@cb");
		var setting = settingService.findWhere(
			criteria = {
				name = "aggregator"
			}
		);
		if ( !isNull( setting ) ) {
			settingService.delete( setting );
		}

		// Change search adapter settings back to default
		var setting = settingService.findWhere(
			criteria = {
				name = "cb_search_adapter"
			}
		);
		if ( isNull( setting ) ) {
			setting = settingService.new(
				properties = {
					name = "cb_search_adapter",
					value = "contentbox.models.search.DBSearch"
				}
			);
		} else {
			setting.setValue( "contentbox.models.search.DBSearch" );
		}
		settingService.save( setting );

		// Flush settings cache
		settingService.flushSettingsCache();

		// Delete permissions
		var permissionService = controller.getWireBox().getInstance("permissionService@cb");
		for ( var item IN permissions ) {
			var permission = permissionService.findWhere(
				criteria = {
					permission = item["permission"]
				}
			);
			if ( !isNull( permission ) ) {
				permissionService.deletePermission( permission.getPermissionID() );
			}
		}

		// Delete scheduled task (will delete if one exists)
		cfschedule( action = "delete", task = "aggregator-import" );

	}

	/**
	 * Fired when module is unloaded
	 */
	function onUnload() {

		// Remove menus
		var menuService = controller.getWireBox().getInstance("adminMenuService@cb");
		menuService.removeTopMenu("aggregator");

		// Remove routes
		var routingService = controller.getRoutingService();
		routingService.removeNamespaceRoutes("aggregator-news");
		routingService.removeNamespaceRoutes("aggregator-feeds");

	}

	/**
	 * Fired when module is deleted
	 */
	function onDelete() {}

}