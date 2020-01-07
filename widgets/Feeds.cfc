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
	 * @includeFeedItems.label Include Feed Items?
	 * @includeFeedItems.hint Displays the most recent five feed items within the list of feeds, defaults to false.
	 * @return The feeds widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		string category="",
		string sortOrder="Feed Title",
		boolean includeFeedItems=ag.setting("feeds_include_feed_items") ) {

		// Grab the event
		var event = getRequestContext();
		var prc = event.getCollection(private=true);

		// Set args
		var args = ag.getViewArgs().append({
			"title" = arguments.title,
			"titleLevel" = arguments.titleLevel,
			"includeFeedItems" = arguments.includeFeedItems
		});

		// Fixes bug in widget preview - take out when fixed
		prc.cbTheme = prc.cbSettings.cb_site_theme;
		prc.cbThemeRecord = themeService.getThemeRecord( prc.cbTheme );

		// Paging
		prc.oPaging = getModel("paging@aggregator");
		prc.oPaging.setpagingMaxRows( ag.setting("paging_max_feeds") );
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink = ag.linkFeeds();

		// Category
		if ( len( arguments.category ) ) {
			prc.pagingLink &= "/category/#arguments.category#/";
		}

		// Paging
		prc.pagingLink &= "?page=@page@";

		// Sort order
		switch ( arguments.sortOrder ) {
			case "Most Recent": {
				prc.pagingLink &= "&sb=recent";
				arguments.sortOrder = "lastPublishedDate DESC";
				break;
			}
			default : {
				arguments.sortOrder = "title ASC";
			}
		}

		// Include feed items
		if ( arguments.includeFeedItems &&
			( arguments.includeFeedItems != ag.setting("feeds_include_feed_items") )
		) {
			prc.pagingLink &= "&inc=items";
		}

		// Grab the results
		var results = feedService.getPublishedFeeds(
			sortOrder = arguments.sortOrder,
			category = arguments.category,
			max = ag.setting("paging_max_feeds"),
			offset = prc.pagingBoundaries.startRow - 1
		);
		prc.feeds = results.feeds;
		prc.itemCount = results.count;

		// Render the feeds view
		return renderView(
			view = "#cb.themeName()#/views/aggregator/widgets/feeds",
			module = cb.themeRecord().module,
			args = args
		);

	}

}