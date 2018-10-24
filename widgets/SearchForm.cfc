/**
 * ContentBox RSS Aggregator
 * Search Form Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return SearchForm
	 */
	SearchForm function init() {
		setName( "Feed Item Search Form" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a feed item search form." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "search" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	 * Renders the search form widget
	 * @title.label Title
	 * @title.hint An optional title to display using an H tag.
	 * @titleLevel.label Title Level
	 * @titleLevel.hint The H{level} to use.
	 * @titleLevel.options 1,2,3,4,5
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2
	) {

		// Set return string
		var string = "";

		// Grab the event
		var event = getRequestContext();

		// Set args
		var args = {
			title = arguments.title,
			titleLevel = arguments.titleLevel,
			q = htmlEditFormat( event.getValue( "q", "" ) )
		};

		// Render the search form
		return renderView(
			view = "#cb.themeName()#/templates/portalsearch",
			module = "contentbox",
			args = args
		);

	}

}