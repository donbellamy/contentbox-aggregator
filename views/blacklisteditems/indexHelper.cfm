<cfoutput>
<script>
function setupBlacklistItemView( settings ) {
	$contentForm = $("##blacklistedItemForm");
	$tableContainer = $("##blacklistedItemsTableContainer");
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