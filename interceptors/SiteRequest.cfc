/**
 * ContentBox RSS Aggregator
 * Site request interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="settingService" inject="settingService@cb";
	property name="contentService" inject="contentService@aggregator";
	property name="cbHelper" inject="CBHelper@cb";
	property name="html" inject="HTMLHelper@coldbox";
	property name="agHelper" inject="helper@aggregator";
	property name="moduleService" inject="coldbox:moduleService";
	property name="routingService" inject="coldbox:routingService";

	/**
	 * Fired on pre process during contentbox public requests only
	 */
	function preProcess( event, interceptData, buffer, rc, prc ) {

		// Check that module is active
		if ( !moduleService.isModuleRegistered("contentbox-aggregator") ) {
			return;
		}

		// Prepare UI if we are in the aggregator module
		if ( reFindNoCase( "^contentbox-aggregator", event.getCurrentEvent() ) ) {
			cbHelper.prepareUIRequest();
		// Return if in admin module
		} else if ( reFindNoCase( "^contentbox-admin", event.getCurrentEvent() ) ) {
			return;
		}

		// Helper
		prc.agHelper = agHelper;

		// Module root
		prc.agRoot = getContextRoot() & event.getModuleRoot( "contentbox-aggregator" );

		// Settings
		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		// Site
		//prc.xehNewsHome = "#prc.agSettings.ag_site_news_entrypoint#";
		//prc.xehFeedsHome = "#prc.agSettings.ag_site_feeds_entrypoint#";

	}

	/**
	 * Fired on post render during aggregator requests only
	 */
	function postRender( event, interceptData, buffer, rc, prc ) eventPattern="^contentbox-aggregator" {

		// Rules to turn off the admin bar
		if (
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
		) {
			return;
		}

		// Set args var
		var args = {
			oContent=javaCast( "null", "" ),
			linkEdit="",
			oCurrentAuthor=prc.oCurrentAuthor
		};

		// Check for cache
		if ( structKeyExists( prc, "contentCacheData" ) ) {
			if ( prc.contentCacheData.contentType NEQ "text/html" ) {
				return;
			}
			if ( val( prc.contentCacheData.contentID ) ) {
				args.oContent = contentService.get( prc.contentCacheData.contentID, false );
				if ( !isNull( args.oContent ) && args.oContent.getContentType() == "Feed" ) {
					prc.feed = args.oContent;
				} else {
					args.oContent = javaCast( "null", "" );
				}
			}
		}

		// Check for feed
		if ( structKeyExists( prc, "feed" ) ) {
			args.oContent = prc.feed;
			args.linkEdit = agHelper.linkFeedForm( prc.feed );
		// Check for feed item
		} else if ( structKeyExists( prc, "feedItem" ) ) {
			args.oContent = prc.feedItem;
			args.linkEdit = agHelper.linkFeedItemForm( prc.feedItem );
		}

		// Render the admin bar
		var adminBar = renderView(
			view="adminbar/index",
			module="contentbox-ui",
			args=args
		);

		// Hide custom fields and insert options
		if ( structKeyExists( prc, "feed" ) ) {
			adminBar &= "<style>##cb-admin-bar-actions .custom_fields,##cb-admin-bar-actions .comments{ display:none; } @media (max-width: 768px) { .button.importing{ display:none; } }</style>";
			adminBar &= "<script>$('<a href=""#args.linkEdit###importing"" class=""button importing"" target=""_blank"">Importing</a>').insertAfter('##cb-admin-bar-actions .edit');</script>";
		} else if ( structKeyExists( prc, "feedItem" ) ) {
			adminBar &= "<style>##cb-admin-bar-actions .custom_fields,##cb-admin-bar-actions .comments,##cb-admin-bar-actions .seo{ display:none; }</style>";
		// Insert clear cache button
		} else if ( structKeyExists( prc, "contentCacheData" ) ) {
			adminBar &= "<script>$('<a href=""#event.buildLink( event.getCurrentRoutedURL() )#?cbCache=true"" class=""button button-admin clear-cache"">Clear Cache</a>').insertBefore('##cb-admin-bar-actions .button-admin');</script>";
		}

		// Add to html head
		cfhtmlhead( text=adminBar );

	}

	/**
	 * Renderer helper injection
	 */
	function afterInstanceCreation( event, interceptData, buffer ) {
		if ( isInstanceOf( arguments.interceptData.target, "coldbox.system.web.Renderer" ) ) {
			var prc = event.getCollection( private=true );
			arguments.interceptData.target.ag = agHelper;
			arguments.interceptData.target.$agInject = variables.$agInject;
			arguments.interceptData.target.$agInject();
		}
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Injects the ag helper
	 */
	private function $aginject() {
		variables.ag = this.ag;
	}

}