/**
 * ContentBox RSS Aggregator
 * Categories Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return Categories
	 */
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
	 * Renders the feed item categories widget
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
	 * @includeEntries.label Include Entries?
	 * @includeEntries.hint Include entries in the item count or not, defaults to the global setting.
	 * @return The feed item categories widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		string category="",
		boolean useDropdown=false,
		boolean showItemCount=true,
		boolean includeEntries=ag.setting("ag_portal_display_entries") ) {

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
			if ( arguments.useDropdown ) {
				writeoutput( buildDropDown( categories, arguments.showItemCount, arguments.category, arguments.includeEntries ) );
			// List
			} else {
				writeoutput( buildList( categories, arguments.showItemCount, arguments.category, arguments.includeEntries ) );
			}
		}

		return string;

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Builds the drop down menu
	 */
	private string function buildDropDown( categories, showItemCount, categoryFilter, includeEntries ) {

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// Select start
			writeOutput('<select name="categories" id="categories" onchange="window.location=this.value" )><option value="##">Select Category</option>');
			// Select options
			for ( var x=1; x LTE arrayLen( arguments.categories ); x++ ) {
				var feedItemCount = feedItemService.getPublishedFeedItems( category=categories[x].getSlug(), countOnly=true, includeEntries=arguments.includeEntries ).count;
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

	/**
	 * Builds the list menu
	 */
	private string function buildList( categories, showItemCount, categoryFilter, includeEntries  ) {

		// Set return string
		var string = "";

		// Generate html
		saveContent variable="string" {
			// List start
			writeOutput('<ul id="categories">');
			// List items
			for ( var x=1; x LTE arrayLen( arguments.categories ); x++ ) {
				var feedItemCount = feedItemService.getPublishedFeedItems( category=categories[x].getSlug(), countOnly=true, includeEntries=arguments.includeEntries ).count;
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

}