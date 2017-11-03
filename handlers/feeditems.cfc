component extends="baseHandler" {

	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="categoryService" inject="categoryService@cb";
	property name="authorService" inject="authorService@cb";
	property name="editorService" inject="editorService@cb";
	property name="htmlHelper" inject="HTMLHelper@coldbox";
	property name="ckHelper" inject="CKHelper@contentbox-ckeditor";

	function preHandler( event, action, eventArguments, rc, prc ) {

		super.preHandler( argumentCollection=arguments );
		
		prc.xehSlugify = "#prc.agAdminEntryPoint#.feeditems.slugify";
		prc.xehSlugCheck = "#prc.cbAdminEntryPoint#.content.slugUnique";

		if ( !prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR" ) ) {
			cbMessagebox.error( "You do not have permission to access feed items." );
			setNextEvent( prc.cbAdminEntryPoint );
			return;
		}

	}

	function index( event, rc, prc ) {

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

		prc.oPaging = getModel( "Paging@cb" );
		prc.paging = prc.oPaging.getBoundaries();
		prc.pagingLink = "javascript:contentPaginate(@page@)";

		var results = feedItemService.search(
			search=rc.search,
			feed=rc.feed,
			category=rc.category,
			status=rc.status,
			offset=( rc.showAll ? 0 : prc.paging.startRow-1 ),
			max=( rc.showAll ? 0 : prc.cbSettings.cb_paging_maxrows ),
			sortOrder="datePublished DESC"
		);
		prc.feedItems = results.feedItems;
		prc.feedItemsCount = results.count;

		event.setView( view="feeditems/table", layout="ajax" );

	}

	function editor( event, rc, prc ) {

		prc.ckHelper = ckHelper;

		prc.markups = editorService.getRegisteredMarkups();
		prc.editors = editorService.getRegisteredEditorsMap();
		prc.defaultMarkup = prc.oCurrentAuthor.getPreference( "markup", editorService.getDefaultMarkup() );
		prc.defaultEditor = getUserDefaultEditor( prc.oCurrentAuthor );
		prc.oEditorDriver = editorService.getEditor( prc.defaultEditor );

		prc.categories = categoryService.getAll( sortOrder="category" );

		if ( !structKeyExists( prc, "feedItem" ) ) {
			prc.feedItem = feedItemService.get( event.getValue( "contentID", 0 ) );
		}

		// We dont support creating feed items
		if ( !prc.feedItem.isLoaded() ) {
			setNextEvent( prc.xehFeedItems );
		} else {
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
		event.paramValue( "excerpt", "" );
		// Publishing
		event.paramValue( "isPublished", true );
		event.paramValue( "publishedDate", now() );
		event.paramValue( "publishedTime", timeFormat( rc.publishedDate, "HH" ) & ":" & timeFormat( rc.publishedDate, "mm" ) );
		event.paramValue( "expireDate", "" );
		event.paramValue( "expireTime", "" );
		event.paramValue( "changelog", "" );
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
			cbMessageBox.warn( messageArray=errors );
			return editor( argumentCollection=arguments );
		}

		// TODO: strip out, not needed?
		var isNew = ( NOT prc.feedItem.isLoaded() );

		if ( isNew ) {
			prc.feed.setCreator( prc.oCurrentAuthor );
		}

		// TODO: Do we care about this?  We will be using excerpt mainly, content is the full content on import
		prc.feedItem.addNewContentVersion( 
			content=rc.content, 
			changelog=rc.changelog, 
			author=prc.oCurrentAuthor
		);

		var categories = [];
		if( len( trim( rc.newCategories ) ) ){
			categories = categoryService.createCategories( trim( rc.newCategories ) );
		}
		categories.addAll( categoryService.inflateCategories( rc ) );
		prc.feedItem.removeAllCategories().setCategories( categories );

		announceInterception( "agadmin_preFeedItemSave", { // TODO: Add to moduleconfig, also to import routine
			feedItem=prc.feedItem,
			isNew=isNew,
			originalSlug=originalSlug
		});

		feedItemService.save( prc.feedItem );

		announceInterception( "agadmin_postFeedItemSave", {
			feedItem=prc.feedItem,
			isNew=isNew,
			originalSlug=originalSlug
		});

		if ( event.isAjax() ) {
			var rData = { "CONTENTID" = prc.feedItem.getContentID() };
			event.renderData( type="json", data=rData );
		} else {
			cbMessageBox.info( "Feed Item Saved!" );
			setNextEvent( prc.xehFeedItems );
		}

	}

	function remove( event, rc, prc ) {
		
		event.paramValue( "contentID", "" );

		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feedItem = feedItemService.get( contentID );
				if ( isNull( feedItem ) ) {
					arrayAppend( messages, "Invalid feed item selected: #contentID#." );
				} else {
					var title = feedItem.getTitle();
					announceInterception( "agadmin_preFeedItemRemove", { feedItem=feedItem } );
					feedItemService.deleteContent( feedItem );
					announceInterception( "agadmin_postFeedItemRemove", { contentID=contentID } );
					arrayAppend( messages, "Feed item '#title#' deleted." );
				}
			}
			cbMessageBox.info( messageArray=messages );
		} else {
			cbMessageBox.warn( "No feed Items selected!" );
		}

		setNextEvent( prc.xehFeedItems );

	}

	function status( event, rc, prc ) {

		event.paramValue( "contentID", "" );
		event.paramValue( "contentStatus", "draft" );

		if ( len( rc.contentID ) ) {
			feedItemService.bulkPublishStatus( contentID=rc.contentID, status=rc.contentStatus );
			announceInterception( "agadmin_onFeedItemStatusUpdate", { contentID=rc.contentID, status=rc.contentStatus } );
			cbMessageBox.info( "#listLen( rc.contentID )# feed items were set to '#rc.contentStatus#'." );
		} else {
			cbMessageBox.warn( "No feed items selected!" );
		}

		setNextEvent( prc.xehFeedItems );

	}

	function resetHits( event, rc, prc ) {

		event.paramValue( "contentID", "" );
		
		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feedItem = feedItemService.get( contentID );
				if ( isNull( feedItem ) ) {
					arrayAppend( messages, "Invalid feed item selected: #contentID#." );
				} else {
					if ( feedItem.hasStats() ) {
						feedItem.getStats().setHits( 0 );
						feedItemService.save( feedItem );
					}
					arrayAppend( messages, "Hits reset for '#feedItem.getTitle()#'." );
				}
			}
			cbMessageBox.info( messageArray=messages );
		} else {
			cbMessageBox.warn( "No feed items selected!" );
		}

		setNextEvent( prc.xehFeedItems );

	}

}