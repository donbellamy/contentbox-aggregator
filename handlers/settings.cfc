/**
 * ContentBox Aggregator
 * Settings handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="baseHandler" {

	// Dependencies
	property name="authorService" inject="authorService@cb";
	property name="roleService" inject="roleService@cb";
	property name="categoryService" inject="categoryService@cb";
	property name="pageService" inject="pageService@cb";
	property name="themeService" inject="themeService@cb";
	property name="markdownEditor" inject="markdownEditor@contentbox-markdowneditor";
	property name="routingService" inject="coldbox:routingService";
	property name="moduleSettings" inject="coldbox:moduleSettings:contentbox-aggregator";
	property name="cbModuleConfig" inject="coldbox:moduleConfig:contentbox-ui";

	/**
	 * Pre handler
	 */
	function preHandler( event, rc, prc, action, eventArguments ) {

		super.preHandler( argumentCollection=arguments );

		// Check permissions
		if ( !prc.oCurrentAuthor.checkPermission( "AGGREGATOR_SETTINGS" ) ) {
			cbMessagebox.error( "You do not have permission to access the aggregator settings." );
			setNextEvent( prc.cbAdminEntryPoint );
			return;
		}

	}

	/**
	 * Displays the settings form
	 */
	function index( event, rc, prc ) {

		// Lookups
		prc.pages = pageService.getAllFlatPages();
		prc.intervals = [
			{ name = "Never", value = "" },
			{ name = "Every 15 Minutes", value = "900" },
			{ name = "Every 30 Minutes", value = "1800" },
			{ name = "Every Hour", value = "3600" },
			{ name = "Every Two Hours", value = "7200" },
			{ name = "Every Twelve Hours", value = "43200" },
			{ name = "Once a Day", value = "daily" },
			{ name = "Once a Week", value = "weekly" },
			{ name = "Once a Month", value = "monthly" }
		];
		prc.authors = authorService.getAll( sortOrder = "lastName" );
		prc.categories = categoryService.getAll( sortOrder = "category" );
		prc.limitUnits = [
			{ name = "None", value = "" },
			{ name = "Days", value = "days" },
			{ name = "Weeks", value = "weeks" },
			{ name = "Months", value = "months" },
			{ name = "Years", value = "years" }
		];
		prc.linkOptions = [
			{ name = "Forward the user directly to the feed item.", value = "forward" },
			{ name = "Link the user directly to the feed item.", value = "link" },
			{ name = "Use an interstitial page before forwarding the user to the feed item.", value = "interstitial" },
			{ name = "Display the entire feed item within the site.", value = "display" }
		];
		prc.feedFeaturedImageOptions = [
			{ name = "Display the default featured image.", value = "default" },
			{ name = "Do not display a featured image.", value = "none" }
		];
		prc.featuredImageOptions = [
			{ name = "Display the parent feed's featured image.", value = "feed" },
			{ name = "Display the default featured image.", value = "default" },
			{ name = "Do not display a featured image.", value = "none" }
		];
		prc.cacheNames = cachebox.getCacheNames();
		prc.matchOptions = [
			{ name = "Only assign the categories above to feed items that contain 'any' of the keywords below in the title or body.", value = "any" },
			{ name = "Only assign the categories above to feed items that contain 'all' of the keywords below in the title or body.", value = "all" },
			{ name = "Only assign the categories above to feed items that contain 'any' of the keywords below in the feed item url or attachment url.", value = "url" },
			{ name = "Assign the categories above to all feed items ignoring any of the keywords below.", value = "none" }
		];
		markdownEditor.loadAssets();

		event.setView( "settings/index" );

	}

	/**
	 * Saves the settings
	 */
	function save( event, rc, prc ) {

		// Set timeout
		setting requestTimeout = "999999";

		// Old settings
		var oldSettings = duplicate( prc.agSettings );

		// Taxonomies
		var taxonomies = [];
		rc["importing_taxonomies"] = [];
		for ( var item IN rc ) {
			if ( reFindNoCase( "^importing_taxonomies_", item ) ) {
				var key = listLast( item, "_" );
				var count = listGetAt( item, 3, "_" );
				if ( arrayLen( taxonomies ) LT count ) {
					taxonomies[ count ] = {};
				}
				taxonomies[ count ][ key ] = rc[ item ];
			}
		}
		for ( var item IN taxonomies ) {
			if ( len( item.categories) &&
				( len( trim( item.keywords ) ) || item.method == "none"  )
			) {
				arrayAppend( rc["importing_taxonomies"], item );
			}
		}

		// Set settings struct
		for ( var key IN rc ) {
			if ( structKeyExists( prc.agSettings, key ) ) {
				prc.agSettings[ key ] = rc[ key ];
			}
		}

		announceInterception(
			"aggregator_preSettingsSave",
			{ settings = prc.agSettings, oldSettings = oldSettings }
		);

		// Validate settings
		var errors = validateSettings( prc );
		if ( arrayLen( errors ) ) {
			cbMessagebox.warn( messageArray=errors );
			return index( argumentCollection=arguments );
		}

		// Update the site routes
		routingService.setRoutes(
			routingService.getRoutes().map( function( item ) {
				if ( item.namespaceRouting IS "aggregator-feed-items" ) {
					item.pattern = item.regexpattern = ( len( cbModuleConfig.entryPoint ) ? cbModuleConfig.entryPoint & "/" : "" ) & replace( prc.agSettings.feed_items_entrypoint, "/", "-", "all" ) & "/";
				}
				if ( item.namespaceRouting IS "aggregator-feeds" ) {
					item.pattern = item.regexpattern = ( len( cbModuleConfig.entryPoint ) ? cbModuleConfig.entryPoint & "/" : "" ) & replace( prc.agSettings.feeds_entrypoint, "/", "-", "all" ) & "/";
				}
				return item;
			})
		);

		// Save settings
		var setting = settingService.findWhere( { name = "aggregator" } );
		setting.setValue( serializeJSON( prc.agSettings ) );
		settingService.save( setting );

		// Clear cache
		settingService.flushSettingsCache();

		// Import scheduled task
		if ( len( prc.agSettings.importing_interval ) ) {
			cfschedule(
				action = "update",
				task = "aggregator-import",
				url = "#prc.agHelper.linkImport(importActive=true)#",
				startDate = prc.agSettings.importing_start_date,
				startTime = prc.agSettings.importing_start_time,
				interval = prc.agSettings.importing_interval
			);
		} else {
			cfschedule( action = "delete", task = "aggregator-import" );
		}

		announceInterception(
			"aggregator_postSettingsSave",
			{ settings = prc.agSettings, oldSettings = oldSettings }
		);

		cbMessagebox.info( "Settings Updated!" );
		setNextEvent( prc.xehAggregatorSettings );

	}

	/**
	 * Resets the settings to the default settings
	 */
	function reset( event, rc, prc ) {

		// Set vars
		var currentSettings = prc.agSettings;
		var defaultSettings = moduleSettings;

		// Check to see if entry points changed and create pages if needed
		if ( ( currentSettings.feeds_entrypoint != defaultSettings.feeds_entrypoint ) || ( currentSettings.feed_items_entrypoint != defaultSettings.feed_items_entrypoint ) ) {

			// Set author
			if ( len( currentSettings.importing_feed_item_author ) ) {
				var author = authorService.get( currentSettings.importing_feed_item_author );
			} else {
				var adminRole = roleService.findWhere( { role="Administrator" } );
				var author = authorService.findWhere( { role=adminRole } );
			}

			// Check feeds entrypoint
			if ( currentSettings.feeds_entrypoint != defaultSettings.feeds_entrypoint ) {
				var feedsPage = pageService.findBySlug( defaultSettings.feeds_entrypoint );
				if ( feedsPage.isLoaded() ) {
					feedsPage.setLayout("aggregator");
					pageService.savePage( feedsPage );
				} else {
					feedsPage.setTitle( "Feeds" );
					feedsPage.setSlug( defaultSettings.feeds_entrypoint );
					feedsPage.setPublishedDate( now() );
					feedsPage.setCreator( author );
					feedsPage.setLayout( "aggregator" );
					feedsPage.addNewContentVersion(
						content = "<!-- Feeds page placeholder content. -->",
						changelog = "Page created by ContentBox Aggregator Module.",
						author = author
					);
					pageService.savePage( feedsPage );
				}
			}

			// Check feed items entrypoint
			if ( currentSettings.feed_items_entrypoint != defaultSettings.feed_items_entrypoint ) {
				var feedItemsPage = pageService.findBySlug( defaultSettings.feed_items_entrypoint );
				if ( feedItemsPage.isLoaded() ) {
					feedItemsPage.setLayout( "aggregator" );
					pageService.savePage( feedItemsPage );
				} else {
					feedItemsPage.setTitle( "News" );
					feedItemsPage.setSlug( defaultSettings.feed_items_entrypoint );
					feedItemsPage.setPublishedDate( now() );
					feedItemsPage.setCreator( author );
					feedItemsPage.setLayout( "aggregator" );
					feedItemsPage.addNewContentVersion(
						content = "<!-- Feed items page placeholder content. -->",
						changelog = "Page created by ContentBox Aggregator Module.",
						author = author
					);
					pageService.savePage( feedItemsPage );
				}
			}

			// Update the site routes
			routingService.setRoutes(
				routingService.getRoutes().map( function( item ) {
					if ( item.namespaceRouting IS "aggregator-feed-items" ) {
						item.pattern = item.regexpattern = ( len( cbModuleConfig.entryPoint ) ? cbModuleConfig.entryPoint & "/" : "" ) & replace( defaultSettings.feed_items_entrypoint, "/", "-", "all" ) & "/";
					}
					if ( item.namespaceRouting IS "aggregator-feeds" ) {
						item.pattern = item.regexpattern = ( len( cbModuleConfig.entryPoint ) ? cbModuleConfig.entryPoint & "/" : "" ) & replace( defaultSettings.feeds_entrypoint, "/", "-", "all" ) & "/";
					}
					return item;
				})
			);

		}

		// Save settings
		var setting = settingService.findWhere( { name = "aggregator" } );
		setting.setValue( serializeJSON( defaultSettings ) );
		settingService.save( setting );

		// Clear cache
		settingService.flushSettingsCache();

		// Forward to form
		cbMessagebox.info( "Settings Reset!" );
		setNextEvent( prc.xehAggregatorSettings );

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Validates the settings
	 * @return An array of errors or an empty array if none are present
	 */
	private array function validateSettings( prc ) {

		var errors = [];

		// Importing
		if ( !len( prc.agSettings.importing_interval ) ) {
			prc.agSettings.importing_start_date = "";
			prc.agSettings.importing_start_time = "";
		} else {
			if ( len( prc.agSettings.importing_start_date ) && !isDate( prc.agSettings.importing_start_date ) ) {
				arrayAppend( errors, "A valid start date is required." );
			} else if ( isDate( prc.agSettings.importing_start_date ) ) {
				prc.agSettings.importing_start_date = dateFormat( prc.agSettings.importing_start_date, "mm/dd/yy" );
			} else {
				prc.agSettings.importing_start_date = dateFormat( now(), "mm/dd/yy" );
			}
			if ( len( prc.agSettings.importing_start_time ) && !isDate( prc.agSettings.importing_start_time ) ) {
				arrayAppend( errors, "A valid start time is required." );
			} else if ( isDate( prc.agSettings.importing_start_time ) ) {
				prc.agSettings.importing_start_time = timeFormat( prc.agSettings.importing_start_time, "short" );
			} else {
				prc.agSettings.importing_start_time = timeFormat( now(), "short" );
			}
		}
		if ( !len( trim( prc.agSettings.importing_secret_key ) ) ) {
			arrayAppend( errors, "A valid secret key is required." );
		}
		if ( len( prc.agSettings.importing_max_feed_imports ) && !isNumeric( prc.agSettings.importing_max_feed_imports ) ) {
			arrayAppend( errors, "A valid import history limit is required." );
		}
		if ( len( prc.agSettings.importing_max_feed_item_age ) && !isNumeric( prc.agSettings.importing_max_feed_item_age ) ) {
			arrayAppend( errors, "A valid age limit is required." );
		}
		if ( len( prc.agSettings.importing_max_feed_items ) && !isNumeric( prc.agSettings.importing_max_feed_items ) ) {
			arrayAppend( errors, "A valid item limit is required." );
		}
		if ( val( prc.agSettings.importing_max_feed_items ) && !len( prc.agSettings.importing_max_feed_item_age_unit ) ) {
			arrayAppend( errors, "A valid age limit unit is required" );
		}
		prc.agSettings.importing_match_any_filter = trim( prc.agSettings.importing_match_any_filter );
		prc.agSettings.importing_match_all_filter = trim( prc.agSettings.importing_match_all_filter );
		prc.agSettings.importing_match_none_filter = trim( prc.agSettings.importing_match_none_filter );
		if ( len( prc.agSettings.importing_image_minimum_width ) && !isNumeric( prc.agSettings.importing_image_minimum_width ) ) {
			arrayAppend( errors, "A valid minimum width is required." );
		}
		if ( len( prc.agSettings.importing_image_minimum_height ) && !isNumeric( prc.agSettings.importing_image_minimum_height ) ) {
			arrayAppend( errors, "A valid minimum height is required." );
		}

		// Site options
		if ( !len( trim( prc.agSettings.feeds_entrypoint ) ) ) {
			arrayAppend( errors, "A feeds page is required." );
		} else {
			prc.agSettings.feeds_entrypoint = trim( prc.agSettings.feeds_entrypoint );
		}
		if ( !len( trim( prc.agSettings.feed_items_entrypoint ) ) ) {
			arrayAppend( errors, "A feed items page is required." );
		} else {
			prc.agSettings.feed_items_entrypoint = trim( prc.agSettings.feed_items_entrypoint );
		}
		if ( prc.agSettings.feed_items_entrypoint == prc.agSettings.feeds_entrypoint ) {
			arrayAppend( errors, "The feed items and feeds pages must be different." );
		}
		if ( !val( prc.agSettings.feed_items_excerpt_limit ) ) {
			arrayAppend( errors, "A valid max feed items value is required." );
		}
		prc.agSettings.feed_items_excerpt_ending = trim( prc.agSettings.feed_items_excerpt_ending );
		prc.agSettings.feed_items_read_more_text = trim( prc.agSettings.feed_items_read_more_text );
		if ( !val( prc.agSettings.paging_max_feeds ) ) {
			arrayAppend( errors, "A valid max feeds value is required." );
		}
		if ( !val( prc.agSettings.paging_max_feed_items ) ) {
			arrayAppend( errors, "A valid max feed items value is required." );
		}
		if ( !val( prc.agSettings.site_cache_timeout ) ) {
			arrayAppend( errors, "A valid site cache timeout is required." );
		}
		if ( !val( prc.agSettings.site_cache_idle_timeout ) ) {
			arrayAppend( errors, "A valid site cache idle timeout is required." );
		}

		// Global html
		prc.agSettings.html_pre_feed_items_display = trim( prc.agSettings.html_pre_feed_items_display );
		prc.agSettings.html_post_feed_items_display = trim( prc.agSettings.html_post_feed_items_display );
		prc.agSettings.html_pre_feeds_display = trim( prc.agSettings.html_pre_feeds_display );
		prc.agSettings.html_post_feeds_display = trim( prc.agSettings.html_post_feeds_display );
		prc.agSettings.html_pre_feed_display = trim( prc.agSettings.html_pre_feed_display );
		prc.agSettings.html_post_feed_display = trim( prc.agSettings.html_post_feed_display );
		prc.agSettings.html_pre_feedItem_display = trim( prc.agSettings.html_pre_feedItem_display );
		prc.agSettings.html_post_feedItem_display = trim( prc.agSettings.html_post_feedItem_display );
		prc.agSettings.html_pre_archives_display = trim( prc.agSettings.html_pre_archives_display );
		prc.agSettings.html_post_archives_display = trim( prc.agSettings.html_post_archives_display );
		prc.agSettings.html_pre_sidebar_display = trim( prc.agSettings.html_pre_sidebar_display );
		prc.agSettings.html_post_sidebar_display = trim( prc.agSettings.html_post_sidebar_display );

		// RSS
		if ( !len( trim( prc.agSettings.rss_title ) ) ) {
			arrayAppend( errors, "A valid feed title is required." );
		} else {
			prc.agSettings.rss_title = trim( prc.agSettings.rss_title );
		}
		if ( !len( trim( prc.agSettings.rss_description ) ) ) {
			arrayAppend( errors, "A valid feed description is required." );
		} else {
			prc.agSettings.rss_description = trim( prc.agSettings.rss_description );
		}
		prc.agSettings.rss_generator = trim( prc.agSettings.rss_generator );
		prc.agSettings.rss_copyright = trim( prc.agSettings.rss_copyright );
		if ( len( trim( prc.agSettings.rss_webmaster ) ) && !isValid( "email", trim( prc.agSettings.rss_webmaster ) ) ) {
			arrayAppend( errors, "The value for the feed webmaster is invalid." );
		} else {
			prc.agSettings.rss_webmaster = trim( prc.agSettings.rss_webmaster );
		}
		if ( !val( prc.agSettings.rss_max_feed_items ) ) {
			arrayAppend( errors, "A valid max rss content items is required." );
		}
		if ( !val( prc.agSettings.rss_cache_timeout ) ) {
			arrayAppend( errors, "A valid feed cache timeout is required." );
		}
		if ( !val( prc.agSettings.rss_cache_idle_timeout ) ) {
			arrayAppend( errors, "A valid feed cache idle timeout is required." );
		}

		return errors;

	}

}