<cfoutput>

<div class="row">
	<div class="col-md-12">
		<h1 class="h1">
			<i class="fa fa-rss fa-lg"></i>
			RSS Aggregator Settings
		</h1>
	</div>
</div>

<div class="row">
	<div class="col-md-12">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
	</div>
</div>

<!---<cfdump var="#prc.aggregatorSettings#" />--->

<div class="row">
	<div class="col-md-12">
		#html.startForm( name="settingsForm", action="#prc.xehAggregatorSaveSettings#", novalidate="novalidate" )#
			#html.anchor( name="top" )#
			<div class="panel panel-default">
				<div class="panel-body">
					<div class="tab-wrapper tab-left tab-primary">
						<ul class="nav nav-tabs">
							<li class="active">
								<a href="##general_options" data-toggle="tab"><i class="fa fa-cog fa-lg"></i> General</a>
							</li>
							<li>
								<a href="##display_options" data-toggle="tab"><i class="fa fa-desktop fa-lg"></i> Display</a>
							</li>
							<li>
								<a href="##rss_options" data-toggle="tab"><i class="fa fa-rss fa-lg"></i> RSS Feed</a>
							</li>
						</ul>
						<div class="tab-content">
							<div class="tab-pane active" id="general_options">
								<fieldset>
									<legend><i class="fa fa-cog fa-lg"></i> <strong>General Options</strong></legend>
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-list fa-lg"></i> <strong>Portal Options</strong></legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="general_disable_portal",
											content="Disable Portal:"
										)#
										<div class="controls">
											<small>You can disable the portal in this installation. This does not delete data, it just disables the portal features.  Feed items will link directly to their source urls and will not be tracked by ContentBox when using the RRS Aggregator widgets in your site.</small>
											<br/><br/>
											#html.checkbox(
												name = "general_disable_portal_toggle",
												data = { toggle: 'toggle', match: 'general_disable_portal' },
												checked	= prc.aggregatorSettings.general_disable_portal
											)#
											#html.hiddenField( 
												name = "general_disable_portal", 
												value = prc.aggregatorSettings.general_disable_portal 
											)#
										</div>
									</div>
									#html.textField(
										name = "general_portal_title",
										label = "Portal Title:",
										value = prc.aggregatorSettings.general_portal_title,
										class = "form-control",
										title = "The title of the portal",
										wrapper = "div class=controls",
										labelClass = "control-label",
										groupWrapper = "div class=form-group"
									)#
									<div class="form-group">
										#html.label(
											class="control-label",
											field="general_portal_entrypoint",
											content="Portal Entry Point:" 
										)#
										<div class="controls">
											<small>Choose the entry point in the URL to trigger the portal engine. The usual default entry point pattern is <strong>news</strong>. Do not use symbols or slashes (/ \)</small>
											<br/>
											<code>#prc.cb.linkHome()#</code> 
											#html.textField(
												name="general_portal_entrypoint", 
												value=prc.aggregatorSettings.general_portal_entrypoint, 
												class="form-control",
												title="The protal entry point"
											)#
										</div>
									</div> 
								</fieldset>
							</div>
							<div class="tab-pane" id="display_options">
								<fieldset>
									<legend><i class="fa fa-desktop fa-lg"></i> <strong>Display Options</strong></legend>
								</fieldset>
							</div>
							<div class="tab-pane" id="rss_options">
								<fieldset>
									<legend><i class="fa fa-rss fa-lg"></i> <strong>RSS Feed Options</strong></legend>
								</fieldset>
							</div>
							<div class="form-actions">
								#html.submitButton( value="Save Settings", class="btn btn-danger" )#
							</div>
						</div>
					</div>
				</div>
			</div>
		#html.endForm()#
	</div>
</div>

</cfoutput>