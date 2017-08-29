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

			"ag_general_interval" = "60",
			"ag_general_limit_by_age" = "",
			"ag_general_limit_by_number" = "",
			"ag_general_filter_any" = "",
			"ag_general_filter_all" = "",
			"ag_general_filter_none" = "",
			"ag_general_log_level" = "ERROR",
			// TODO: Log file name? - add in logbox logging to test
			// TODO: User Agent?

			"ag_display_title_link" = true,
			"ag_display_author_show" = true,
			"ag_display_source_show" = true,
			"ag_display_source_link" = true,
			"ag_display_link_new_window" = true,
			"ag_display_link_as_nofollow" = true,

			"ag_display_excerpt_show" = true,
			"ag_display_excerpt_ending" = "...",
			"ag_display_read_more_show" = true,
			"ag_display_read_more_text" = "Read more...",

			"ag_display_thumbnail_enable" = true,
			"ag_display_thumbnail_link" = true,
			"ag_display_thumbnail_width" = 150,
			"ag_display_thumbnail_height" = 150,

			"ag_display_paging_max_rows" = 10,
			"ag_display_paging_type" = "paging", 

			"ag_portal_enable" = true,
			"ag_portal_title" = "RSS Aggregator News",
			"ag_portal_entrypoint" = "news",
			"ag_portal_layout" = "pages",
			"ag_portal_hits_track" = true,
			"ag_portal_hits_ignore_bots" = false,
			"ag_portal_hits_bot_regex" = "Google|msnbot|Rambler|Yahoo|AbachoBOT|accoona|AcioRobot|ASPSeek|CocoCrawler|Dumbot|FAST-WebCrawler|GeonaBot|Gigabot|Lycos|MSRBOT|Scooter|AltaVista|IDBot|eStyle|Scrubby", // Get setting from cb?
			"ag_portal_cache_enable" = true,
			"ag_portal_cache_name" = "Template",
			"ag_portal_cache_timeout" = 60,
			"ag_portal_cache_timeout_idle" = 15,

			"ag_rss_enable" = true,
			"ag_rss_title" = "RSS Aggregator Feed",
			"ag_rss_description" = "RSS Aggregator Feed",
			"ag_rss_generator" = "RSS Aggregator by Perfect Code",
			"ag_rss_copyright" = "Perfect Code, LCC (perfectcode.com)",
			"ag_rss_webmaster" = "",
			"ag_rss_max_items" = 10,
			"ag_rss_cache_enable" = true,
			"ag_rss_cache_name" = "Template",
			"ag_rss_cache_timeout" = 60,
			"ag_rss_cache_timeout_idle" = 15

		};

		routes = [
			// TODO: Why do routes not work here? - Any plans to fix????
			{ pattern="/:handler/:action?" }
		];

		aggregatorRoutes = [
			{ pattern="/feeds/:slug", handler="portal", action="feed", namespace="aggregator" },
			{ pattern="/feeds", handler="portal", action="feeds", namespace="aggregator" },
			{ pattern="/:slug", handler="portal", action="item", namespace="aggregator" },
			{ pattern="/", handler="portal", action="index", namespace="aggregator" }
		];

		// TODO: Fix interceptors
		interceptors = [
			{ class="#moduleMapping#.interceptors.request", name="request@aggregator" }
		];

		binder.map("helper@aggregator").to("#moduleMapping#.models.Helper");
		binder.map("feedService@aggregator").to("#moduleMapping#.models.FeedService");

	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad() {

		var menuService = controller.getWireBox().getInstance("adminMenuService@cb");
		var settingService = controller.getWireBox().getInstance("settingService@cb");

		registerAggregatorNameSpace();

		// TODO: Add/Check permissions? - they can be passed in the menus below

		menuService.addTopMenu(
			name="aggregator",
			label="<i class='fa fa-rss'></i> RSS Aggregator"
		);
		menuService.addSubMenu(
			topMenu="aggregator",
			name="feeds",
			label="Feeds",
			href="#menuService.buildModuleLink('aggregator','feeds')#"
		);
		menuService.addSubMenu(
			topMenu="aggregator",
			name="items",
			label="Feed Items",
			href="#menuService.buildModuleLink('aggregator','items')#"
		);
		menuService.addSubMenu(
			topMenu="aggregator",
			name="import",
			label="Import & Export",
			href="#menuService.buildModuleLink('aggregator','import-export')#"
		);
		menuService.addSubMenu(
			topMenu="aggregator",
			name="debug",
			label="Debugging",
			href="#menuService.buildModuleLink('aggregator','debugging')#"
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

		var menuService = controller.getWireBox().getInstance("adminMenuService@cb");
		
		menuService.removeTopMenu("aggregator");

	}

	/**
	* Fired when the module is deactivated by ContentBox
	*/
	function onDeactivate() {

		var settingService = controller.getWireBox().getInstance("settingService@cb");
		var setting = settingService.findWhere( criteria = { name="aggregator" } );

		if( !isNull( setting ) ){
			settingService.delete( setting );
		}

		// TODO: unregister namespace

		settingService.flushSettingsCache();

	}

}