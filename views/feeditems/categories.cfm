<cfoutput>
<div id="categoriesDialog" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="categoriesTitle" aria-hidden="true">
	<div class="modal-dialog" role="document" >
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="categoriesTitle"><i class="fa fa-tags"></i> Assign Categories</h4>
			</div>
			<div class="modal-body">
				#html.startForm( name="categoriesForm", action="#prc.xehFeedItemCategories#", class="form-vertical", role="form" )#
					#html.hiddenField( name="contentID", value="" )#
					<div id="categoriesChecks">
						<cfloop from="1" to="#arrayLen( prc.categories )#" index="x">
							<div class="checkbox">
								<label>
									#html.checkbox(
										name="category_#x#",
										value="#prc.categories[x].getCategoryID()#"
									)#
									#prc.categories[x].getCategory()#
								</label>
							</div>
						</cfloop>
					</div>
					#html.textField(
						name="newCategories",
						label="New Categories",
						size="30",
						title="Comma delimited list of new categories to create",
						class="form-control"
					)#
				#html.endForm()#
			</div>
			<div class="modal-footer">
				<button class="btn btn-default" id="categoriesClose" data-dismiss="modal" type="button">Cancel</button>
				<button class="btn btn-danger" id="categoriesSubmit" type="button">Assign</button>
			</div>
		</div>
	</div>
</div>
</cfoutput>