<cfoutput>
<script>
function setupFeedView( settings ) {

	$contentForm = $("##feedForm");
	$tableContainer = $("##feedsTableContainer");

	$("##search").keyup(
		_.debounce(
			function() {
				var $this = $( this );
				contentLoad( { search : $this.val() } );
			},
			300
		)
	);

}

function contentLoad( criteria ) {

	if ( criteria == undefined ) { criteria = {}; }
	if ( !( "page" in criteria) ) { criteria.page = 1; }
	if ( !( "search" in criteria) ) { criteria.search = ""; }
	if ( !( "state" in criteria) ) { criteria.state = "any"; }
	if ( !( "category" in criteria) ) { criteria.category = "all"; }
	if ( !( "status" in criteria) ) { criteria.status = "any"; }
	if ( !( "showAll" in criteria) ) { criteria.showAll = false; }

	$tableContainer.css( "opacity", .60 );

	var args = {
		page : criteria.page,
		search : criteria.search,
		state : criteria.state,
		category : criteria.category,
		status : criteria.status,
		showAll : criteria.showAll
	};

	$tableContainer.load( "#event.buildLink( prc.xehFeedTable )#", args, function() {
		$tableContainer.css( "opacity", 1 );
		$(this).fadeIn("fast");
	});

}

function contentFilter() {
	if ( $("##state").val() != "any" || $("##category").val() != "all" || $("##status").val() != "any" ) {
		$("##filterBox").addClass("selected");
	} else {
		$("##filterBox").removeClass("selected");
	}
	$("##stateFilter").val( $("##state").val() );
	$("##categoryFilter").val( $("##category").val() );
	$("##statusFilter").val( $("##status").val() );
	contentLoad({
		search : $("##search").val(),
		state : $("##state").val(),
		category : $("##category").val(),
		status : $("##status").val()
	});
}

function contentShowAll() {
	contentLoad({
		search : $("##search").val(),
		state : $("##state").val(),
		category : $("##category").val(),
		status : $("##status").val(),
		showAll : true
	});
}

function resetFilter( reload ){
	if ( reload ) {
		contentLoad();
	}
	$("##search").val("");
	$("##stateFilter").val("any");
	$("##categoryFilter").val("all");
	$("##statusFilter").val("any");
	$("##state").val("any");
	$("##category").val("all");
	$("##status").val("any");
	$("##filterBox").removeClass("selected");
}

function activateInfoPanels() {
	$(".popovers").popover({
		html : true,
		content : function() {
			return getInfoPanelContent( $(this).attr("data-contentID")  );
		},
		trigger : "hover",
		placement : "left",
		title : '<i class="fa fa-info-circle"></i> Quick Info',
		delay : { show: 200, hide: 500 }
	});
}

function getInfoPanelContent( contentID ) {
	return $( "##infoPanel_" + contentID ).html();
}

function remove( contentID ) {
	if ( contentID != null ) {
		checkByValue( "contentID", contentID );
	}
	$contentForm.submit();
}

function changeStatus( status, contentID ) {
	$contentForm.attr( "action", "#event.buildlink( prc.xehFeedStatus )#" );
	$contentForm.find("##contentStatus").val( status );
	if ( contentID != null ) {
		checkByValue( "contentID", contentID );
	}
	$contentForm.submit();
}

function changeState( state, contentID ) {
	$contentForm.attr( "action", "#event.buildlink( prc.xehFeedState )#" );
	$contentForm.find("##contentState").val( state );
	if ( contentID != null ) {
		checkByValue( "contentID", contentID );
	}
	$contentForm.submit();
}

function resetHits( contentID ) {
	$contentForm.attr( "action", "#event.buildlink( prc.xehFeedResetHits )#" );
	if ( contentID != null ) {
		checkByValue( "contentID", contentID );
	}
	$contentForm.submit();
}

function importFeed( contentID ) {
	$contentForm.attr( "action", "#event.buildlink( prc.xehFeedImport )#" );
	if ( contentID != null ) {
		checkByValue( "contentID", contentID );
	}
	$contentForm.submit();
}

function importAll() {
	$contentForm.attr( "action", "#event.buildlink( prc.xehFeedImportAll )#" ).submit();
}

function contentPaginate( page ) {
	contentLoad( {
		search : $("##search").val(),
		page : page,
		state : $("##state").val(),
		category : $("##category").val(),
		status : $("##status").val()
	} );
}

$(document).ready( function() {
	setupFeedView();
	var criteria = {
		page: "#rc.page#",
		search: "#rc.search#",
		state: "#rc.state#",
		category: "#rc.category#",
		status: "#rc.status#",
		showAll: "#rc.showAll#"
	};
	contentLoad( criteria );
});
</script>
</cfoutput>