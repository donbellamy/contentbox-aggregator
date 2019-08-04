<cfoutput>
<div class="row">
	<div class="col-md-12">
		<h1 class="h1">
			<i class="fa fa-ban fa-lg"></i>
			RSS Aggregator - Blacklisted Items
		</h1>
	</div>
</div>
<div class="row">
	<div class="col-md-9">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
		#html.startForm( name="blacklistedItemForm", action=prc.xehBlacklistedItemRemove )#
			#html.hiddenField( name="blacklistedItemID", value="" )#
			#html.hiddenField( name="feed", id="feedFilter", value="#rc.feed#" )#
			<div class="panel panel-default">
				<div class="panel-heading">
					<div class="row">
						<div class="col-md-6">
							<div class="form-group form-inline no-margin">
								#html.textField(
									name="search",
									class="form-control",
									placeholder="Quick Search",
									value="#rc.search#"
								)#
							</div>
						</div>
						<div class="col-md-6">
							<div class="pull-right">
								<div class="btn-group btn-group-sm">
									<button class="btn dropdown-toggle btn-info" data-toggle="dropdown">
										Bulk Actions <span class="caret"></span>
									</button>
									<ul class="dropdown-menu">
										<cfif prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN" ) >
											<li>
												<a href="javascript:remove();"
													class="confirmIt"
													data-title="Delete Selected Blacklisted Items?"
													data-message="This will delete the blacklisted items, are you sure?">
													<i class="fa fa-trash-o"></i> Delete Selected
												</a>
											</li>
										</cfif>
										<li><a href="javascript:contentShowAll();"><i class="fa fa-list"></i> Show All</a></li>
									</ul>
								</div>
								<button class="btn btn-primary btn-sm" onclick="return create();">
									Create Blacklisted Item
								</button>
							</div>
						</div>
					</div>
				</div>
				<div class="panel-body">
					<div id="blacklistedItemsTableContainer">
						<p class="text-center"><i id="blacklistedItemLoader" class="fa fa-spinner fa-spin fa-lg icon-4x"></i></p>
					</div>
				</div>
			</div>
		#html.endForm()#
	</div>
	<div class="col-md-3">
		<div class="panel panel-primary">
			<div class="panel-heading">
				<h3 class="panel-title"><i class="fa fa-filter"></i> Filters</h3>
			</div>
			<div class="panel-body">
				<div id="filterBox">
					#html.startForm( name="blacklistedItemFilterForm", action=prc.xehBlacklistedItemSearch, class="form-vertical", role="form" )#
						<div class="form-group">
							<label for="feed" class="control-label">Feeds:</label>
							<select name="feed" id="feed" class="form-control input-sm">
								<option value=""<cfif !len( rc.feed ) > selected="selected"</cfif>>All Feeds</option>
								<cfloop array="#prc.feeds#" index="feed">
									<option value="#feed.getContentID()#"<cfif rc.feed EQ feed.getContentID() > selected="selected"</cfif>>#feed.getTitle()#</option>
								</cfloop>
							</select>
						</div>
						<a class="btn btn-info btn-sm" href="javascript:contentFilter()">Apply Filters</a>
						<a class="btn btn-sm btn-default" href="javascript:resetFilter(true)">Reset</a>
					#html.endForm()#
				</div>
			</div>
		</div>
		#renderview( view="sidebar/help", module="contentbox-aggregator" )#
	</div>
</div>
<div id="blacklistedItemEditorContainer" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="blacklistedItemLabel" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content" id="modalContent">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="blacklistedItemLabel"><i class="fa fa-ban"></i> Blacklisted Item Editor</h4>
			</div>
			#html.startForm(
				action=prc.xehBlacklistedItemSave,
				name="blacklistedItemEditor",
				novalidate="novalidate",
				class="form-vertical",
				role="form"
			)#
			<div class="modal-body">
				#html.hiddenField( name="blacklistedItemID", value="" )#
				#html.textfield(
					label="Title:",
					name="title",
					maxlength="255",
					required="required",
					title="The title for this blacklisted item",
					class="form-control",
					wrapper="div class=controls",
					labelClass="control-label",
					groupWrapper="div class=form-group"
				)#
				<div class="form-group">
					<label class="control-label" for="itemUrl">Item URL:</label>
					<div class="controls">
						<small>
							The URL of the feed item.
							Be sure to include the <code>http(s)://</code> prefix in the url.
						</small>
						#html.inputfield(
							type="url",
							name="itemUrl",
							maxlength="510",
							required="required",
							title="The url for this blacklisted item",
							class="form-control"
						)#
					</div>
				</div>
				<div class="form-group">
					<label class="control-label" for="feedId">Feed:</label>
					<div class="controls">
						<select name="feedId" id="feedId" required="required" class="form-control input-sm">
							<option value=""></option>
							<cfloop array="#prc.feeds#" index="feed">
								<option value="#feed.getContentID()#">#feed.getTitle()#</option>
							</cfloop>
						</select>
					</div>
				</div>
			</div>
			<div class="modal-footer">
				#html.resetButton(
					name="btnReset",
					value="Cancel",
					class="btn btn-default",
					onclick="closeModal( $('##blacklistedItemEditorContainer') )"
				)#
				#html.submitButton( name="btnSave", value="Save", class="btn btn-danger" )#
			</div>
			#html.endForm()#
		</div>
	</div>
</div>
</cfoutput>