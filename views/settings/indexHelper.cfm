<cfoutput>
<script type="text/javascript" src="#prc.agRoot#/includes/js/bootstrap-multiselect.js"></script>
<link rel="stylesheet" href="#prc.agRoot#/includes/css/bootstrap-multiselect.css" type="text/css"/>
<style>
.CodeMirror, .CodeMirror-scroll {
	height: 200px;
	min-height: 200px;
}
.multiselect.btn {
	margin-bottom: 0 !important;
}
</style>
<script>
$( document ).ready( function() {
	$("##settingsForm").validate();
	$("input.slider").on( "slide", function( slideEvt ) {
		$( "##" + slideEvt.target.id + "_label" ).text( slideEvt.value );
	});
	$("##importing_interval").on("change",function() {
		if ( $(this).val() == "" ) {
			$("##importing_start_date").val("");
			$("##importing_start_time").val("");
		}
	});
	$(".datepicker").datepicker( { format: "mm/dd/yy" } );
	$(".clockpicker").clockpicker( { twelvehour: true } );
	$(".counter").on( "change", function() {
		if ( $(this).val() == 0 ) $(this).val("");
	});
	var numRemoved = 0;
	$("##addTaxonomy").click(function() {
		var templateIndex = $("##taxonomies").children(".taxonomy").size() + 1 + numRemoved;
		var template = $("##taxonomyTemplate").html().replace(/templateIndex/g, templateIndex);
		$("##taxonomies").append( template );
		$(".multiselect" + templateIndex).multiselect({
			nonSelectedText: "Choose Categories",
			numberDisplayed: 0,
			buttonWidth: "100%"
		});
	});
	$("##removeAll").click(function() {
		if ( confirm("Are you sure you want to remove all taxonomies?") ) {
			$("##taxonomies .taxonomy").remove();
		}
		return false;
	});
	$(".removeTaxonomy").click(function() {
		if ( confirm("Are you sure you want to remove this taxonomy?") ) {
			$(this).closest(".taxonomy").remove();
			numRemoved++;
		}
		return false;
	});
	$(".multiselect").multiselect({
		nonSelectedText: "Choose Categories",
		numberDisplayed: 0,
		buttonWidth: "100%"
	});
});
function loadAssetChooser( callback, w, h ) {
	openRemoteModal(
		"#event.buildLink( prc.cbAdminEntryPoint )#/ckFileBrowser/assetChooser?callback=" + callback,
		{},
		w || "75%",
		h
	);
}
function defaultFeedImageCallback( filePath, fileURL, fileType ) {
	if ( $( "##feed_featured_image_default" ).val().length ) { cancelDefaultImage(); }
	$( "##default_feed_image_controls" ).toggleClass( "hide" );
	$( "##feed_featured_image_default" ).val( filePath );
	$( "##feed_featured_image_default_url" ).val( fileURL );
	$( "##default_feed_image_preview" ).attr( "src", fileURL );
	closeRemoteModal();
}
function cancelDefaultFeedImage() {
	$( "##feed_featured_image_default" ).val( "" );
	$( "##feed_featured_image_default_url" ).val( "" );
	$( "##default_feed_image_preview" ).attr( "src", "" );
	$( "##default_feed_image_controls" ).toggleClass( "hide" );
}
function defaultImageCallback( filePath, fileURL, fileType ) {
	if ( $( "##feed_items_featured_image_default" ).val().length ) { cancelDefaultImage(); }
	$( "##default_image_controls" ).toggleClass( "hide" );
	$( "##feed_items_featured_image_default" ).val( filePath );
	$( "##feed_items_featured_image_default_url" ).val( fileURL );
	$( "##default_image_preview" ).attr( "src", fileURL );
	closeRemoteModal();
}
function cancelDefaultImage() {
	$( "##feed_items_featured_image_default" ).val( "" );
	$( "##feed_items_featured_image_default_url" ).val( "" );
	$( "##default_image_preview" ).attr( "src", "" );
	$( "##default_image_controls" ).toggleClass( "hide" );
}
function reset() {
	var $settingsForm = $("##settingsForm");
	$settingsForm.attr( "action", "#event.buildlink( prc.xehAggregatorSettingsReset )#" );
	$settingsForm.submit();
}
</script>
</cfoutput>