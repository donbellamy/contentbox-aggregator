component extends="baseHandler" {

	function index( event, rc, prc ) {

		prc.cacheNames = cachebox.getCacheNames();

		event.setView( "settings/index" );

	}

	function save( event, rc, prc ) {

		//announceInterception( "aggregator_preSettingsSave",{ oldSettings = prc.agSettings, newSettings = rc } );

		for ( var key IN rc ) {
			if ( structKeyExists( prc.agSettings, key ) ) {
				prc.agSettings[ key ] = rc[ key ];
			}
		}

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

		//announceInterception( "aggregator_postSettingsSave" );

		cbMessagebox.info( "Settings Updated!" );
		setNextEvent( prc.xehAgSettings );

	}

}