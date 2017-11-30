component extends="contentbox.models.system.SettingService" accessors="true" threadsafe singleton {

	property name="requestService" inject="coldbox:requestService";

	SettingService function init() {

		super.init();

		return this;

	}

	struct function getSettings() {

		return deserializeJSON( getSetting( "aggregator" ) );

	}

	array function validateSettings() { 

		var prc = requestService.getContext().getCollection( private=true );
		var errors = [];

		if ( !len( prc.agSettings.ag_general_import_interval ) ) {
			
		} else {

		}

		return errors;

	}

}