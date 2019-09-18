/**
 * ContentBox Aggregator
 * Paging Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component accessors="true" extends="contentbox.models.ui.Paging" {

	/**
	 * Renders the paging widget
	 * @foundRows The total number of rows
	 * @link The link to use in the paging widget
	 * @pagingMaxRows The max paging rows
	 * @asList Whether or not to display as a list
	 * @type The type of content we are paging, defaults to "items"
	 * @return The paging widget html
	 */
	string function renderIt(
		required numeric foundRows,
		required string link,
		numeric pagingMaxRows,
		boolean asList=false,
		string type="items" ) {

		var pager = super.renderIt( argumentCollection=arguments );

		return replaceNoCase( pager, "entries", arguments.type, "all" );

	}

}
