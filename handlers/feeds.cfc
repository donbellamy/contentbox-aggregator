/**
 * ContentBox RSS Aggregator
 * Feeds handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="contentHandler" {

	// Dependencies
	property name="feedImportService" inject="feedImportService@aggregator";

	/**
	 * Pre handler
	 */
	function preHandler( event, action, eventArguments, rc, prc ) {

		super.preHandler( argumentCollection=arguments );

		// Exit handler
		prc.xehSlugify = "#prc.agAdminEntryPoint#.feeds.slugify";

		// Check permissions
		if ( !prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN,FEEDS_EDITOR" ) ) {
			cbMessagebox.error( "You do not have permission to access the aggregator feeds." );
			setNextEvent( prc.cbAdminEntryPoint );
			return;
		}

	}

	/**
	 * Displays the feed index
	 */
	function index( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "state", "any" );
		event.paramValue( "category", "all" );
		event.paramValue( "status", "any" );
		event.paramValue( "showAll", false );

		// Grab categories
		prc.categories = categoryService.getAll( sortOrder="category" );

		event.setView( "feeds/index" );

	}

	/**
	 * Displays the feed table
	 */
	function table( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "state", "any" );
		event.paramValue( "category", "all" );
		event.paramValue( "status", "any" );
		event.paramValue( "showAll", false );

		// Paging
		prc.oPaging = getModel("paging@aggregator");
		prc.paging = prc.oPaging.getBoundaries();
		prc.pagingLink = "javascript:contentPaginate(@page@)";

		// Grab results
		var results = feedService.search(
			searchTerm=rc.search,
			state=rc.state,
			category=rc.category,
			status=rc.status,
			sortOrder="title ASC",
			max=( rc.showAll ? 0 : prc.cbSettings.cb_paging_maxrows ),
			offset=( rc.showAll ? 0 : prc.paging.startRow - 1 )
		);
		prc.feeds = results.feeds;
		prc.itemCount = results.count;

		event.setView( view="feeds/table", layout="ajax" );

	}

	/**
	 * Displays the feed editor
	 */
	function editor( event, rc, prc ) {

		event.paramValue( "contentID", 0 );

		// Grab the feed
		if ( !structKeyExists( prc, "feed" ) ) {
			prc.feed = feedService.get( event.getValue( "contentID", 0 ) );
		}

		// Editor settings
		prc.ckHelper = ckHelper;
		prc.markups = editorService.getRegisteredMarkups();
		prc.editors = editorService.getRegisteredEditorsMap();
		prc.defaultMarkup = prc.oCurrentAuthor.getPreference( "markup", editorService.getDefaultMarkup() );
		prc.defaultEditor = getUserDefaultEditor( prc.oCurrentAuthor );
		prc.oEditorDriver = editorService.getEditor( prc.defaultEditor );

		// Lookups
		prc.limitUnits = [ "days", "weeks", "months", "years" ];
		prc.categories = categoryService.getAll( sortOrder="category" );
		prc.linkOptions = [
			{ name="Forward the user directly to the feed item.", value="forward" },
			{ name="Use an interstitial page before forwarding the user to the feed item.", value="interstitial" },
			{ name="Display the entire feed item within the site.", value="display" }
		];
		arrayPrepend( prc.linkOptions, {
			name="Use the default setting - #prc.linkOptions[ arrayFind( prc.linkOptions, function( struct ) { return struct.value == prc.agSettings.ag_portal_item_link_behavior; } ) ].name#",
			value=""
		});
		prc.featuredImageOptions = [
			{ name="Display the default featured image.", value="default" },
			{ name="Display the parent feed's featured image.", value="feed" },
			{ name="Do not display a featured image.", value="none" }
		];
		arrayPrepend( prc.featuredImageOptions, {
			name="Use the default setting - #prc.featuredImageOptions[ arrayFind( prc.featuredImageOptions, function( struct ) { return struct.value == prc.agSettings.ag_portal_item_featured_image_behavior; } ) ].name#",
			value=""
		});
		prc.itemStatuses = [
			{ name="Draft", value="draft" },
			{ name="Published", value="published" }
		];
		arrayPrepend( prc.itemStatuses, {
			name="Use the default setting - #prc.itemStatuses[ arrayFind( prc.itemStatuses, function( struct ) { return struct.value == prc.agSettings.ag_importing_item_status; } ) ].name#",
			value=""
		});
		prc.itemPubDates = [
			{ name="Original published date", value="original" },
			{ name="Imported date", value="imported" }
		];
		arrayPrepend( prc.itemPubDates, {
			name="Use the default setting - #prc.itemPubDates[ arrayFind( prc.itemPubDates, function( struct ) { return struct.value == prc.agSettings.ag_importing_item_pub_date; } ) ].name#",
			value=""
		});
		prc.importFeaturedImageOptions = [
			{ name="Import featured images for this feed.", value="true" },
			{ name="Do not import featured images for this feed.", value="false" }
		];
		arrayPrepend( prc.importFeaturedImageOptions, {
			name="Use the default setting - #prc.importFeaturedImageOptions[ arrayFind( prc.importFeaturedImageOptions, function( struct ) { return struct.value == prc.agSettings.ag_importing_featured_image_enable; } ) ].name#",
			value=""
		});
		prc.importImageOptions = [
			{ name="Import images for this feed.", value="true" },
			{ name="Do not import images for this feed.", value="false" }
		];
		arrayPrepend( prc.importImageOptions, {
			name="Use the default setting - #prc.importImageOptions[ arrayFind( prc.importImageOptions, function( struct ) { return struct.value == prc.agSettings.ag_importing_image_import_enable; } ) ].name#",
			value=""
		});
		prc.matchOptions = [
			{ name="Only assign the categories above to feed items that contain 'any' of the words/phrases below in the title or body.", value="any" },
			{ name="Only assign the categories above to feed items that contain 'all' of the words/phrases below in the title or body.", value="all" }
		];

		// Grab feed items and versions
		if ( prc.feed.isLoaded() ) {
			prc.feedItems = feedItemService.search( feed=prc.feed.getContentID(), max=5 ).feedItems;
			prc.versionsViewlet = runEvent(event="contentbox-admin:versions.pager",eventArguments={contentID=rc.contentID});
		}

		event.setView( "feeds/editor" );

	}

	/**
	 * Saves feed
	 */
	function save( event, rc, prc ) {

		// Editor
		event.paramValue( "contentID", 0 );
		event.paramValue( "contentType", "Feed" );
		event.paramValue( "title", "" );
		event.paramValue( "slug", "" );
		event.paramValue( "siteUrl", "" );
		event.paramValue( "feedUrl", "" );
		event.paramValue( "tagLine", "" );
		event.paramValue( "content", "" );

		// Portal
		event.paramValue( "linkBehavior", "" );
		event.paramValue( "featuredImageBehavior", "" );
		event.paramValue( "pagingMaxItems", "" );

		// Importing
		event.paramValue( "isActive", true );
		event.paramValue( "startDate", "" );
		event.paramValue( "startTime", "" );
		event.paramValue( "stopDate", "" );
		event.paramValue( "stopTime", "" );
		event.paramValue( "itemStatus", "" );
		event.paramValue( "ItemPubDate", "" );
		event.paramValue( "maxAge", "" );
		event.paramValue( "maxAgeUnit", "" );
		event.paramValue( "maxItems", "" );
		event.paramValue( "matchAnyFilter", "" );
		event.paramValue( "matchAllFilter", "" );
		event.paramValue( "matchNoneFilter", "" );
		event.paramValue( "importFeaturedImages", "" );
		event.paramValue( "importImages", "" );
		event.paramValue( "taxonomies", {} );

		// HTML
		event.paramValue( "preFeedDisplay", "" );
		event.paramValue( "postFeedDisplay", "" );
		event.paramValue( "preFeedItemDisplay", "" );
		event.paramValue( "postFeedItemDisplay", "" );

		// SEO
		event.paramValue( "htmlTitle", "" );
		event.paramValue( "htmlKeywords", "" );
		event.paramValue( "htmlDescription", "" );

		// Publishing
		event.paramValue( "isPublished", true );
		event.paramValue( "publishedDate", now() );
		event.paramValue( "publishedTime", timeFormat( rc.publishedDate, "HH" ) & ":" & timeFormat( rc.publishedDate, "mm" ) );
		event.paramValue( "expireDate", "" );
		event.paramValue( "expireTime", "" );
		event.paramValue( "changelog", "" );

		// Categories
		event.paramValue( "newCategories", "" );

		// Taxonomies
		var taxonomies = [];
		for ( var item IN structKeyArray( rc.taxonomies ) ) {
			if ( structKeyExists( rc.taxonomies[item], "categories" ) && len( trim( rc.taxonomies[item].keywords ) ) ) {
				arrayAppend( taxonomies, rc.taxonomies[item] );
			}
		}
		rc.taxonomies = taxonomies;

		// Published date
		if ( NOT len( rc.publishedDate ) ) {
			rc.publishedDate = dateFormat( now() );
		}

		// Slug
		rc.slug =  htmlHelper.slugify( len( rc.slug ) ? rc.slug : rc.title );

		// Check permission
		if( !prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN" ) ) {
			rc.isPublished 	= "false";
		}

		// Grab the feed
		prc.feed = feedService.get( rc.contentID );
		var originalSlug = prc.feed.getSlug();
		var originalTaxonomies = prc.feed.getTaxonomies();
		var wasPaused = !prc.feed.canImport();

		// Populate feed
		populateModel( prc.feed )
			.addJoinedPublishedtime( rc.publishedTime )
			.addJoinedExpiredTime( rc.expireTime )
			.addJoinedStartTime( rc.startTime )
			.addJoinedStopTime( rc.stopTime );

		// Validate feed
		var errors = prc.feed.validate();
		if ( arrayLen( errors ) ) {
			cbMessagebox.warn( messageArray=errors );
			return editor( argumentCollection=arguments );
		}

		// Check if new
		var isNew = ( NOT prc.feed.isLoaded() );
		if ( isNew ) {
			prc.feed.setCreator( prc.oCurrentAuthor );
		}

		// Add new content version if needed
		if ( compare( prc.feed.getContent(), rc.content ) != 0 ) {
			prc.feed.addNewContentVersion(
				content=rc.content,
				changelog=rc.changelog,
				author=prc.oCurrentAuthor
			);
		}

		// Categories
		var categories = [];
		if ( len( trim( rc.newCategories ) ) ) {
			categories = categoryService.createCategories( trim( rc.newCategories ) );
		}
		categories.addAll( categoryService.inflateCategories( rc ) );
		prc.feed.removeAllCategories().setCategories( categories );

		announceInterception( "aggregator_preFeedSave", {
			feed=prc.feed,
			isNew=isNew,
			originalSlug=originalSlug,
			originalTaxonomies=originalTaxonomies
		});

		// Save feed
		feedService.save( prc.feed );

		// Import feed if needed
		if ( isNew && prc.feed.canImport() || wasPaused && prc.feed.canImport() ) {
			feedImportService.import( prc.feed, prc.oCurrentAuthor );
		}

		announceInterception( "aggregator_postFeedSave", {
			feed=prc.feed,
			isNew=isNew,
			originalSlug=originalSlug,
			originalTaxonomies=originalTaxonomies
		});

		if ( event.isAjax() ) {
			var rData = { "CONTENTID" = prc.feed.getContentID() };
			event.renderData( type="json", data=rData );
		} else {
			cbMessagebox.info( "Feed Saved!" );
			setNextEvent( prc.xehFeeds );
		}

	}

	/**
	 * Removes feed
	 */
	function remove( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		// Remove selected feed
		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feed = feedService.get( contentID );
				if ( feed.isLoaded() ) {
					var title = feed.getTitle();
					announceInterception( "aggregator_preFeedRemove", { feed=feed } );
					feedService.deleteContent( feed );
					announceInterception( "aggregator_postFeedRemove", { contentID=contentID } );
					arrayAppend( messages, "Feed '#title#' deleted." );
				} else {
					arrayAppend( messages, "Invalid feed selected: #contentID#." );
				}
			}
			cbMessagebox.info( messageArray=messages );
		} else {
			cbMessagebox.warn( "No feeds selected!" );
		}

		setNextEvent( event=prc.xehFeeds, persistStruct=getFilters( rc )  );

	}

	/**
	 * Updates feed status
	 */
	function updateStatus( event, rc, prc ) {

		event.paramValue( "contentID", "" );
		event.paramValue( "contentStatus", "draft" );

		// Update selected feed status
		if ( len( rc.contentID ) ) {
			feedService.bulkPublishStatus( contentID=rc.contentID, status=rc.contentStatus );
			announceInterception( "aggregator_onFeedStatusUpdate", { contentID=rc.contentID, status=rc.contentStatus } );
			cbMessagebox.info( "#listLen( rc.contentID )# feeds were set to '#rc.contentStatus#'." );
		} else {
			cbMessagebox.warn( "No feeds selected!" );
		}

		setNextEvent( event=prc.xehFeeds, persistStruct=getFilters( rc )  );

	}

	/**
	 * Resets feed hits
	 */
	function resetHits( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		// Reset selected feed hits
		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feed = feedService.get( contentID );
				if ( feed.isLoaded() ) {
					if ( feed.hasStats() ) {
						feed.getStats().setHits( 0 );
						feedService.save( feed );
					}
					arrayAppend( messages, "Hits reset for '#feed.getTitle()#'." );
				} else {
					arrayAppend( messages, "Invalid feed selected: #contentID#." );
				}
			}
			cbMessagebox.info( messageArray=messages );
		} else {
			cbMessagebox.warn( "No feeds selected!" );
		}

		setNextEvent( event=prc.xehFeeds, persistStruct=getFilters( rc )  );

	}

	/**
	 * Resets feed import state
	 */
	function state( event, rc, prc ) {

		event.paramValue( "contentID", "" );
		event.paramValue( "contentState", "pause" );

		// Reset selected feed state
		if ( len( rc.contentID ) ) {
			feedService.bulkActiveState( contentID=rc.contentID, state=rc.contentState );
			announceInterception( "aggregator_onFeedStateUpdate", { contentID=rc.contentID, state=rc.contentState } );
			cbMessagebox.info( "#listLen( rc.contentID )# feeds were set to '#rc.contentState#'." );
		} else {
			cbMessagebox.warn( "No feeds selected!" );
		}

		setNextEvent( event=prc.xehFeeds, persistStruct=getFilters( rc )  );

	}

	/**
	 * Imports selected feeds
	 */
	function import( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		// Set timeout
		setting requestTimeout="999999";

		// Import selected feed
		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID IN rc.contentID ) {
				var feed = feedService.get( contentID );
				if ( feed.isLoaded() ) {
					feedImportService.import( feed, prc.oCurrentAuthor );
					arrayAppend( messages, "Feed items imported for '#feed.getTitle()#'." );
				} else {
					arrayAppend( messages, "Invalid feed selected: #contentID#." );
				}
			}
			announceInterception( "aggregator_postFeedImports" );
			cbMessagebox.info( messageArray=messages );
		} else {
			cbMessagebox.warn( "No feeds selected!" );
		}

		setNextEvent( prc.xehFeeds );

	}

	/**
	 * Imports all feeds
	 */
	function importAll( event, rc, prc ) {

		// Set timeout
		setting requestTimeout="999999";

		// Grab the feeds
		var feeds = feedService.getAll( sortOrder="title" );
		var messages = [];

		// Import feeds
		for ( var feed IN feeds ) {
			feedImportService.import( feed, prc.oCurrentAuthor );
			arrayAppend( messages, "Feed items imported for '#feed.getTitle()#'." );
		}
		announceInterception( "aggregator_postFeedImports" );
		cbMessagebox.info( messageArray=messages );

		setNextEvent( prc.xehFeeds );

	}

	/**
	 * Displays the feed import record
	 */
	function viewImport( event, rc, prc ) {

		event.paramValue( "feedImportID", "" );

		prc.feedImport = feedImportService.get( rc.feedImportID, false );

		event.setView( view="feeds/import", layout="ajax" );

	}

	/**
	 * Removes the feed import record
	 */
	function removeImport( event, rc, prc ) {

		event.paramValue( "feedImportID", "" );

		var results = { "ERROR" = false, "MESSAGES" = "" };

		prc.feedImport = feedImportService.get( rc.feedImportID, false );

		if ( !isNull( prc.feedImport ) ) {

			feedImportService.deleteByID( rc.feedImportID );
			results.messages = "Feed import removed!";

		} else {
			results.error = true;
			results.messages = "Invalid feed import!";
		}

		event.renderData( type="json", data=results );

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Creates the feed filter struct
	 * @return The feed filter struct
	 */
	private struct function getFilters( rc ) {

		var filters = {};

		// Check for filters and add to struct
		if ( structKeyExists( rc, "page" ) ) filters.page = rc.page;
		if ( structKeyExists( rc, "search" ) ) filters.search = rc.search;
		if ( structKeyExists( rc, "feed" ) ) filters.feed = rc.feed;
		if ( structKeyExists( rc, "category" ) ) filters.category = rc.category;
		if ( structKeyExists( rc, "status" ) ) filters.status = rc.status;

		return filters;

	}

}