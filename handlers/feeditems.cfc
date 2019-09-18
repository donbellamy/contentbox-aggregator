/**
 * ContentBox Aggregator
 * Feed items handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="contentHandler" {

	// Dependencies
	property name="blacklistedItemService" inject="blacklistedItemService@aggregator";
	property name="entryService" inject="entryService@cb";

	/**
	 * Pre handler
	 */
	function preHandler( event, rc, prc, action, eventArguments ) {

		super.preHandler( argumentCollection=arguments );

		// Check permissions
		if ( !prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR" ) ) {
			cbMessagebox.error( "You do not have permission to access the aggregator feed items." );
			setNextEvent( prc.cbAdminEntryPoint );
			return;
		}

		// Exit handler
		prc.xehSlugify = "#prc.agAdminEntryPoint#.feeditems.slugify";

	}

	/**
	 * Displays feed item index
	 */
	function index( event, rc, prc ) {

		event.paramValue( "page", 1 )
			.paramValue( "search", "" )
			.paramValue( "feed", "" )
			.paramValue( "category", "" )
			.paramValue( "status", "" )
			.paramValue( "showAll", false );

		// Grab feeds and categories
		prc.feeds = feedService.getAll( sortOrder = "title" );
		prc.categories = categoryService.getAll( sortOrder = "category" );

		event.setView( "feeditems/index" );

	}

	/**
	 * Displays feed item table
	 */
	function table( event, rc, prc ) {

		event.paramValue( "page", 1 )
			.paramValue( "search", "" )
			.paramValue( "feed", "" )
			.paramValue( "category", "" )
			.paramValue( "status", "" )
			.paramValue( "showAll", false );

		// Paging
		prc.oPaging = getModel("paging@aggregator");
		prc.paging = prc.oPaging.getBoundaries();
		prc.pagingLink = "javascript:contentPaginate(@page@)";

		// Grab results
		var results = feedItemService.getFeedItems(
			status = rc.status,
			searchTerm = rc.search,
			searchActiveContent = false,
			category = rc.category,
			feed = rc.feed,
			max = ( rc.showAll ? 0 : prc.cbSettings.cb_paging_maxrows ),
			offset = ( rc.showAll ? 0 : prc.paging.startRow - 1 )
		);
		prc.feedItems = results.feedItems;
		prc.itemCount = results.count;

		event.setView(
			view = "feeditems/table",
			layout = "ajax"
		);

	}

	/**
	 * Displays feed item editor
	 */
	function editor( event, rc, prc ) {

		event.paramValue( "contentID", 0 );

		// Grab the feed item
		if ( !structKeyExists( prc, "feedItem" ) ) {
			prc.feedItem = feedItemService.get( rc.contentID );
		}

		// Editor settings
		prc.ckHelper = ckHelper;
		prc.markups = editorService.getRegisteredMarkups();
		prc.editors = editorService.getRegisteredEditorsMap();
		prc.defaultMarkup = prc.oCurrentAuthor.getPreference( "markup", editorService.getDefaultMarkup() );
		prc.defaultEditor = getUserDefaultEditor( prc.oCurrentAuthor );
		prc.oEditorDriver = editorService.getEditor( prc.defaultEditor );

		// Related/Linked content
		prc.relatedContent = prc.feedItem.hasRelatedContent() ? prc.feedItem.getRelatedContent() : [];
		prc.linkedContent = prc.feedItem.hasLinkedContent() ? prc.feedItem.getLinkedContent() : [];
		prc.relatedContentIDs = prc.feedItem.getRelatedContentIDs();

		// Categories
		prc.categories = categoryService.getAll( sortOrder = "category" );

		// Exit handlers
		prc.xehRelatedContentSelector = "#prc.cbAdminEntryPoint#.content.relatedContentSelector";
		prc.xehShowRelatedContentSelector = "#prc.cbAdminEntryPoint#.content.showRelatedContentSelector";
		prc.xehBreakContentLink = "#prc.cbAdminEntryPoint#.content.breakContentLink";

		// We dont support creating feed items
		if ( !prc.feedItem.isLoaded() ) {
			setNextEvent( prc.xehFeedItems );
		} else {
			prc.versionsViewlet = runEvent(
				event = "contentbox-admin:versions.pager",
				eventArguments = { contentID = rc.contentID }
			);
			event.setView( "feeditems/editor" );
		}

	}

	/**
	 * Saves feed item
	 */
	function save( event, rc, prc ) {

		// Editor
		event.paramValue( "contentID", 0 )
			.paramValue( "contentType", "FeedItem" )
			.paramValue( "title", "" )
			.paramValue( "slug", "" )
			.paramValue( "content", "" )
			.paramValue( "excerpt", "" );

		// Publishing
		event.paramValue( "isPublished", true )
			.paramValue( "publishedDate", now() )
			.paramValue( "publishedTime", timeFormat( rc.publishedDate, "HH" ) & ":" & timeFormat( rc.publishedDate, "mm" ) )
			.paramValue( "expireDate", "" )
			.paramValue( "expireTime", "" )
			.paramValue( "changelog", "" );

		// Related content
		event.paramValue( "relatedContentIDs", "" );

		// Categories
		event.paramValue( "newCategories", "" );

		// Published date
		if ( NOT len( rc.publishedDate ) ) {
			rc.publishedDate = dateFormat( now() );
		}

		// Slug
		rc.slug =  htmlHelper.slugify( len( rc.slug ) ? rc.slug : rc.title );

		// Check permission
		if ( !prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN" ) ) {
			rc.isPublished = "false";
		}

		// Grab the feed item
		prc.feedItem = feedItemService.get( rc.contentID );

		// Old feed item
		var oldFeedItem = duplicate( prc.feedItem.getMemento() );

		// Populate feed item
		populateModel( prc.feedItem )
			.addJoinedPublishedtime( rc.publishedTime )
			.addJoinedExpiredTime( rc.expireTime );

		// Validate feed item
		var errors = prc.feedItem.validate();
		if ( !len( trim( rc.content ) ) ) {
			arrayAppend( errors, "Please enter some content." );
		}
		if ( arrayLen( errors ) ) {
			cbMessagebox.warn( messageArray = errors );
			return editor( argumentCollection = arguments );
		}

		// Add new content version if needed
		if ( compare( prc.feedItem.getContent(), rc.content ) != 0 ) {
			prc.feedItem.addNewContentVersion(
				content = rc.content,
				changelog = rc.changelog,
				author = prc.oCurrentAuthor
			);
		}

		// Categories
		var categories = [];
		if ( len( trim( rc.newCategories ) ) ) {
			categories = categoryService.createCategories( trim( rc.newCategories ) );
		}
		categories.addAll( categoryService.inflateCategories( rc ) );
		prc.feedItem.removeAllCategories().setCategories( categories );
		prc.feedItem.inflateRelatedContent( rc.relatedContentIDs );

		announceInterception(
			"aggregator_preFeedItemSave",
			{ feedItem = prc.feedItem, oldFeedItem = oldFeedItem }
		);

		// Save feed item
		feedItemService.save( prc.feedItem );

		announceInterception(
			"aggregator_postFeedItemSave",
			{ feedItem = prc.feedItem, oldFeedItem = oldFeedItem }
		);

		if ( event.isAjax() ) {
			var data = { "CONTENTID" = prc.feedItem.getContentID() };
			event.renderData(
				type = "json",
				data = data
			);
		} else {
			cbMessagebox.info( "Feed Item Saved!" );
			setNextEvent( prc.xehFeedItems );
		}

	}

	/**
	 * Saves categories
	 */
	function saveCategories( event, rc, prc ) {

		event.paramValue( "contentID", "" )
			.paramValue( "newCategories", "" );

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
				var feedItem = feedItemService.get( contentID, false );
				if ( !isNull( feedItem ) ) {
					feedItem.removeAllCategories().setCategories( categories );
					feedItemService.save( feedItem );
					arrayAppend( messages, "Categories saved for '#feedItem.getTitle()#'." );
				} else {
					arrayAppend( messages, "Invalid feed item selected: #contentID#." );
				}
			}
			cbMessagebox.info( messageArray=messages );
		} else {
			cbMessagebox.warn( "No feed items selected!" );
		}

		setNextEvent(
			event = prc.xehFeedItems,
			persistStruct = getFilters( rc )
		);

	}

	/**
	 * Removes feed item
	 */
	function remove( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		// Remove selected feed item
		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feedItem = feedItemService.get( contentID, false );
				if ( !isNull( feedItem ) ) {
					var title = feedItem.getTitle();
					announceInterception(
						"aggregator_preFeedItemRemove",
						{ feedItem = feedItem }
					);
					feedItemService.deleteContent( feedItem );
					announceInterception(
						"aggregator_postFeedItemRemove",
						{ contentID = contentID }
					);
					arrayAppend( messages, "Feed item '#title#' deleted." );
				} else {
					arrayAppend( messages, "Invalid feed item selected: #contentID#." );
				}
			}
			cbMessagebox.info( messageArray=messages );
		} else {
			cbMessagebox.warn( "No feed Items selected!" );
		}

		setNextEvent(
			event = prc.xehFeedItems,
			persistStruct = getFilters( rc )
		);

	}

	/**
	 * View feed item
	 */
	function view( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		if ( val( rc.contentID ) ) {
			var feedItem = feedItemService.get( rc.contentID, false );
			if ( !isNull( feedItem ) ) {
				location(
					url = prc.agHelper.linkFeedItem( feedItem ),
					addToken = false
				);
			} else {
				cbMessagebox.info( "Invalid feed item selected: #rc.contentID#." );
			}
		} else {
			cbMessagebox.warn( "No feed items selected!" );
		}

		setNextEvent(
			event = prc.xehFeedItems,
			persistStruct = getFilters( rc )
		);

	}

	/**
	 * Updates feed item status
	 */
	function updateStatus( event, rc, prc ) {

		event.paramValue( "contentID", "" )
			.paramValue( "contentStatus", "draft" );

		// Update selected feed item status
		if ( len( rc.contentID ) ) {
			feedItemService.bulkPublishStatus( contentID=rc.contentID, status=rc.contentStatus );
			announceInterception(
				"aggregator_onFeedItemStatusUpdate",
				{ contentID = rc.contentID, status = rc.contentStatus }
			);
			cbMessagebox.info( "#listLen( rc.contentID )# feed item#listLen(rc.contentID) GT 1?'s were':' was'# set to '#rc.contentStatus#'." );
		} else {
			cbMessagebox.warn( "No feed items selected!" );
		}

		setNextEvent(
			event = prc.xehFeedItems,
			persistStruct = getFilters( rc )
		);

	}

	/**
	 * Blacklists feed item
	 */
	function blacklist( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		// Create blacklist item and delete feed item
		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feedItem = feedItemService.get( contentID, false );
				if ( !isNull( feedItem ) ) {
					// Create and save the blacklisted item
					var blacklistedItem = blacklistedItemService.new();
					blacklistedItem.setTitle( feedItem.getTitle() );
					blacklistedItem.setItemUrl( feedItem.getItemUrl() );
					blacklistedItem.setFeed( feedItem.getFeed() );
					blacklistedItem.setCreator( prc.oCurrentAuthor );
					announceInterception(
						"aggregator_preBlacklistedItemSave",
						{ blacklistedItem = blacklistedItem }
					);
					blacklistedItemService.save( blacklistedItem );
					announceInterception(
						"aggregator_postBlacklistedItemSave",
						{ blacklistedItem = blacklistedItem }
					);
					// Delete feed item
					var title = feedItem.getTitle();
					announceInterception(
						"aggregator_preFeedItemRemove",
						{ feedItem = feedItem }
					);
					feedItemService.deleteContent( feedItem );
					announceInterception(
						"aggregator_postFeedItemRemove",
						{ contentID = contentID }
					);
					arrayAppend( messages, "Blacklisted item created from feed item '#title#'." );
				} else {
					arrayAppend( messages, "Invalid feed item selected: #contentID#." );
				}
			}
			cbMessagebox.info( messageArray=messages );
		} else {
			cbMessagebox.warn( "No feed items selected!" );
		}

		setNextEvent(
			event = prc.xehFeedItems,
			persistStruct = getFilters( rc )
		);

	}

	/**
	 * Resets feed item hits
	 */
	function resetHits( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		// Reset selected feed item hits
		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feedItem = feedItemService.get( contentID, false );
				if ( !isNull( feedItem ) ) {
					if ( feedItem.hasStats() ) {
						feedItem.getStats().setHits( 0 );
						feedItemService.save( feedItem );
					}
					arrayAppend( messages, "Hits reset for '#feedItem.getTitle()#'." );
				} else {
					arrayAppend( messages, "Invalid feed item selected: #contentID#." );
				}
			}
			cbMessagebox.info( messageArray=messages );
		} else {
			cbMessagebox.warn( "No feed items selected!" );
		}

		setNextEvent(
			event = prc.xehFeedItems,
			persistStruct = getFilters( rc )
		);

	}

	/**
	 * Displays feed item import record
	 */
	function viewImport( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		prc.feedItem = feedItemService.get( rc.contentID, false );

		event.setView(
			view = "feeditems/import",
			layout = "ajax"
		);

	}

	/**
	 * Saves a feed item as a blog entry
	 */
	function saveAsEntry( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		// Save selected feed item as entry
		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feedItem = feedItemService.get( contentID, false );
				if ( !isNull( feedItem ) ) {
					var entry = entryService.new();
					entry.setTitle( feedItem.getTitle() );
					entry.setSlug( htmlHelper.slugify( feedItem.getTitle() ) );
					entry.setExcerpt( feedItem.getExcerpt() );
					entry.setCreator( prc.oCurrentAuthor );
					entry.prepareForClone(
						author = prc.oCurrentAuthor,
						original = feedItem,
						originalService = feedItemService,
						publish = false,
						originalSlugRoot = feedItem.getSlug(),
						newSlugRoot = entry.getSlug()
					);
					entry.inflateRelatedContent( feedItem.getContentID() );
					entryService.saveEntry( entry );
					arrayAppend( messages, "Feed item '#feedItem.getTitle()#' saved as Entry." );
				} else {
					arrayAppend( messages, "Invalid feed item selected: #contentID#." );
				}
			}

			cbMessagebox.info( messageArray=messages );

			setNextEvent(
				event = prc.xehEntries,
				persistStruct = getFilters( rc )
			);

		} else {

			cbMessagebox.warn( "No feed items selected!" );

			setNextEvent(
				event = prc.xehFeedItems,
				persistStruct = getFilters( rc )
			);

		}

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Creates the feed item filter struct
	 * @return The the feed item filter struct
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