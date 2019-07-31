<cfoutput>
<div class="btn-group btn-group-xs">
	<button class="btn btn-sm btn-info" onclick="window.location.href='#event.buildLink( prc.xehBlacklistedItems )#';return false;">
		<i class="fa fa-reply"></i> Back
	</button>
	<button class="btn btn-sm btn-info dropdown-toggle" data-toggle="dropdown" title="Quick Actions">
		<span class="fa fa-cog"></span>
	</button>
	<ul class="dropdown-menu">
		<li><a href="javascript:quickSave()"><i class="fa fa-save"></i> Quick Save</a></li>
		<li><a href="#prc.blacklistedItem.getItemUrl()#" target="_blank"><i class="fa fa-external-link fa-lg"></i> View Item</a></li>
	</ul>
</div>
#html.startForm(
	action=prc.xehBlacklistedItemSave,
	name="blacklistedItemForm",
	novalidate="novalidate",
	class="form-vertical"
)#
<div class="row">
	<div class="col-md-8" id="main-content-slot">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
		#html.hiddenField( name="blacklistedItemID", bind=prc.blacklistedItem )#
		<div class="panel panel-default">
			<div class="tab-wrapper margin0">
				<ul class="nav nav-tabs" role="tablist">
					<li role="presentation" class="active">
						<a href="##editor" aria-controls="editor" role="tab" data-toggle="tab">
							<i class="fa fa-edit"></i> Editor
						</a>
					</li>
				</ul>
			</div>
			<div class="panel-body tab-content">
				<div role="tabpanel" class="tab-pane active" id="editor">
					#html.textfield(
						label="Title:",
						name="title",
						bind=prc.blacklistedItem,
						maxlength="250",
						required="required",
						title="The title for this blacklisted item",
						class="form-control",
						wrapper="div class=controls",
						labelClass="control-label",
						groupWrapper="div class=form-group"
					)#
					#html.textfield(
						label="URL:",
						name="itemUrl",
						bind=prc.blacklistedItem,
						maxlength="250",
						required="required",
						title="The url for this blacklisted item",
						class="form-control",
						wrapper="div class=controls",
						labelClass="control-label",
						groupWrapper="div class=form-group"
					)#
				</div>
			</div>
		</div>
	</div>
	<div class="col-md-4" id="main-content-sidebar">
		#renderview( view="sidebar/help", module="contentbox-aggregator" )#
	</div>
</div>
#html.endForm()#
</cfoutput>