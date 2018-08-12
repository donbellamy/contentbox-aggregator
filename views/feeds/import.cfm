<cfoutput>
<div class="modal-dialog modal-lg" role="document" >
	<div class="modal-content">
		<div class="modal-header">
			<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
			<h3>Feed Import<cfif prc.feedImport.failed() > - Fatal Error Occurred</cfif></h3>
			<h4>Imported on: #prc.feedImport.getDisplayImportedDate()#</h4>
		</div>
		<div class="modal-body">
			<cfdump var="#prc.feedImport.getMetaInfo()#" />
		</div>
		<div class="modal-footer">
			<button class="btn" onclick="closeRemoteModal();">Close</button>
		</div>
	</div>
</div>
</cfoutput>