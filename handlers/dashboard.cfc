/**
 * Admin dashboard handler.  Extends and adds feed and feed item data to the admin dashboard.
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="baseHandler" {

	// Dependencies
	property name="entryService" inject="entryService@cb";
	property name="pageService" inject="pageService@cb";
	property name="categoryService" inject="categoryService@cb";
	property name="contentService" inject="contentService@cb";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";

	/**
	 * Clear portal cache
	 */
	function clearCache( event, rc, prc ) {
		announceInterception("aggregator_onClearCache");
		if( event.isAjax() ) {
			event.renderData( type="json", data={ error = false, executed = true } );
		} else {
			setNextEvent( prc.xehDashboard );
		}
	}

	/**
	 * Display top content
	 */
	function topContent( event, rc, prc ) {
		prc.topContent = contentService.getTopVisitedContent();
		event.setView( view="dashboard/topContent", layout="ajax" );
	}

	/**
	 * Display top commented
	 */
	function topCommented( event, rc, prc ) {
		prc.topCommented = contentService.getTopCommentedContent();
		event.setView( view="dashboard/topCommented", layout="ajax" );
	}

	/**
	 * Display content counts
	 */
	function contentCounts( event, rc, prc ) {
		prc.entriesCount = entryService.count();
		prc.pagesCount = pageService.count();
		prc.categoriesCount = categoryService.count();
		prc.feedsCount = feedService.count();
		prc.feedItemsCount = feedItemService.count();
		event.setView( view="dashboard/contentCounts", layout="ajax" );
	}

}