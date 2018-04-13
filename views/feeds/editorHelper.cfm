<cfoutput>
#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/editors", prePostExempt=true )#
<script>
var feedSaveUrl = "#event.buildLink( prc.xehFeedSave )#";
$( document ).ready( function() {
	var $feedForm = $("##feedForm");
	setupEditors( $feedForm, true, feedSaveUrl );
	$("##validateFeed").click(function() {
		var feedUrl = $("##feedUrl").val();
		if ( isUrlValid( feedUrl ) ) {
			var win = window.open( "http://validator.w3.org/feed/check.cgi?url=" + feedUrl, "_blank" );
			if ( win ) {
				win.focus();
			} else {
				alert("Popup blocked.");
			}
		}
	});
	$("##openSiteUrl").click(function() {
		var siteUrl = $("##siteUrl").val();
		if ( isUrlValid( siteUrl ) ) {
			var win = window.open( siteUrl, "_blank" );
			if ( win ) {
				win.focus();
			} else {
				alert("Popup blocked.");
			}
		}
	});
	$(".counter").on( "change", function() {
		if ( $(this).val() == 0 ) $(this).val("");
	});
	// Hide quick preview and full history links for now
	$("##contentToolBar .pull-right").hide();
	$("##versionsPager .buttonBar .btn-default").hide();
});
function importFeed() {
	var $feedForm = $("##feedForm");
	$feedForm.attr("action","#event.buildLink( prc.xehFeedImport )#").submit();
}
function isUrlValid( url ) {
	return /^https?:\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(##((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(url);
}
function removeImport( feedImportID ) {
	$.post(
		"#event.buildlink( prc.xehFeedImportRemove )#",
		{ feedImportID : feedImportID },
		function( data ) {
			closeConfirmations();
			if( !data.ERROR ){
				$( '##import_row_' + feedImportID ).fadeOut().remove();
				adminNotifier( "info", data.MESSAGES, 10000 );
			} else {
				adminNotifier( "error", data.MESSAGES, 10000 );
			}
		},
		"json"
	);
}
</script>
</cfoutput>