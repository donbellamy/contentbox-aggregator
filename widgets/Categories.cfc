component extends="aggregator.models.BaseWidget" singleton {

	Categories function init() {
		setName( "Categories" );
		setVersion( "1.0" );
		setDescription( "A widget that displays feed item categories." );
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

		// Grab the categories TODO: Filter on feeditems and bring back number of them
		var categories = categoryService.list( sortOrder="category", asQuery=false );
		//var categories = feedItemService.getFeedItemCategories();
		//OR categoryService

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

	private function buildDropDown(categories,showPostCount){
		var rString = "";
		// generate recent comments
		saveContent variable="rString"{
			writeOutput('<select name="categories" id="categories" onchange="window.location=this.value" )><option value="##">Select Category</option>');
			// iterate and create
			for(var x=1; x lte arrayLen( arguments.categories ); x++){
				if( arguments.categories[ x ].getNumberOfEntries() gt 0 ){
					writeOutput('<option value="#cb.linkCategory(arguments.categories[ x ])#">#arguments.categories[ x ].getCategory()#');
					if( arguments.showPostCount ){ writeOutput( " (#arguments.categories[ x ].getNumberOfEntries()#)" ); }
					writeOutput('</option>');
				}
			}
			// close ul
			writeOutput( "</select>" );
		}
		return rString;
	}

	private function buildList(categories,showPostCount){
		var rString = "";
		// generate recent comments
		saveContent variable="rString"{
			writeOutput('<ul id="categories">');
			// iterate and create
			for(var x=1; x lte arrayLen( arguments.categories ); x++){
				if( arguments.categories[ x ].getNumberOfEntries() gt 0 ){
					writeOutput('<li class="categories"><a href="#cb.linkCategory(arguments.categories[ x ])#">#arguments.categories[ x ].getCategory()#');
					if( arguments.showPostCount ){ writeOutput( " (#arguments.categories[ x ].getNumberOfEntries()#)" ); }
					writeOutput('</a></li>');
				}
			}
			// close ul
			writeOutput( "</ul>" );
		}
		return rString;
	}

}