<cfoutput>
<style>
.CodeMirror, .CodeMirror-scroll {
	height: 200px;
	min-height: 200px;
}
</style>
<script>
$( document ).ready( function() {
	$("##settingsForm").validate();
	$("input.slider").on( "slide", function( slideEvt ) {
		$( "##" + slideEvt.target.id + "_label" ).text( slideEvt.value );
	});
	var mdEditors =  {};
	$( ".mde" ).each( function(){
		mdEditors[ $( this ).prop( "id" ) ] = new SimpleMDE( {
			element 		: this,
			autosave 		: { enabled : false },
			promptURLs 		: true,
			tabSize 		: 2,
			forceSync 		: true,
			placeholder 	: 'Type here...',
			spellChecker 	: false
		} );
	} );
	$("##ag_importing_import_interval").on("change",function(){
		if ( $(this).val() == "" ) {
			$("##ag_importing_import_start_date").val("");
			$("##ag_importing_import_start_time").val("");
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
	if( $( "##ag_importing_featured_image_default" ).val().length ){ cancelDefaultImage(); }
    $( "##default_image_controls" ).toggleClass( "hide" );
    $( "##ag_importing_featured_image_default" ).val( filePath );
    $( "##ag_importing_featured_image_default_url" ).val( fileURL );
    $( "##default_image_preview" ).attr( "src", fileURL );
    closeRemoteModal();
}
function cancelDefaultImage(){
    $( "##ag_importing_featured_image_default" ).val( "" );
    $( "##ag_importing_featured_image_default_url" ).val( "" );
    $( "##default_image_preview" ).attr( "src", "" );
    $( "##default_image_controls" ).toggleClass( "hide" );
}
</script>
</cfoutput>