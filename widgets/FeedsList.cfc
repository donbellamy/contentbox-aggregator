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
		setDescription( "A widget that displays a simple list of feeds." );
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
	 * @max.options 1,5,10,15,20,25,50,100,unlimited
	 * @category.label Category
	 * @category.hint The list of categories to filter on.
	 * @category.multiOptionsUDF getCategorySlugs
	 * @return The feeds list widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		numeric max=5,
		string category="" ) {

		// Grab the event
		var event = getRequestContext();
		var prc = event.getCollection(private=true);

		// Fixes bug in widget preview - take out when fixed
		prc.cbTheme = prc.cbSettings.cb_site_theme;
		prc.cbThemeRecord = themeService.getThemeRecord( prc.cbTheme );

		return "";

	}

}