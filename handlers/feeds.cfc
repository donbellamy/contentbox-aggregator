/**
 * ContentBox RSS Aggregator
 * Feeds handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="contentHandler" {

	// Dependencies
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="blacklistedItemService" inject="blacklistedItemService@aggregator";

	// Pre handler exeptions (to allow use on front end)
	this.preHandler_except = "import,importFeed";

	/**
	 * Pre handler
	 */
	function preHandler( event, rc, prc, action, eventArguments ) {

		super.preHandler( argumentCollection=arguments );

		// Check permissions
		if ( !prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN,FEEDS_EDITOR,FEEDS_IMPORT" ) ) {
			cbMessagebox.error( "You do not have permission to access the aggregator feeds." );
			setNextEvent( prc.cbAdminEntryPoint );
			return;
		}

		// Exit handler
		prc.xehSlugify = "#prc.agAdminEntryPoint#.feeds.slugify";

	}

	/**
	 * Displays feed index
	 */
	function index( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "state", "" );
		event.paramValue( "category", "" );
		event.paramValue( "status", "" );
		event.paramValue( "showAll", false );

		// Grab categories
		prc.categories = categoryService.getAll( sortOrder="category" );

		event.setView( "feeds/index" );

	}

	/**
	 * Displays feed table
	 */
	function table( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "state", "" );
		event.paramValue( "category", "" );
		event.paramValue( "status", "" );
		event.paramValue( "showAll", false );

		// Paging
		prc.oPaging = getModel("paging@aggregator");
		prc.paging = prc.oPaging.getBoundaries();
		prc.pagingLink = "javascript:contentPaginate(@page@)";

		// Grab results
		var results = feedService.getFeeds(
			searchTerm=rc.search,
			searchActiveContent=false,
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
	 * Displays feed editor
	 */
	function editor( event, rc, prc ) {

		event.paramValue( "contentID", 0 );

		// Grab the feed
		if ( !structKeyExists( prc, "feed" ) ) {
			prc.feed = feedService.get( rc.contentID );
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
			{ name="Link the user directly to the feed item.", value="link" },
			{ name="Use an interstitial page before forwarding the user to the feed item.", value="interstitial" },
			{ name="Display the entire feed item within the site.", value="display" }
		];
		arrayPrepend( prc.linkOptions, {
			name="Use the default setting - #prc.linkOptions[ arrayFind( prc.linkOptions, function( struct ) { return struct.value == prc.agSettings.ag_site_item_link_behavior; } ) ].name#",
			value=""
		});
		prc.featuredImageOptions = [
			{ name="Display the default featured image.", value="default" },
			{ name="Display the parent feed's featured image.", value="feed" },
			{ name="Do not display a featured image.", value="none" }
		];
		arrayPrepend( prc.featuredImageOptions, {
			name="Use the default setting - #prc.featuredImageOptions[ arrayFind( prc.featuredImageOptions, function( struct ) { return struct.value == prc.agSettings.ag_site_item_featured_image_behavior; } ) ].name#",
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
			{ name="Import all images for this feed.", value="true" },
			{ name="Do not import all images for this feed.", value="false" }
		];
		arrayPrepend( prc.importImageOptions, {
			name="Use the default setting - #prc.importImageOptions[ arrayFind( prc.importImageOptions, function( struct ) { return struct.value == prc.agSettings.ag_importing_all_images_enable; } ) ].name#",
			value=""
		});
		prc.matchOptions = [
			{ name="Only assign the categories above to feed items that contain 'any' of the words/phrases below in the title or body.", value="any" },
			{ name="Only assign the categories above to feed items that contain 'all' of the words/phrases below in the title or body.", value="all" },
			{ name="Assign the categories above to all feed items ignoring any of the words/phrases below.", value="none" }
		];

		// Grab feed items and versions
		if ( prc.feed.isLoaded() ) {
			prc.feedItems = feedItemService.getFeedItems( feed=prc.feed.getContentID(), max=5 ).feedItems;
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
		event.paramValue( "feedUrl", "" );
		event.paramValue( "tagLine", "" );
		event.paramValue( "content", "" );

		// Site
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
		event.paramValue( "importAllImages", "" );
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
			if ( structKeyExists( rc.taxonomies[item], "categories" ) &&
				( len( trim( rc.taxonomies[item].keywords ) ) || rc.taxonomies[item].method == "none"  )
			) {
				arrayAppend( taxonomies, rc.taxonomies[item] );
			}
		}
		rc.taxonomies = taxonomies;

		// Published date
		if ( NOT len( rc.publishedDate ) ) {
			rc.publishedDate = dateFormat( now() );
		}

		// Slug
		rc.slug = htmlHelper.slugify( len( rc.slug ) ? rc.slug : rc.title );

		// Check permission
		if ( !prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN" ) ) {
			rc.isPublished = "false";
		}

		// Grab the feed
		prc.feed = feedService.get( rc.contentID );
		var wasPaused = !prc.feed.canImport();

		// Old feed
		var oldFeed = duplicate( prc.feed.getMemento() );

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
			oldFeed=oldFeed,
			isNew=isNew
		});

		// Save feed
		feedService.save( prc.feed );

		// Import feed if needed
		// TODO: move to postfeedsave?
		if ( isNew && prc.feed.canImport() || wasPaused && prc.feed.canImport() ) {
			feedImportService.import( prc.feed, prc.oCurrentAuthor );
		}

		announceInterception( "aggregator_postFeedSave", {
			feed=prc.feed,
			oldFeed=oldFeed,
			isNew=isNew
		});

		if ( event.isAjax() ) {
			var data = { "CONTENTID" = prc.feed.getContentID() };
			event.renderData( type="json", data=data );
		} else {
			cbMessagebox.info( "Feed Saved!" );
			setNextEvent( prc.xehFeeds );
		}

	}

	/**
	 * Saves categories
	 */
	function saveCategories( event, rc, prc ) {

		event.paramValue( "contentID", "" );
		event.paramValue( "newCategories", "" );

		// Check and create categories if needed
		var categories = [];
		if ( len( trim( rc.newCategories ) ) ) {
			categories = categoryService.createCategories( trim( rc.newCategories ) );
		}
		categories.addAll( categoryService.inflateCategories( rc ) );

		// Save feed item categories
		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feed = feedService.get( contentID, false );
				if ( !isNull( feed ) ) {
					feed.removeAllCategories().setCategories( categories );
					feedService.save( feed );
					arrayAppend( messages, "Categories saved for '#feed.getTitle()#'." );
				} else {
					arrayAppend( messages, "Invalid feed selected: #contentID#." );
				}
			}
			cbMessagebox.info( messageArray=messages );
		} else {
			cbMessagebox.warn( "No feed selected!" );
		}

		setNextEvent( event=prc.xehFeeds, persistStruct=getFilters( rc ) );

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
				var feed = feedService.get( contentID, false );
				if ( !isNull( feed ) ) {
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
	 * View feed
	 */
	function view( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		if ( val( rc.contentID ) ) {
			var feed = feedService.get( rc.contentID, false );
			if ( !isNull( feed ) ) {
				location( url=prc.agHelper.linkFeed( feed ), addToken=false );
			} else {
				cbMessagebox.info( "Invalid feed selected: #contentID#." );
			}
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
			cbMessagebox.info( "#listLen( rc.contentID )# feed#listLen(rc.contentID) GT 1?'s were':' was'# set to '#rc.contentStatus#'." );
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
				var feed = feedService.get( contentID, false );
				if ( !isNull( feed ) ) {
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
			cbMessagebox.info( "#listLen( rc.contentID )# feed#listLen(rc.contentID) GT 1?'s were':' was'# set to '#rc.contentState#'." );
		} else {
			cbMessagebox.warn( "No feeds selected!" );
		}

		setNextEvent( event=prc.xehFeeds, persistStruct=getFilters( rc )  );

	}

	/**
	 * The main feed import routine
	 */
	function import( event, rc, prc ) {

		event.paramValue( "contentID", "" );
		event.paramValue( "importAll", false );
		event.paramValue( "importActive", false );
		event.paramValue( "key", "" );

		// Set vars
		var feeds = [];
		var data = {
			"error"=false,
			"messages"=[]
		};

		// Are we in the admin?
		var inAdmin = reFindNoCase( "^contentbox-admin", event.getCurrentEvent() );

		// Check for key unless we are in the admin
		if ( rc.key EQ prc.agSettings.ag_importing_secret_key || inAdmin ) {

			// Set timeout
			setting requestTimeout="999999";

			// Grab the author
			if ( inAdmin || ( structKeyExists( prc, "oCurrentAuthor" ) && prc.oCurrentAuthor.isLoaded() && prc.oCurrentAuthor.isLoggedIn() ) ) {
				var author = prc.oCurrentAuthor;
			} else if ( len( prc.agSettings.ag_importing_item_author ) ) {
				var author = authorService.get( prc.agSettings.ag_importing_item_author );
			} else {
				var adminRole = roleService.findWhere( { role="Administrator" } );
				var author = authorService.findWhere( { role=adminRole } );
			}

			// Grab the feeds
			if ( len( rc.contentID ) ) {
				rc.contentID = listToArray( rc.contentID );
				for ( var contentID IN rc.contentID ) {
					var feed = feedService.get( contentID, false );
					if ( !isNull( feed ) ) {
						arrayAppend( feeds, feed );
					} else {
						data.error = true;
						arrayAppend( data.messages, "Invalid feed selected: #contentID#." );
					}
				}
			} else if ( rc.importAll ) {
				var feeds = feedService.getAll( sortOrder="title" );
			} else if ( rc.importActive ) {
				var feeds = feedService.getFeedsForImport();
			}

			// Import feeds
			if ( arrayLen( feeds ) && !isNull( author ) ) {
				announceInterception( "aggregator_preFeedImports", { feeds=feeds } );
				for ( var feed IN feeds ) {
					try {
						var result = new http( method="get", url=prc.agHelper.linkImportFeed( feed, author ) ).send().getPrefix();
						if ( result.status_code == "200" && isJson( result.fileContent ) ) {
							var returnData = deserializeJson( result.fileContent );
							arrayAppend( data.messages, returnData.message );
						} else {
							data.error = true;
							arrayAppend( data.messages, "Error importing feed items for '#feed.getTitle()#'." );
						}
					} catch ( any e ) {
						data.error = true;
						arrayAppend( data.messages, "Fatal error importing feed items for '#feed.getTitle()#'."  & " " & e.message & " " & e.detail );
					}
				}
				announceInterception( "aggregator_postFeedImports", { feeds=feeds } );
				sleep(1000);
			} else {
				data.error = true;
				if ( !arrayLen( data.messages ) ) {
					arrayAppend( data.messages, "No Feeds Selected!" );
				}
			}
		} else {
			data.error = true;
			arrayAppend( data.messages, "Invalid key passed to import function." );
		}

		// Set reponse
		if ( event.isAjax() || !inAdmin ) {
			rc.format = "json";
			event.renderData( type="json", data=data );
		} else {
			if ( data.error ) {
				cbMessagebox.error( messageArray=data.messages );
			} else {
				cbMessagebox.info( messageArray=data.messages );
			}
			setNextEvent( prc.xehFeeds );
		}

	}

	/**
	 * Runs the feed import routine for a single feed
	 */
	function importFeed( event, rc, prc ) {

		// Set params
		event.paramValue( name="key", value="" );
		event.paramValue( name="contentID", value="" );
		event.paramValue( name="authorID", value="" );

		// Set format
		rc.format = "json";

		// Set vars
		var data = {
			"error"=false,
			"message"=""
		};

		// Are we in the admin?
		var inAdmin = reFindNoCase( "^contentbox-admin", event.getCurrentEvent() );

		// Check key, contentID and authorID
		if ( rc.key EQ prc.agSettings.ag_importing_secret_key || inAdmin ) {

			// Grab feed and author
			var feed = feedService.get( rc.contentID, false );
			var author = authorService.get( rc.authorID, false );

			// Run the import routine
			if ( !isNull( feed ) && !isNull( author ) ) {
				try {
					feedImportService.import( feed, author );
					data.message = "Feed items imported for '#feed.getTitle()#'.";
				} catch ( any e ) {
					data.error = true;
					data.message = "Error importing feed items for '#feed.getTitle()#'." & " " & e.message & " " & e.detail;
				}
			} else {
				data.error = true;
				data.message = "Invalid feed and/or author passed to importFeed function.";
			}

		} else {

			data.error = true;
			data.message = "Invalid key passed to importFeed function.";

		}

		// Set response
		event.renderData( type="json", data=data );

	}

	/**
	 * Runs the feed import routine for all feeds
	 */
	function importAll( event, rc, prc ) {
		rc.importAll = true;
		import( argumentCollection=arguments );
	}

	/**
	 * Runs the feed import routine for all active feeds
	 */
	function importActive( event, rc, prc ) {
		rc.importActive = true;
		import( argumentCollection=arguments );
	}

	/**
	 * Displays feed import record
	 */
	function viewImport( event, rc, prc ) {

		event.paramValue( "feedImportID", "" );

		prc.feedImport = feedImportService.get( rc.feedImportID, false );

		event.setView( view="feeds/import", layout="ajax" );

	}

	/**
	 * Removes feed import record
	 */
	function removeImport( event, rc, prc ) {

		event.paramValue( "feedImportID", "" );

		rc.format = "json";

		var data = { "ERROR" = false, "MESSAGES" = "" };

		prc.feedImport = feedImportService.get( rc.feedImportID, false );

		if ( !isNull( prc.feedImport ) ) {
			feedImportService.deleteByID( rc.feedImportID );
			data.messages = "Feed import removed!";
		} else {
			data.error = true;
			data.messages = "Invalid feed import!";
		}

		event.renderData( type="json", data=data );

	}

	/**
	 * Blacklists feed item from feed import
	 */
	function blacklist( event, rc, prc ) {

		event.paramValue( "feedImportID", "" );

		// Grab the feed import
		var feedImport = feedImportService.get( rc.feedImportID, false );

		if ( !isNull( feedImport ) && structKeyExists( feedImport.getMetaInfo(), "FeedItem" ) ) {

			// Grab the feed item struct
			var feedItem = feedImport.getMetaInfo().FeedItem;

			// Create and save the blacklisted item
			var blacklistedItem = blacklistedItemService.new();
			blacklistedItem.setTitle( feedItem.title );
			blacklistedItem.setItemUrl( feedItem.itemUrl );
			blacklistedItem.setFeed( feedImport.getFeed() );
			blacklistedItem.setCreator( prc.oCurrentAuthor );
			announceInterception( "aggregator_preBlacklistedItemSave", { blacklistedItem=blacklistedItem });
			blacklistedItemService.save( blacklistedItem );
			announceInterception( "aggregator_postBlacklistedItemSave", { blacklistedItem=blacklistedItem });

			cbMessagebox.info( "Blacklisted item '#feedItem.title#' created!<br/><br/>Click <a href='#event.buildLink(prc.xehFeedImport)#/contentID/#feedImport.getFeed().getContentID()#'>here</a> to import items for '#feedImport.getFeed().getTitle()#'." );

		} else {
			cbMessagebox.warn( "Invalid feed import and/or no feed item attached to feed import." );
		}

		setNextEvent( event=prc.xehFeeds );

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