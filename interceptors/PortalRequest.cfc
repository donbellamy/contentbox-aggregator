component extends="coldbox.system.Interceptor" {

	// TODO: rename to publicrequest or uirequest?
	property name="settingService" inject="settingService@aggregator";
	property name="cbHelper" inject="CBHelper@cb";
	property name="agHelper" inject="helper@aggregator";

	function configure() {}

	function preProcess( event, interceptData, buffer, rc, prc ) {

		// Prepare UI if we are in the aggregator module
		if ( reFindNoCase( "^contentbox-rss-aggregator", event.getCurrentEvent() ) ) {
			CBHelper.prepareUIRequest();
		// Return if in admin module
		} else if ( reFindNoCase( "^contentbox-admin", event.getCurrentEvent() ) ) {
			return;
		}

		// Settings
		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		// Entry point
		prc.agEntryPoint = prc.agSettings.ag_portal_entrypoint;

		// Portal
		prc.xehPortalHome = prc.agEntryPoint;
		prc.xehPortalFeeds = "#prc.agEntryPoint#.feeds";

	}

	function postRender( event, interceptData, buffer, rc, prc ) eventPattern="^contentbox-rss-aggregator" {}

	function postProcess( event, interceptData, buffer, rc, prc ) eventPattern="^contentbox-rss-aggregator" {}

	function afterInstanceCreation( event, interceptData, buffer, rc, prc ) eventPattern="^contentbox-rss-aggregator" {
		if( isInstanceOf( arguments.interceptData.target, "coldbox.system.web.Renderer" ) ) {
			var prc = event.getCollection( private=true ); // Needed?
			// decorate it
			arguments.interceptData.target.ag = agHelper;
			arguments.interceptData.target.$agInject = variables.$agInject;
			arguments.interceptData.target.$agInject();
			// re-broadcast event
			//announceInterception( 
			//	"cbui_onRendererDecoration",
			//	{ renderer=arguments.interceptData.target, CBHelper=arguments.interceptData.target.cb } 
			//);
		}
	}

	function $aginject() {
		variables.ag = this.ag;
	}

}