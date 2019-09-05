/**
 * ContentBox RSS Aggregator
 * Feed Items Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return FeedItems
	 */
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
	 * Renders the feed items widget
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
	 * @includeEntries.hint Include entries or not, defaults to the global setting.
	 * @return The feed items widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		numeric max=5,
		string feed = "",
		string category="",
		string searchTerm="",
		string sortOrder="Most Recent",
		boolean openNewWindow=false,
		boolean includeEntries=ag.setting("ag_site_display_entries") ) {

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

		// Grab the results
		var results = feedItemService.getPublishedFeedItems(
			category = arguments.category,
			searchTerm = arguments.searchTerm,
			feed = arguments.feed,
			sortOrder = arguments.sortOrder,
			max = arguments.max,
			includeEntries = arguments.includeEntries
		);

		// iteration cap
		if ( results.count LT arguments.max ) {
			arguments.max = results.count;
		}

		// Set return html
		var html = "";

		// Title
		if ( len( trim( arguments.title ) ) ) {
			html &= "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>";
		}

		// List start
		html &= '<ul id="feedItems">';

		// List items
		for ( var x=1; x LTE arguments.max; x++ ) {
			var target = "_self";
			if ( arguments.openNewWindow ) {
				target = "_blank";
			}
			html &= '<li class="feedItems"><a href="#ag.linkContent( results.feedItems[x] )#" target="#target#" rel="nofollow<cfif args.openNewWindow > noopener</cfif>">#results.feedItems[x].getTitle()#</a></li>';
		}

		// List end
		html &= "</ul>";

		return html;

	}

}