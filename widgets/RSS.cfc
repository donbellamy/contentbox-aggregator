component extends="aggregator.models.BaseWidget" singleton {

	RSS function init() {
		setName( "Portal RSS" );
		setVersion( "1.0" );
		setDescription( "A simple widget that displays a link to the portal rss feed." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "rss" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	* @title.label Title
	* @title.hint An optional title to display using an H tag.
	* @titleLevel.label Title Level
	* @titleLevel.hint The H{level} to use.
	* @titleLevel.options 1,2,3,4,5
	*/
	string function renderIt(
		string title="",
		numeric titleLevel=2
	){

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// Title
			if ( len( trim( arguments.title ) ) ) {
				writeOutput( "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>" );
			}
			// RSS Link
			writeOutput('<ul id="portalrss">');
			writeOutput('<li><a href="#ag.linkRSS()#" title="Subscribe to our RSS Feed!"><i class="fa fa-rss"></i></a> <a href="#ag.linkRSS()#" title="Subscribe to our RSS Feed!">RSS Feed</a></li>');
			writeOutput('</ul>');
		}

		return string;

	}

}