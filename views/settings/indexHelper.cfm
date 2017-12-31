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
} );
</script>
</cfoutput>