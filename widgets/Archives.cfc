component extends="aggregator.models.BaseWidget" singleton {

	Archives function init() {
		setName( "Feed Item Archives" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a list of feed item archives." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "calendar" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	* @title.label Title
	* @title.hint An optional title to display using an H tag.
	* @titleLevel.label Title Level
	* @titleLevel.hint The H{level} to use.
	* @titleLevel.options 1,2,3,4,5
	* @useDropdown.label Use Dropdown?
	* @useDropdown.hint Display as a dropdown or a list, default is list.
	* @showItemCount.label Show Item Count?
	* @showItemCount.hint Show item counts or not, default is true.
	*/
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		boolean useDropdown=false,
		boolean showItemCount=true
	) {

		// Grab the archives
		var archives = feedItemService.getArchiveReport();

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// Title
			if ( len( trim( arguments.title ) ) ) {
				writeOutput( "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>" );
			}
			// Dropdown
			if( arguments.useDropdown ){
				writeoutput( buildDropDown( archives, arguments.showItemCount ) );
			// List
			} else {
				writeoutput( buildList( archives, arguments.showItemCount ) );
			}
		}

		return string;

	}

	private function buildDropDown( archives, showItemCount ) {

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// Select start
			writeOutput('<select name="archives" id="archives" onchange="window.location=this.value" )><option value="##">Select Archive</option>');
			// Select options
			for ( var x=1; x LTE arrayLen( arguments.archives ); x++ ) {
				var thisDate = arguments.archives[x]["year"] & "-" & arguments.archives[x]["month"] & "-1";
				writeOutput('<option value="#ag.linkArchive( year=arguments.archives[x]['year'], month=arguments.archives[x]['month'])#">#dateFormat( thisDate, "mmmm yyyy" )#');
				if ( arguments.showItemCount ) { writeOutput( " (#arguments.archives[x]['count']#)" ); }
				writeOutput('</option>');
			}
			// Select end
			writeOutput( "</select>" );
		}

		return string;

	}

	private function buildList( archives, showItemCount ) {

		// Set return html
		var string = "";

		// Generate html
		saveContent variable="string" {
			// List start
			writeOutput('<ul id="archives">');
			// List items
			for ( var x=1; x LTE arrayLen( arguments.archives ); x++ ) {
				var thisDate = arguments.archives[x]["year"] & "-" & arguments.archives[x]["month"] & "-1";
				writeOutput('<li class="archives"><a href="#ag.linkArchive( year=arguments.archives[x]['year'], month=arguments.archives[x]['month'])#">#dateFormat( thisDate, "mmmm yyyy" )#');
				if ( arguments.showItemCount ) { writeOutput( " (#arguments.archives[x]['count']#)" ); }
				writeOutput('</a></li>');
			}
			// List end
			writeOutput( "</ul>" );
		}

		return string;

	}

}