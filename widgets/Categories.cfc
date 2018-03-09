component extends="aggregator.models.BaseWidget" singleton {

	Categories function init() {
		setName( "Feed Item Categories" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a list of feed item categories." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "tags" );
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

		// Grab the categories
		var categories = categoryService.list( sortOrder="category", asQuery=false );

		// Set return html
		var html = "";

		// Generate html
		saveContent variable="html" {
			// Title
			if ( len( trim( arguments.title ) ) ) {
				writeOutput( "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>" );
			}
			// Dropdown
			if( arguments.useDropdown ){
				writeoutput( buildDropDown( categories, arguments.showItemCount ) );
			// List
			} else {
				writeoutput( buildList( categories, arguments.showItemCount ) );
			}
		}

		return html;

	}

	private function buildDropDown( categories, showItemCount ) {

		// Set return html
		var html = "";

		// Generate html
		saveContent variable="html" {
			// Select start
			writeOutput('<select name="categories" id="categories" onchange="window.location=this.value" )><option value="##">Select Category</option>');
			// Select options
			for ( var x=1; x LTE arrayLen( arguments.categories ); x++ ) {
				var feedItemCount = feedItemService.getPublishedFeedItems( category=categories[x].getSlug(), countOnly=true ).count;
				if ( feedItemCount ) {
					writeOutput('<option value="#ag.linkCategory( arguments.categories[x] )#">#arguments.categories[x].getCategory()#');
					if ( arguments.showItemCount ) { writeOutput( " (#feedItemCount#)" ); }
					writeOutput('</option>');
				}
			}
			// Select end
			writeOutput( "</select>" );
		}

		return html;

	}

	private function buildList( categories, showItemCount ) {

		// Set return html
		var html = "";

		// Generate html
		saveContent variable="html" {
			// List start
			writeOutput('<ul id="categories">');
			// List items
			for ( var x=1; x LTE arrayLen( arguments.categories ); x++ ) {
				var feedItemCount = feedItemService.getPublishedFeedItems( category=categories[x].getSlug(), countOnly=true ).count;
				if ( feedItemCount ) {
					writeOutput('<li class="categories"><a href="#ag.linkCategory( arguments.categories[x] )#">#arguments.categories[x].getCategory()#');
					if ( arguments.showItemCount ) { writeOutput( " (#feedItemCount#)" ); }
					writeOutput('</a></li>');
				}
			}
			// List end
			writeOutput( "</ul>" );
		}

		return html;

	}

}