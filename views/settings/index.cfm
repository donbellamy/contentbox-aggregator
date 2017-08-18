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

<div class="row">
	<div class="col-md-12">
		#html.startForm( name="settingsForm", action="#prc.xehAgSaveSettings#", novalidate="novalidate" )#
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
											field="ag_portal_enable",
											content="Enable Portal:"
										)#
										<div class="controls">
											<!---<small></small><br/><br/>--->
											#html.checkbox(
												name = "ag_portal_enable_toggle",
												data = { toggle: 'toggle', match: 'ag_portal_enable' },
												checked	= prc.agSettings.ag_portal_enable
											)#
											#html.hiddenField( 
												name = "ag_portal_enable", 
												value = prc.agSettings.ag_portal_enable 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_title",
											content="Portal Title:"
										)#
										<div class="controls">
											#html.textField(
												name = "ag_portal_title",
												value = prc.agSettings.ag_portal_title,
												class = "form-control",
												title = "The title of the portal"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_entrypoint",
											content="Portal Entry Point:" 
										)#
										<div class="controls">
											<small>Choose the entry point in the URL to trigger the portal engine. The usual default entry point pattern is <strong>news</strong>. Do not use symbols or slashes (/ \)</small>
											<br/>
											<code>#prc.cb.linkHome()#</code> 
											#html.textField(
												name="ag_portal_entrypoint", 
												value=prc.agSettings.ag_portal_entrypoint, 
												class="form-control",
												title="The portal entry point"
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
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_enable",
											content="Enable RSS Feed:"
										)#
										<div class="controls">
											<!---<small></small><br/><br/>--->
											#html.checkbox(
												name = "ag_rss_enable_toggle",
												data = { toggle: 'toggle', match: 'ag_rss_enable' },
												checked	= prc.agSettings.ag_rss_enable
											)#
											#html.hiddenField( 
												name = "ag_rss_enable", 
												value = prc.agSettings.ag_rss_enable 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_title",
											content="Feed Title:"
										)#
										<div class="controls">
											<small>The title of the rss feed</small><br/>
											#html.textField(
												name = "ag_rss_title",
												required="required",
												value = prc.agSettings.ag_rss_title,
												class = "form-control",
												title = "The title of the rss feed"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_generator",
											content="Feed Generator:" 
										)#
										<div class="controls">
											<small>The generator of the rss feed</small><br/>
											#html.textField(
												name="ag_rss_generator",
												required="required",
												value=prc.agSettings.ag_rss_generator,
												class="form-control",
												title="The generator of the rss feed" 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_copyright",
											content="Feed Copyright:" 
										)#
										<div class="controls">
											<small>The copyright of the rss feed</small><br/>
											#html.textField(
												name="ag_rss_copyright",
												required="required",
												value=prc.agSettings.ag_rss_copyright,
												class="form-control",
												title="The copyright of the rss feed" 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_description",
											content="Feed Description:" 
										)#
										<div class="controls">
											<small>The description of the rss feed</small><br/>
											#html.textField(
												name="ag_rss_description",
												required="required",
												value=prc.agSettings.ag_rss_description,
												class="form-control",
												title="The description of the rss feed" 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_webmaster",
											content="Feed Webmaster:" 
										)#
										<div class="controls">
											<small>The rss feed webmaster. Ex: myemail@mysite.com (Site Administrator)</small><br/>
											#html.textField(
												name="ag_rss_webmaster",
												value=prc.agSettings.ag_rss_webmaster,
												class="form-control",
												title="The rss feed webmaster"
											)#
										</div>
									</div>
									<div class="form-group">
										<label class="control-label" for="ag_rss_max_items">
											Max RSS Content Items:
											<span class="badge badge-info" id="ag_rss_max_items_label">#prc.agSettings.ag_rss_max_items#</span>
										</label>
										<div class="controls">
											<small>The number of items to show in the rss feed.</small><br/>
											<strong class="margin10">10</strong>
											<input 	type="text"
												id="ag_rss_max_items"
												name="ag_rss_max_items"
												class="slider"
												data-slider-value="#prc.agSettings.ag_rss_max_items#"
												data-provide="slider"
												data-slider-min="10"
												data-slider-max="50"
												data-slider-step="10"
												data-slider-tooltip="hide" />
											<strong class="margin10">50</strong>
										</div>
									</div>
								</fieldset>
									<fieldset>
									<legend><i class="fa fa-hdd-o fa-lg"></i> <strong>RSS Caching</strong></legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_cache_enable",
											content="Enable RSS feed caching:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_rss_cache_enable_toggle",
												data = { toggle: 'toggle', match: 'ag_rss_cache_enable' },
												checked	= prc.agSettings.ag_rss_cache_enable
											)#
											#html.hiddenField(
												name = "ag_rss_cache_enable",
												value = prc.agSettings.ag_rss_cache_enable
											)#
										</div>
									</div>
									<div class="form-group">
										<label class="control-label" for="ag_rss_cache_name">Feed Cache Provider:</label>
										<div class="controls">
											<small>Choose the CacheBox provider to cache feeds into.</small><br/>
											#html.select(
												name="ag_rss_cache_name",
												options=prc.cacheNames,
												selectedValue=prc.agSettings.ag_rss_cache_name,
												class="input-sm"
											)#
										</div>
									</div>
									<div class="form-group">
										<label class="control-label" for="ag_rss_cache_timeout">
											Feed Cache Timeouts:
											<span class="badge badge-info" id="ag_rss_cache_timeout_label">#prc.agSettings.ag_rss_cache_timeout#</span>
										</label>
										<div class="controls">
											<small>The number of minutes a feed XML is cached per permutation of feed type.</small><br/>
											<strong class="margin10">5</strong>
											<input type="text"
												id="ag_rss_cache_timeout"
												name="ag_rss_cache_timeout"
												class="slider"
												data-slider-value="#prc.agSettings.ag_rss_cache_timeout#"
												data-provide="slider"
												data-slider-min="5"
												data-slider-max="1440"
												data-slider-step="5"
												data-slider-tooltip="hide"
												data-slider-scale="logarithmic" />
											<strong class="margin10">500</strong>
										</div>
									</div>
									<div class="form-group">
										<label class="control-label" for="ag_rss_cache_timeout_idle">
											Feed Cache Idle Timeouts:
											<span class="badge badge-info" id="ag_rss_cache_timeout_idle_label">#prc.agSettings.ag_rss_cache_timeout_idle#</span>
										</label>
										<div class="controls">
											<small>The number of idle minutes allowed for cached RSS feeds to live. Usually this is less than the timeout you selected above</small><br/>
											<strong class="margin10">5</strong>
											<input 	type="text"
												id="ag_rss_cache_timeout_idle"
												name="ag_rss_cache_timeout_idle"
												class="slider"
												data-slider-value="#prc.agSettings.ag_rss_cache_timeout_idle#"
												data-provide="slider"
												data-slider-min="5"
												data-slider-max="1440"
												data-slider-step="5"
												data-slider-tooltip="hide"
												data-slider-scale="logarithmic" />
											<strong class="margin10">500</strong>
										</div>
									</div>
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