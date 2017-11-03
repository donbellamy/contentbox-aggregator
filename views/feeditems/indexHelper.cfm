<cfoutput>
<script>
function setupFeedView( settings ) {

	$contentForm = $("##feedItemForm");
	$tableContainer = $("##feedItemsTableContainer");

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
	if ( !( "feed" in criteria) ) { criteria.feed = "all"; }
	if ( !( "category" in criteria) ) { criteria.category = "all"; }
	if ( !( "status" in criteria) ) { criteria.status = "any"; }
	if ( !( "showAll" in criteria) ) { criteria.showAll = false; }
	
	$tableContainer.css( "opacity", .60 );

	var args = {  
		page : criteria.page,
		search : criteria.search,
		feed : criteria.feed,
		category : criteria.category,
		status : criteria.status,
		showAll : criteria.showAll
	};

	$tableContainer.load( "#event.buildLink( prc.xehFeedItemTable )#", args, function() {
		$tableContainer.css( "opacity", 1 );
		$(this).fadeIn("fast");
	});

}

function contentFilter() {
	if ( $("##feed").val() != "all" || $("##category").val() != "all" || $("##status").val() != "any" ) {
		$("##filterBox").addClass("selected");
	} else {
		$("##filterBox").removeClass("selected");
	}
	contentLoad({
		search : $("##search").val(),
		feed : $("##feed").val(),
		category : $("##category").val(),
		status : $("##status").val()
	});
}

function contentShowAll() {
	resetFilter();
	contentLoad( { showAll: true } );
}

function resetFilter( reload ){
	if ( reload ) {
		contentLoad();
	}
	$("##search").val("");
	$("##feed").val("all");
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
	$contentForm.attr( "action", "#event.buildlink( prc.xehFeedItemStatus )#" );
	$contentForm.find("##contentStatus").val( status );
	if ( contentID != null ) {
		checkByValue( "contentID", contentID );
	}
	$contentForm.submit();
}

function resetHits( contentID ) {
	$contentForm.attr( "action", "#event.buildlink( prc.xehFeedItemResetHits )#" );
	if ( contentID != null ) {
		checkByValue( "contentID", contentID );
	}
	$contentForm.submit();
}

function contentPaginate( page ) {
	contentLoad( {
		search : $("##search").val(),
		page : page,
		feed : $("##feed").val(),
		category : $("##category").val(),
		status : $("##status").val()
	} );
}

$(document).ready( function() {
	setupFeedView();
	contentLoad();
});
</script>
</cfoutput>