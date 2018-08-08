component extends="coldbox.system.Interceptor" {

	property name="html" inject="HTMLHelper@coldbox";
	property name="settingService" inject="settingService@cb";
	property name="helper" inject="helper@aggregator";

	function preProcess( event, interceptData, rc, prc ) eventPattern="^contentbox-admin" {

		// Helper
		prc.agHelper = helper;

		// Module root
		prc.agRoot = getContextRoot() & event.getModuleRoot( "contentbox-aggregator" );

		// Settings
		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		// Portal entry point
		prc.agEntryPoint = prc.agSettings.ag_portal_entrypoint;

		// Admin entry point
		prc.agAdminEntryPoint = "#getModuleConfig('contentbox-admin').entryPoint#.module.#getModuleConfig('contentbox-aggregator').entryPoint#";

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

	function postRender( event, interceptData, buffer, rc, prc ) eventPattern="^contentbox-admin" {

		// Param format
		event.paramValue( "format", "html" );

		// Add portal link, new feed and clear cache to nav bar
		if ( !event.isAjax() && rc.format EQ "html" ) {
			html.$htmlhead("<script>
				$(function() {
					$('div.user-nav ul li:first').after('<li data-placement=""right auto"" title=""Visit Portal""><a class=""btn btn-default options toggle"" href=""#helper.linkPortal()#"" target=""_blank""><i class=""fa fa-newspaper-o""></i></a></li>');
				});
			</script>");
			if ( prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN,FEEDS_EDITOR" ) ) {
				html.$htmlhead("<script>
					$(function() {
						$('div.user-nav ul.dropdown-menu:first').append('<li><a data-keybinding=""ctrl+shift+f"" href=""#helper.linkFeedForm()#"" title=""ctrl+shift+f""><i class=""fa fa-rss""></i> New Feed</a></li>');
					});
				</script>");
			}
			if ( prc.oCurrentAuthor.checkPermission( "RELOAD_MODULES" ) ) {
				html.$htmlhead("<script>
					$(function() {
						$('li[data-name=""utils""] ul.dropdown-menu').append('<li data-name=""portal""><a href=""javascript:adminAction( \'portal-purge\', \'#event.buildLink( prc.xehClearPortalCache )#\' );"" class="""">Clear Portal Caches</a></li>');
					});
				</script>");
			}
		}

		// Fix dashbaord content links
		if ( event.getCurrentEvent() EQ "contentbox-admin:dashboard.latestsystemedits" ) {
			html.$htmlhead('<script>
				$(function() {
					$("table[id*=''contentTable''] tbody tr").each(function(){
						var $titleLink = $(this).find("td:first a");
						var $actionLink = $(this).find("td:last a");
						var contentType = $(this).find("td:first span").text();
						var url = $titleLink.attr("href");
						var contentID = url.substring( url.lastIndexOf("/") + 1 );
						if ( contentType == "FeedItem" ) {
							$titleLink.attr("title","Edit Feed Item");
							$titleLink.attr("href", "#helper.linkFeedItemForm()#/contentID/" + contentID);
							$actionLink.attr("title","Edit Feed Item");
							$actionLink.attr("href", "#helper.linkFeedItemForm()#/contentID/" + contentID);
						} else if ( contentType == "Feed" ) {
							$titleLink.attr("title","Edit Feed");
							$titleLink.attr("href", "#helper.linkFeedForm()#/contentID/" + contentID);
							$actionLink.attr("title","Edit Feed");
							$actionLink.attr("href", "#helper.linkFeedForm()#/contentID/" + contentID);
						}
					});
				});
			</script>');
		}

		// Fix top hit links, top commented links and add content counts
		if ( event.getCurrentEvent() EQ "contentbox-admin:dashboard.latestSnapshot" ) {
			html.$htmlhead('<script>
				$(function() {
					$("##topcontent table:first tbody").load( "#event.buildLink( prc.xehTopContent )#" );
					$("##topcontent table:last tbody").load( "#event.buildLink( prc.xehTopCommented )#" );
					$("##content div").load( "#event.buildLink( prc.xehContentCounts )#" );
				});
			</script>');
		}

		// Add feed items to related content selector
		if ( event.getCurrentEvent() EQ "contentbox-admin:content.showRelatedContentSelector" ) {
			html.$htmlhead('<script>
				$(function() {
					$("##contentContainer ul.nav-tabs").append(''<li><a href="##FeedItem" data-toggle=tab"><i class="fa fa-rss icon-small" title=FeedItem"></i> FeedItem</a></li>'');
					$("##contentContainer div.tab-content").append(''<div class="tab-pane fade" id="FeedItem"></div>'');
					$("##contentSearch").keyup(
						_.debounce(
							function(){
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
				});
			</script>');
		}

	}

	function aggregator_feedItemEditorSidebarFooter() {
		appendToBuffer( getRelatedContentIconScript() );
	}

	function cbadmin_pageEditorSidebarFooter() {
		appendToBuffer( getRelatedContentIconScript() );
	}

	function cbadmin_entryEditorSidebarFooter() {
		appendToBuffer( getRelatedContentIconScript() );
	}

	/************************************** PRIVATE *********************************************/

	private function getRelatedContentIconScript() {
		return '<script>
			$(function() {
				$("##relatedContent-items tr td:first-child, ##linkedContent-items tr td:first-child").each(function(){
					var $this = $(this);
					// No child so assume it is a feed item - TODO: need to modify cb code to add a content type class
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