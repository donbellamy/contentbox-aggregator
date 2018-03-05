component extends="aggregator.models.BaseWidget" singleton {

	RecentItems function init() {
		setName( "Recent Items" );
		setVersion( "1.0" );
		setDescription( "A basic widget that displays recent feed items." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "list" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	* @max.hint The number of feed items to display.
	* @max.label Maximum Items
	* @title.hint An optional title to display using an H tag.
	* @title.label Title
	* @titleLevel.hint The H{level} to use.
	* @titleLevel.label Title Level
	* @category.hint The list of categories to filter on.
	* @category.label Category
	* @category.multiOptionsUDF getAllCategories
	* @searchTerm.hint The search term to filter on.
	* @searchTerm.label Search Term
	* @sortOrder.hint How to order the results, defaults to date published from the feed.
	* @sortOrder.label Sort Order
	* @sortOrder.options Most Recent,Most Popular
	*/
	// TODO: feed argument
	// TODO: list, listitem classes
	string function renderIt(
		numeric max=5,
		string title="",
		numeric titleLevel=2,
		string category="",
		string searchTerm="",
		string sortOrder="Most Recent"
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
			max=arguments.max,
			category=arguments.category,
			searchTerm=arguments.searchTerm,
			sortOrder=arguments.sortOrder
		);

		// iteration cap
		if( results.count LT arguments.max ){
			arguments.max = results.count;
		}

		// Set return html
		var html = "";

		// Generate html
		saveContent variable="html" {
			// Title
			if ( len( trim( arguments.title ) ) ) { 
				writeOutput( "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>" ); 
			}
			// List start
			writeOutput('<ul id="recentEntries">');
			// List items
			for ( var x=1; x LTE arguments.max; x++ ) {
				writeOutput('<li class="recentEntries"><a href="#ag.linkFeedItem( results.feedItems[x] )#">#results.feedItems[x].getTitle()#</a></li>');
			}
			// List end
			writeOutput( "</ul>" );
		}

		return html;
	}

	/**
	* Get all the categories
	*/
	array function getAllCategories() cbIgnore {
		return categoryService.getAllNames();
	}

}