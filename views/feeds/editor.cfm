<cfoutput>
<div class="btn-group btn-group-xs">
	<button class="btn btn-sm btn-info" onclick="window.location.href='#event.buildLink( prc.xehFeeds )#';return false;">
		<i class="fa fa-reply"></i> Back
	</button>
	<button class="btn btn-sm btn-info dropdown-toggle" data-toggle="dropdown" title="Quick Actions">
		<span class="fa fa-cog"></span>
	</button>
	<ul class="dropdown-menu">
		<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN" ) >
			<li><a href="javascript:quickPublish( false )"><i class="fa fa-globe"></i> Publish</a></li>
		</cfif>
		<li><a href="javascript:quickPublish( true )"><i class="fa fa-eraser"></i> Publish as Draft</a></li>
		<li><a href="javascript:quickSave()"><i class="fa fa-save"></i> Quick Save</a></li>
		<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN,FEEDS_IMPORT" ) && prc.feed.isLoaded() >
			<li><a href="javascript:importFeed()"><i class="fa fa-rss"></i> Quick Import</a></li>
		</cfif>
		<cfif prc.feed.isLoaded() >
			<cfif prc.agSettings.ag_portal_enable >
				<li><a href="#prc.cbHelper.linkHome()##prc.agSettings.ag_portal_entrypoint#/feeds/#prc.feed.getSlug()#" target="_blank"><i class="fa fa-eye"></i> Open In Site</a></li>
			<cfelse>
				<li><a href="#prc.feed.getUrl()#" target="_blank"><i class="fa fa-eye"></i> Open In Site</a></li>
			</cfif>
		</cfif>
	</ul>
</div>
#html.startForm( 
	action=prc.xehFeedSave, 
	name="feedForm", 
	novalidate="novalidate",
	class="form-vertical" 
)#
<div class="row">
	<div class="col-md-8" id="main-content-slot">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
		#html.hiddenField( name="contentID", bind=prc.feed )#
		#html.hiddenField( name="contentType", bind=prc.feed )#
		<div class="panel panel-default">
			<div class="tab-wrapper margin0">
				<ul class="nav nav-tabs" role="tablist">
					<li role="presentation" class="active">
						<a href="##editor" aria-controls="editor" role="tab" data-toggle="tab">
							<i class="fa fa-edit"></i> Editor
						</a>
					</li>
					<li role="presentation">
						<a href="##options" aria-controls="options" role="tab" data-toggle="tab">
							<i class="fa fa-gear"></i> Options
						</a>
					</li>
					<li role="presentation">
						<a href="##seo" aria-controls="seo" role="tab" data-toggle="tab">
							<i class="fa fa-cloud"></i> SEO
						</a>
					</li>
					<cfif prc.feed.isLoaded() >
						<li role="presentation">
							<a href="##history" aria-controls="history" role="tab" data-toggle="tab">
								<i class="fa fa-history"></i> History
							</a>
						</li>
						<li role="presentation">
							<a href="##imports" aria-controls="imports" role="tab" data-toggle="tab">
								<i class="fa fa-download"></i> Imports
							</a>
						</li>
					</cfif>
				</ul>
			</div>
			<div class="panel-body tab-content">
				<div role="tabpanel" class="tab-pane active" id="editor">
					<div class="form-group">
						<label for="url" class="control-label">
							Feed URL:
						</label>
						<div class="controls">
							<small>
								The URL of the feed source.
								Be sure to include the <code>http(s)://</code> prefix in the url.
							</small>
							<div class="input-group">
								#html.inputfield(
									type="url",
									name="url",
									bind=prc.feed,
									maxlength="255",
									required="required",
									title="The url for this feed",
									class="form-control"
								)#
								<a id="validateFeed" title="Validate Feed URL" class="input-group-addon" href="javascript:void(0);" data-original-title="Validate Feed URL" data-container="body">
									<i class="fa fa-rss"></i>
								</a>
							</div>
						</div>
					</div>
					#html.textfield(
						label="Title:",
						name="title",
						bind=prc.feed,
						maxlength="200",
						required="required",
						title="The title for this feed",
						class="form-control",
						wrapper="div class=controls",
						labelClass="control-label",
						groupWrapper="div class=form-group"
					)#
					<div class="form-group">
						<label for="slug" class="control-label">
							Permalink:
							<cfif prc.agSettings.ag_portal_enable >
								<i class="fa fa-cloud" title="Convert title to permalink" onclick="createPermalink()"></i>
								<small>#prc.cbHelper.linkHome()##prc.agSettings.ag_portal_entrypoint#/feeds/</small>
							</cfif>
						</label>
						<div class="controls">
							<div id='slugCheckErrors'></div>
							<div class="input-group">
								#html.textfield(
									name="slug", 
									bind=prc.feed, 
									maxlength="200",
									class="form-control", 
									title="The URL permalink for this feed", 
									disabled="#prc.feed.isLoaded() && prc.feed.getIsPublished() ? 'true' : 'false'#"
								)#
								<a title="Lock/Unlock Permalink" class="input-group-addon" href="javascript:void(0);" onclick="togglePermalink(); return false;" data-original-title="Lock/Unlock Permalink" data-container="body">
									<i id="togglePermalink" class="fa fa-#prc.feed.isLoaded() && prc.feed.getIsPublished() ? 'lock' : 'unlock'#"></i>
								</a>
							</div>
						</div>
					</div>
					<div class="form-group">
						<!--- TODO: Fix preview - Write own tag here? --->
						#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/content/markup", args={ content=prc.feed } )#
						#html.textarea(
							name="content", 
							bind=prc.feed, 
							rows="25", 
							class="form-control"
						)#
					</div>
					<div class="form-group">
						#html.textarea(
							label="Excerpt:",
							name="excerpt", 
							bind=prc.feed, 
							rows="10",
							class="form-control"
						)#
					</div>
				</div>
				<div role="tabpanel" class="tab-pane" id="options">
					<fieldset>
						<legend><i class="fa fa-list-ol fa-lg"></i> Item Limits</legend>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="maxAge",
								content="Limit items by age:"
							)#
							<div>
								<small>
									The maximum age allowed for feed items.
									Existing feed items will be deleted once they exceed this age limit.
								</small>
							</div>
							<div class="controls row">
								<div class="col-sm-6">
									#html.inputField(
										name="maxAge",
										type="number",
										value=prc.feed.getMaxAge(),
										class="form-control counter",
										placeholder="No limit",
										min="0"
									)#
								</div>
								<div class="col-sm-6">
									#html.select(
										name="maxAgeUnit",
										options=prc.limitUnits,
										selectedValue=prc.feed.getMaxAgeUnit(),
										class="form-control"
									)#
								</div>
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="maxItems",
								content="Limit items by number:"
							)#
							<div class="controls">
								<small>
									The maximum number of feed items to keep per feed.
									When feeds are imported and this limit is exceeded, the oldest feed items will be deleted first to make room for the new ones.
								</small>
								#html.inputField(
									name="maxItems",
									type="number",
									value=prc.feed.getMaxItems(),
									class="form-control counter",
									placeholder="No limit",
									min="0"
								)#
							</div>
						</div>
					</fieldset>
					<fieldset>
						<legend><i class="fa fa-filter fa-lg"></i> Keyword Filtering</legend>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="matchAnyFilter",
								content="Contains any of these words/phrases:"
							)#
							<div class="controls">
								<small>
									Only feed items that contain any of these words/phrases in the title or body will be imported.  
									Existing feed items that do not contain any of these words/phrases in the title or body will be deleted.
								</small>
								#html.textArea(
									name="matchAnyFilter", 
									value=prc.feed.getMatchAnyFilter(),
									rows="3",
									class="form-control",
									placeholder="Comma delimited list of words or phrases",
									maxlength="255"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="matchAllFilter",
								content="Contains all of these words/phrases:"
							)#
							<div class="controls">
								<small>
									Only feed items that contain all of these words/phrases in the title or body will be imported.  
									Existing feed items that do not contain all of these words/phrases in the title or body will be deleted.
								</small>
								#html.textArea(
									name="matchAllFilter", 
									value=prc.feed.getMatchAllFilter(),
									rows="3",
									class="form-control",
									placeholder="Comma delimited list of words or phrases",
									maxlength="255"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="matchNoneFilter",
								content="Contains none of these words/phrases:"
							)#
							<div class="controls">
								<small>
									Only feed items that do not contain any of these words/phrases in the title or body will be imported.  
									Existing feed items that contain any of these words/phrases in the title or body will be deleted.
								</small>
								#html.textArea(
									name="matchNoneFilter", 
									value=prc.feed.getMatchNoneFilter(), 
									rows="3",
									class="form-control",
									placeholder="Comma delimited list of words or phrases",
									maxlength="255"
								)#
							</div>
						</div>
					</fieldset>
				</div>
				<div role="tabpanel" class="tab-pane" id="seo">
					<div class="form-group">
						#html.textfield(
							name="htmlTitle",
							label="Title: (Leave blank to use the feed title)", 
							bind=prc.feed,
							class="form-control",
							maxlength="255"
						)#
					</div>
					<div class="form-group">
						#html.textArea(
							name="htmlKeywords",
							label="Keywords: (<span id='html_keywords_count'>0</span>/160 characters left)", 
							bind=prc.feed,
							class="form-control",
							maxlength="160",
							rows="5"
						)#
					</div>
					<div class="form-group">
						#html.textArea(
							name="htmlDescription",
							label="Description: (<span id='html_description_count'>0</span>/160 characters left)", 
							bind=prc.feed,
							class="form-control",
							maxlength="160",
							rows="5"
						)#
					</div>
				</div>
				<cfif prc.feed.isLoaded() >
					<div role="tabpanel" class="tab-pane" id="history">
						#prc.versionsViewlet#
					</div>
					<div role="tabpanel" class="tab-pane" id="imports">
						<!--- TODO: Fix This #prc.versionsViewlet# --->
					</div>
				</cfif>
			</div>
		</div>
	</div>
	<div class="col-md-4" id="main-content-sidebar">
		<div class="panel panel-primary">
			<div class="panel-heading">
				<h3 class="panel-title"><i class="fa fa-info-circle"></i> Feed Details</h3>
			</div>
			<div class="panel-body">
				#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/content/publishing", args={ content=prc.feed } )#
				<div id="accordion" class="panel-group accordion" data-stateful="feed-sidebar">
					<cfif prc.feed.isLoaded() >
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a class="accordion-toggle" data-toggle="collapse" data-parent="##accordion" href="##feedInfo">
										<i class="fa fa-info-circle fa-lg"></i> Info
									</a>
								</h4>
							</div>
							<div id="feedInfo" class="panel-collapse collapse in">
								<div class="panel-body">
									<table class="table table-hover table-condensed table-striped size12">
										<tr>
											<th class="col-md-4">Last Imported:</th>
											<td class="col-md-8">
												<cfif isDate( prc.feed.getLastImportedDate() ) >
													#prc.feed.getDisplayLastImportedDate()#
												<cfelse>
													Never imported
												</cfif>
											</td>
										</tr>
										<cfif prc.feed.hasChild() >
											<tr>
												<th class="col-md-4">Feed Items:</th>
												<td class="col-md-8">
													#prc.feed.getNumberOfChildren()#
												</td>
											</tr>
										</cfif>
										<tr>
											<th class="col-md-4">Created By:</th>
											<td class="col-md-8">
												<a href="mailto:#prc.feed.getCreatorEmail()#">#prc.feed.getCreatorName()#</a>
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Created On:</th>
											<td class="col-md-8">
												#prc.feed.getDisplayCreatedDate()#
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Published On:</th>
											<td class="col-md-8">
												#prc.feed.getDisplayPublishedDate()#
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Version:</th>
											<td class="col-md-8">
												#prc.feed.getActiveContent().getVersion()#
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Last Edit By:</th>
											<td class="col-md-8">
												<a href="mailto:#prc.feed.getAuthorEmail()#">#prc.feed.getAuthorName()#</a>
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Last Edit On:</th>
											<td class="col-md-8">
												#prc.feed.getActiveContent().getDisplayCreatedDate()#
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Views:</th>
											<td class="col-md-8">
												#prc.feed.getNumberOfHits()#
											</td>
										</tr>
									</table>
								</div>
							</div>
						</div>
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a class="accordion-toggle collapsed" data-toggle="collapse" data-parent="##accordion" href="##preview">
										<i class="fa fa-rss fa-lg"></i> Feed Preview
									</a>
								</h4>
							</div>
							<div id="preview" class="panel-collapse collapse">
								<div class="panel-body">
									<cfif prc.feed.hasFeedItem() >
										<table class="table table-condensed table-hover table-striped" width="100%">
											<thead>
												<tr>
													<th>Title</th>
													<th width="100" class="text-center">Date</th>
												</tr>
											</thead>
											<tbody>
												<cfloop array="#prc.feedItems#" index="feedItem">
													<tr
														<cfif feedItem.isExpired() >
															class="danger"
														<cfelseif feedItem.isPublishedInFuture() >
															class="success"
														<cfelseif !feedItem.isContentPublished() >
															class="warning"
														<cfelseif !feedItem.getNumberOfActiveVersions() >
															class="danger" title="No active content versions found, please publish one."
														</cfif>
													>
														<td>
															<cfif prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR" ) >
																<a href="#event.buildLink( prc.xehFeedItemEditor )#/contentID/#feedItem.getContentID()#">#feedItem.getTitle()#</a>
															<cfelse>
																#feedItem.getTitle()#
															</cfif>
														</td> 
														<td class="text-center">#feedItem.getDisplayDatePublished()#</td>
													</tr>
												</cfloop>
											</tbody>
										</table>
									<cfelse>
										<p>No items imported.</p>
									</cfif>
								</div>
							</div>
						</div>
					</cfif>
					<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN" ) >
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a class="accordion-toggle collapsed" data-toggle="collapse" data-parent="##accordion" href="##processing">
										<i class="fa fa-cogs fa-lg"></i> Feed Processing
									</a>
								</h4>
							</div>
							<div id="processing" class="panel-collapse collapse">
								<div class="panel-body">
									<div class="form-group">
										#html.label(
											class="control-label",
											field="isActive",
											content="Import State"
										)#
										<div class="controls">
											#html.select(
												name="isActive",
												options=[{name="Active",value="true"},{name="Paused",value="false"}],
												column="value",
												nameColumn="name",
												selectedValue=prc.feed.getIsActive(),
												class="form-control input-sm"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="defaultStatus",
											content="Default Item Status"
										)#
										<div class="controls">
											#html.select(
												name="defaultStatus",
												options=[{name="Draft",value="draft"},{name="Published",value="published"}],
												column="value",
												nameColumn="name",
												selectedValue=prc.feed.getDefaultStatus(),
												class="form-control input-sm"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="startDate",
											content="Start Date"
										)#
										<div class="controls row">
											<div class="col-md-6">
												<div class="input-group">
													#html.inputField(
														size="9", 
														name="startDate",
														value=prc.feed.getStartDateForEditor(), 
														class="form-control datepicker",
														placeholder="Immediately"
													)#
													<span class="input-group-addon">
														<span class="fa fa-calendar"></span>
													</span>
												</div>
											</div>
											<cfscript>
												theTime = "";
												hour = prc.ckHelper.ckHour( prc.feed.getStartDateForEditor( showTime=true ) );
												minute = prc.ckHelper.ckMinute( prc.feed.getStartDateForEditor( showTime=true ) );
												if ( len( hour ) && len( minute ) ) {
													theTime = hour & ":" & minute;
												}
											</cfscript>
											<div class="col-md-6">
												<div class="input-group clockpicker" data-placement="left" data-align="top" data-autoclose="true">
													<input type="text" class="form-control inline" value="#theTime#" name="startTime" />
													<span class="input-group-addon">
														<span class="fa fa-clock-o"></span>
													</span>
												</div>
											</div>
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="stopDate",
											content="Stop Date"
										)#
										<div class="controls row">
											<div class="col-md-6">
												<div class="input-group">
													#html.inputField(
														size="9", 
														name="stopDate",
														value=prc.feed.getStopDateForEditor(), 
														class="form-control datepicker",
														placeholder="Never"
													)#
													<span class="input-group-addon">
														<span class="fa fa-calendar"></span>
													</span>
												</div>
											</div>
											<cfscript>
												theTime = "";
												hour = prc.ckHelper.ckHour( prc.feed.getStopDateForEditor( showTime=true ) );
												minute = prc.ckHelper.ckMinute( prc.feed.getStopDateForEditor( showTime=true ) );
												if ( len( hour ) && len( minute ) ) {
													theTime = hour & ":" & minute;
												}
											</cfscript>
											<div class="col-md-6">
												<div class="input-group clockpicker" data-placement="left" data-align="top" data-autoclose="true">
													<input type="text" class="form-control inline" value="#theTime#" name="stopTime" />
													<span class="input-group-addon">
														<span class="fa fa-clock-o"></span>
													</span>
												</div>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
					</cfif>
					<div class="panel panel-default">
						<div class="panel-heading">
							<h4 class="panel-title">
								<a class="accordion-toggle collapsed" data-toggle="collapse" data-parent="##accordion" href="##categories">
									<i class="fa fa-tags fa-lg"></i> Categories
								</a>
							</h4>
						</div>
						<div id="categories" class="panel-collapse collapse">
							<div class="panel-body">
								<div id="categoriesChecks">
									<cfloop from="1" to="#arrayLen( prc.categories )#" index="x">
										<div class="checkbox">
											<label>
												#html.checkbox(
													name="category_#x#",
													value="#prc.categories[ x ].getCategoryID()#",
													checked=prc.feed.hasCategories( prc.categories[ x ] )
												)#
												#prc.categories[ x ].getCategory()#
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
							</div>
						</div>
					</div>
					<div class="panel panel-default">
						<div class="panel-heading">
							<h4 class="panel-title">
								<a class="accordion-toggle collapsed" data-toggle="collapse" data-parent="##accordion" href="##featuredImagePanel">
									<i class="fa fa-picture-o fa-lg"></i> Featured Image
								</a>
							</h4>
						</div>
						<div id="featuredImagePanel" class="panel-collapse collapse">
							<div class="panel-body">
								<div class="form-group text-center">
									<a class="btn btn-primary" href="javascript:loadAssetChooser( 'featuredImageCallback' )">Select Image</a>
									<div class="<cfif !len( prc.feed.getFeaturedImageURL() ) >hide</cfif> form-group" id="featuredImageControls">
										<a class="btn btn-danger" href="javascript:cancelFeaturedImage()">Clear Image</a>
										#html.hiddenField(
											name="featuredImage",
											bind=prc.feed
										)#
										#html.hiddenField(
											name="featuredImageURL",
											bind=prc.feed
										)#
										<div class="margin10">
											<cfif len( prc.feed.getFeaturedImageURL() ) >
												<img id="featuredImagePreview" src="#prc.feed.getFeaturedImageURL()#" class="img-thumbnail" height="75">
											<cfelse>
												<img id="featuredImagePreview" class="img-thumbnail" height="75">
											</cfif>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
#html.endForm()#
</cfoutput>