<cfoutput>
#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/editors", prePostExempt=true )#
<script>
var feedItemSaveUrl = "#event.buildLink( prc.xehFeedItemSave )#";
$( document ).ready( function() {
	var $feedItemForm = $("##feedItemForm");
	setupEditors( $feedItemForm, true, feedItemSaveUrl );
	// Hide quick preview and full history links for now
	$("##contentToolBar .pull-right").hide();
	$("##versionsPager .buttonBar .btn-default").hide();
});
</script>
</cfoutput>