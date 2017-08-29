<cfoutput>
#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/editors", prePostExempt=true )#
<script>
$( document ).ready( function() {
	$feedForm = $( "##feedForm" );
	setupEditors( $feedForm, false, '#event.buildLink( prc.xehFeedSave )#' );
} );
</script>
</cfoutput>