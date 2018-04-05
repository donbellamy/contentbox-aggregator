component extends="coldbox.system.Interceptor" {

	function aggregator_preIndexDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_pre_index_display );
	}

	function aggregator_postIndexDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_post_index_display );
	}

	function aggregator_preFeedsDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_pre_feeds_display );
	}

	function aggregator_postFeedsDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_post_feeds_display );
	}

	function aggregator_preFeedDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_pre_feed_display );
	}

	function aggregator_postFeedDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_post_feed_display );
	}

	function aggregator_preArchivesDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_pre_archives_display );
	}

	function aggregator_postArchivesDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_post_archives_display );
	}

	function aggregator_preSideBarDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_pre_sidebar_display );
	}

	function aggregator_postSideBarDisplay( event, interceptData ) {
		appendToBuffer( getSettings( event ).ag_html_post_sidebar_display );
	}

	private function getSettings( event ) {
		return event.getValue( name="agSettings", private=true );
	}

}