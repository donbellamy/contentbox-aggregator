component extends="baseHandler" {

	property name="feedService" inject="feedService@aggregator";
	//property name="authorService" inject="authorService@cb";
	//property name="themeService" inject="themeService@cb";
	property name="categoryService" inject="categoryService@cb";
	property name="editorService" inject="editorService@cb";
	property name="htmlHelper" inject="HTMLHelper@coldbox";
	property name="ckHelper" inject="CKHelper@contentbox-ckeditor";

	function preHandler( event, action, eventArguments, rc, prc ) {
		
		super.preHandler( argumentCollection=arguments );

		prc.xehSlugify = "#prc.agAdminEntryPoint#.feeds.slugify";
		prc.xehSlugCheck = "#prc.agAdminEntryPoint#.feeds.slugUnique"; // TODO: slugunique

	}

	function index( event, rc, prc ) {

		event.setView( "feeds/index" );

	}

	function table( event, rc, prc ) {

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

		prc.feed = feedService.get( event.getValue( "contentID", 0 ) );

		event.setView( "feeds/editor" );

	}

	function save( event, rc, prc ) {

		writedump(rc);
		abort;

		setNextEvent( prc.xehFeeds );

	}

	function slugify( event, rc, prc ) {
		event.renderData( data=trim( htmlHelper.slugify( rc.slug ) ), type="plain" );
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