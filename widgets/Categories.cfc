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
	* @category.label Category
	* @category.hint The list of categories to filter on.
	* @category.multiOptionsUDF getAllCategories
	* @useDropdown.label Use Dropdown?
	* @useDropdown.hint Display as a dropdown or a list, default is list.
	* @showItemCount.label Show Item Count?
	* @showItemCount.hint Show item counts or not, default is true.
	*/
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		string category="",
		boolean useDropdown=false,
		boolean showItemCount=true
	) {

		// Grab the categories
		var categories = categoryService.list( sortOrder="category", asQuery=false );

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
				writeoutput( buildDropDown( categories, arguments.showItemCount, arguments.category ) );
			// List
			} else {
				writeoutput( buildList( categories, arguments.showItemCount, arguments.category ) );
			}
		}

		return string;

	}

	private function buildDropDown( categories, showItemCount, categoryFilter ) {

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// Select start
			writeOutput('<select name="categories" id="categories" onchange="window.location=this.value" )><option value="##">Select Category</option>');
			// Select options
			for ( var x=1; x LTE arrayLen( arguments.categories ); x++ ) {
				var feedItemCount = feedItemService.getPublishedFeedItems( category=categories[x].getSlug(), countOnly=true ).count;
				var showCategory = !len( arguments.categoryFilter ) || ( len( arguments.categoryFilter ) && listFindNoCase( arguments.categoryFilter, categories[x].getCategory() ) );
				if ( feedItemCount && showCategory ) {
					writeOutput('<option value="#ag.linkCategory( arguments.categories[x] )#">#arguments.categories[x].getCategory()#');
					if ( arguments.showItemCount ) { writeOutput( " (#feedItemCount#)" ); }
					writeOutput('</option>');
				}
			}
			// Select end
			writeOutput( "</select>" );
		}

		return string;

	}

	private function buildList( categories, showItemCount, categoryFilter ) {

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// List start
			writeOutput('<ul id="categories">');
			// List items
			for ( var x=1; x LTE arrayLen( arguments.categories ); x++ ) {
				var feedItemCount = feedItemService.getPublishedFeedItems( category=categories[x].getSlug(), countOnly=true ).count;
				var showCategory = !len( arguments.categoryFilter ) || ( len( arguments.categoryFilter ) && listFindNoCase( arguments.categoryFilter, categories[x].getCategory() ) );
				if ( feedItemCount && showCategory ) {
					writeOutput('<li class="categories"><a href="#ag.linkCategory( arguments.categories[x] )#">#arguments.categories[x].getCategory()#');
					if ( arguments.showItemCount ) { writeOutput( " (#feedItemCount#)" ); }
					writeOutput('</a></li>');
				}
			}
			// List end
			writeOutput( "</ul>" );
		}

		return string;

	}

	array function getAllCategories() cbIgnore {
		return categoryService.getAllNames();
	}

}