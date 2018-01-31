component accessors="true" singleton threadSafe {

	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="settingService" inject="settingService@aggregator";
	property name="requestService" inject="coldbox:requestService";
	property name="controller" inject="coldbox";
	property name="cbHelper" inject="CBHelper@cb";

	function init() {
		return this;
	}

	function getRequestContext() {
		return requestService.getContext();
	}

	struct function getRequestCollection( boolean private=false ) {
		return getRequestContext().getCollection( private=arguments.private );
	}

	struct function getPrivateRequestCollection() {
		return getRequestCollection( private=true );
	}

	struct function getModuleSettings( required module ) {
		return getModuleConfig( arguments.module ).settings;
	}

	struct function getModuleConfig( required module ) {
		var mConfig = controller.getSetting( "modules");
		if( structKeyExists( mConfig, arguments.module ) ) {
			return mConfig[ arguments.module ];
		}
		throw( 
			message = "The module you passed #arguments.module# is invalid.",
			detail = "The loaded modules are #structKeyList( mConfig )#",
			type = "FrameworkSuperType.InvalidModuleException"
		);
	}

	any function setting( required key, value ) {

		var prc = getPrivateRequestCollection();

		if ( structKeyExists( prc.agSettings, arguments.key ) ) {
			return prc.agSettings[ key ];
		}
		if ( structKeyExists( arguments, "value" ) ){
			return arguments.value;
		}
		throw(
			message = "Setting requested: #arguments.key# not found",
			detail	= "Settings keys are #structKeyList( prc.agSettings )#",
			type 	= "aggregator.helper.InvalidSetting" 
		);

	}

	function getAggregatorVersion() {
		return getModuleConfig("contentbox-rss-aggregator").version;
	}

	function getPortalEntryPoint() {
		return setting( "ag_portal_entrypoint", "news" );
	}

	function getSiteRoot() {
		var prc = getPrivateRequestCollection();
		return prc.cbEntryPoint;
	}

	function linkPortal( boolean ssl=getRequestContext().isSSL() ) {
		return getRequestContext().buildLink( linkto=len( getSiteRoot() ) ? getSiteRoot() & "." & getPortalEntryPoint() : getPortalEntryPoint(), ssl=arguments.ssl );
	}

}