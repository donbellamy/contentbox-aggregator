component extends="contentHandler" {

	property name="entryService" inject="entryService@cb";

	function preHandler( event, action, eventArguments, rc, prc ) {

		super.preHandler( argumentCollection=arguments );

		prc.xehSlugify = "#prc.agAdminEntryPoint#.feeditems.slugify";

		if ( !prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR" ) ) {
			cbMessagebox.error( "You do not have permission to access feed items." );
			setNextEvent( prc.cbAdminEntryPoint );
			return;
		}

	}

	function index( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "feed", "all" );
		event.paramValue( "category", "all" );
		event.paramValue( "status", "any" );
		event.paramValue( "showAll", false );

		prc.feeds = feedService.getAll( sortOrder="title" );
		prc.categories = categoryService.getAll( sortOrder="category" );

		event.setView( "feeditems/index" );

	}

	function table( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "feed", "all" );
		event.paramValue( "category", "all" );
		event.paramValue( "status", "any" );
		event.paramValue( "showAll", false );

		prc.oPaging = getModel("paging@aggregator");
		prc.paging = prc.oPaging.getBoundaries();
		prc.pagingLink = "javascript:contentPaginate(@page@)";

		var results = feedItemService.search(
			search=rc.search,
			feed=rc.feed,
			category=rc.category,
			status=rc.status,
			max=( rc.showAll ? 0 : prc.cbSettings.cb_paging_maxrows ),
			offset=( rc.showAll ? 0 : prc.paging.startRow - 1 )
		);

		prc.feedItems = results.feedItems;
		prc.itemCount = results.count;

		event.setView( view="feeditems/table", layout="ajax" );

	}

	function editor( event, rc, prc ) {

		event.paramValue( "contentID", 0 );

		if ( !structKeyExists( prc, "feedItem" ) ) {
			prc.feedItem = feedItemService.get( event.getValue( "contentID", 0 ) );
		}

		prc.ckHelper = ckHelper;
		prc.markups = editorService.getRegisteredMarkups();
		prc.editors = editorService.getRegisteredEditorsMap();
		prc.defaultMarkup = prc.oCurrentAuthor.getPreference( "markup", editorService.getDefaultMarkup() );
		prc.defaultEditor = getUserDefaultEditor( prc.oCurrentAuthor );
		prc.oEditorDriver = editorService.getEditor( prc.defaultEditor );
		prc.relatedContent = prc.feedItem.hasRelatedContent() ? prc.feedItem.getRelatedContent() : [];
		prc.linkedContent = prc.feedItem.hasLinkedContent() ? prc.feedItem.getLinkedContent() : [];
		prc.relatedContentIDs = prc.feedItem.getRelatedContentIDs();
		prc.xehRelatedContentSelector = "#prc.cbAdminEntryPoint#.content.relatedContentSelector";
		prc.xehShowRelatedContentSelector = "#prc.cbAdminEntryPoint#.content.showRelatedContentSelector";
		prc.xehBreakContentLink = "#prc.cbAdminEntryPoint#.content.breakContentLink";

		prc.categories = categoryService.getAll( sortOrder="category" );

		// We dont support creating feed items
		if ( !prc.feedItem.isLoaded() ) {
			setNextEvent( prc.xehFeedItems );
		} else {
			prc.versionsViewlet = runEvent(event="contentbox-admin:versions.pager",eventArguments={contentID=rc.contentID});
			event.setView( "feeditems/editor" );
		}

	}

	function save( event, rc, prc ) {

		// Editor
		event.paramValue( "contentID", 0 );
		event.paramValue( "contentType", "Feed" );
		event.paramValue( "title", "" );
		event.paramValue( "slug", "" );
		event.paramValue( "content", "" );
		// Publishing
		event.paramValue( "isPublished", true );
		event.paramValue( "publishedDate", now() );
		event.paramValue( "publishedTime", timeFormat( rc.publishedDate, "HH" ) & ":" & timeFormat( rc.publishedDate, "mm" ) );
		event.paramValue( "expireDate", "" );
		event.paramValue( "expireTime", "" );
		event.paramValue( "changelog", "" );
		// Related content
		event.paramValue( "relatedContentIDs", "" );
		// Categories
		event.paramValue( "newCategories", "" );

		if ( NOT len( rc.publishedDate ) ) {
			rc.publishedDate = dateFormat( now() );
		}

		rc.slug =  htmlHelper.slugify( len( rc.slug ) ? rc.slug : rc.title );

		if ( !prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN" ) ) {
			rc.isPublished 	= "false";
		}

		prc.feedItem = feedItemService.get( rc.contentID );
		var originalSlug = prc.feedItem.getSlug();

		populateModel( prc.feedItem )
			.addJoinedPublishedtime( rc.publishedTime )
			.addJoinedExpiredTime( rc.expireTime );

		var errors = prc.feedItem.validate();

		if ( !len( trim( rc.content ) ) ) {
			arrayAppend( errors, "Please enter some content." );
		}

		if ( arrayLen( errors ) ) {
			cbMessagebox.warn( messageArray=errors );
			return editor( argumentCollection=arguments );
		}

		if ( compare( prc.feedItem.getContent(), rc.content ) != 0 ) {
			prc.feedItem.addNewContentVersion(
				content=rc.content,
				changelog=rc.changelog,
				author=prc.oCurrentAuthor
			);
		}

		var categories = [];
		if ( len( trim( rc.newCategories ) ) ) {
			categories = categoryService.createCategories( trim( rc.newCategories ) );
		}
		categories.addAll( categoryService.inflateCategories( rc ) );
		prc.feedItem.removeAllCategories().setCategories( categories );
		prc.feedItem.inflateRelatedContent( rc.relatedContentIDs );

		announceInterception( "aggregator_preFeedItemSave", {
			feedItem=prc.feedItem,
			originalSlug=originalSlug
		});

		feedItemService.save( prc.feedItem );

		announceInterception( "aggregator_postFeedItemSave", {
			feedItem=prc.feedItem,
			originalSlug=originalSlug
		});

		if ( event.isAjax() ) {
			var rData = { "CONTENTID" = prc.feedItem.getContentID() };
			event.renderData( type="json", data=rData );
		} else {
			cbMessagebox.info( "Feed Item Saved!" );
			setNextEvent( prc.xehFeedItems );
		}

	}

	function saveCategories( event, rc, prc ) {

		event.paramValue( "contentID", "" );
		event.paramValue( "newCategories", "" );

		var categories = [];
		if ( len( trim( rc.newCategories ) ) ) {
			categories = categoryService.createCategories( trim( rc.newCategories ) );
		}
		categories.addAll( categoryService.inflateCategories( rc ) );

		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feedItem = feedItemService.get( contentID );
				if ( feedItem.isLoaded() ) {
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

		setNextEvent( event=prc.xehFeedItems, persistStruct=getFilters( rc ) );

	}

	function remove( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feedItem = feedItemService.get( contentID );
				if ( feedItem.isLoaded() ) {
					var title = feedItem.getTitle();
					announceInterception( "aggregator_preFeedItemRemove", { feedItem=feedItem } );
					feedItemService.deleteContent( feedItem );
					announceInterception( "aggregator_postFeedItemRemove", { contentID=contentID } );
					arrayAppend( messages, "Feed item '#title#' deleted." );
				} else {
					arrayAppend( messages, "Invalid feed item selected: #contentID#." );
				}
			}
			cbMessagebox.info( messageArray=messages );
		} else {
			cbMessagebox.warn( "No feed Items selected!" );
		}

		setNextEvent( event=prc.xehFeedItems, persistStruct=getFilters( rc ) );

	}

	function updateStatus( event, rc, prc ) {

		event.paramValue( "contentID", "" );
		event.paramValue( "contentStatus", "draft" );

		if ( len( rc.contentID ) ) {
			feedItemService.bulkPublishStatus( contentID=rc.contentID, status=rc.contentStatus );
			announceInterception( "aggregator_onFeedItemStatusUpdate", { contentID=rc.contentID, status=rc.contentStatus } );
			cbMessagebox.info( "#listLen( rc.contentID )# feed items were set to '#rc.contentStatus#'." );
		} else {
			cbMessagebox.warn( "No feed items selected!" );
		}

		setNextEvent( event=prc.xehFeedItems, persistStruct=getFilters( rc ) );

	}

	function resetHits( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feedItem = feedItemService.get( contentID );
				if ( feedItem.isLoaded() ) {
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

		setNextEvent( event=prc.xehFeedItems, persistStruct=getFilters( rc ) );

	}

	function viewImport( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		prc.feedItem  = feedItemService.get( rc.contentID, false );

		event.setView( view="feeditems/import", layout="ajax" );

	}

	function saveAsEntry( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feedItem = feedItemService.get( contentID );
				if ( feedItem.isLoaded() ) {
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
			setNextEvent( event=prc.xehEntries, persistStruct=getFilters( rc ) );
		} else {
			cbMessagebox.warn( "No feed items selected!" );
			setNextEvent( event=prc.xehFeedItems, persistStruct=getFilters( rc ) );
		}

	}

	/************************************** PRIVATE *********************************************/

	private struct function getFilters( rc ) {

		var filters = {};

		if ( structKeyExists( rc, "page" ) ) filters.page = rc.page;
		if ( structKeyExists( rc, "search" ) ) filters.search = rc.search;
		if ( structKeyExists( rc, "feed" ) ) filters.feed = rc.feed;
		if ( structKeyExists( rc, "category" ) ) filters.category = rc.category;
		if ( structKeyExists( rc, "status" ) ) filters.status = rc.status;

		return filters;

	}

}