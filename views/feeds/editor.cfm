<cfoutput>

<div class="btn-group btn-group-xs">
	<button class="btn btn-sm btn-info" onclick="window.location.href='#event.buildLink( prc.xehFeeds )#';return false;">
		<i class="fa fa-reply"></i> Back
	</button>
	<button class="btn btn-sm btn-info dropdown-toggle" data-toggle="dropdown" title="Quick Actions">
		<span class="fa fa-cog"></span>
	</button>
	<ul class="dropdown-menu">
		<li><a href="javascript:quickPublish( false )"><i class="fa fa-globe"></i> Publish</a></li>
		<li><a href="javascript:quickPublish( true )"><i class="fa fa-eraser"></i> Publish as Draft</a></li>
		<li><a href="javascript:quickSave()"><i class="fa fa-save"></i> Quick Save</a></li>
		<!--- TODO: Will have to check portal setting first, and create a helper to create url
		<cfif prc.feed.isLoaded() >
			<li><a href="#prc.cbHelper.linkPage( prc.page )#" target="_blank"><i class="fa fa-eye"></i> Open In Site</a></li>
		</cfif>--->
	</ul>
</div>

#html.startForm( 
	action=prc.xehFeedSave, 
	name="feedForm", 
	novalidate="novalidate", // TODO: what does novalidate do?
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
					<!--- TODO: Custom fields? --->
					<!---<cfif prc.oCurrentAuthor.checkPermission( "EDITORS_HTML_ATTRIBUTES" )>--->
					<li role="presentation">
						<a href="##seo" aria-controls="seo" role="tab" data-toggle="tab">
							<i class="fa fa-cloud"></i> SEO
						</a>
					</li>
					<!---</cfif>--->
					<!--- TODO: History? --->
				</ul>
			</div>
			<div class="panel-body tab-content">
				<div role="tabpanel" class="tab-pane active" id="editor">
					#html.textfield(
						label="Title:",
						name="title",
						bind=prc.feed,
						maxlength="100",
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
							<!--- TODO: Only show if portal is enabled --->
							<!--- prc.agHelper.isPortalEnabled() --->
							<!--- TODO: Create a helper for agHelper, like getPortalLink() getFeedLink() etc... --->
							<!--- TODO: fix javascript slug functions --->
							<i class="fa fa-cloud" title="Convert title to permalink" onclick="createPermalink()"></i>
							<small>#prc.cbHelper.linkHome()##prc.agSettings.ag_portal_entrypoint#/</small>
						</label>
						<div class="controls">
							<div id='slugCheckErrors'></div>
							<div class="input-group">
								#html.textfield(
									name="slug", 
									bind=prc.feed, 
									maxlength="100", 
									class="form-control", 
									title="The URL permalink for this feed", 
									disabled="#prc.feed.isLoaded() && prc.feed.getIsPublished() ? 'true' : 'false'#"
								)#
								<a title="" class="input-group-addon" href="javascript:void(0)" onclick="togglePermalink(); return false;" data-original-title="Lock/Unlock Permalink" data-container="body">
									<i id="togglePermalink" class="fa fa-#prc.feed.isLoaded() && prc.feed.getIsPublished() ? 'lock' : 'unlock'#"></i>
								</a>
							</div>
						</div>
					</div>
					<div class="form-group">
						<label for="url" class="control-label">
							URL:
						</label>
						<div class="controls">
							<div class="input-group">
								#html.inputfield(
									type="url",
									name="url",
									bind=prc.feed,
									maxlength="100",
									required="required",
									title="The url for this feed",
									class="form-control"
								)#
								<!--- TODO: Point to http://validator.w3.org/feed/check.cgi?url=url --->
								<a title="Validate Feed URL" class="input-group-addon" href="javascript:alert('TODO: Add feed validator');" data-original-title="Validate Feed URL" data-container="body">
									<i id="validateUrl" class="fa fa-rss"></i>
								</a>
							</div>
						</div>
					</div>
					<div class="form-group">
						<!--- TODO remove preview if portal is off --->
						<!--- TODO: Write own tag if run into issues here? --->
						#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/content/markup", args={ content=prc.feed } )#
						#html.textarea(
							label="Description:",
							name="content", 
							value=htmlEditFormat( prc.feed.getContent() ), 
							rows="25", 
							class="form-control"
						)#
					</div>
					<div class="form-group">
						<!--- TODO: Setting to turn on/off excerpts? --->
						<!---<cfif prc.cbSettings.cb_page_excerpts >--->
						<!--- TODO: htmleditformat() ?  See above --->
						#html.textarea(
							label="Excerpt:",
							name="excerpt", 
							bind=prc.feed, 
							rows="10",
							class="form-control"
						)#
						<!---</cfif>--->
					</div>
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
				<!--- TODO: History? --->
			</div>
		</div>
	</div>
	<div class="col-md-4" id="main-content-sidebar">
		<div class="panel panel-primary">
			<div class="panel-heading">
				<h3 class="panel-title"><i class="fa fa-info-circle"></i> Feed Details</h3>
			</div>
			<div class="panel-body">
				<!--- TODO: Write own tag if run into issues here? --->
				#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/content/publishing", args={ content=prc.feed } )#
				<div id="accordion" class="panel-group accordion" data-stateful="page-sidebar"><!--- TODO: page-sidebar ? --->
					<cfif prc.feed.isLoaded() >
						<!--- Info --->
						<!--- TODO: Write own tag here - dont need comments, will want last ran, # of items, etc... --->
						#renderView(
							view="/contentbox/modules/contentbox-admin/views/_tags/content/infotable",
							args={ content=prc.feed }
						)#
						<!--- Feed preview --->
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a class="accordion-toggle collapsed" data-toggle="collapse" data-parent="##accordion" href="##preview">
										<i class="fa fa-rss fa-lg"></i> Feed Preview
									</a>
								</h4>
							</div>
							<div id="preview" class="panel-collapse collapse">
							</div>
						</div>
					</cfif>
					<!--- Feed processing --->
					<div class="panel panel-default">
						<div class="panel-heading">
							<h4 class="panel-title">
								<a class="accordion-toggle collapsed" data-toggle="collapse" data-parent="##accordion" href="##processing">
									<i class="fa fa-cogs fa-lg"></i> Feed Processing
								</a>
							</h4>
						</div>
						<div id="processing" class="panel-collapse collapse">
						</div>
					</div>
					<!--- TODO: Permission? --->
					<!---<cfif prc.oCurrentAuthor.checkPermission( "EDITORS_CATEGORIES" ) >--->
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
					<!---</cfif>--->
					<!--- TODO: Permission here? --->
					<!---<cfif prc.oCurrentAuthor.checkPermission( "EDITORS_FEATURED_IMAGE" )>  --->
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
					<!---</cfif>--->
				</div>
			</div>
		</div>
	</div>
</div>

#html.endForm()#

</cfoutput>