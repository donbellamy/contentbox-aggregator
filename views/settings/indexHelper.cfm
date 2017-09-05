<cfoutput>
<script>
$( document ).ready( function() {
	$(".counter").on( "change", function() {
		if ( $(this).val() == 0 ) $(this).val("");
	});
} );
</script>
</cfoutput>