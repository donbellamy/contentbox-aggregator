<cfoutput>
#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/editors", prePostExempt=true )#
<script>
var feedItemSaveUrl = "#event.buildLink( prc.xehFeedItemSave )#";
$( document ).ready( function() {
	var $feedItemForm = $("##feedItemForm");
	setupEditors( $feedItemForm, true, feedItemSaveUrl );
});
</script>
</cfoutput>