<cfoutput>
<script>

function setupFeedView( settings ) {

	$contentForm = $("##feedForm");
	$tableContainer = $("##feedsTableContainer");
	$tableURL = "#event.buildLink( prc.xehFeedTable )#";
	$bulkStatusURL = "#event.buildlink( prc.xehFeedBulkStatus )#";

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

	if( criteria == undefined ) { criteria = {}; }
	if( !( "page" in criteria) ) { criteria.page = 1; }
	if( !( "search" in criteria) ) { criteria.search = ""; }
	if( !( "creator" in criteria) ) { criteria.creator = "all"; }
	if( !( "category" in criteria) ) { criteria.category = "all"; }
	if( !( "status" in criteria) ) { criteria.status = "any"; }
	if( !( "state" in criteria) ) { criteria.state = "any"; }
	if( !( "showAll" in criteria) ) { criteria.showAll = false; }
	
	$tableContainer.css( "opacity", .60 );

	var args = {  
		page : criteria.page,
		search : criteria.search,
		creator : criteria.creator,
		category : criteria.category,
		status : criteria.status,
		state : criteria.state,
		showAll : criteria.showAll
	};

	$tableContainer.load( $tableURL, args, function() {
		$tableContainer.css( "opacity", 1 );
		$(this).fadeIn("fast");
	});

}

function contentFilter() {
	if ( $("##creator").val() != "all" || 
		$("##category").val() != "all" || 
		$("##status").val() != "any" || 
		$("##state").val() != "any" ) {
		$("##filterBox").addClass("selected");
	} else {
		$("##filterBox").removeClass("selected");
	}
	contentLoad({
		search : $("##search").val(),
		creator : $("##creator").val(),
		category : $("##category").val(),
		status : $("##status").val(),
		state : $("##state").val()
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
	$("##creator").val("all");
	$("##category").val("all");
	$("##status").val("any");
	$("##state").val("any");
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

function remove( contentID, id ) {
	id = typeof id !== "undefined" ? id : "contentID";
	checkAll( false, id );
	if ( contentID != null ) {
		$( "##delete_" + contentID ).removeClass("fa fa-minus-circle").addClass("fa fa-spinner fa-spin");
		checkByValue( id, contentID );
	}
	$contentForm.submit();
}

function bulkRemove() {
	$contentForm.submit();
}

function bulkChangeStatus( status, contentID ) {
	$contentForm.attr( "action", $bulkStatusURL );
	$contentForm.find("##contentStatus").val( status );
	if( contentID != null ) {
		$( "##status_"+ recordID ).removeClass("fa fa-minus-circle").addClass("fa fa-spinner fa-spin");
		checkByValue( "contentID", contentID );
	}
	$contentForm.submit();
}

function resetHits( contentID ) {
	if( !contentID.length ){ return; }
	$.post( 
		"#event.buildLink( prc.xehResetHits )#",
		{ contentID: contentID }
	).done( function( data ) {
		if ( data.error ) {
			window.alert( "Error Reseting Hits: " + data.messages.join( ',' ) );
		} else {
			adminNotifier( "info", data.messages.join( "<br/>" ), 3000 );
			contentFilter();
		}
	});
}

function resetBulkHits() {
	var selected = [];
	$("##contentID:checked").each( function() {
		selected.push( $( this ).val() );
	});
	if( selected.length ) { 
		resetHits( selected.join( "," ) ); 
	}
}

$(document).ready( function() {
	setupFeedView();
	contentLoad();
});

</script>
</cfoutput>