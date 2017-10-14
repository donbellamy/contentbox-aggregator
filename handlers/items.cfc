component extends="baseHandler" {

	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="categoryService" inject="categoryService@cb";

	function preHandler( event, action, eventArguments, rc, prc ) {
		
		super.preHandler( argumentCollection=arguments );

		//prc.xehSlugify = "#prc.agAdminEntryPoint#.feeds.slugify";
		//prc.xehSlugCheck = "#prc.agAdminEntryPoint#.feeds.slugUnique";

	}

	function index( event, rc, prc ) {

		prc.feeds = feedService.getAll( sortOrder="title" );
		prc.categories = categoryService.getAll( sortOrder="category" );

		event.setView( "items/index" );

	}

	function table( event, rc, prc ) {

		event.paramValue( "page", 1 );
		event.paramValue( "search", "" );
		event.paramValue( "feed", "all" );
		event.paramValue( "category", "all" );
		event.paramValue( "status", "any" );
		event.paramValue( "showAll", false );

		prc.oPaging = getModel( "Paging@cb" );
		prc.paging = prc.oPaging.getBoundaries();
		prc.pagingLink = "javascript:contentPaginate(@page@)";

		var results = feedItemService.search(
			search=rc.search,
			feed=rc.feed,
			category=rc.category,
			status=rc.status,
			offset=( rc.showAll ? 0 : prc.paging.startRow-1 ),
			max=( rc.showAll ? 0 : prc.cbSettings.cb_paging_maxrows ),
			sortOrder="title ASC"
		);
		prc.feedItems = results.feeds;
		prc.feedItemsCount = results.count;

		event.setView( view="items/table", layout="ajax" );

	}

	function editor( event, rc, prc ) {

		prc.ckHelper = ckHelper;

		if ( !structKeyExists( prc, "feedItem" ) ) {
			prc.feedItem = feedItemService.get( event.getValue( "contentID", 0 ) );
		}

		event.setView( "feeds/editor" );

	}

}