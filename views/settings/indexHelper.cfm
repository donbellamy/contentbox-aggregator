<cfoutput>
<script>
$( document ).ready( function() {
	$("##ag_general_import_interval").on("change",function(){
		var $group = $(".start-date-group");
		if ( $(this).val() == "" ) $group.hide();
		else $group.show();
	});
	$(".datepicker").datepicker( { format: "mm/dd/yy" } );
	$(".clockpicker").clockpicker( { twelvehour: true } );
	$(".counter").on( "change", function() {
		if ( $(this).val() == 0 ) $(this).val("");
	});
} );
</script>
</cfoutput>