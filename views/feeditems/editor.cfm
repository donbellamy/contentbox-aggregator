<cfoutput>
<div class="btn-group btn-group-xs">
	<button class="btn btn-sm btn-info" onclick="window.location.href='#event.buildLink( prc.xehFeedItems )#';return false;">
		<i class="fa fa-reply"></i> Back
	</button>
	<button class="btn btn-sm btn-info dropdown-toggle" data-toggle="dropdown" title="Quick Actions">
		<span class="fa fa-cog"></span>
	</button>
	<ul class="dropdown-menu">
		<cfif prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN" ) >
			<li><a href="javascript:quickPublish( false )"><i class="fa fa-globe"></i> Publish</a></li>
		</cfif>
		<li><a href="javascript:quickPublish( true )"><i class="fa fa-eraser"></i> Publish as Draft</a></li>
		<li><a href="javascript:quickSave()"><i class="fa fa-save"></i> Quick Save</a></li>
		<li><a href="#prc.agHelper.linkFeedItem( prc.feedItem )#" target="_blank"><i class="fa fa-eye"></i> Open In Site</a></li>
		<li><a href="javascript:openRemoteModal('#event.buildLink(prc.xehFeedItemImportView)#/contentID/#prc.feedItem.getContentID()#');"><i class="fa fa-rss"></i> View Import</a></li>
		<li><a href="#event.buildLink(prc.xehFeedItemEntry)#/contentID/#prc.feedItem.getContentID()#"><i class="fa fa-copy"></i> Copy as Entry</a></li>
	</ul>
</div>
#html.startForm(
	action=prc.xehFeedItemSave,
	name="feedItemForm",
	novalidate="novalidate",
	class="form-vertical"
)#
<div class="row">
	<div class="col-md-8" id="main-content-slot">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
		#html.hiddenField( name="contentID", bind=prc.feedItem )#
		#html.hiddenField( name="contentType", bind=prc.feedItem )#
		<div class="panel panel-default">
			<div class="tab-wrapper margin0">
				<ul class="nav nav-tabs" role="tablist">
					<li role="presentation" class="active">
						<a href="##editor" aria-controls="editor" role="tab" data-toggle="tab">
							<i class="fa fa-edit"></i> Editor
						</a>
					</li>
					<li role="presentation">
						<a href="##history" aria-controls="history" role="tab" data-toggle="tab">
							<i class="fa fa-history"></i> History
						</a>
					</li>
				</ul>
			</div>
			<div class="panel-body tab-content">
				<div role="tabpanel" class="tab-pane active" id="editor">
					#html.textfield(
						label="Title:",
						name="title",
						bind=prc.feedItem,
						maxlength="200",
						required="required",
						title="The title for this feed item",
						class="form-control",
						wrapper="div class=controls",
						labelClass="control-label",
						groupWrapper="div class=form-group"
					)#
					<div class="form-group">
						<label for="slug" class="control-label">
							Permalink:
							<i class="fa fa-cloud" title="Convert title to permalink" onclick="createPermalink()"></i>
							<small>#prc.agHelper.linkPortal()#/</small>
						</label>
						<div class="controls">
							<div id='slugCheckErrors'></div>
							<div class="input-group">
								#html.textfield(
									name="slug",
									bind=prc.feedItem,
									maxlength="200",
									class="form-control",
									title="The URL permalink for this feed item",
									disabled="#prc.feedItem.isLoaded() && prc.feedItem.getIsPublished() ? 'true' : 'false'#"
								)#
								<a title="Lock/Unlock Permalink" class="input-group-addon" href="javascript:void(0);" onclick="togglePermalink(); return false;" data-original-title="Lock/Unlock Permalink" data-container="body">
									<i id="togglePermalink" class="fa fa-#prc.feedItem.isLoaded() && prc.feedItem.getIsPublished() ? 'lock' : 'unlock'#"></i>
								</a>
							</div>
						</div>
					</div>
					<div class="form-group">
						#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/content/markup", args={ content=prc.feedItem } )#
						#html.textarea(
							name="content",
							bind=prc.feedItem,
							rows="25",
							class="form-control"
						)#
					</div>
					<div class="form-group">
						#html.textarea(
							label="Excerpt:",
							name="excerpt",
							bind=prc.feedItem,
							rows="10",
							class="form-control"
						)#
					</div>
				</div>
				<div role="tabpanel" class="tab-pane" id="history">
					#prc.versionsViewlet#
				</div>
			</div>
		</div>
	</div>
	<div class="col-md-4" id="main-content-sidebar">
		<div class="panel panel-primary">
			<div class="panel-heading">
				<h3 class="panel-title"><i class="fa fa-info-circle"></i> Feed Item Details</h3>
			</div>
			<div class="panel-body">
				#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/content/publishing", args={ content=prc.feedItem } )#
				<div id="accordion" class="panel-group accordion" data-stateful="feedItem-sidebar">
					<div class="panel panel-default">
						<div class="panel-heading">
							<h4 class="panel-title">
								<a class="accordion-toggle" data-toggle="collapse" data-parent="##accordion" href="##feedItemInfo">
									<i class="fa fa-info-circle fa-lg"></i> Info
								</a>
							</h4>
						</div>
						<div id="feedItemInfo" class="panel-collapse collapse in">
							<div class="panel-body">
								<table class="table table-hover table-condensed table-striped size12">
									<tr>
										<th class="col-md-4">Feed:</th>
										<td class="col-md-8">
											<a href="#event.buildLink( prc.xehFeedEditor )#/contentID/#prc.feedItem.getFeed().getContentID()#">#prc.feedItem.getFeed().getTitle()#</a>
										</td>
									</tr>
									<tr>
										<th class="col-md-4">Date Published:</th>
										<td class="col-md-8">
											#prc.feedItem.getDisplayPublishedDate()#
										</td>
									</tr>
									<tr>
										<th class="col-md-4">Imported By:</th>
										<td class="col-md-8">
											<a href="mailto:#prc.feedItem.getCreatorEmail()#">#prc.feedItem.getCreatorName()#</a>
										</td>
									</tr>
									<tr>
										<th class="col-md-4">Imported On:</th>
										<td class="col-md-8">
											<a href="javascript:openRemoteModal('#event.buildLink(prc.xehFeedItemImportView)#/contentID/#prc.feedItem.getContentID()#');">
												#prc.feedItem.getDisplayCreatedDate()#
											</a>
										</td>
									</tr>
									<tr>
										<th class="col-md-4">Published On:</th>
										<td class="col-md-8">
											#prc.feedItem.getDisplayPublishedDate()#
										</td>
									</tr>
									<tr>
										<th class="col-md-4">Version:</th>
										<td class="col-md-8">
											#prc.feedItem.getActiveContent().getVersion()#
										</td>
									</tr>
									<tr>
										<th class="col-md-4">Last Edit By:</th>
										<td class="col-md-8">
											<a href="mailto:#prc.feedItem.getAuthorEmail()#">#prc.feedItem.getAuthorName()#</a>
										</td>
									</tr>
									<tr>
										<th class="col-md-4">Last Edit On:</th>
										<td class="col-md-8">
											#prc.feedItem.getActiveContent().getDisplayCreatedDate()#
										</td>
									</tr>
									<tr>
										<th class="col-md-4">Views:</th>
										<td class="col-md-8">
											#prc.feedItem.getNumberOfHits()#
										</td>
									</tr>
								</table>
							</div>
						</div>
					</div>
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
													checked=prc.feedItem.hasCategories( prc.categories[ x ] )
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
									<div class="<cfif !len( prc.feedItem.getFeaturedImageURL() ) >hide</cfif> form-group" id="featuredImageControls">
										<a class="btn btn-danger" href="javascript:cancelFeaturedImage()">Clear Image</a>
										#html.hiddenField(
											name="featuredImage",
											bind=prc.feedItem
										)#
										#html.hiddenField(
											name="featuredImageURL",
											bind=prc.feedItem
										)#
										<div class="margin10">
											<cfif len( prc.feedItem.getFeaturedImageURL() ) >
												<img id="featuredImagePreview" src="#prc.feedItem.getFeaturedImageURL()#" class="img-thumbnail" height="75">
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