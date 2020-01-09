/**
 * ContentBox Aggregator
 * Feed Items List Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return FeedsList
	 */
	FeedsList function init() {
		setName( "Feeds List" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a simple list of published feeds." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "list-alt" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	 * Renders the feeds list widget
	 * @title.label Title
	 * @title.hint An optional title to display using an H tag.
	 * @titleLevel.label Title Level
	 * @titleLevel.hint The H{level} to use.
	 * @titleLevel.options 1,2,3,4,5
	 * @max.label Maximum Feeds
	 * @max.hint The number of feeds to display.
	 * @max.options 1,5,10,15,20,25,50,100
	 * @category.label Category
	 * @category.hint The category to filter on.
	 * @category.optionsUDF getCategorySlugs
	 * @return The feeds list widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		numeric max=5,
		string category="" ) {

		// Grab the results
		var results = feedService.getPublishedFeeds(
			category = arguments.category,
			max = arguments.max
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
		html &= '<ul id="feeds-list">';

		// List items
		for ( var x=1; x LTE arguments.max; x++ ) {
			html &= '<li><a href="#ag.linkFeed( results.feeds[x] )#" rel="nofollow">#results.feeds[x].getTitle()#</a></li>';
		}

			// List end
		html &= "</ul>";

		return html;

	}

}