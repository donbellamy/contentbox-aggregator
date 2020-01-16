/**
 * ContentBox Aggregator
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
	 * @useDropdown.label Use Dropdown?
	 * @useDropdown.hint Display as a dropdown or a list, default is list.
	 * @showItemCount.label Show Item Count?
	 * @showItemCount.hint Show item counts or not, default is true.
	 * @return The feed item categories widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		boolean useDropdown=false,
		boolean showItemCount=true ) {

		// Grab the categories
		var categories = categoryService.list(
			sortOrder = "category",
			asQuery = false
		);

		// Set return html
		var html = "";

		// Title
		if ( len( trim( arguments.title ) ) ) {
			html &= "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>";
		}

		// Dropdown
		if ( arguments.useDropdown ) {
			html &= buildDropDown( categories, arguments.showItemCount );
		// List
		} else {
			html &= buildList( categories, arguments.showItemCount );
		}

		return html;

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Builds the drop down menu
	 */
	private string function buildDropDown( categories, showItemCount ) {

		// Set return html
		var html = "";

		// Select start
		html &= '<select onchange="window.location=this.value" )><option value="##">Select Category</option>';

			// Select options
		for ( var x=1; x LTE arrayLen( arguments.categories ); x++ ) {
			var feedItemCount = feedItemService.getPublishedFeedItems(
				category = categories[x].getSlug(),
				countOnly = true,
				includeEntries = ag.setting("feed_items_include_entries")
			).count;
			if ( feedItemCount ) {
				html &= '<option value="#ag.linkCategory( arguments.categories[x] )#">#arguments.categories[x].getCategory()#';
				if ( arguments.showItemCount ) {
					html &= " (#feedItemCount#)";
				}
				html &= "</option>";
			}
		}

		// Select end
		html &= "</select>";

		return html;

	}

	/**
	 * Builds the list menu
	 */
	private string function buildList( categories, showItemCount ) {

		// Set return html
		var html = "";

		// List start
		html &= '<ul>';

		// List items
		for ( var x=1; x LTE arrayLen( arguments.categories ); x++ ) {
			var feedItemCount = feedItemService.getPublishedFeedItems(
				category = categories[x].getSlug(),
				countOnly = true,
				includeEntries = ag.setting("feed_items_include_entries")
			).count;
			if ( feedItemCount ) {
				html &= '<li><a href="#ag.linkCategory( arguments.categories[x] )#">#arguments.categories[x].getCategory()#';
				if ( arguments.showItemCount ) {
					html &= " (#feedItemCount#)";
				}
				html &= "</a></li>";
			}
		}

		// List end
		html &= "</ul>";

		return html;

	}

}