component extends="coldbox.system.Interceptor" {

	property name="settingService" inject="settingService@aggregator";
	property name="cbHelper" inject="CBHelper@cb";
	property name="helper" inject="helper@aggregator";
	property name="html" inject="HTMLHelper@coldbox";

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

	function postRender( event, interceptData, buffer, rc, prc ) eventPattern="^contentbox-rss-aggregator" {

		// Rules to turn off the admin bar
		if(
			// Disabled SiteBar Setting
			!prc.cbSettings.cb_site_adminbar
			||
			// Disabled SiteBar per request
			structKeyExists( prc, "cbAdminBar" ) and !prc.cbAdminBar
			||
			// Ajax Request
			event.isAjax()
			||
			// Output Format not HTML
			( structKeyExists( rc, "format" ) && rc.format != "html" )
			||
			// Logged In
			!prc.oCurrentAuthor.isLoggedIn()
			||
			// Permissions
			!prc.oCurrentAuthor.checkPermission( "CONTENTBOX_ADMIN,FEEDS_ADMIN,FEEDS_EDITOR" )
		){
			return;
		}

		// Set args var
		var args = {
			oContent=javaCast( "null", "" ),
			linkEdit="",
			oCurrentAuthor=prc.oCurrentAuthor
		};

		// TODO: work this in when doing caching stuff
		/*if( structKeyExists( prc, "contentCacheData" ) ){
			if( prc.contentCacheData.contentType neq "text/html" ){
				return;
			}
			var feed = contentService.get( prc.contentCacheData.contentID );
		}*/

		// Check for feed
		if ( structKeyExists( prc, "feed" ) ) {
			args.oContent = prc.feed;
			args.linkEdit = helper.linkFeedForm( prc.feed );
		}

		// Render the admin bar
		var adminBar = renderView(
			view="adminbar/index",
			module="contentbox-ui",
			args=args
		);

		// Hide custom fields and insert options
		if ( structKeyExists( prc, "feed" ) ) {
			adminBar &= "<style>##cb-admin-bar-actions .custom_fields,##cb-admin-bar-actions .comments{ display:none; }</style>";
			adminBar &= "<script>$('<a href=""#args.linkEdit###importing"" class=""button options"" target=""_blank"">Importing</a>').insertAfter('##cb-admin-bar-actions .edit');</script>";
		}

		// Add to html
		html.$htmlhead( adminBar );

	}

	function postProcess( event, interceptData, buffer, rc, prc ) eventPattern="^contentbox-rss-aggregator" {}

	function afterInstanceCreation( event, interceptData, buffer, rc, prc ) eventPattern="^contentbox-rss-aggregator" {
		if( isInstanceOf( arguments.interceptData.target, "coldbox.system.web.Renderer" ) ) {
			var prc = event.getCollection( private=true ); // Needed?
			// decorate it
			arguments.interceptData.target.ag = helper;
			arguments.interceptData.target.$agInject = variables.$agInject;
			arguments.interceptData.target.$agInject();
			// re-broadcast event
			// TODO: test this
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