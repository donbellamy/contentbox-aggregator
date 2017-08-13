component extends="baseHandler" {

	function index( event, rc, prc ) {

		event.setView( "settings/index" );

	}

	function save( event, rc, prc ) {

		event.paramValue( "general_disable_portal", false );
		
		//announceInterception( "aggregator_preSettingsSave",{ oldSettings = prc.aggregatorSettings, newSettings = rc } );

		for ( var key IN rc ) {
			if ( structKeyExists( prc.aggregatorSettings, key ) ) {
				prc.aggregatorSettings[ key ] = rc[ key ];
			}
		}

		var setting = settingService.findWhere( { name="aggregator" } );
		setting.setValue( serializeJSON( prc.aggregatorSettings ) );
		settingService.save( setting );

		settingService.flushSettingsCache();

		var ses = getInterceptor("SES");
		var routes = ses.getRoutes();
		for( var key IN routes ) {
			if( key.namespaceRouting eq "aggregator" ){
				key.pattern = key.regexpattern = replace(  rc[ "general_portal_entrypoint" ] , "/", "-", "all" ) & "/";
			}
		}
		ses.setRoutes( routes );

		//announceInterception( "aggregator_postSettingsSave" );

		cbMessagebox.info( "Settings Updated!" );
		setNextEvent( prc.xehAggregatorSettings );

	}

}