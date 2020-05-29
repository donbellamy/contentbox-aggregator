/**
 * ContentBox Aggregator
 * Module Config
 * @author Don Bellamy <don@perfectcode.com>
 */
component {

	// Module properties
	this.title = "ContentBox Aggregator";
	this.author = "Don Bellamy <don@perfectcode.com>";
	this.webURL = "https://github.com/donbellamy/contentbox-aggregator";
	this.description = "An RSS aggregator for ContentBox.";
	this.version = "0.9.7";
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

			// Importing
			"importing_interval" = "",
			"importing_start_date" = "",
			"importing_start_time" = "",
			"importing_secret_key" = hash( getCurrentTemplatePath() ),
			"importing_max_feed_imports" = "25",
			"importing_feed_item_author" = "",
			"importing_feed_item_status" = "published",
			"importing_feed_item_published_date" = "original",
			"importing_max_feed_item_age" = "",
			"importing_max_feed_item_age_unit" = "",
			"importing_max_feed_items" = "",
			"importing_match_any_filter" = "",
			"importing_match_all_filter" = "",
			"importing_match_none_filter" = "",
			"importing_featured_image_enable" = "true",
			"importing_all_images_enable" = "false",
			"importing_image_minimum_width" = "100",
			"importing_image_minimum_height" = "100",
			"importing_taxonomies" = [],

			// Site options
			"feeds_entrypoint" = "feeds",
			"feeds_include_feed_items" = "false",
			"feeds_show_website" = "true",
			"feeds_show_rss" = "true",
			"feeds_show_featured_image" = "true",
			"feed_featured_image_behavior" = "default",
			"feed_featured_image_default" = "",
			"feed_featured_image_default_url" = "",
			"feed_items_entrypoint" = "news",
			"feed_items_include_entries" = "false",
			"feed_items_group_by_date" = "false",
			"feed_items_show_video_player" = "true",
			"feed_items_show_audio_player" = "true",
			"feed_items_show_source" = "true",
			"feed_items_show_author" = "false",
			"feed_items_show_categories" = "false",
			"feed_items_show_excerpt" = "true",
			"feed_items_excerpt_limit" = "255",
			"feed_items_excerpt_ending" = "...",
			"feed_items_show_read_more" = "true",
			"feed_items_read_more_text" = "Read More...",
			"feed_items_link_behavior" = "forward",
			"feed_items_open_new_window" = "false",
			"feed_items_show_featured_image" = "true",
			"feed_items_featured_image_behavior" = "feed",
			"feed_items_featured_image_default" = "",
			"feed_items_featured_image_default_url" = "",
			"paging_max_feeds" = "20",
			"paging_max_feed_items" = "20",
			"site_cache_enable" = "true",
			"site_cache_name" = "Template",
			"site_cache_timeout" = "60",
			"site_cache_idle_timeout" = "15",

			// Global html
			"html_pre_feed_items_display" = "",
			"html_post_feed_items_display" = "",
			"html_pre_feeds_display" = "",
			"html_post_feeds_display" = "",
			"html_pre_feed_display" = "",
			"html_post_feed_display" = "",
			"html_pre_feeditem_display" = "",
			"html_post_feeditem_display" = "",
			"html_pre_archives_display" = "",
			"html_post_archives_display" = "",
			"html_pre_sidebar_display" = "",
			"html_post_sidebar_display" = "",

			// RSS
			"rss_enable" = "true",
			"rss_title" = "ContentBox Aggregator Feed",
			"rss_description" = "ContentBox Aggregator Feed",
			"rss_generator" = "ContentBox Aggregator by Perfect Code, LLC",
			"rss_copyright" = "Perfect Code, LCC (perfectcode.com)",
			"rss_webmaster" = "info@perfectcode.com",
			"rss_max_feeds" = "30",
			"rss_max_feed_items" = "30",
			"rss_content_enable" = "true",
			"rss_cache_enable" = "true",
			"rss_cache_name" = "Template",
			"rss_cache_timeout" = "60",
			"rss_cache_idle_timeout" = "15"

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
			{ pattern="/archives/:year-numeric{4}?/:month-numeric{1,2}?/:day-numeric{1,2}?", handler="site", action="archives", namespace="aggregator-feed-items" },
			{ pattern="/category/:category", handler="site", action="index", namespace="aggregator-feed-items" },
			{ pattern="/rss/:category?", handler="site", action="rss", namespace="aggregator-feed-items" },
			{ pattern="/hit/:slug", handler="site", action="hit", namespace="aggregator-feed-items" },
			{ pattern="/:slug", handler="site", action="feeditem", namespace="aggregator-feed-items" },
			{ pattern="/", handler="site", action="index", namespace="aggregator-feed-items" }
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
		var isSSL = isBoolean( CGI.SERVER_PORT_SECURE ) && CGI.SERVER_PORT_SECURE;
		menuService.addTopMenu( name = "aggregator", label = "<i class='fa fa-rss'></i> RSS Aggregator" )
			.addSubMenu(
				topMenu = "aggregator",
				name = "feeds",
				label = "Feeds",
				href = "#menuService.buildModuleLink( module = 'aggregator', linkTo = 'feeds', ssl = isSSL )#",
				permissions = "FEEDS_ADMIN,FEEDS_EDITOR")
			.addSubMenu(
				topMenu = "aggregator",
				name = "feeditems",
				label = "Feed Items",
				href = "#menuService.buildModuleLink( module = 'aggregator', linkTo = 'feeditems', ssl = isSSL )#",
				permissions = "FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR" )
			.addSubMenu(
				topMenu = "aggregator",
				name = "blacklisteditems",
				label = "Blacklisted Items",
				href = "#menuService.buildModuleLink( module = 'aggregator', linkTo = 'blacklisteditems', ssl = isSSL )#",
				permissions = "FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR" )
			.addSubMenu(
				topMenu = "aggregator",
				name = "settings",
				label = "Settings",
				href = "#menuService.buildModuleLink( module = 'aggregator', linkTo = 'settings', ssl = isSSL )#",
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
		var feedsEntryPoint = settings.feeds_entrypoint;
		var feedItemsEntryPoint = settings.feed_items_entrypoint;
		if ( !isNull( setting ) ) {
			var agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );
			feedsEntryPoint = agSettings.feeds_entrypoint;
			feedItemsEntryPoint = agSettings.feed_items_entrypoint;
		}
		if ( len( cbEntryPoint ) ) {
			routingService.addNamespace(
				pattern = "#cbEntryPoint#/#feedsEntryPoint#",
				namespace = "aggregator-feeds",
				append = false
			);
			routingService.addNamespace(
				pattern = "#cbEntryPoint#/#feedItemsEntryPoint#",
				namespace = "aggregator-feed-items",
				append = false
			);
		} else {
			routingService.addNamespace(
				pattern = "#feedsEntryPoint#",
				namespace = "aggregator-feeds",
				append = false
			);
			routingService.addNamespace(
				pattern = "#feedItemsEntryPoint#",
				namespace = "aggregator-feed-items",
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
		if ( len( agSettings.importing_feed_item_author ) ) {
			var author = authorService.get( agSettings.importing_feed_item_author );
		} else {
			var adminRole = roleService.findWhere( { role="Administrator" } );
			var author = authorService.findWhere( { role=adminRole } );
		}
		var feedsPage = pageService.findBySlug( agSettings.feeds_entrypoint );
		if ( feedsPage.isLoaded() ) {
			feedsPage.setLayout("aggregator");
			pageService.savePage( feedsPage );
		} else {
			feedsPage.setTitle( "Feeds" );
			feedsPage.setSlug( agSettings.feeds_entrypoint );
			feedsPage.setPublishedDate( now() );
			feedsPage.setCreator( author );
			feedsPage.setLayout( "aggregator" );
			feedsPage.addNewContentVersion(
				content = "<!-- Feeds page placeholder content. -->",
				changelog = "Page created by ContentBox Aggregator Module.",
				author = author
			);
			pageService.savePage( feedsPage );
		}
		var feedItemsPage = pageService.findBySlug( agSettings.feed_items_entrypoint );
		if ( feedItemsPage.isLoaded() ) {
			feedItemsPage.setLayout( "aggregator" );
			pageService.savePage( feedItemsPage );
		} else {
			feedItemsPage.setTitle( "News" );
			feedItemsPage.setSlug( agSettings.feed_items_entrypoint );
			feedItemsPage.setPublishedDate( now() );
			feedItemsPage.setCreator( author );
			feedItemsPage.setLayout( "aggregator" );
			feedItemsPage.addNewContentVersion(
				content = "<!-- Feed items page placeholder content. -->",
				changelog = "Page created by ContentBox Aggregator Module.",
				author = author
			);
			pageService.savePage( feedItemsPage );
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
				if ( !isNull( editorRole ) && item["level"] IS "editor" ) {
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
		routingService.removeNamespaceRoutes("aggregator-feed-items");
		routingService.removeNamespaceRoutes("aggregator-feeds");

	}

	/**
	 * Fired when module is deleted
	 */
	function onDelete() {}

}