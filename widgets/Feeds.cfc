/**
 * ContentBox Aggregator
 * Feeds Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return Feeds
	 */
	Feeds function init() {
		setName( "Feeds" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a detailed list of feeds, similar to the feeds page." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "list" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	 * Renders the feeds widget
	 * @title.label Title
	 * @title.hint An optional title to display using an H tag.
	 * @titleLevel.label Title Level
	 * @titleLevel.hint The H{level} to use.
	 * @titleLevel.options 1,2,3,4,5
	 * @category.label Category
	 * @category.hint The list of categories to filter on.
	 * @category.optionsUDF getCategorySlugs
	 * @includeItems.label Include Feed Items
	 * @includeItems.hint Displays the most recent 5 feed items (last 7 days) within the list of feeds.  A feed without any recent feed items will not display.
	 * @return The feeds widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		string category="",
		boolean includeItems=true ) {

		// Grab the event
		var event = getRequestContext();
		var prc = event.getCollection(private=true);

		// Fixes bug in widget preview - take out when fixed
		prc.cbTheme = prc.cbSettings.cb_site_theme;
		prc.cbThemeRecord = themeService.getThemeRecord( prc.cbTheme );

		// Paging
		prc.oPaging = getModel("paging@aggregator");
		prc.oPaging.setpagingMaxRows( ag.setting("ag_site_paging_max_feeds") );
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink = ag.linkFeeds();

		// Category
		if ( len( arguments.category) ) {
			prc.pagingLink &= "/category/#arguments.category#/";
		}

		// Paging
		prc.pagingLink &= "?page=@page@";

		// Grab the results
		var results = feedService.getPublishedFeeds(
			category = arguments.category,
			max = ag.setting("ag_site_paging_max_feeds"),
			offset = prc.pagingBoundaries.startRow - 1
		);
		prc.feeds = results.feeds;
		prc.itemCount = results.count;

		// Set args
		var args = {
			title = arguments.title,
			titleLevel = arguments.titleLevel,
			includeItems = arguments.includeItems
		};

		// Render the feeds view
		return renderView(
			view = "#cb.themeName()#/views/aggregator/widgets/feeds",
			module = cb.themeRecord().module,
			args = args
		);

	}

}