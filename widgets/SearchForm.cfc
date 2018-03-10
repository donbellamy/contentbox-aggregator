component extends="aggregator.models.BaseWidget" singleton {

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

		// Check incoming text
		var q = htmlEditFormat( event.getValue( "q", "" ) );

		// TODO: Change this to use a template rather than hardcoded classes
		// Generate html
		saveContent variable="string"{
			// Title
			if ( len( trim( arguments.title ) ) ) {
				writeOutput( "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>" );
			}
			// Form
			writeOutput('
			#html.startForm( name="searchForm", action=ag.linkPortal(), method="get" )#
				<div class="input-group">
					#html.textField( name="q", placeholder="Search", value=q, class="form-control")#
					<span class="input-group-btn">
						<button class="btn btn-primary" type="submit"><i class="fa fa-search"></i></button>
					</span>
				</div>
			#html.endForm()#
			');
		}

		return string;

	}

}