/**
 * ContentBox RSS Aggregator
 * Feed cleanup interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="feedService" inject="feedService@aggregator";

	/**
	 * Fired before feed delete
	 */
	function aggregator_preFeedRemove( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		if ( len( feed.getFeaturedImage() ) && fileExists( feed.getFeaturedImage() ) && !feedservice.isImageInUse( feed.getFeaturedImageUrl() ) ) {
			try { fileDelete( feed.getFeaturedImage() ); } catch( any e ) {}
		}
	}

}