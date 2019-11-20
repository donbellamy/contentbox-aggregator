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
	 * @category.hint The category to filter on.
	 * @category.optionsUDF getCategorySlugs
	 * @sortOrder.label Sort Order
	 * @sortOrder.hint How to order the results, defaults to feed title.
	 * @sortOrder.options Feed Title,Most Recent
	 * @includeItems.label Include Feed Items?
	 * @includeItems.hint Displays the most recent five feed items within the list of feeds, defaults to false.
	 * @return The feeds widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		string category="",
		string sortOrder="Feed Title",
		boolean includeItems=false ) {

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

		// Sort order
		switch ( arguments.sortOrder ) {
			case "Most Recent": {
				// TODO: Check global setting and do not include if we can
				prc.pagingLink &= "&sb=recent";
				arguments.sortOrder = "lastPublishedDate DESC";
				break;
			}
			default : {
				arguments.sortOrder = "title ASC";
			}
		}

		// Include items
		// TODO: Check global setting and do not include if we can
		if ( arguments.includeItems ) {
			prc.pagingLink &= "&inc=items";
		}

		// Grab the results
		var results = feedService.getPublishedFeeds(
			sortOrder = arguments.sortOrder,
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