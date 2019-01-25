/**
 * ContentBox RSS Aggregator
 * Admin request interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="html" inject="HTMLHelper@coldbox";
	property name="settingService" inject="settingService@cb";
	property name="agHelper" inject="helper@aggregator";

	/**
	 * Fired on pre process during contentbox admin requests only
	 */
	function preProcess( event, interceptData, rc, prc ) eventPattern="^contentbox-admin" {

		// Helper
		prc.agHelper = agHelper;

		// Module root
		prc.agRoot = getContextRoot() & event.getModuleRoot( "contentbox-aggregator" );

		// Settings
		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		// Portal entry point
		prc.agEntryPoint = prc.agSettings.ag_portal_entrypoint;

		// Admin entry point
		prc.agAdminEntryPoint = "#getModuleConfig('contentbox-admin').entryPoint#.module.#getModuleConfig('contentbox-aggregator').entryPoint#";

		/************************************** NAVIGATION EXIT HANDLERS *********************************************/

		// Dashboard
		prc.xehTopContent = "#prc.agAdminEntryPoint#.dashboard.topcontent";
		prc.xehTopCommented = "#prc.agAdminEntryPoint#.dashboard.topcommented";
		prc.xehContentCounts = "#prc.agAdminEntryPoint#.dashboard.contentcounts";
		prc.xehClearPortalCache = "#prc.agAdminEntryPoint#.dashboard.clearcache";

		// Feeds
		prc.xehFeeds = "#prc.agAdminEntryPoint#.feeds";
		prc.xehFeedSearch = "#prc.agAdminEntryPoint#.feeds";
		prc.xehFeedTable = "#prc.agAdminEntryPoint#.feeds.table";
		prc.xehFeedStatus = "#prc.agAdminEntryPoint#.feeds.updateStatus";
		prc.xehFeedState = "#prc.agAdminEntryPoint#.feeds.state";
		prc.xehFeedEditor = "#prc.agAdminEntryPoint#.feeds.editor";
		prc.xehFeedSave = "#prc.agAdminEntryPoint#.feeds.save";
		prc.xehFeedRemove = "#prc.agAdminEntryPoint#.feeds.remove";
		prc.xehFeedImport = "#prc.agAdminEntryPoint#.feeds.import";
		prc.xehFeedImportAll = "#prc.agAdminEntryPoint#.feeds.importAll";
		prc.xehFeedImportView = "#prc.agAdminEntryPoint#.feeds.viewImport";
		prc.xehFeedImportRemove = "#prc.agAdminEntryPoint#.feeds.removeImport";
		prc.xehFeedResetHits = "#prc.agAdminEntryPoint#.feeds.resetHits";

		// Feeditems
		prc.xehFeedItems = "#prc.agAdminEntryPoint#.feeditems";
		prc.xehFeedItemSearch = "#prc.agAdminEntryPoint#.feeditems";
		prc.xehFeedItemTable = "#prc.agAdminEntryPoint#.feeditems.table";
		prc.xehFeedItemStatus = "#prc.agAdminEntryPoint#.feeditems.updateStatus";
		prc.xehFeedItemEditor = "#prc.agAdminEntryPoint#.feeditems.editor";
		prc.xehFeedItemSave = "#prc.agAdminEntryPoint#.feeditems.save";
		prc.xehFeedItemCategories = "#prc.agAdminEntryPoint#.feeditems.saveCategories";
		prc.xehFeedItemRemove = "#prc.agAdminEntryPoint#.feeditems.remove";
		prc.xehFeedItemResetHits = "#prc.agAdminEntryPoint#.feeditems.resetHits";
		prc.xehFeedItemImportView = "#prc.agAdminEntryPoint#.feeditems.viewImport";
		prc.xehFeedItemEntry = "#prc.agAdminEntryPoint#.feeditems.saveAsEntry";

		// Settings
		prc.xehAggregatorSettings = "#prc.agAdminEntryPoint#.settings";
		prc.xehAggregatorSettingsSave = "#prc.agAdminEntryPoint#.settings.save";

	}

	/**
	 * Fired on post render during contentbox admin requests only
	 */
	function postRender( event, interceptData, buffer, rc, prc ) eventPattern="^contentbox-admin" {

		// Param format
		event.paramValue( "format", "html" );

		// Add portal link, new feed and clear cache to nav bar
		if ( !event.isAjax() && rc.format EQ "html" ) {
			html.addJSContent("$(function(){$('div.user-nav ul li:first').after('<li data-placement=""right auto"" title=""Visit Portal""><a class=""btn btn-default options toggle"" href=""#agHelper.linkPortal()#"" target=""_blank""><i class=""fa fa-newspaper-o""></i></a></li>');});",true);
			if ( prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN,FEEDS_EDITOR" ) ) {
				html.addJSContent("$(function() {$('div.user-nav ul.dropdown-menu:first').append('<li><a data-keybinding=""ctrl+shift+f"" href=""#agHelper.linkFeedForm()#"" title=""ctrl+shift+f""><i class=""fa fa-rss""></i> New Feed</a></li>');});",true);
			}
			if ( prc.oCurrentAuthor.checkPermission( "RELOAD_MODULES" ) ) {
				html.addJSContent("$(function() {$('li[data-name=""utils""] ul.dropdown-menu').append('<li data-name=""portal""><a href=""javascript:adminAction( \'portal-purge\', \'#event.buildLink( prc.xehClearPortalCache )#\' );"" class="""">Clear Portal Caches</a></li>');});",true);
			}
		}

		// Fix dashbaord content links
		if ( event.getCurrentEvent() == "contentbox-admin:dashboard.latestsystemedits" ||
			event.getCurrentEvent() == "contentbox-admin:dashboard.futurePublishedContent" ||
			event.getCurrentEvent() == "contentbox-admin:dashboard.expiredContent" ||
			event.getCurrentEvent() == "contentbox-admin:dashboard.latestUserDrafts"
		 ) {
			html.addJSContent('$(function() {
				$("table[id*=''contentTable''] tbody tr").each(function() {
					var $titleLink = $(this).find("td:first a");
					var $actionLink = $(this).find("td:last a");
					var $icon =  $(this).find("td:last a i");
					var contentType = $(this).find("td:first span").text();
					var url = $titleLink.attr("href");
					var contentID = url.substring( url.lastIndexOf("/") + 1 );
					if ( contentType == "FeedItem" ) {
						$titleLink.attr("title","Edit FeedItem");
						$titleLink.attr("href", "#agHelper.linkFeedItemForm()#/contentID/" + contentID);
						$actionLink.attr("title","View in Site").attr("target","_blank");
						$actionLink.removeClass("btn-primary").addClass("btn-info");
						$actionLink.attr("href", "#agHelper.linkFeedItemsAdmin()#/view/contentID/" + contentID);
						$icon.removeClass("fa-edit").addClass("fa-eye");
					} else if ( contentType == "Feed" ) {
						$titleLink.attr("title","Edit Feed");
						$titleLink.attr("href", "#agHelper.linkFeedForm()#/contentID/" + contentID);
						$actionLink.attr("title","View in Site").attr("target","_blank");
						$actionLink.removeClass("btn-primary").addClass("btn-info");
						$actionLink.attr("href", "#agHelper.linkFeedsAdmin()#/view/contentID/" + contentID);
						$icon.removeClass("fa-edit").addClass("fa-eye");
					}
				});
			});',true);
		}

		// Fix top hit links, top commented links and add content counts
		if ( event.getCurrentEvent() == "contentbox-admin:dashboard.latestSnapshot" ) {
			html.addJSContent('$(function() {
				$("##topcontent table:first tbody").load( "#event.buildLink( prc.xehTopContent )#" );
				$("##topcontent table:last tbody").load( "#event.buildLink( prc.xehTopCommented )#" );
				$("##content div").load( "#event.buildLink( prc.xehContentCounts )#" );
			});',true);
		}

		// Add feed items to related content selector
		if ( event.getCurrentEvent() == "contentbox-admin:content.showRelatedContentSelector" ) {
			html.addJSContent('$(function() {
				$("##contentContainer ul.nav-tabs").append(''<li><a href="##FeedItem" data-toggle=tab"><i class="fa fa-rss icon-small" title=FeedItem"></i> FeedItem</a></li>'');
				$("##contentContainer div.tab-content").append(''<div class="tab-pane fade" id="FeedItem"></div>'');
				$("##contentSearch").keyup(
					_.debounce(
						function() {
							var $this = $(this);
							var clearIt = ( $this.val().length > 0 ? false : true );
							var params = { search: $this.val(), clear: clearIt };
							loadContentTypeTab( "FeedItem", params );
						},
						300
					)
				);
				function waitForIt() {
					if ( typeof loadContentTypeTab !== "undefined" ) {
						loadContentTypeTab( "FeedItem", {} )
					} else {
						setTimeout(waitForIt,250);
					}
				}
				waitForIt();
			});',true);
		}

	}

	/**
	 * Fired after feed item editor sidebar is rendered
	 */
	function aggregator_feedItemEditorSidebarFooter( event, interceptData, buffer ) {
		arguments.buffer.append( getRelatedContentIconScript() );
	}

	/**
	 * Fired after page editor sidebar is rendered
	 */
	function cbadmin_pageEditorSidebarFooter( event, interceptData, buffer ) {
		arguments.buffer.append( getRelatedContentIconScript() );
	}

	/**
	 * Fired after entry editor sidebar is rendered
	 */
	function cbadmin_entryEditorSidebarFooter( event, interceptData, buffer ) {
		arguments.buffer.append( getRelatedContentIconScript() );
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Gets the related content icon script
	 * @return The related content icon script
	 */
	private string function getRelatedContentIconScript() {
		return '<script>
			$(function() {
				$("##relatedContent-items tr td:first-child, ##linkedContent-items tr td:first-child").each(function() {
					var $this = $(this);
					// No child so assume it is a feed item
					if ( $this.children().length == 0 ) {
						$this.append(''<i class="fa fa-rss icon-small" title="FeedItem"></i>'');
					}
				});
			});
			function getIconByContentType( type ) {
				var icon = "";
				switch( type ) {
					case "Page":
						icon = ''<i class="fa fa-file icon-small" title="Page"></i>'';
						break;
					case "Entry":
						icon = ''<i class="fa fa-quote-left icon-small" title="Entry"></i>'';
						break;
					case "ContentStore":
						icon = ''<i class="fa fa-hdd-o icon-small" title="ContentStore"></i>'';
						break;
					case "FeedItem":
						icon = ''<i class="fa fa-rss icon-small" title="FeedItem"></i>'';
						break;
				}
				return icon;
			}
		</script>';
	}

}