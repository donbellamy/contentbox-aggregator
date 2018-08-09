component extends="baseHandler" {

	property name="authorService" inject="authorService@cb";
	property name="categoryService" inject="categoryService@cb";
	property name="themeService" inject="themeService@cb";
	property name="helper" inject="helper@aggregator";
	property name="markdownEditor" inject="markdownEditor@contentbox-markdowneditor";

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
		prc.categories = categoryService.getAll( sortOrder="category" );
		prc.limitUnits = [ "days", "weeks", "months", "years" ];
		prc.linkOptions = [
			{ name="Forward the user directly to the feed item.", value="forward" },
			{ name="Use an interstitial page before forwarding the user to the feed item.", value="interstitial" },
			{ name="Display the entire feed item within the site.", value="display" }
		];
		prc.featuredImageOptions = [
			{ name="Display the default featured image.", value="default" },
			{ name="Display the parent feed's featured image.", value="feed" },
			{ name="Do not display a featured image.", value="none" }
		];
		prc.cacheNames = cachebox.getCacheNames();
		prc.matchOptions = [
			{ name="Only assign the categories above to feed items that contain 'any' of the words/phrases below in the title or body.", value="any" },
			{ name="Only assign the categories above to feed items that contain 'all' of the words/phrases below in the title or body.", value="all" }
		];
		markdownEditor.loadAssets();

		event.setView( "settings/index" );

	}

	function save( event, rc, prc ) {

		announceInterception( "aggregator_preSettingsSave", { oldSettings=prc.agSettings, newSettings=rc } );

		if ( structKeyExists( rc, "ag_importing_taxonomies" ) ) {
			var taxonomies = [];
			for ( var item IN structKeyArray( rc.ag_importing_taxonomies ) ) {
				if ( structKeyExists( rc.ag_importing_taxonomies[item], "categories" ) && len( trim( rc.ag_importing_taxonomies[item].keywords ) ) ) {
					arrayAppend( taxonomies, rc.ag_importing_taxonomies[item] );
				}
			}
			rc.ag_importing_taxonomies = taxonomies;
		}

		for ( var key IN rc ) {
			if ( structKeyExists( prc.agSettings, key ) ) {
				prc.agSettings[ key ] = rc[ key ];
			}
		}

		var errors = validateSettings( prc );
		if ( arrayLen( errors ) ) {
			cbMessagebox.warn( messageArray=errors );
			return index( argumentCollection=arguments );
		}

		var setting = settingService.findWhere( { name="aggregator" } );
		setting.setValue( serializeJSON( prc.agSettings ) );
		settingService.save( setting );

		settingService.flushSettingsCache();

		// Import scheduled task
		if ( len( prc.agSettings.ag_importing_import_interval ) ) {
			cfschedule(
				action="update",
				task="aggregator-import",
				url="#helper.linkImport()#",
				startDate=prc.agSettings.ag_importing_import_start_date,
				startTime=prc.agSettings.ag_importing_import_start_time,
				interval=prc.agSettings.ag_importing_import_interval
			);
		} else {
			cfschedule( action="delete", task="aggregator-import" );
		}

		// Set portal entrypoint
		var ses = getInterceptor("SES");
		var routes = ses.getRoutes();
		for ( var key IN routes ) {
			if ( key.namespaceRouting EQ "aggregator" ) {
				key.pattern = key.regexpattern = replace( prc.agSettings.ag_portal_entrypoint, "/", "-", "all" ) & "/";
			}
		}
		ses.setRoutes( routes );

		announceInterception( "aggregator_postSettingsSave" );

		cbMessagebox.info( "Settings Updated!" );
		setNextEvent( prc.xehAggregatorSettings );

	}

	private function validateSettings( prc ) {

		var errors = [];

		// Portal settings
		if ( !len( trim( prc.agSettings.ag_portal_name ) ) ) {
			arrayAppend( errors, "A valid portal name is required." );
		} else {
			prc.agSettings.ag_portal_name = trim( prc.agSettings.ag_portal_name );
		}
		prc.agSettings.ag_portal_tagline = trim( prc.agSettings.ag_portal_tagline );
		if ( !len( trim( prc.agSettings.ag_portal_entrypoint ) ) ) {
			arrayAppend( errors, "A valid portal entry point is required." );
		} else {
			prc.agSettings.ag_portal_entrypoint = trim( prc.agSettings.ag_portal_entrypoint );
		}
		prc.agSettings.ag_portal_description = trim( prc.agSettings.ag_portal_description );
		prc.agSettings.ag_portal_keywords = trim( prc.agSettings.ag_portal_keywords );
		if ( !len( trim( prc.agSettings.ag_portal_feeds_title ) ) ) {
			arrayAppend( errors, "A valid feeds page title is required." );
		} else {
			prc.agSettings.ag_portal_feeds_title = trim( prc.agSettings.ag_portal_feeds_title );
		}
		if ( !val( prc.agSettings.ag_portal_paging_max_items ) ) {
			arrayAppend( errors, "A valid max feed items value is required." );
		}
		if ( !val( prc.agSettings.ag_portal_paging_max_feeds ) ) {
			arrayAppend( errors, "A valid max feeds value is required." );
		}
		if ( !val( prc.agSettings.ag_portal_cache_timeout ) ) {
			arrayAppend( errors, "A valid portal cache timeout is required." );
		}
		if ( !val( prc.agSettings.ag_portal_cache_timeout_idle ) ) {
			arrayAppend( errors, "A valid portal cache idle timeout is required." );
		}

		// Importing settings
		if ( !len( prc.agSettings.ag_importing_import_interval ) ) {
			prc.agSettings.ag_importing_import_start_date = "";
			prc.agSettings.ag_importing_import_start_time = "";
		} else {
			if ( len( prc.agSettings.ag_importing_import_start_date ) && !isDate( prc.agSettings.ag_importing_import_start_date ) ) {
				arrayAppend( errors, "A valid start date is required." );
			} else if ( isDate( prc.agSettings.ag_importing_import_start_date ) ) {
				prc.agSettings.ag_importing_import_start_date = dateFormat( prc.agSettings.ag_importing_import_start_date, "mm/dd/yy" );
			} else {
				prc.agSettings.ag_importing_import_start_date = dateFormat( now(), "mm/dd/yy" );
			}
			if ( len( prc.agSettings.ag_importing_import_start_time ) && !isDate( prc.agSettings.ag_importing_import_start_time ) ) {
				arrayAppend( errors, "A valid start time is required." );
			} else if ( isDate( prc.agSettings.ag_importing_import_start_time ) ) {
				prc.agSettings.ag_importing_import_start_time = timeFormat( prc.agSettings.ag_importing_import_start_time, "short" );
			} else {
				prc.agSettings.ag_importing_import_start_time = timeFormat( now(), "short" );
			}
		}
		if ( !len( trim( prc.agSettings.ag_importing_secret_key ) ) ) {
			arrayAppend( errors, "A valid secret key is required." );
		}
		if ( len( prc.agSettings.ag_importing_max_feed_imports ) && !isNumeric( prc.agSettings.ag_importing_max_feed_imports ) ) {
			arrayAppend( errors, "A valid import history limit is required." );
		}
		if ( len( prc.agSettings.ag_importing_max_age ) && !isNumeric( prc.agSettings.ag_importing_max_age ) ) {
			arrayAppend( errors, "A valid age limit is required." );
		}
		if ( len( prc.agSettings.ag_importing_max_items ) && !isNumeric( prc.agSettings.ag_importing_max_items ) ) {
			arrayAppend( errors, "A valid item limit is required." );
		}
		prc.agSettings.ag_importing_match_any_filter = trim( prc.agSettings.ag_importing_match_any_filter );
		prc.agSettings.ag_importing_match_all_filter = trim( prc.agSettings.ag_importing_match_all_filter );
		prc.agSettings.ag_importing_match_none_filter = trim( prc.agSettings.ag_importing_match_none_filter );
		if ( len( prc.agSettings.ag_importing_image_minimum_width ) && !isNumeric( prc.agSettings.ag_importing_image_minimum_width ) ) {
			arrayAppend( errors, "A valid minimum width is required." );
		}
		if ( len( prc.agSettings.ag_importing_image_minimum_height ) && !isNumeric( prc.agSettings.ag_importing_image_minimum_height ) ) {
			arrayAppend( errors, "A valid minimum height is required." );
		}

		// Global html
		prc.agSettings.ag_html_pre_index_display = trim( prc.agSettings.ag_html_pre_index_display );
		prc.agSettings.ag_html_post_index_display = trim( prc.agSettings.ag_html_post_index_display );
		prc.agSettings.ag_html_pre_feeds_display = trim( prc.agSettings.ag_html_pre_feeds_display );
		prc.agSettings.ag_html_post_feeds_display = trim( prc.agSettings.ag_html_post_feeds_display );
		prc.agSettings.ag_html_pre_feed_display = trim( prc.agSettings.ag_html_pre_feed_display );
		prc.agSettings.ag_html_post_feed_display = trim( prc.agSettings.ag_html_post_feed_display );
		prc.agSettings.ag_html_pre_feedItem_display = trim( prc.agSettings.ag_html_pre_feedItem_display );
		prc.agSettings.ag_html_post_feedItem_display = trim( prc.agSettings.ag_html_post_feedItem_display );
		prc.agSettings.ag_html_pre_archives_display = trim( prc.agSettings.ag_html_pre_archives_display );
		prc.agSettings.ag_html_post_archives_display = trim( prc.agSettings.ag_html_post_archives_display );
		prc.agSettings.ag_html_pre_sidebar_display = trim( prc.agSettings.ag_html_pre_sidebar_display );
		prc.agSettings.ag_html_post_sidebar_display = trim( prc.agSettings.ag_html_post_sidebar_display );

		// RSS settings
		if ( !len( trim( prc.agSettings.ag_rss_title ) ) ) {
			arrayAppend( errors, "A valid feed title is required." );
		} else {
			prc.agSettings.ag_rss_title = trim( prc.agSettings.ag_rss_title );
		}
		if ( !len( trim( prc.agSettings.ag_rss_description ) ) ) {
			arrayAppend( errors, "A valid feed description is required." );
		} else {
			prc.agSettings.ag_rss_description = trim( prc.agSettings.ag_rss_description );
		}
		prc.agSettings.ag_rss_generator = trim( prc.agSettings.ag_rss_generator );
		prc.agSettings.ag_rss_copyright = trim( prc.agSettings.ag_rss_copyright );
		if ( len( trim( prc.agSettings.ag_rss_webmaster ) ) && !isValid( "email", trim( prc.agSettings.ag_rss_webmaster ) ) ) {
			arrayAppend( errors, "The value for the feed webmaster is invalid." );
		} else {
			prc.agSettings.ag_rss_webmaster = trim( prc.agSettings.ag_rss_webmaster );
		}
		if ( !val( prc.agSettings.ag_rss_max_items ) ) {
			arrayAppend( errors, "A valid max rss content items is required." );
		}
		if ( !val( prc.agSettings.ag_rss_cache_timeout ) ) {
			arrayAppend( errors, "A valid feed cache timeout is required." );
		}
		if ( !val( prc.agSettings.ag_rss_cache_timeout_idle ) ) {
			arrayAppend( errors, "A valid feed cache idle timeout is required." );
		}

		return errors;

	}

}