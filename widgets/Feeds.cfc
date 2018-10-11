/**
 * ContentBox RSS Aggregator
 * Feeds Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	// Widget properties
	Feeds function init() {
		setName( "Feeds" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a list of feeds." );
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
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2
	) {

		// Grab the results
		var results = feedService.search(
			status="published"
		);

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// Title
			if ( len( trim( arguments.title ) ) ) {
				writeOutput( "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>" );
			}
			// List start
			writeOutput('<ul id="feeds">');
			// List items
			for ( var x=1; x LTE results.count; x++ ) {
				writeOutput('<li class="feeds"><a href="#ag.linkFeed( results.feeds[x] )#">#results.feeds[x].getTitle()#</a></li>');
			}
			// List end
			writeOutput( "</ul>" );
		}

		return string;

	}

}