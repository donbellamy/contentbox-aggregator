component extends="baseHandler" {

	property name="themeService" inject="themeService@cb";

	function index( event, rc, prc ) {

		prc.intervals = [
			{ name="Every 15 Minutes", value="15" },
			{ name="Every 30 Minutes", value="30" },
			{ name="Every Hour", value="60" },
			{ name="Every Two Hours", value="120" },
			{ name="Every Twelve Hours", value="720" },
			{ name="Once Daily", value="1440" }
		]; 
		prc.logLevels = [ "OFF", "FATAL", "ERROR", "WARN", "INFO", "DEBUG" ];
		prc.pagingTypes = [
			{ name="Paging links", value="paging" },
			{ name="Older/Newer links", value="oldnew" }
		];
		prc.cacheNames = cachebox.getCacheNames();
		prc.activeTheme = themeService.getActiveTheme();
		prc.layouts = reReplaceNoCase( prc.activeTheme.layouts, "blog_?[a-zA-Z]*,?", "", "all" );

		event.setView( "settings/index" );

	}

	function save( event, rc, prc ) {

		//announceInterception( "agadmin_preSettingsSave",{ oldSettings = prc.agSettings, newSettings = rc } );

		for ( var key IN rc ) {
			if ( structKeyExists( prc.agSettings, key ) ) {
				prc.agSettings[ key ] = rc[ key ];
			}
		}

		// TODO: Validate settings

		var setting = settingService.findWhere( { name="aggregator" } );
		setting.setValue( serializeJSON( prc.agSettings ) );
		settingService.save( setting );

		settingService.flushSettingsCache();

		var ses = getInterceptor("SES");
		var routes = ses.getRoutes();
		for( var key IN routes ) {
			if( key.namespaceRouting eq "aggregator" ){
				key.pattern = key.regexpattern = replace(  rc[ "ag_portal_entrypoint" ] , "/", "-", "all" ) & "/";
			}
		}
		ses.setRoutes( routes );

		//announceInterception( "agadmin_postSettingsSave" );

		cbMessagebox.info( "Settings Updated!" );
		setNextEvent( prc.xehAgSettings );

	}

}