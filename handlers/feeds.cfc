component extends="baseHandler" {

	property name="feedService" inject="feedService@aggregator";
	property name="categoryService" inject="categoryService@cb";
	property name="editorService" inject="editorService@cb";
	property name="htmlHelper" inject="HTMLHelper@coldbox";
	property name="ckHelper" inject="CKHelper@contentbox-ckeditor";

	function preHandler( event, action, eventArguments, rc, prc ) {
		
		super.preHandler( argumentCollection=arguments );

		prc.xehSlugify = "#prc.agAdminEntryPoint#.feeds.slugify";
		prc.xehSlugCheck = "#prc.agAdminEntryPoint#.feeds.slugUnique";

	}

	function index( event, rc, prc ) {

		prc.authors = authorService.getAll( sortOrder="lastName" );
		prc.categories = categoryService.getAll( sortOrder="category" );

		event.setView( "feeds/index" );

	}

	function table( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "creator", "all" );
		event.paramValue( "category", "all" );
		event.paramValue( "status", "any" );
		event.paramValue( "state", "any" );
		event.paramValue( "showAll", false );

		prc.oPaging = getModel( "Paging@cb" );
		prc.paging = prc.oPaging.getBoundaries();
		prc.pagingLink = "javascript:contentPaginate(@page@)";

		var results = feedService.search(
			search=rc.search,
			creator=rc.creator,
			category=rc.category,
			status=rc.status,
			state=rc.state,
			offset=( rc.showAll ? 0 : prc.paging.startRow-1 ),
			max=( rc.showAll ? 0 : prc.cbSettings.cb_paging_maxrows ),
			sortOrder="title ASC"
		);
		prc.feeds = results.feeds;
		prc.feedsCount = results.count;

		event.setView( view="feeds/table", layout="ajax" );

	}

	function editor( event, rc, prc ) {

		prc.ckHelper = ckHelper;

		prc.markups = editorService.getRegisteredMarkups();
		prc.editors = editorService.getRegisteredEditorsMap();
		prc.defaultMarkup = prc.oCurrentAuthor.getPreference( "markup", editorService.getDefaultMarkup() );
		prc.defaultEditor = getUserDefaultEditor( prc.oCurrentAuthor );
		prc.oEditorDriver = editorService.getEditor( prc.defaultEditor );

		prc.categories = categoryService.getAll( sortOrder="category" );

		if ( !structKeyExists( prc, "feed" ) ) {
			prc.feed = feedService.get( event.getValue( "contentID", 0 ) );
		}

		event.setView( "feeds/editor" );

	}

	function save( event, rc, prc ) {

		// Editor
		event.paramValue( "contentID", 0 );
		event.paramValue( "contentType", "Feed" );
		event.paramValue( "title", "" );
		event.paramValue( "slug", "" );
		event.paramValue( "content", "" );
		event.paramValue( "excerpt", "" );
		// Filtering
		event.paramValue( "filterByAny", "" );
		event.paramValue( "filterByAll", "" );
		event.paramValue( "filterByNone", "" );
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
		// Feed processing
		event.paramValue( "isActive", true );
		event.paramValue( "startDate", "" );
		event.paramValue( "startTime", "" );
		event.paramValue( "stopDate", "" );
		event.paramValue( "stopTime", "" );
		// Categories
		event.paramValue( "newCategories", "" );

		if ( NOT len( rc.publishedDate ) ) {
			rc.publishedDate = dateFormat( now() );
		}

		rc.slug =  htmlHelper.slugify( len( rc.slug ) ? rc.slug : rc.title );

		// TODO: Publishing permissions
		// FEEDS_ADMIN ?
		/*if( !prc.oCurrentAuthor.checkPermission( "PAGES_ADMIN" ) ){
			rc.isPublished 	= "false";
		}*/

		prc.feed = feedService.get( rc.contentID );
		var originalSlug = prc.feed.getSlug();
		var wasPaused = !prc.feed.isActive();

		populateModel( prc.feed )
			.addJoinedPublishedtime( rc.publishedTime )
			.addJoinedExpiredTime( rc.expireTime )
			.addJoinedStartTime( rc.startTime )
			.addJoinedStopTime( rc.stopTime );

		var errors = prc.feed.validate();

		if ( !len( trim( rc.content ) ) ) {
			arrayAppend( errors, "Please enter a description." );
		}

		if ( arrayLen( errors ) ) {
			cbMessageBox.warn( messageArray=errors );
			return editor( argumentCollection=arguments );
		}

		var isNew = ( NOT prc.feed.isLoaded() );

		if ( isNew ) {
			prc.feed.setCreator( prc.oCurrentAuthor );
		}

		prc.feed.addNewContentVersion( 
			content=rc.content, 
			changelog=rc.changelog, 
			author=prc.oCurrentAuthor
		);

		var categories = [];
		if( len( trim( rc.newCategories ) ) ){
			categories = categoryService.createCategories( trim( rc.newCategories ) );
		}
		categories.addAll( categoryService.inflateCategories( rc ) );
		prc.feed.removeAllCategories().setCategories( categories );

		announceInterception( "agadmin_preFeedSave", {
			feed=prc.feed,
			isNew=isNew,
			originalSlug=originalSlug
		});

		feedService.save( prc.feed );

		// TODO: Fetch items (only if new and active or was paused and now is active)
		/*
		if ( isNew && prc.feed.isActive() || wasPaused && prc.feed.isActive() ) {
			feedService.import( prc.feed );
		}
		*/

		announceInterception( "agadmin_postFeedSave", {
			feed=prc.feed,
			isNew=isNew,
			originalSlug=originalSlug
		});

		if ( event.isAjax() ) {
			var rData = { "CONTENTID" = prc.feed.getContentID() };
			event.renderData( type="json", data=rData );
		} else {
			cbMessageBox.info( "Feed Saved!" );
			setNextEvent( prc.xehFeeds );
		}

	}

	function remove( event, rc, prc ) {
		
		event.paramValue( "contentID", "" );

		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feed = feedService.get( contentID );
				if ( isNull( feed ) ) {
					arrayAppend( messages, "Invalid feed selected: #contentID#." );
				} else {
					var title = feed.getTitle();
					announceInterception( "agadmin_preFeedRemove", { feed=feed } );
					feedService.deleteContent( feed );
					announceInterception( "agadmin_postFeedRemove", { contentID=contentID } );
					arrayAppend( messages, "Feed '#title#' deleted." );
				}
			}
			cbMessageBox.info( messageArray=messages );
		} else {
			cbMessageBox.warn( "No feeds selected!" );
		}

		setNextEvent( prc.xehFeeds );

	}

	function status( event, rc, prc ) {

		event.paramValue( "contentID", "" );
		event.paramValue( "contentStatus", "draft" );

		if ( len( rc.contentID ) ) {
			feedService.bulkPublishStatus( contentID=rc.contentID, status=rc.contentStatus );
			announceInterception( "agadmin_onFeedStatusUpdate", { contentID=rc.contentID, status=rc.contentStatus } );
			cbMessageBox.info( "#listLen( rc.contentID )# feeds were set to '#rc.contentStatus#'." );
		} else {
			cbMessageBox.warn( "No feeds selected!" );
		}

		setNextEvent( prc.xehFeeds );

	}

	function state( event, rc, prc ) {
		
		event.paramValue( "contentID", "" );
		event.paramValue( "contentState", "pause" );

		if ( len( rc.contentID ) ) {
			feedService.bulkActiveState( contentID=rc.contentID, status=rc.contentState );
			announceInterception( "cbadmin_onEntryStatusUpdate", { contentID=rc.contentID, state=rc.contentState } );
			cbMessageBox.info( "#listLen( rc.contentID )# feeds were set to '#rc.contentState#'." );
		} else {
			cbMessageBox.warn( "No feeds selected!" );
		}

		setNextEvent( prc.xehFeeds );

	}

	function import( event, rc, prc ) {

		event.paramValue( "contentID", "" );

		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feed = feedService.get( contentID );
				if ( isNull( feed ) ) {
					arrayAppend( messages, "Invalid feed selected: #contentID#." );
				} else {
					// TODO: Thread here?
					feedService.import( feed, prc.oCurrentAuthor );
					arrayAppend( messages, "Items imported for '#feed.getTitle()#'." );
				}
			}
			cbMessageBox.info( messageArray=messages );
		} else {
			cbMessageBox.warn( "No feeds selected!" );
		}

		setNextEvent( prc.xehFeeds );

	}

	function resetHits( event, rc, prc ) {

		event.paramValue( "contentID", "" );
		
		if ( len( rc.contentID ) ) {
			rc.contentID = listToArray( rc.contentID );
			var messages = [];
			for ( var contentID in rc.contentID ) {
				var feed = feedService.get( contentID );
				if ( isNull( feed ) ) {
					arrayAppend( messages, "Invalid feed selected: #contentID#." );
				} else {
					if ( feed.hasStats() ) {
						feed.getStats().setHits( 0 );
						feedService.save( feed );
					}
					arrayAppend( messages, "Hits reset for '#feed.getTitle()#'." );
				}
			}
			cbMessageBox.info( messageArray=messages );
		} else {
			cbMessageBox.warn( "No feeds selected!" );
		}

		setNextEvent( prc.xehFeeds );

	}

	function slugify( event, rc, prc ) {
		event.renderData( data=trim( HTMLHelper.slugify( rc.slug ) ), type="plain" );
	}

	function slugUnique( event, rc, prc ) {

		event.paramValue( "slug", "" );
		event.paramValue( "contentID", "" );

		var data = { "UNIQUE" = false };
		
		if ( len( rc.slug ) ) {
			data[ "UNIQUE" ] = feedService.isSlugUnique( trim( rc.slug ), trim( rc.contentID ) );
		}
		
		event.renderData( data=data, type="json" );

	}

	private function getUserDefaultEditor( required author ) {

		var userEditor = arguments.author.getPreference( "editor", editorService.getDefaultEditor() );

		if ( editorService.hasEditor( userEditor ) ) {
			return userEditor;
		}

		arguments.author.setPreference( "editor", editorService.getDefaultEditor() );
		authorService.save( arguments.author );

		return editorService.getDefaultEditor();

	}

}