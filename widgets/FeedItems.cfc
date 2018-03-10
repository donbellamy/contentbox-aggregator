component extends="aggregator.models.BaseWidget" singleton {

	FeedItems function init() {
		setName( "Feed Items" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a list of feed items." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "list" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	* @title.label Title
	* @title.hint An optional title to display using an H tag.
	* @titleLevel.label Title Level
	* @titleLevel.hint The H{level} to use.
	* @titleLevel.options 1,2,3,4,5
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
	* @newWindow.label Open In New Window?
	* @newWindow.hint Open feed items in a new window (tab), default is true.
	*/
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		numeric max=5,
		string feed = "",
		string category="",
		string searchTerm="",
		string sortOrder="Most Recent",
		boolean newWindow=true
	) {

		// Sort order
		switch( arguments.sortOrder ) {
			case "Most Popular": {
				arguments.sortOrder = "numberOfHits DESC";
				break;
			}
			default : {
				arguments.sortOrder = "publishedDate DESC";
			}
		}

		// Grab the results
		var results = feedItemService.getPublishedFeedItems(
			category=arguments.category,
			searchTerm=arguments.searchTerm,
			feed=arguments.feed,
			sortOrder=arguments.sortOrder,
			max=arguments.max
		);

		// iteration cap
		if ( results.count LT arguments.max ) {
			arguments.max = results.count;
		}

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// Title
			if ( len( trim( arguments.title ) ) ) {
				writeOutput( "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>" );
			}
			// List start
			writeOutput('<ul id="recentItems">');
			// List items
			for ( var x=1; x LTE arguments.max; x++ ) {
				var target = "_self";
				if ( arguments.newWindow ) {
					target = "_blank";
				}
				writeOutput('<li class="recentItems"><a href="#ag.linkFeedItem( results.feedItems[x] )#" target="#target#">#results.feedItems[x].getTitle()#</a></li>');
			}
			// List end
			writeOutput( "</ul>" );
		}

		return string;

	}

	array function getFeedSlugs() {
		var slugs = feedService.getAllFlatSlugs();
		arrayPrepend( slugs, "" );
		return slugs;
	}

	array function getAllCategories() {
		return categoryService.getAllNames();
	}

}