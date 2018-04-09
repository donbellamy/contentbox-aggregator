component extends="baseHandler" {

	property name="entryService" inject="id:entryService@cb";
	property name="pageService" inject="id:pageService@cb";
	property name="contentService" inject="id:contentService@cb";
	property name="categoryService" inject="id:categoryService@cb";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";

	function topContent( event, rc, prc ) {
		prc.topContent = contentService.getTopVisitedContent();
		event.setView( view="dashboard/topContent", layout="ajax" );
	}

	function topCommented( event, rc, prc ) {
		prc.topCommented = contentService.getTopCommentedContent();
		event.setView( view="dashboard/topCommented", layout="ajax" );
	}

	function contentCounts( event, rc, prc ) {
		prc.entriesCount = entryService.count();
		prc.pagesCount = pageService.count();
		prc.categoriesCount = categoryService.count();
		prc.feedsCount = feedService.count();
		prc.feedItemsCount = feedItemService.count();
		event.setView( view="dashboard/contentCounts", layout="ajax" );
	}

}