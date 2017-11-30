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
		prc.logLevels = [ "OFF", "FATAL", "ERROR", "WARN", "INFO", "DEBUG" ];
		prc.pagingTypes = [
			{ name='Page numbers with "Next" and "Previous" page links', value="paging" },
			{ name='"Older posts" and "Newer posts" links', value="oldnew" }
		];
		prc.cacheNames = cachebox.getCacheNames();
		prc.activeTheme = themeService.getActiveTheme();
		prc.layouts = reReplaceNoCase( prc.activeTheme.layouts, "blog_?[a-zA-Z]*,?", "", "all" );

		event.setView( "settings/index" );

	}

	function save( event, rc, prc ) {

		announceInterception( "agadmin_preSettingsSave", { oldSettings=prc.agSettings, newSettings=rc } );

		for ( var key IN rc ) {
			if ( structKeyExists( prc.agSettings, key ) ) {
				prc.agSettings[ key ] = rc[ key ];
			}
		}

writedump(settingService);
abort;

		var errors = settingService.validateSettings();
		if ( arrayLen( errors ) ) {
			cbMessageBox.warn( messageArray=errors );
			return index( argumentCollection=arguments );
		}

		var setting = settingService.findWhere( { name="aggregator" } );
		setting.setValue( serializeJSON( prc.agSettings ) );
		settingService.save( setting );

		settingService.flushSettingsCache();

		// Import scheduled task
		if ( len( rc["ag_general_import_interval"] ) ) {
			// TODO: move to a helper?
			var taskUrl = event.getSESBaseUrl() & rc["ag_portal_entrypoint"] & "/import?key=secretkey"
			if ( isDate( rc["ag_general_import_"] ) )
			cfschedule( 
				action="update",
				task="aggregator-import",
				url="#taskUrl#",
				startDate=rc["ag_general_import_start_date"], 
				startTime=rc["ag_general_import_start_date"],
				interval=rc["ag_general_import_interval"]
			);
			// TODO: change to setting?
		} else {
			cfschedule( action="delete", task="aggregator-import" );
		}

		// Configure LogBox
		var logBoxConfig = logBox.getConfig();
		logBoxConfig.appender( name="aggregator", class="coldbox.system.logging.appenders.CFAppender", levelMax=rc["ag_general_log_level"], properties={ fileName=rc["ag_general_log_file_name"] } );
		logBoxConfig.category( name="aggregator", levelMax=rc["ag_general_log_level"], appenders="aggregator" );
		logBox.configure( logBoxConfig );

		// Set portal entrypoint
		var ses = getInterceptor("SES");
		var routes = ses.getRoutes();
		for( var key IN routes ) {
			if( key.namespaceRouting eq "aggregator" ){
				key.pattern = key.regexpattern = replace(  rc["ag_portal_entrypoint"] , "/", "-", "all" ) & "/";
			}
		}
		ses.setRoutes( routes );

		announceInterception( "agadmin_postSettingsSave" );

		cbMessagebox.info( "Settings Updated!" );
		setNextEvent( prc.xehSettings );

	}

}