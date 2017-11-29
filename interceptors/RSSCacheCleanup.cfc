component extends="coldbox.system.Interceptor" {

	// postfeedimport ?
	// postfeedimportprocess ?

	function agadmin_postFeedItemSave( event, interceptData ) {
		//getModel( "rssService@cb" ).clearCaches();
	}
	
	function agadmin_postFeedItemRemove( event, interceptData ) {
		//getModel( "rssService@cb" ).clearCaches();
	}

}