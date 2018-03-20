component extends="aggregator.models.BaseWidget" singleton {

	Portal function init() {
		setName( "Portal" );
		setVersion( "1.0" );
		setDescription( "A widget that displays the portal index." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "newspaper-o" );
		setCategory( "Aggregator" );
		return this;
	}

	string function renderIt() {

		// Grab the event
		var event = getRequestContext();
		var prc = event.getCollection(private=true);

		// Paging
		prc.oPaging = getModel("paging@cb");
		prc.pagingBoundaries = prc.oPaging.getBoundaries( pagingMaxRows=ag.setting("ag_portal_paging_max_rows") );
		prc.pagingLink = ag.linkPortal() & "?page=@page@";

		// Grab the results
		var results = feedItemService.getPublishedFeedItems(
			max=ag.setting("ag_portal_paging_max_rows"),
			offset=prc.pagingBoundaries.startRow - 1
		);

		// Set return string
		var string = "";

		return string;

	}

}