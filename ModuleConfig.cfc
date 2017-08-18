component {

	this.title = "RSS Aggregator";
	this.author = "Perfect Code, LLC";
	this.webURL = "https://perfectcode.com";
	this.description = "RSS feed aggregator for ContentBox";
	this.version = "1.0.0";
	this.viewParentLookup = true;
	this.layoutParentLookup = true;
	this.entryPoint	= "aggregator";

	function configure() {

		settings = {

			"ag_portal_enable" = true,
			"ag_portal_title" = "RSS Aggregator News",
			"ag_portal_entrypoint" = "news",

			"ag_rss_enable" = true,
			"ag_rss_title" = "RSS Aggregator Feed",
			"ag_rss_generator" = "RSS Aggregator by Perfect Code",
			"ag_rss_copyright" = "Perfect Code, LCC (perfectcode.com)",
			"ag_rss_description" = "RSS Aggregator Feed",
			"ag_rss_webmaster" = "",
			"ag_rss_max_items" = 10,
			"ag_rss_cache_enable" = true,
			"ag_rss_cache_name" = "Template",
			"ag_rss_cache_timeout" = 60,
			"ag_rss_cache_timeout_idle" = 15

/*
		"cb_rss_maxEntries" 					= "10",
		"cb_rss_maxComments" 					= "10",
		"cb_rss_caching" 						= "true",
		"cb_rss_cachingTimeout" 				= "60",
		"cb_rss_cachingTimeoutIdle" 			= "15",
		"cb_rss_cacheName" 						= "Template",
		"cb_rss_title" 							= "RSS Feed by ContentBox",
		"cb_rss_generator" 						= "ContentBox by Ortus Solutions",
		"cb_rss_copyright" 						= "Ortus Solutions, Corp (www.ortussolutions.com)",
		"cb_rss_description" 					= "ContentBox RSS Feed",
		"cb_rss_webmaster" 						= "",
*/

			/*

			// General settings
			"general_limit_items_by_age" = 0, // Numeric - limit feed items by age
			"general_limit_items_by_age_unit" = "days", // days, weeks, months, years
			"general_limit_items_imported" = 0, // Numeric
			"general_import_interval" = "hourly", // 15 mins, 30 mins, Hourly, 2 hours, 12 hours, daily
			"general_import_user_agent" = "", // Default = ?
			"general_import_log_level" = "Error", // What are the correct values?

			// Portal settings
			"general_disable_portal" = false,
			"general_portal_title" = "RSS Aggregator News", // Come up with a better title
			"general_portal_entrypoint" = "news",
			// Track hits? = true
			// Layout to use for portal = "pages"

			// Display settings
			"display_link_title" = true,
			"display_show_authors" = true,
			"display_show_source" = true,
			"display_link_source" = true,
			"display_link_new_window" = true,
			"display_link_as_nofollow" = true,

			// Excerpt settings
			"display_show_excerpts" = true,
			"display_excerpt_ending" = "...",
			"display_show_read_more" = true,
			"display_read_more_text" = "Read more...",

			// Thumbnail settings
			"display_show_thumbnails" = true,
			"display_thumbnail_width" = 150,
			"display_thumbnail_height" = 150,

			// Pagination settings
			"display_pagination_limit" = 10,
			"display_pagination_type" = "paging", // older/newer vs pages

			// RSS feed settings
			"rss_disable_feed" = false,
			"rss_feed_entrypoint" = "rss",
			"rss_feed_title" = "RSS Aggregator Feed",
			"rss_feed_generator" = "RSS Aggregator by Perfect Code",
			"rss_feed_copyright" = "Perfect Code, LCC (perfectcode.com)",
			"rss_feed_description" = "RSS Aggregator Feed",
			"rss_feed_webmaster" = "",
			"rss_feed_max_items" = 10

			// Caching?

			*/

		};

		routes = [
			// TODO: Why do routes not work here? - Any plans to fix????
			{ pattern="/:handler/:action?" }
		];

		aggregatorRoutes = [
			{ pattern="/feeds/:slug", handler="news", action="feed", namespace="aggregator" },
			{ pattern="/feeds", handler="news", action="feeds", namespace="aggregator" },
			{ pattern="/:slug", handler="news", action="item", namespace="aggregator" },
			{ pattern="/", handler="news", action="index", namespace="aggregator" }
		];

		interceptors = [
			{ class="#moduleMapping#.interceptors.request", name="request@aggregator" }
		];
	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad() {

		var menuService = controller.getWireBox().getInstance("adminMenuService@cb");
		var settingService = controller.getWireBox().getInstance("settingService@cb");

		registerAggregatorNameSpace();

		menuService.addTopMenu(
			name="aggregator",
			label="<i class='fa fa-rss'></i> RSS Aggregator"
		);
		menuService.addSubMenu(
			topMenu="aggregator",
			name="settings",
			label="Settings",
			href="#menuService.buildModuleLink('aggregator','settings')#"
		);

		settingService.flushSettingsCache();

	}

	function registerAggregatorNameSpace() {

		var ses = controller.getInterceptorService().getInterceptor( "SES", true );
		var settingService = controller.getWireBox().getInstance( "settingService@cb" );
		var cbEntryPoint = controller.getConfigSettings().modules["contentbox-ui"].entryPoint; // TODO: Better way? 
		var agEntryPoint = settings.ag_portal_entrypoint; //TODO: Need to check existing settings first?

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

	/**
	* Fired when the module is activated by ContentBox
	*/
	function onActivate() {

		var settingService = controller.getWireBox().getInstance("settingService@cb");
		var setting = settingService.findWhere( criteria = { name="aggregator" } );

		if ( isNull( setting ) ) {
			var settings = settingService.new( properties = { name="aggregator", value=serializeJSON( settings ) } );
			settingService.save( settings );
		}

		settingService.flushSettingsCache();
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload() {

		var menuService = controller.getWireBox().getInstance("AdminMenuService@cb");
		
		menuService.removeTopMenu("aggregator");

	}

	/**
	* Fired when the module is deactivated by ContentBox
	*/
	function onDeactivate() {

		var settingService = controller.getWireBox().getInstance("SettingService@cb");
		var setting = settingService.findWhere( criteria = { name="aggregator" } );

		if( !isNull( setting ) ){
			settingService.delete( setting );
		}

		// TODO: unregister namespace

		settingService.flushSettingsCache();

	}

}