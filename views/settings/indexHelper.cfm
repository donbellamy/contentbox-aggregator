<cfoutput>
<script>
$( document ).ready( function() {
	$("##ag_general_import_interval").on("change",function(){
		if ( $(this).val() == "" ) {
			$("##ag_general_import_start_date").val("");
			$("##ag_general_import_start_time").val("");
		}
	});
	$(".datepicker").datepicker( { format: "mm/dd/yy" } );
	$(".clockpicker").clockpicker( { twelvehour: true } );
	$(".counter").on( "change", function() {
		if ( $(this).val() == 0 ) $(this).val("");
	});
});
function loadAssetChooser( callback, w, h ){
	openRemoteModal(
		"#event.buildLink( prc.cbAdminEntryPoint )#/ckFileBrowser/assetChooser?callback=" + callback,
		{},
		w || "75%",
		h
	);
}
function defaultImageCallback( filePath, fileURL, fileType ){
	if( $( "##ag_general_image_default" ).val().length ){ cancelDefaultImage(); }
    $( "##default_image_controls" ).toggleClass( "hide" );
    $( "##ag_general_image_default" ).val( filePath );
    $( "##ag_general_image_default_url" ).val( fileURL );
    $( "##default_image_preview" ).attr( "src", fileURL );
    closeRemoteModal();
}
function cancelDefaultImage(){
    $( "##ag_general_image_default" ).val( "" );
    $( "##ag_general_image_default_url" ).val( "" );
    $( "##default_image_preview" ).attr( "src", "" );
    $( "##default_image_controls" ).toggleClass( "hide" );
}
</script>
</cfoutput>