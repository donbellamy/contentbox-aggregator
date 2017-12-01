component extends="contentbox.models.system.SettingService" accessors="true" threadsafe singleton {

	property name="requestService" inject="coldbox:requestService";

	SettingService function init() {

		super.init();

		return this;

	}

	array function validateSettings() { 

		var prc = requestService.getContext().getCollection( private=true );
		var errors = [];

		// General settings
		if ( !len( prc.agSettings.ag_general_import_interval ) ) {
			prc.agSettings.ag_general_import_start_date = "";
			prc.agSettings.ag_general_import_start_time = "";
		} else {
			if ( len( prc.agSettings.ag_general_import_start_date ) && !isDate( prc.agSettings.ag_general_import_start_date ) ) {
				arrayAppend( errors, "A valid start date is required." );
			} else {
				prc.agSettings.ag_general_import_start_date = dateFormat( now(), "mm/dd/yy" );
			}
			if ( len( prc.agSettings.ag_general_import_start_time ) && !isDate( prc.agSettings.ag_general_import_start_time ) ) {
				arrayAppend( errors, "A valid start time is required." );
			} else {
				prc.agSettings.ag_general_import_start_time = timeFormat( now(), "short" );
			}
		}
		if ( len( prc.agSettings.ag_general_max_age ) && !isNumeric( prc.agSettings.ag_general_max_age ) ) {
			arrayAppend( errors, "A valid age limit is required." );
		}
		if ( len( prc.agSettings.ag_general_max_items ) && !isNumeric( prc.agSettings.ag_general_max_items ) ) {
			arrayAppend( errors, "A valid item limit is required." );
		}
		prc.agSettings.ag_general_match_any_filter = trim( left( prc.agSettings.ag_general_match_any_filter, 255 ) );
		prc.agSettings.ag_general_match_all_filter = trim( left( prc.agSettings.ag_general_match_all_filter, 255 ) );
		prc.agSettings.ag_general_match_none_filter = trim( left( prc.agSettings.ag_general_match_none_filter, 255 ) );
		if ( !len( prc.agSettings.ag_general_log_file_name ) ) {
			arrayAppend( errors, "A valid log file name is required." );
		}

		// Display settings
		if ( len( prc.agSettings.ag_display_excerpt_word_limit ) && !isNumeric( prc.agSettings.ag_display_excerpt_word_limit ) ) {
			arrayAppend( errors, "A valid word limit is required." );
		}
		prc.agSettings.ag_display_excerpt_ending = trim( prc.agSettings.ag_display_excerpt_ending );
		prc.agSettings.ag_display_read_more_text = trim( prc.agSettings.ag_display_read_more_text );

		// Portal settings

		// RSS feed settings

		return errors;

	}

}