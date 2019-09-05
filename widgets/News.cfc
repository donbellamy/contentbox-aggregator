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
	 * @includeEntries.label Include Entries?
	 * @includeEntries.hint Include entries in the item count or not, defaults to the global setting.
	 * @return The news widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		numeric max=10,
		string feed="",
		string category="",
		string searchTerm="",
		string sortOrder="Most Recent",
		boolean openNewWindow=false,
		boolean includeEntries=ag.setting("ag_site_display_entries")  ) {

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
		prc.oPaging = getModel("paging@aggregator");
		prc.oPaging.setpagingMaxRows( arguments.max );
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink = ag.linkNews() & "?page=@page@";

		// Grab the results
		var results = feedItemService.getPublishedFeedItems(
			category = arguments.category,
			searchTerm = arguments.searchTerm,
			feed = arguments.feed,
			sortOrder = arguments.sortOrder,
			max = arguments.max,
			offset = prc.pagingBoundaries.startRow - 1,
			includeEntries=arguments.includeEntries
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
			view = "#cb.themeName()#/templates/news",
			module = cb.themeRecord().module,
			args = args
		);

	}

}