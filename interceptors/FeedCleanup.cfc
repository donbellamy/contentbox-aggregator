/**
 * Feed cleanup interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	/**
	 * Fired before feed delete
	 */
	function aggregator_preFeedRemove( event, interceptData ) {
		// TODO: should this fire after the feed is deleted?
		// TODO: make sure no other content is using this
		var feed = arguments.interceptData.feed;
		if ( len( feed.getFeaturedImage() ) && fileExists( feed.getFeaturedImage()  ) ) {
			try { fileDelete( feed.getFeaturedImage() ); } catch( any e ) {}
		}
	}

}