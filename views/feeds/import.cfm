<cfoutput>
<div class="modal-dialog modal-lg" role="document" >
	<div class="modal-content">
		<div class="modal-header">
			<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
			<h3>Imported on #prc.feedImport.getDisplayImportedDate()#</h3>
		</div>
		<div class="modal-body">
			<cfdump var="#deserializeJSON( prc.feedImport.getMetaInfo() )#" />
		</div>
		<div class="modal-footer">
			<button class="btn" onclick="closeRemoteModal();"> Close </button>
		</div>
	</div>
</div>
</cfoutput>