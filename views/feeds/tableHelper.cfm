<cfoutput>
<script>
$(document).ready(function() {
	$feeds = $( "##feeds" );
	$feeds.dataTable( {
		"paging": false,
		"info": false,
		"searching": false,
		"columnDefs": [
			{
				"orderable": false, 
				"targets": '{sorter:false}' 
			}
		],
		"order": []
	});
	activateConfirmations();
	activateTooltips();
	activateInfoPanels();
} );
</script>
</cfoutput>