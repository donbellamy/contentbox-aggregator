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
					#html.textfield(
						label="URL:",
						name="url",
						bind=prc.feed,
						maxlength="100",
						required="required",
						title="The url for this feed",
						class="form-control",
						wrapper="div class=controls",
						labelClass="control-label",
						groupWrapper="div class=form-group"
					)#
					<div class="form-group">
						#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/content/markup", args={ content=prc.feed } )#
						#html.textarea(
							name="content", 
							value=htmlEditFormat( prc.feed.getContent() ), 
							rows="25", 
							class="form-control"
						)#
					</div>
				</div>
				<div role="tabpanel" class="tab-pane" id="seo">
				</div>
			</div>
		</div>
	</div>
	<div class="col-md-4" id="main-content-sidebar">
		<div class="panel panel-primary">
			<div class="panel-heading">
				<h3 class="panel-title"><i class="fa fa-info-circle"></i> Feed Details</h3>
			</div>
		</div>
	</div>
</div>

#html.endForm()#

</cfoutput>