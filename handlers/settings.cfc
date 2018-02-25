component extends="baseHandler" {

	property name="authorService" inject="authorService@cb";
	property name="themeService" inject="themeService@cb";

	function index( event, rc, prc ) {

		prc.intervals = [
			{ name="Never", value="" },
			{ name="Every 15 Minutes", value="900" },
			{ name="Every 30 Minutes", value="1800" },
			{ name="Every Hour", value="3600" },
			{ name="Every Two Hours", value="7200" },
			{ name="Every Twelve Hours", value="43200" },
			{ name="Once a Day", value="daily" },
			{ name="Once a Week", value="weekly" },
			{ name="Once a Month", value="monthly" }
		];
		prc.authors = authorService.getAll( sortOrder="lastName" );
		prc.limitUnits = [ "days", "weeks", "months", "years" ];
		prc.thumbnailOptions = [ 
			{ name="Use the default thumbnail", value="default" },
			{ name="Use the feed's thumbnail", value="feed" },
			{ name="Do not display a thumbnail", value="none" }
		];
		prc.cacheNames = cachebox.getCacheNames();

		event.setView( "settings/index" );

	}

	function save( event, rc, prc ) {

		announceInterception( "aggregator_preSettingsSave", { oldSettings=prc.agSettings, newSettings=rc } );

		for ( var key IN rc ) {
			if ( structKeyExists( prc.agSettings, key ) ) {
				prc.agSettings[ key ] = rc[ key ];
			}
		}

		var errors = settingService.validateSettings();
		if ( arrayLen( errors ) ) {
			cbMessagebox.warn( messageArray=errors );
			return index( argumentCollection=arguments );
		}

		var setting = settingService.findWhere( { name="aggregator" } );
		setting.setValue( serializeJSON( prc.agSettings ) );
		settingService.save( setting );

		settingService.flushSettingsCache();

		// Import scheduled task
		if ( len( prc.agSettings.ag_general_import_interval ) ) {
			var taskUrl = event.getSESBaseUrl() & prc.agSettings.ag_portal_entrypoint & "/import?key=" & prc.agSettings.ag_general_secret_key;
			cfschedule( 
				action="update",
				task="aggregator-import",
				url="#taskUrl#",
				startDate=prc.agSettings.ag_general_import_start_date, 
				startTime=prc.agSettings.ag_general_import_start_time,
				interval=prc.agSettings.ag_general_import_interval
			);
		} else {
			cfschedule( action="delete", task="aggregator-import" );
		}

		// TODO: test this with a cbEntryPoint defined?
		// TODO: What if cbentrypoint is changed via the settings form?
		// Set portal entrypoint
		var ses = getInterceptor("SES");
		var routes = ses.getRoutes();
		for( var key IN routes ) {
			if( key.namespaceRouting EQ "aggregator" ){
				key.pattern = key.regexpattern = replace(  prc.agSettings.ag_portal_entrypoint, "/", "-", "all" ) & "/";
			}
		}
		ses.setRoutes( routes );

		announceInterception( "aggregator_postSettingsSave" );

		cbMessagebox.info( "Settings Updated!" );
		setNextEvent( prc.xehAggregatorSettings );

	}

}