component extends="aggregator.models.BaseWidget" singleton {

	RelatedContent function init() {
		setName( "Related Content" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a list of related content." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "sitemap" );
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
	* @emptyMessage.label Empty Message
	* @emptyMessage.hint Message to show when no related content is found.
	*/
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		boolean useDropdown=false,
		string emptyMessage="Sorry, no related content was found.",
	) {

		// Grab the related content
		var relatedContent = ag.getCurrentRelatedContent();

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// Title
			if ( len( trim( arguments.title ) ) ) {
				writeOutput( "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>" );
			}
			// Check for content
			if ( arrayLen( relatedContent ) ) {
				// Dropdown
				if( arguments.useDropdown ){
					writeoutput( buildDropDown( relatedContent ) );
				// List
				} else {
					writeoutput( buildList( relatedContent ) );
				}
			} else {
				writeoutput( "<p>#arguments.emptyMessage#</p>" );
				if( cb.isPreview() ) {
					writeoutput( "<small>NOTE: Related content may not appear in preview mode!</small>" );
				}
			}
		}

		return string;

	}

	private function buildDropDown( required array relatedContent ) {

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// Select start
			writeOutput('<select name="relatedcontent" id="relatedcontent" onchange="window.location=this.value" )><option value="##">Select Content</option>');
			// Select options
			for ( var x=1; x LTE arrayLen( arguments.relatedContent ); x++ ){
				if( relatedContent[x].isContentPublished() ){
					writeoutput('<option value="#ag.linkContent( arguments.relatedContent[x] )#">#arguments.relatedContent[x].getTitle()#');
					writeoutput('</option>');
				}
			}
			// Select end
			writeOutput( "</select>" );
		}

		return string;

	}

	private function buildList( required array relatedContent ) {

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// List start
			writeOutput('<ul id="relatedcontent">');
			// List items
			for ( var x=1; x LTE arrayLen( arguments.relatedContent ); x++ ) {
				if ( relatedContent[x].isContentPublished() ) {
					writeOutput('<li class="relatedcontent"><a href="#ag.linkContent( arguments.relatedContent[x] )#">#arguments.relatedContent[x].getTitle()#');
					writeOutput('</a></li>');
				}
			}
			// List end
			writeOutput( "</ul>" );
		}

		return string;

	}

}