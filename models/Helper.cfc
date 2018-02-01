component accessors="true" singleton threadSafe {

	property name="requestService" inject="coldbox:requestService";

	function init() {
		return this;
	}

	function getRequestContext() {
		return requestService.getContext();
	}

	function getCBEntryPoint() {
		var prc = getRequestContext().getCollection( private=true );
		return prc.cbEntryPoint;
	}

	function getPortalEntryPoint() {
		var prc = getRequestContext().getCollection( private=true );
		return prc.agEntryPoint;
	}

	function linkPortal( boolean ssl=getRequestContext().isSSL() ) {
		return requestService.getContext().buildLink( linkto=len( getCBEntryPoint() ) ? getCBEntryPoint() & "." & getPortalEntryPoint() : getPortalEntryPoint(), ssl=arguments.ssl );
	}

}