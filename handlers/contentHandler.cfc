/**
 * ContentBox RSS Aggregator
 * Content handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="baseHandler" {

	// Dependencies
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="categoryService" inject="categoryService@cb";
	property name="authorService" inject="authorService@cb";
	property name="editorService" inject="editorService@cb";
	property name="htmlHelper" inject="HTMLHelper@coldbox";
	property name="ckHelper" inject="CKHelper@contentbox-ckeditor";

	/**
	 * Pre handler
	 */
	function preHandler( event, rc, prc, action, eventArguments ) {

		// Exit handler
		prc.xehSlugCheck = "#prc.cbAdminEntryPoint#.content.slugUnique";

	}

	/**
	 * Slugify the value of rc.slug
	 */
	function slugify( event, rc, prc ) {

		event.paramValue( "slug", "" );

		event.renderData( data=trim( htmlHelper.slugify( rc.slug ) ), type="plain" );

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Gets the user's default editor
	 * @author The author object
	 * @return The default editor
	 */
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