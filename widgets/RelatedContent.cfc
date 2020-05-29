/**
 * ContentBox Aggregator
 * Related Content Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return RelatedContent
	 */
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
	 * Renders the related content widget
	 * @title.label Title
	 * @title.hint An optional title to display using an H tag.
	 * @titleLevel.label Title Level
	 * @titleLevel.hint The H{level} to use.
	 * @titleLevel.options 1,2,3,4,5
	 * @useDropdown.label Use Dropdown?
	 * @useDropdown.hint Display as a dropdown or a list, defaults to list.
	 * @emptyMessage.label Empty Message
	 * @emptyMessage.hint Message to show when no related content is found.
	 * @return The related content widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		boolean useDropdown=false,
		string emptyMessage="Sorry, no related content was found." ) {

		// Grab the related content
		var relatedContent = ag.getCurrentRelatedContent();

		// Set return html
		var html = "";

		// Title
		if ( len( trim( arguments.title ) ) ) {
			html &= "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>";
		}

		// Check for content
		if ( arrayLen( relatedContent ) ) {
			// Dropdown
			if ( arguments.useDropdown ) {
				html &= buildDropDown( relatedContent );
			// List
			} else {
				html &= buildList( relatedContent );
			}
		} else {
			html &= "<p>#arguments.emptyMessage#</p>";
			if ( cb.isPreview() ) {
				html &= "<small>NOTE: Related content may not appear in preview mode!</small>";
			}
		}

		return html;

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Builds the drop down menu
	 */
	private string function buildDropDown( required array relatedContent ) {

		// Set return html
		var html = "";

		// Select start
		html &= '<select onchange="window.location=this.value" )><option value="##">Select Content</option>';

		// Select options
		for ( var x=1; x LTE arrayLen( arguments.relatedContent ); x++ ) {
			if ( relatedContent[x].isContentPublished() ) {
				html &= '<option value="#ag.linkContent( arguments.relatedContent[x] )#">#arguments.relatedContent[x].getTitle()#</option>';
			}
		}

		// Select end
		html &= "</select>";

		return html;

	}

	/**
	 * Builds the list menu
	 */
	private string function buildList( required array relatedContent ) {

		// Set return html
		var html = "";

		// List start
		html &= '<ul>';

		// List items
		for ( var x=1; x LTE arrayLen( arguments.relatedContent ); x++ ) {
			if ( relatedContent[x].isContentPublished() ) {
				html &= '<li><a href="#ag.linkContent( arguments.relatedContent[x] )#">#arguments.relatedContent[x].getTitle()#</a></li>';
			}
		}

		// List end
		html &= "</ul>";

		return html;

	}

}