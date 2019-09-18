<cfoutput>
<script>
function setupBlacklistItemView( settings ) {
	$contentForm = $("##blacklistedItemForm");
	$tableContainer = $("##blacklistedItemsTableContainer");
	$blacklistedItemEditor = $("##blacklistedItemEditor");
	$blacklistedItemEditor.validate();
	$("##btnReset").click(function() {
		$blacklistedItemEditor.find( "##blacklistedItemID" ).val("");
	});
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
	if ( !( "feed" in criteria) ) { criteria.feed = ""; }
	if ( !( "showAll" in criteria) ) { criteria.showAll = false; }
	$tableContainer.css( "opacity", .60 );
	var args = {
		page : criteria.page,
		search : criteria.search,
		feed : criteria.feed,
		showAll : criteria.showAll
	};
	$tableContainer.load( "#event.buildLink( prc.xehBlacklistedItemTable )#", args, function() {
		$tableContainer.css( "opacity", 1 );
		$(this).fadeIn("fast");
	});
}
function contentFilter() {
	if ( $("##feed").val() != "" ) {
		$("##filterBox").addClass("selected");
	} else {
		$("##filterBox").removeClass("selected");
	}
	$("##feedFilter").val( $("##feed").val() );
	contentLoad({
		search : $("##search").val(),
		feed : $("##feed").val()
	});
}
function contentShowAll() {
	contentLoad({
		search : $("##search").val(),
		feed : $("##feed").val(),
		showAll : true
	});
}
function resetFilter( reload ) {
	if ( reload ) {
		contentLoad();
	}
	$("##search").val("");
	$("##feedFilter").val("");
	$("##feed").val("");
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
function remove( blacklistedItemID ) {
	if ( blacklistedItemID != null ) {
		checkByValue( "blacklistedItemID", blacklistedItemID );
	}
	$contentForm.submit();
}
function edit(blacklistedItemID,title,itemUrl,feedId) {
	openModal( $( "##blacklistedItemEditorContainer" ) );
	$blacklistedItemEditor.find( "##blacklistedItemID" ).val(blacklistedItemID);
	$blacklistedItemEditor.find( "##title" ).val(title);
	$blacklistedItemEditor.find( "##itemUrl" ).val(itemUrl);
	$blacklistedItemEditor.find( "##feedId" ).val(feedId);
	return false;
}
function create() {
	openModal( $( "##blacklistedItemEditorContainer" ) );
	$blacklistedItemEditor.find( "##blacklistedItemID" ).val("");
	$blacklistedItemEditor.find( "##title" ).val("");
	$blacklistedItemEditor.find( "##itemUrl" ).val("");
	$blacklistedItemEditor.find( "##feedId" ).val("");
	return false;
}
function contentPaginate( page ) {
	contentLoad({
		page : page,
		search : $("##search").val(),
		feed : $("##feed").val()
	});
}
$(document).ready( function() {
	setupBlacklistItemView();
	var criteria = {
		page: "#rc.page#",
		search: "#rc.search#",
		feed: "#rc.feed#",
		showAll: "#rc.showAll#"
	};
	contentLoad( criteria );
});
</script>
</cfoutput>