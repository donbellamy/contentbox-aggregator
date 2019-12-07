/**
 * ContentBox Aggregator
 * Feed Items Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return FeedItems
	 */
	FeedItems function init() {
		setName( "Feed items" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a detailed list of feed items, similar to the feed items page." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "list" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	 * Renders the feed items widget
	 * @title.label Title
	 * @title.hint An optional title to display using an H tag.
	 * @titleLevel.label Title Level
	 * @titleLevel.hint The H{level} to use.
	 * @titleLevel.options 1,2,3,4,5
	 * @type.label Type
	 * @type.hint The type of feed item to filter on.
	 * @type.optionsUDF getTypes
	 * @feed.label Feed
	 * @feed.hint The feed to filter on.
	 * @feed.optionsUDF getFeedSlugs
	 * @category.label Category
	 * @category.hint The category to filter on.
	 * @category.optionsUDF getCategorySlugs
	 * @searchTerm.label Search Term
	 * @searchTerm.hint The search term to filter on.
	 * @sortOrder.label Sort Order
	 * @sortOrder.hint How to order the results, defaults to most recent.
	 * @sortOrder.options Most Recent,Most Popular
	 * @groupByDate.label Group by Date?
	 * @groupByDate.hint Group the results by published date, default is false.
	 * @openNewWindow.label Open In New Window?
	 * @openNewWindow.hint Open feed items in a new window (tab), default is false.
	 * @return The feed items widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		string type="",
		string feed="",
		string category="",
		string searchTerm="",
		string sortOrder="Most Recent",
		boolean groupByDate=false,
		boolean openNewWindow=false ) {

		// Grab the event
		var event = getRequestContext();
		var prc = event.getCollection(private=true);

		// Fixes bug in widget preview - take out when fixed
		prc.cbTheme = prc.cbSettings.cb_site_theme;
		prc.cbThemeRecord = themeService.getThemeRecord( prc.cbTheme );

		// Paging
		prc.oPaging = getModel("paging@aggregator");
		prc.oPaging.setpagingMaxRows( ag.setting("paging_max_feed_items") );
		prc.pagingBoundaries = prc.oPaging.getBoundaries();
		prc.pagingLink = ag.linkFeedItems();

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

		// Group by date
		// TODO: setting for this, then do not have to pass in the url
		prc.groupByDate = false; // TODO: move to args?
		if ( arguments.groupByDate ) {
			prc.groupByDate = true;
			prc.pagingLink &= "&gb=date";
			arguments.sortOrder = "Most Recent";
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

		// Set template and paging label
		prc.template = "feeditem";
		prc.pagingLabel = "items";
		if ( len( arguments.type ) && listFindNoCase( "podcast,video", arguments.type ) ) {
			prc.template = arguments.type;
			prc.pagingLink &= "&type=" & arguments.type;
			if ( arguments.type == "video" ) prc.pagingLabel = "videos";
			else if ( arguments.type == "podcast" ) prc.pagingLabel = "podcasts";
		}

		// Grab the results
		var results = feedItemService.getPublishedFeedItems(
			searchTerm = arguments.searchTerm,
			category = arguments.category,
			feed = arguments.feed,
			type = arguments.type,
			sortOrder = arguments.sortOrder,
			max = ag.setting("paging_max_feed_items"),
			offset = prc.pagingBoundaries.startRow - 1,
			includeEntries = ag.setting("feed_items_include_entries")
		);
		prc.feedItems = results.feedItems;
		prc.itemCount = results.count;

		// Set args
		var args = {
			title = arguments.title,
			titleLevel = arguments.titleLevel,
			openNewWindow = arguments.openNewWindow
		};

		// Render the feed items template
		return renderView(
			view = "#cb.themeName()#/views/aggregator/widgets/feeditems",
			module = cb.themeRecord().module,
			args = args
		);

	}

}