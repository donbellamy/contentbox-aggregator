component extends="coldbox.system.EventHandler" {

	property name="settingService" inject="settingService@aggregator";
	property name="messagebox" inject="messagebox@cbmessagebox";
	
	// TODO: rename to baseAdminHandler ?  That way we can move a lot of common things here that wont be used on public side of things
	// TODO: baseContentHandler ?  Move stuff like slugunique, slugify, defaulteditor, etc... to it

	function preHandler( event, rc, prc, action, eventArguments ) {}

	// TODO: Move to baseAdminHandler ?  Or use cbadmins?
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