component extends="aggregator.models.BaseWidget" singleton {

	Portal function init() {
		setName( "Portal" );
		setVersion( "1.0" );
		setDescription( "A widget that displays the portal index." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "newspaper-o" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	* @max.label Maximum Items
	* @max.hint The number of feed items to display.
	* @max.options 1,5,10,15,20,25,50,100
	* @feed.label Feed
	* @feed.hint The feed to filter on.
	* @feed.optionsUDF getFeedSlugs
	* @category.label Category
	* @category.hint The list of categories to filter on.
	* @category.multiOptionsUDF getAllCategories
	* @searchTerm.label Search Term
	* @searchTerm.hint The search term to filter on.
	* @sortOrder.label Sort Order
	* @sortOrder.hint How to order the results, defaults to date published from the feed.
	* @sortOrder.options Most Recent,Most Popular
	* @openNewWindow.label Open In New Window?
	* @openNewWindow.hint Open feed items in a new window (tab), default is false.
	*/
	string function renderIt(
		numeric max = 10,
		string feed = "",
		string category = "",
		string searchTerm = "",
		string sortOrder = "Most Recent",
		boolean openNewWindow=false
	) {

		// Sort order
		switch ( arguments.sortOrder ) {
			case "Most Popular": {
				arguments.sortOrder = "numberOfHits DESC";
				break;
			}
			default : {
				arguments.sortOrder = "publishedDate DESC";
			}
		}

		// Grab the event
		var event = getRequestContext();
		var prc = event.getCollection(private=true);

		// Paging
		prc.oPaging = getModel("paging@cb");
		prc.oPaging.setpagingMaxRows( arguments.max );
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink = ag.linkPortal() & "?page=@page@";

		// Grab the results
		var results = feedItemService.getPublishedFeedItems(
			category=arguments.category,
			searchTerm=arguments.searchTerm,
			feed=arguments.feed,
			sortOrder=arguments.sortOrder,
			max = arguments.max,
			offset = prc.pagingBoundaries.startRow - 1
		);
		prc.feedItems = results.feedItems;
		prc.itemCount = results.count;

		// Set return string
		var string = "";
		var args = {
			openNewWindow = arguments.openNewWindow
		};

		// Generate html
		saveContent variable="string" {
			if ( prc.itemCount ) {
				writeOutput( "#ag.quickFeedItems( args=args )#" );
				writeOutput( '<div class="contentBar">#ag.quickPaging()#</div>' );
			} else {
				writeOutput( "<div>No results found.</div>" );
			}
		}

		return string;

	}

	array function getFeedSlugs() cbIgnore {
		var slugs = feedService.getAllFlatSlugs();
		arrayPrepend( slugs, "" );
		return slugs;
	}

	array function getAllCategories() cbIgnore {
		return categoryService.getAllNames();
	}

}