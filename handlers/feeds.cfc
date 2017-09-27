component extends="baseHandler" {

	property name="feedService" inject="feedService@aggregator";
	property name="authorService" inject="authorService@cb";
	//property name="themeService" inject="themeService@cb";
	property name="categoryService" inject="categoryService@cb";
	property name="editorService" inject="editorService@cb";
	property name="htmlHelper" inject="HTMLHelper@coldbox";
	property name="ckHelper" inject="CKHelper@contentbox-ckeditor";

	function preHandler( event, action, eventArguments, rc, prc ) {
		
		super.preHandler( argumentCollection=arguments );

		prc.xehSlugify = "#prc.agAdminEntryPoint#.feeds.slugify"; // TODO: slugify
		prc.xehSlugCheck = "#prc.agAdminEntryPoint#.feeds.slugUnique"; // TODO: slugunique

	}

	function index( event, rc, prc ) {

		prc.authors = authorService.getAll( sortOrder="lastName" );
		prc.categories = categoryService.getAll( sortOrder="category" );

		event.setView( "feeds/index" );

	}

	function table( event, rc, prc ) {

		prc.feeds = feedService.getAll( sortOrder="title" ); //TODO: replace with filtered list

		event.setView( view="feeds/table", layout="ajax" );

	}

	function bulkStatus( event, rc, prc ) {}

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

		populateModel( prc.feed )
			.addJoinedPublishedtime( rc.publishedTime )
			.addJoinedExpiredTime( rc.expireTime )
			.addJoinedStartTime( rc.startTime )
			.addJoinedStopTime( rc.stopTime );

		var errors = prc.feed.validate();

		if ( !len( trim( rc.content ) ) ) {
			arrayAppend( errors, "Please enter a description." );
		}

		// TODO: Add validation to Feed.cfc
		if( arrayLen( errors ) ) {
			cbMessageBox.warn( messageArray=errors );
			return editor( argumentCollection=arguments );
		}

		var isNew = ( NOT prc.feed.isLoaded() );

		if ( isNew ) {
			prc.feed.setCreator( prc.oCurrentAuthor );
		}

		// TODO: Author?

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

		// TODO: Fetch items

		announceInterception( "agadmin_postFeedSave", {
			feed=prc.feed,
			isNew=isNew,
			originalSlug=originalSlug
		});

		// TODO: Ajax?

		cbMessageBox.info( "Feed Saved!" );
		setNextEvent( prc.xehFeeds );

	}

	// TODO: SlugUnique - look in content.cfc handler or use it like cbadmin does?

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