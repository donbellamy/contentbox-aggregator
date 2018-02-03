component extends="baseHandler" {

	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="categoryService" inject="categoryService@cb";
	property name="authorService" inject="authorService@cb";
	property name="editorService" inject="editorService@cb";
	property name="htmlHelper" inject="HTMLHelper@coldbox";
	property name="ckHelper" inject="CKHelper@contentbox-ckeditor";

	function preHandler( event, rc, prc, action, eventArguments ) {
		
		prc.xehSlugCheck = "#prc.cbAdminEntryPoint#.content.slugUnique";

	}

	function slugify( event, rc, prc ) {
		event.renderData( data=trim( htmlHelper.slugify( rc.slug ) ), type="plain" );
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