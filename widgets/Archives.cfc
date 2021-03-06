/**
 * ContentBox Aggregator
 * Archives Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return Archives
	 */
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
	 * Renders the feed item archives widget
	 * @title.label Title
	 * @title.hint An optional title to display using an H tag.
	 * @titleLevel.label Title Level
	 * @titleLevel.hint The H{level} to use.
	 * @titleLevel.options 1,2,3,4,5
	 * @useDropdown.label Use Dropdown?
	 * @useDropdown.hint Display as a dropdown or a list, defaults to list.
	 * @showItemCount.label Show Item Count?
	 * @showItemCount.hint Show item counts or not, defaults to true.
	 * @monthLimit.label Number of months displayed
	 * @monthLimit.hint The number of months to display in the widget, defaults to 12, enter 0 for unlimited.
	 * @return The feed item archives widget html
	 */
	string function renderIt(
		string title="",
		numeric titleLevel=2,
		boolean useDropdown=false,
		boolean showItemCount=true,
		numeric monthLimit=12 ) {

		// Grab the archives
		var archives = feedItemService.getArchiveReport( includeEntries=ag.setting("feed_items_include_entries") );

		// Set return html
		var html = "";

		// Title
		if ( len( trim( arguments.title ) ) ) {
			html &= "<h#arguments.titleLevel#>#arguments.title#</h#arguments.titleLevel#>";
		}

		// Dropdown
		if ( arguments.useDropdown ) {
			html &= buildDropDown( archives, arguments.showItemCount, arguments.monthLimit );
		// List
		} else {
			html &= buildList( archives, arguments.showItemCount, arguments.monthLimit );
		}

		return html;

	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Builds the drop down menu
	 * @return The drop down menu html
	 */
	private string function buildDropDown( archives, showItemCount, monthLimit ) {

		// Set return html
		var html = "";

		// Select start
		html &= '<select onchange="window.location=this.value" )><option value="##">Select Archive</option>';

		// Select options
		for ( var x=1; x LTE arrayLen( arguments.archives ); x++ ) {
			var thisDate = arguments.archives[x]["year"] & "-" & arguments.archives[x]["month"] & "-1";
			html &= '<option value="#ag.linkArchive( year=arguments.archives[x]['year'], month=arguments.archives[x]['month'])#">#dateFormat( thisDate, "mmmm yyyy" )#';
			if ( arguments.showItemCount ) {
				html &= " (#arguments.archives[x]['count']#)";
			}
			html &= "</option>";
			if ( arguments.monthLimit && x == arguments.monthLimit ) {
				break;
			}
		}

		// Select end
		html &= "</select>";

		return html;

	}

	/**
	 * Builds the list menu
	 * @return The list menu html
	 */
	private string function buildList( archives, showItemCount, monthLimit ) {

		// Set return html
		var html = "";

		// List start
		html &= '<ul>';

		// List items
		for ( var x=1; x LTE arrayLen( arguments.archives ); x++ ) {
			var thisDate = arguments.archives[x]["year"] & "-" & arguments.archives[x]["month"] & "-1";
			html &= '<li><a href="#ag.linkArchive( year=arguments.archives[x]['year'], month=arguments.archives[x]['month'])#">#dateFormat( thisDate, "mmmm yyyy" )#';
			if ( arguments.showItemCount ) {
				html &= " (#arguments.archives[x]['count']#)";
			}
			html &= "</a></li>";
			if ( arguments.monthLimit && x == arguments.monthLimit ) {
				break;
			}
		}

		// List end
		html &= "</ul>";

		return html;

	}

}