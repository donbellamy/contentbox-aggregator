component {

	// Module Properties
	this.title = "RSS Aggregator";
	this.author = "Perfect Code, LLC";
	this.webURL = "https://perfectcode.com";
	this.description = "RSS feed aggregator for ContentBox";
	this.version = "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup = true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint	= "aggregator";

	function configure() {

		settings = {

			// General settings
			"general_disable_portal" = false,
			"general_portal_entrypoint" = "news",

			// Display settings
			"display_link_title" = true,
			"display_show_excerpts" = true,
			"display_excerpt_ending" = "...",
			"display_show_read_more" = true,
			"display_read_more_text" = "Read more...",
			"display_show_source" = true,
			"display_link_source" = true,

			// RSS feed settings
			"rss_enable_feed" = true,
			"rss_feed_entrypoint" = "rss",
			"rss_feed_title" = "RSS Aggregator Feed"

		};

		// SES Routes
		routes = [
			// TODO: Find out why routes do not work here? - Any plans to fix????
			{ pattern="/:handler/:action?" }
		];

		aggregatorRoutes = [
			{ pattern="/feeds/:slug", handler="news", action="feed", namespace="aggregator" },
			{ pattern="/feeds", handler="news", action="feeds", namespace="aggregator" },
			{ pattern="/:slug", handler="news", action="item", namespace="aggregator" },
			{ pattern="/", handler="news", action="index", namespace="aggregator" }
		];

		// Interceptors
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

		// Flush the settings cache so our new settings are reflected
		settingService.flushSettingsCache();

	}

	function registerAggregatorNameSpace() {

		var ses = controller.getInterceptorService().getInterceptor( "SES", true );
		var settingService = controller.getWireBox().getInstance( "settingService@cb" );

		//var blogEntryPoint = settingService.findWhere( {name="cb_site_blog_entrypoint"} );
		//if( !isNull( blogEntryPoint ) ){
		//	ses.addNamespace(pattern="#this.entryPoint#/#blogEntryPoint.getValue()#", namespace="blog", append=false);
		//}
		//else{
		//	ses.addNamespace(pattern="#this.entryPoint#/blog", namespace="blog", append=false);
		//}

		var cbEntryPoint = ""; // TODO: need to look this up, cb could be installed in a sub dir
		var aggregatorEntryPoint = "news"; // TODO: Needs to be a setting that we look up

		ses.addNamespace( pattern="#cbEntryPoint#/#aggregatorEntryPoint#", namespace="aggregator", append=false );

		// Register namespace routes
		for( var x=1; x LTE arrayLen( aggregatorRoutes ); x++ ){
			var args = duplicate( aggregatorRoutes[ x ] );
			// Check if handler defined
			if( structKeyExists( args, "handler" ) ){
				args.handler = "contentbox-aggregator:#args.handler#";
			}
			// Add the namespace routes
			ses.addRoute(argumentCollection=args);
		}

	}

	/**
	* Fired when the module is activated by ContentBox
	*/
	function onActivate(){

		var settingService = controller.getWireBox().getInstance("SettingService@cb");

		// Store default settings
		var findArgs = { name="aggregator" };
		var setting = settingService.findWhere( criteria=findArgs );
		if ( isNull( setting ) ) {
			var args = { name="aggregator", value=serializeJSON( settings ) };
			var agSettings = settingService.new(properties=args);
			settingService.save(agSettings);
		}

		// Flush the settings cache so our new settings are reflected
		settingService.flushSettingsCache();
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload() {
		
		//var settingService = controller.getWireBox().getInstance("SettingService@cb");
		var menuService = controller.getWireBox().getInstance("AdminMenuService@cb");

		menuService.removeTopMenu("aggregator");
	}

	/**
	* Fired when the module is deactivated by ContentBox
	*/
	function onDeactivate() {

		var settingService = controller.getWireBox().getInstance("SettingService@cb");

		var args = {name="aggregator"};
		var setting = settingService.findWhere(criteria=args);
		if(!isNull(setting)){
			settingService.delete(setting);
		}

		// Flush the settings cache so our new settings are reflected
		settingService.flushSettingsCache();
	}

}