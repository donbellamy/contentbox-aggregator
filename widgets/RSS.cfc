/**
 * ContentBox Aggregator
 * RSS Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return RSS
	 */
	RSS function init() {
		setName( "Aggregator RSS" );
		setVersion( "1.0" );
		setDescription( "A simple widget that displays a link to the aggregator rss feed." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "rss" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	 * Renders the rss widget
	 * @title.label Title
	 * @title.hint An optional title to display using an H tag.
	 * @titleLevel.label Title Level
	 * @titleLevel.hint The H{level} to use.
	 * @titleLevel.options 1,2,3,4,5
	 * @return The rss widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2 ) {

		// Set return html
		var html = "";

		// Title
		if ( len( trim( arguments.title ) ) ) {
			html &= "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>";
		}

		// RSS Link
		html &= '<ul id="aggregator-rss"><li><a href="#ag.linkRSS()#" title="Subscribe to our RSS Feed!"><i class="fa fa-rss"></i></a> <a href="#ag.linkRSS()#" title="Subscribe to our RSS Feed!">RSS Feed</a></li></ul>';

		return html;

	}

}