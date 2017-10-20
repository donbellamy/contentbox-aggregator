<cfoutput>
<script>
$(document).ready(function() {
	$feedItems = $( "##feedItems" );
	$feedItems.dataTable( {
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