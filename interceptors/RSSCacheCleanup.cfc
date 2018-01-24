component extends="coldbox.system.Interceptor" {

	// postfeedimport ?
	// postfeedimportprocess ?

	function aggregator_postFeedItemSave( event, interceptData ) {
		//getModel( "rssService@cb" ).clearCaches();
	}
	
	function aggregator_postFeedItemRemove( event, interceptData ) {
		//getModel( "rssService@cb" ).clearCaches();
	}

}