<cfoutput>
#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/editors", prePostExempt=true )#
<script type="text/javascript" src="#prc.agRoot#/includes/js/bootstrap-multiselect.js"></script>
<link rel="stylesheet" href="#prc.agRoot#/includes/css/bootstrap-multiselect.css" type="text/css"/>
<style>
.multiselect.btn {
	margin-bottom: 0 !important;
}
</style>
<script>
$( document ).ready( function() {
	setupFeedForm();
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
	$("##contentToolBar .pull-right").hide();
	$("##versionsPager .buttonBar .btn-default").hide();
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
function setupFeedForm() {

	// Setup global editor elements
	$targetEditorForm = $("##feedForm");
	$targetEditorSaveURL = "#event.buildLink( prc.xehFeedSave )#";
	$uploaderBarLoader = $targetEditorForm.find("##uploadBarLoader");
	$uploaderBarStatus = $targetEditorForm.find("##uploadBarLoaderStatus");
	$excerpt = $targetEditorForm.find("##excerpt");
	$content = $targetEditorForm.find("##content");
	$isPublished = $targetEditorForm.find("##isPublished");
	$contentID = $targetEditorForm.find("##contentID");
	$changelog = $targetEditorForm.find("##changelog");
	$slug = $targetEditorForm.find("##slug");
	$publishingBar = $targetEditorForm.find("##publishingBar");
	$actionBar = $targetEditorForm.find("##actionBar");
	$publishButton = $targetEditorForm.find("##publishButton");
	$withExcerpt = false;
	$wasSubmitted = false;

	// Startup the choosen editor via driver CFC
	$cbEditorStartup();

	// Activate date pickers
	$("[type=date]").datepicker( { format: "yyyy-mm-dd" } );
	$(".datepicker").datepicker( { format: "yyyy-mm-dd" } );

	// Activate Form Validators
	$targetEditorForm.validate( {
		ignore: "content",
		submitHandler: function( form ) {
			// Update Editor Content
			try{
				updateEditorContent();
			} catch( err ) {
				console.log( err );
			};
			// Enable slug for saving.
			$slug.prop( "disabled", false );
			// Disable Publish Buttons
			$publishButton.prop( "disabled", true );
			// Submit
			form.submit();
		}
	});

	// Changelog mandatory?
	if ( $cbEditorConfig.changelogMandatory ) {
		$changelog.attr( "required", $cbEditorConfig.changelogMandatory );
	}

	// Activate blur slugify on titles
	var $title = $targetEditorForm.find( "##title" );
	// set up live event for title, do nothing if slug is locked..
	$title.on( "blur", function() {
		if ( !$slug.prop( "disabled" ) ) {
			createPermalink( $title.val() );
		}
	} );

	// Activate permalink blur
	$slug.on( "blur",function() {
		if ( !$( this ).prop( "disabled" ) ) {
			permalinkUniqueCheck();
		}
	} );

	// Editor dirty checks
	window.onbeforeunload = askLeaveConfirmation;

	// counters
	$("##htmlKeywords").keyup(function() {
		$("##html_keywords_count").html( $("##htmlKeywords").val().length );
	} );
	$("##htmlDescription").keyup(function() {
		$("##html_description_count").html( $("##htmlDescription").val().length );
	} );

	// setup clockpickers
	$('.clockpicker').clockpicker();

	// setup autosave
	autoSave( $content, $contentID, "contentAutoSave" );

	// Collapse navigation for better editing experience
	var bodyEl = $('##container');
	collapseNav = true;
	if ( collapseNav && !$( bodyEl ).hasClass("sidebar-mini") ) {
		$("body").removeClass("off-canvas-open");
		$( bodyEl ).toggleClass("sidebar-mini");
	}

}
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
			if ( !data.ERROR ) {
				$( "##import_row_" + feedImportID ).fadeOut().remove();
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