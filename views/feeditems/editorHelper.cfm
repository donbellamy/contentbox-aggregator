<cfoutput>
#renderView( view="/contentbox/modules/contentbox-admin/views/_tags/editors", prePostExempt=true )#
<script>
var feedItemSaveUrl = "#event.buildLink( prc.xehFeedItemSave )#";
$( document ).ready( function() {
	var $feedItemForm = $("##feedItemForm");
	setupEditors( $feedItemForm, false, feedItemSaveUrl );
	$("##contentToolBar .pull-right").hide();
	$("##versionsPager .buttonBar .btn-default").hide();
});
</script>
</cfoutput>