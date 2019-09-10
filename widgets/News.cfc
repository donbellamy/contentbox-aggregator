/**
 * ContentBox RSS Aggregator
 * News Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return News
	 */
	News function init() {
		setName( "News" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a list of feed items, similar to the news page." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "newspaper-o" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	 * Renders the news widget
	 * @title.label Title
	 * @title.hint An optional title to display using an H tag.
	 * @titleLevel.label Title Level
	 * @titleLevel.hint The H{level} to use.
	 * @titleLevel.options 1,2,3,4,5
	 * @feed.label Feed
	 * @feed.hint The feed to filter on.
	 * @feed.optionsUDF getFeedSlugs
	 * @category.label Category
	 * @category.hint The list of categories to filter on.
	 * @category.multiOptionsUDF getCategorySlugs
	 * @searchTerm.label Search Term
	 * @searchTerm.hint The search term to filter on.
	 * @sortOrder.label Sort Order
	 * @sortOrder.hint How to order the results, defaults to date published from the feed.
	 * @sortOrder.options Most Recent,Most Popular
	 * @openNewWindow.label Open In New Window?
	 * @openNewWindow.hint Open feed items in a new window (tab), default is false.
	 * @return The news widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		string feed="",
		string category="",
		string searchTerm="",
		string sortOrder="Most Recent",
		boolean openNewWindow=false ) {

		// Grab the event
		var event = getRequestContext();
		var prc = event.getCollection(private=true);

		// Fixes bug in widget preview - take out when fixed
		prc.cbTheme = prc.cbSettings.cb_site_theme;
		prc.cbThemeRecord = themeService.getThemeRecord( prc.cbTheme );

		// Paging
		prc.oPaging = getModel("paging@aggregator");
		prc.oPaging.setpagingMaxRows( ag.setting("ag_site_paging_max_items") );
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink = ag.linkNews();

		// Category
		if ( len( trim( arguments.category ) ) ) {
			prc.pagingLink &= "/category/#arguments.category#/";
		}

		// Paging
		prc.pagingLink &= "?page=@page@";

		// Feed
		if ( len( trim( arguments.feed ) ) ) {
			prc.pagingLink &= "&feed=" & arguments.feed;
		}

		// Search
		if ( len( trim( arguments.searchTerm ) ) ) {
			prc.pagingLink &= "&q=" & arguments.searchTerm;
		}

		// Sort order
		switch ( arguments.sortOrder ) {
			case "Most Popular": {
				prc.pagingLink &= "&sb=hits";
				arguments.sortOrder = "numberOfHits DESC";
				break;
			}
			default : {
				arguments.sortOrder = "publishedDate DESC";
			}
		}

		// Grab the results
		var results = feedItemService.getPublishedFeedItems(
			searchTerm = arguments.searchTerm,
			category = arguments.category,
			feed = arguments.feed,
			sortOrder = arguments.sortOrder,
			max = ag.setting("ag_site_paging_max_items"),
			offset = prc.pagingBoundaries.startRow - 1,
			includeEntries = ag.setting("ag_site_display_entries")
		);
		prc.feedItems = results.feedItems;
		prc.itemCount = results.count;

		// Set args
		var args = {
			title = arguments.title,
			titleLevel = arguments.titleLevel,
			openNewWindow = arguments.openNewWindow
		};

		// Render the news template
		return renderView(
			view = "#cb.themeName()#/templates/aggregator/news",
			module = cb.themeRecord().module,
			args = args
		);

	}

}