component extends="coldbox.system.Interceptor" {

	function aggregator_preFeedRemove( event, interceptData ) {
		// TODO: make sure no other content is using this
		var feed = arguments.interceptData.feed;
		if ( len( feed.getFeaturedImage() ) && fileExists( feed.getFeaturedImage()  ) ) {
			try { fileDelete( feed.getFeaturedImage() ); } catch( any e ) {}
		}
	}

}