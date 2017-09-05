<cfoutput>
<!--- TODO: Write own tag if run into issues here? --->
#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/editors", prePostExempt=true )#
<script>
$( document ).ready( function() {
	$feedForm = $( "##feedForm" );
	setupEditors( $feedForm, <!---#prc.cbSettings.cb_page_excerpts#---> true, "#event.buildLink( prc.xehFeedSave )#" );
} );
</script>
</cfoutput>