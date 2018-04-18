component accessors="true" extends="contentbox.models.ui.Paging" {

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
