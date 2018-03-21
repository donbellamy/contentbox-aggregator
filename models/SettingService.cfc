component extends="contentbox.models.system.SettingService" accessors="true" threadsafe singleton {

	SettingService function init() {

		super.init();

		return this;

	}

	array function validateSettings() {

		var prc = requestService.getContext().getCollection( private=true );
		var errors = [];

		// Portal settings
		if ( !len( trim( prc.agSettings.ag_portal_entrypoint ) ) ) {
			arrayAppend( errors, "A valid portal entry point is required." );
		} else {
			prc.agSettings.ag_portal_entrypoint = trim( prc.agSettings.ag_portal_entrypoint );
		}
		if ( !len( trim( prc.agSettings.ag_portal_title ) ) ) {
			arrayAppend( errors, "A valid portal title is required." );
		} else {
			prc.agSettings.ag_portal_title = trim( prc.agSettings.ag_portal_title );
		}
		if ( !len( trim( prc.agSettings.ag_portal_feeds_title ) ) ) {
			arrayAppend( errors, "A valid feeds title is required." );
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

		// Display settings
		/*
		if ( len( prc.agSettings.ag_display_excerpt_character_limit ) && !isNumeric( prc.agSettings.ag_display_excerpt_character_limit ) ) {
			arrayAppend( errors, "A valid charcter limit is required." );
		}
		prc.agSettings.ag_display_excerpt_ending = trim( prc.agSettings.ag_display_excerpt_ending );
		prc.agSettings.ag_display_read_more_text = trim( prc.agSettings.ag_display_read_more_text );
		*/


		return errors;

	}

}