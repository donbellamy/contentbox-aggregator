component extends="coldbox.system.Interceptor" {

	function aggregator_preFeedRemove( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		if ( len( feed.getFeaturedImage() ) && fileExists( feed.getFeaturedImage()  ) ) {
			try { fileDelete( feed.getFeaturedImage() ); } catch( any e ) {}
		}
	}

}