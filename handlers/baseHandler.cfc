component extends="coldbox.system.EventHandler" {

	property name="settingService" inject="settingService@aggregator";
	property name="messagebox" inject="messagebox@cbmessagebox";

	function preHandler( event, rc, prc, action, eventArguments ) {}

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