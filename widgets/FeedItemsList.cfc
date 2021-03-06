/**
 * ContentBox Aggregator
 * Feed Items List Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return FeedItemsList
	 */
	FeedItemsList function init() {
		setName( "Feed Items List" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a simple list of published feed items." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "list-alt" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	 * Renders the feed items list widget
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
	 * @category.hint The category to filter on.
	 * @category.optionsUDF getCategorySlugs
	 * @searchTerm.label Search Term
	 * @searchTerm.hint The search term to filter on.
	 * @sortOrder.label Sort Order
	 * @sortOrder.hint How to order the feed items, defaults to published date.
	 * @sortOrder.options Most Recent,Most Popular,Title
	 * @return The feed items list widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		numeric max=5,
		string feed = "",
		string category="",
		string searchTerm="",
		string sortOrder="Most Recent" ) {

		// Sort order
		switch ( arguments.sortOrder ) {
			case "Most Popular": {
				arguments.sortOrder = "numberOfHits DESC";
				break;
			}
			case "Title": {
				arguments.sortOrder = "title ASC";
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
			includeEntries = ag.setting("feed_items_include_entries")
		);

		// Iteration cap
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
		html &= '<ul id="feed-items-list">';

		// List items
		for ( var x=1; x LTE arguments.max; x++ ) {
			html &= '<li><a href="#ag.linkContent( results.feedItems[x] )#" rel="nofollow">#results.feedItems[x].getTitle()#</a></li>';
		}

		// List end
		html &= "</ul>";

		return html;

	}

}