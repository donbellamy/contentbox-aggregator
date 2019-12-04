/**
 * ContentBox Aggregator
 * Settings handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="baseHandler" {

	// Dependencies
	property name="authorService" inject="authorService@cb";
	property name="categoryService" inject="categoryService@cb";
	property name="pageService" inject="pageService@cb";
	property name="themeService" inject="themeService@cb";
	property name="markdownEditor" inject="markdownEditor@contentbox-markdowneditor";
	property name="routingService" inject="coldbox:routingService";

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
		prc.limitUnits = [ "days", "weeks", "months", "years" ];
		prc.linkOptions = [
			{ name = "Forward the user directly to the feed item.", value = "forward" },
			{ name = "Link the user directly to the feed item.", value = "link" },
			{ name = "Use an interstitial page before forwarding the user to the feed item.", value = "interstitial" },
			{ name = "Display the entire feed item within the site.", value = "display" }
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
		if ( structKeyExists( rc, "ag_importing_taxonomies" ) ) {
			var taxonomies = [];
			for ( var item IN structKeyArray( rc.ag_importing_taxonomies ) ) {
				if ( structKeyExists( rc.ag_importing_taxonomies[item], "categories" ) &&
					( len( trim( rc.ag_importing_taxonomies[item].keywords ) ) || rc.ag_importing_taxonomies[item].method == "none" )
				) {
					arrayAppend( taxonomies, rc.ag_importing_taxonomies[item] );
				}
			}
			rc.ag_importing_taxonomies = taxonomies;
		} else {
			rc.ag_importing_taxonomies = [];
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
				if ( item.namespaceRouting EQ "aggregator-feed-items" ) {
					item.pattern = item.regexpattern = replace( prc.agSettings.ag_site_feed_items_entrypoint, "/", "-", "all" ) & "/";
				}
				if ( item.namespaceRouting EQ "aggregator-feeds" ) {
					item.pattern = item.regexpattern = replace( prc.agSettings.ag_site_feeds_entrypoint, "/", "-", "all" ) & "/";
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
		if ( len( prc.agSettings.ag_importing_import_interval ) ) {
			cfschedule(
				action = "update",
				task = "aggregator-import",
				url = "#prc.agHelper.linkImport(importActive=true)#",
				startDate = prc.agSettings.ag_importing_import_start_date,
				startTime = prc.agSettings.ag_importing_import_start_time,
				interval = prc.agSettings.ag_importing_import_interval
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

	/************************************** PRIVATE *********************************************/

	/**
	 * Validates the settings
	 * @return An array of errors or an empty array if none are present
	 */
	private array function validateSettings( prc ) {

		var errors = [];

		// Site Options
		if ( !len( trim( prc.agSettings.ag_site_feeds_entrypoint ) ) ) {
			arrayAppend( errors, "A feeds page is required." );
		} else {
			prc.agSettings.ag_site_feeds_entrypoint = trim( prc.agSettings.ag_site_feeds_entrypoint );
		}
		if ( !len( trim( prc.agSettings.ag_site_feed_items_entrypoint ) ) ) {
			arrayAppend( errors, "A feed items page is required." );
		} else {
			prc.agSettings.ag_site_feed_items_entrypoint = trim( prc.agSettings.ag_site_feed_items_entrypoint );
		}
		if ( prc.agSettings.ag_site_feed_items_entrypoint == prc.agSettings.ag_site_feeds_entrypoint ) {
			arrayAppend( errors, "The feed items and feeds pages must be different." );
		}
		if ( !val( prc.agSettings.ag_site_feed_items_excerpt_limit ) ) {
			arrayAppend( errors, "A valid max feed items value is required." );
		}
		prc.agSettings.ag_site_feed_items_excerpt_ending = trim( prc.agSettings.ag_site_feed_items_excerpt_ending );
		prc.agSettings.ag_site_feed_items_read_more_text = trim( prc.agSettings.ag_site_feed_items_read_more_text );
		if ( !val( prc.agSettings.ag_site_paging_max_feeds ) ) {
			arrayAppend( errors, "A valid max feeds value is required." );
		}
		if ( !val( prc.agSettings.ag_site_paging_max_feed_items ) ) {
			arrayAppend( errors, "A valid max feed items value is required." );
		}
		if ( !val( prc.agSettings.ag_site_cache_timeout ) ) {
			arrayAppend( errors, "A valid site cache timeout is required." );
		}
		if ( !val( prc.agSettings.ag_site_cache_timeout_idle ) ) {
			arrayAppend( errors, "A valid site cache idle timeout is required." );
		}

		// Importing settings
		if ( !len( prc.agSettings.ag_importing_import_interval ) ) {
			prc.agSettings.ag_importing_import_start_date = "";
			prc.agSettings.ag_importing_import_start_time = "";
		} else {
			if ( len( prc.agSettings.ag_importing_import_start_date ) && !isDate( prc.agSettings.ag_importing_import_start_date ) ) {
				arrayAppend( errors, "A valid start date is required." );
			} else if ( isDate( prc.agSettings.ag_importing_import_start_date ) ) {
				prc.agSettings.ag_importing_import_start_date = dateFormat( prc.agSettings.ag_importing_import_start_date, "mm/dd/yy" );
			} else {
				prc.agSettings.ag_importing_import_start_date = dateFormat( now(), "mm/dd/yy" );
			}
			if ( len( prc.agSettings.ag_importing_import_start_time ) && !isDate( prc.agSettings.ag_importing_import_start_time ) ) {
				arrayAppend( errors, "A valid start time is required." );
			} else if ( isDate( prc.agSettings.ag_importing_import_start_time ) ) {
				prc.agSettings.ag_importing_import_start_time = timeFormat( prc.agSettings.ag_importing_import_start_time, "short" );
			} else {
				prc.agSettings.ag_importing_import_start_time = timeFormat( now(), "short" );
			}
		}
		if ( !len( trim( prc.agSettings.ag_importing_secret_key ) ) ) {
			arrayAppend( errors, "A valid secret key is required." );
		}
		if ( len( prc.agSettings.ag_importing_max_feed_imports ) && !isNumeric( prc.agSettings.ag_importing_max_feed_imports ) ) {
			arrayAppend( errors, "A valid import history limit is required." );
		}
		if ( len( prc.agSettings.ag_importing_max_age ) && !isNumeric( prc.agSettings.ag_importing_max_age ) ) {
			arrayAppend( errors, "A valid age limit is required." );
		}
		if ( len( prc.agSettings.ag_importing_max_items ) && !isNumeric( prc.agSettings.ag_importing_max_items ) ) {
			arrayAppend( errors, "A valid item limit is required." );
		}
		prc.agSettings.ag_importing_match_any_filter = trim( prc.agSettings.ag_importing_match_any_filter );
		prc.agSettings.ag_importing_match_all_filter = trim( prc.agSettings.ag_importing_match_all_filter );
		prc.agSettings.ag_importing_match_none_filter = trim( prc.agSettings.ag_importing_match_none_filter );
		if ( len( prc.agSettings.ag_importing_image_minimum_width ) && !isNumeric( prc.agSettings.ag_importing_image_minimum_width ) ) {
			arrayAppend( errors, "A valid minimum width is required." );
		}
		if ( len( prc.agSettings.ag_importing_image_minimum_height ) && !isNumeric( prc.agSettings.ag_importing_image_minimum_height ) ) {
			arrayAppend( errors, "A valid minimum height is required." );
		}

		// Global html
		prc.agSettings.ag_html_pre_feed_items_display = trim( prc.agSettings.ag_html_pre_feed_items_display );
		prc.agSettings.ag_html_post_feed_items_display = trim( prc.agSettings.ag_html_post_feed_items_display );
		prc.agSettings.ag_html_pre_feeds_display = trim( prc.agSettings.ag_html_pre_feeds_display );
		prc.agSettings.ag_html_post_feeds_display = trim( prc.agSettings.ag_html_post_feeds_display );
		prc.agSettings.ag_html_pre_feed_display = trim( prc.agSettings.ag_html_pre_feed_display );
		prc.agSettings.ag_html_post_feed_display = trim( prc.agSettings.ag_html_post_feed_display );
		prc.agSettings.ag_html_pre_feedItem_display = trim( prc.agSettings.ag_html_pre_feedItem_display );
		prc.agSettings.ag_html_post_feedItem_display = trim( prc.agSettings.ag_html_post_feedItem_display );
		prc.agSettings.ag_html_pre_archives_display = trim( prc.agSettings.ag_html_pre_archives_display );
		prc.agSettings.ag_html_post_archives_display = trim( prc.agSettings.ag_html_post_archives_display );
		prc.agSettings.ag_html_pre_sidebar_display = trim( prc.agSettings.ag_html_pre_sidebar_display );
		prc.agSettings.ag_html_post_sidebar_display = trim( prc.agSettings.ag_html_post_sidebar_display );

		// RSS settings
		if ( !len( trim( prc.agSettings.ag_rss_title ) ) ) {
			arrayAppend( errors, "A valid feed title is required." );
		} else {
			prc.agSettings.ag_rss_title = trim( prc.agSettings.ag_rss_title );
		}
		if ( !len( trim( prc.agSettings.ag_rss_description ) ) ) {
			arrayAppend( errors, "A valid feed description is required." );
		} else {
			prc.agSettings.ag_rss_description = trim( prc.agSettings.ag_rss_description );
		}
		prc.agSettings.ag_rss_generator = trim( prc.agSettings.ag_rss_generator );
		prc.agSettings.ag_rss_copyright = trim( prc.agSettings.ag_rss_copyright );
		if ( len( trim( prc.agSettings.ag_rss_webmaster ) ) && !isValid( "email", trim( prc.agSettings.ag_rss_webmaster ) ) ) {
			arrayAppend( errors, "The value for the feed webmaster is invalid." );
		} else {
			prc.agSettings.ag_rss_webmaster = trim( prc.agSettings.ag_rss_webmaster );
		}
		if ( !val( prc.agSettings.ag_rss_max_items ) ) {
			arrayAppend( errors, "A valid max rss content items is required." );
		}
		if ( !val( prc.agSettings.ag_rss_cache_timeout ) ) {
			arrayAppend( errors, "A valid feed cache timeout is required." );
		}
		if ( !val( prc.agSettings.ag_rss_cache_timeout_idle ) ) {
			arrayAppend( errors, "A valid feed cache idle timeout is required." );
		}

		return errors;

	}

}