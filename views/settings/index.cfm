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
		#html.startForm( name="settingsForm", action="#prc.xehAgSettingsSave#", novalidate="novalidate" )#
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
								<a href="##portal_options" data-toggle="tab"><i class="fa fa-newspaper-o fa-lg"></i> Portal</a>
							</li>
							<li>
								<a href="##rss_options" data-toggle="tab"><i class="fa fa-rss fa-lg"></i> RSS Feed</a>
							</li>
						</ul>
						<div class="tab-content">
							<div class="tab-pane active" id="general_options">
								<fieldset>
									<legend><i class="fa fa-cog fa-lg"></i> General Options</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_interval",
											content="Import interval:"
										)#
										<div class="controls">
											#html.select(
												name="ag_general_interval",
												options=prc.intervals,
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_general_interval,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_limit_by_age",
											content="Item age limit:"
										)#
										<div class="controls">
											#html.inputField(
												name="ag_general_limit_by_age",
												type="number",
												value=prc.agSettings.ag_general_limit_by_age,
												class="form-control",
												placeholder="No limit"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_limit_by_number",
											content="Item number limit:"
										)#
										<div class="controls">
											#html.inputField(
												name="ag_general_limit_by_number",
												type="number",
												value=prc.agSettings.ag_general_limit_by_number,
												class="form-control",
												placeholder="No limit"
											)#
										</div>
									</div>

								</fieldset>
								<fieldset>
									<legend><i class="fa fa-filter fa-lg"></i> Keyword Filtering</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_filter_any",
											content="Contains any of these words:"
										)#
										<div class="controls">
											#html.textArea(
												name="ag_general_filter_any", 
												value=prc.agSettings.ag_general_filter_any,
												rows="4",
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_filter_all",
											content="Contains all of these words:"
										)#
										<div class="controls">
											#html.textArea(
												name="ag_general_filter_all", 
												value=prc.agSettings.ag_general_filter_all,
												rows="4",
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_filter_none",
											content="Contains none of these words:"
										)#
										<div class="controls">
											#html.textArea(
												name="ag_general_filter_none", 
												value=prc.agSettings.ag_general_filter_none, 
												rows="4",
												class="form-control"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-database fa-lg"></i> Logging</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_log_level",
											content="Log level:"
										)#
										<div class="controls">
											#html.select(
												name="ag_general_log_level",
												options=prc.logLevels,
												selectedValue=prc.agSettings.ag_general_log_level,
												class="form-control"
											)#
										</div>
									</div>
								</fieldset>
							</div>
							<div class="tab-pane" id="display_options">
								<fieldset>
									<legend><i class="fa fa-desktop fa-lg"></i> Display Options</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_title_link",
											content="Link title:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_display_title_link_toggle",
												data = { toggle: 'toggle', match: 'ag_display_title_link' },
												checked	= prc.agSettings.ag_display_title_link
											)#
											#html.hiddenField( 
												name = "ag_display_title_link", 
												value = prc.agSettings.ag_display_title_link 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_author_show",
											content="Show author:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_display_author_show_toggle",
												data = { toggle: 'toggle', match: 'ag_display_author_show' },
												checked	= prc.agSettings.ag_display_author_show
											)#
											#html.hiddenField( 
												name = "ag_display_author_show", 
												value = prc.agSettings.ag_display_author_show 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_source_show",
											content="Show source:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_display_source_show_toggle",
												data = { toggle: 'toggle', match: 'ag_display_source_show' },
												checked	= prc.agSettings.ag_display_source_show
											)#
											#html.hiddenField( 
												name = "ag_display_source_show", 
												value = prc.agSettings.ag_display_source_show 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_source_link",
											content="Link source:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_display_source_link_toggle",
												data = { toggle: 'toggle', match: 'ag_display_source_link' },
												checked	= prc.agSettings.ag_display_source_link
											)#
											#html.hiddenField( 
												name = "ag_display_source_link", 
												value = prc.agSettings.ag_display_source_link 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_link_new_window",
											content="Open links in new window:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_display_link_new_window_toggle",
												data = { toggle: 'toggle', match: 'ag_display_link_new_window' },
												checked	= prc.agSettings.ag_display_link_new_window
											)#
											#html.hiddenField( 
												name = "ag_display_link_new_window", 
												value = prc.agSettings.ag_display_link_new_window 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_link_as_nofollow",
											content="Set links as nofollow:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_display_link_as_nofollow_toggle",
												data = { toggle: 'toggle', match: 'ag_display_link_as_nofollow' },
												checked	= prc.agSettings.ag_display_link_as_nofollow
											)#
											#html.hiddenField( 
												name = "ag_display_link_as_nofollow", 
												value = prc.agSettings.ag_display_link_as_nofollow 
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-list-alt fa-lg"></i> Excerpt Options</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_excerpt_show",
											content="Show excerpts:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_display_excerpt_show_toggle",
												data = { toggle: 'toggle', match: 'ag_display_excerpt_show' },
												checked	= prc.agSettings.ag_display_excerpt_show
											)#
											#html.hiddenField( 
												name = "ag_display_excerpt_show", 
												value = prc.agSettings.ag_display_excerpt_show 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_excerpt_ending",
											content="Excerpt ending:"
										)#
										<div class="controls">
											#html.textField(
												name = "ag_display_excerpt_ending",
												value = prc.agSettings.ag_display_excerpt_ending,
												class = "form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_read_more_show",
											content="Show read more:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_display_read_more_show_toggle",
												data = { toggle: 'toggle', match: 'ag_display_read_more_show' },
												checked	= prc.agSettings.ag_display_read_more_show
											)#
											#html.hiddenField( 
												name = "ag_display_read_more_show", 
												value = prc.agSettings.ag_display_read_more_show 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_read_more_text",
											content="Read more text:"
										)#
										<div class="controls">
											#html.textField(
												name = "ag_display_read_more_text",
												value = prc.agSettings.ag_display_read_more_text,
												class = "form-control"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-image fa-lg"></i> Thumbnail Options</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_thumbnail_enable",
											content="Enable thumbnails:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_display_thumbnail_enable_toggle",
												data = { toggle: 'toggle', match: 'ag_display_thumbnail_enable' },
												checked	= prc.agSettings.ag_display_thumbnail_enable
											)#
											#html.hiddenField( 
												name = "ag_display_thumbnail_enable", 
												value = prc.agSettings.ag_display_thumbnail_enable 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_thumbnail_link",
											content="Link thumbnail:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_display_thumbnail_link_toggle",
												data = { toggle: 'toggle', match: 'ag_display_thumbnail_link' },
												checked	= prc.agSettings.ag_display_thumbnail_link
											)#
											#html.hiddenField( 
												name = "ag_display_thumbnail_link", 
												value = prc.agSettings.ag_display_thumbnail_link 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_thumbnail_width",
											content="Thumbnail width:"
										)#
										<div class="controls">
											#html.textField(
												name = "ag_display_thumbnail_width",
												value = prc.agSettings.ag_display_thumbnail_width,
												class = "form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_thumbnail_height",
											content="Thumbnail height:"
										)#
										<div class="controls">
											#html.textField(
												name = "ag_display_thumbnail_height",
												value = prc.agSettings.ag_display_thumbnail_height,
												class = "form-control"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-copy fa-lg"></i> Paging Options</legend>
									<div class="form-group">
										<label class="control-label" for="ag_display_paging_max_rows">
											Paging max rows:
											<span class="badge badge-info" id="ag_display_paging_max_rows_label">#prc.agSettings.ag_display_paging_max_rows#</span>
										</label>
										<div class="controls">
											<strong class="margin10">10</strong>
											<input 	type="text"
												id="ag_display_paging_max_rows"
												name="ag_display_paging_max_rows"
												class="slider"
												data-slider-value="#prc.agSettings.ag_display_paging_max_rows#"
												data-provide="slider"
												data-slider-min="10"
												data-slider-max="50"
												data-slider-step="10"
												data-slider-tooltip="hide" />
											<strong class="margin10">50</strong>
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_paging_type",
											content="Paging type:"
										)#
										<div class="controls">
											#html.select(
												name="ag_display_paging_type",
												options=prc.pagingTypes,
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_display_paging_type,
												class="form-control"
											)#
										</div>
									</div>
								</fieldset>
							</div>
							<div class="tab-pane" id="portal_options">
								<fieldset>
									<legend><i class="fa fa-newspaper-o fa-lg"></i> Portal Options</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_enable",
											content="Enable portal:"
										)#
										<div class="controls">
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
											content="Portal title:"
										)#
										<div class="controls">
											#html.textField(
												name = "ag_portal_title",
												value = prc.agSettings.ag_portal_title,
												class = "form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_entrypoint",
											content="Portal entry point:" 
										)#
										<div class="controls">
											<small>Choose the entry point in the URL to trigger the portal engine. The usual default entry point pattern is <strong>news</strong>. Do not use symbols or slashes (/ \)</small><br/>
											<code>#prc.cbHelper.linkHome()#</code> 
											#html.textField(
												name="ag_portal_entrypoint", 
												value=prc.agSettings.ag_portal_entrypoint, 
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_layout",
											content="Portal layout:"
										)#
										<div class="controls">
											#html.select(
												name="ag_portal_layout",
												options=prc.layouts,
												selectedValue=prc.agSettings.ag_portal_layout,
												class="form-control"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-bar-chart-o fa-lg"></i> Item Stats Tracking</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_hits_track",
											content="Track item hits:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_portal_hits_track_toggle",
												data = { toggle: 'toggle', match: 'ag_portal_hits_track' },
												checked	= prc.agSettings.ag_portal_hits_track
											)#
											#html.hiddenField( 
												name = "ag_portal_hits_track", 
												value = prc.agSettings.ag_portal_hits_track 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_hits_ignore_bots",
											content="Ignore bot hits:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_portal_hits_ignore_bots_toggle",
												data = { toggle: 'toggle', match: 'ag_portal_hits_ignore_bots' },
												checked	= prc.agSettings.ag_portal_hits_ignore_bots
											)#
											#html.hiddenField( 
												name = "ag_portal_hits_ignore_bots", 
												value = prc.agSettings.ag_portal_hits_ignore_bots 
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_hits_bot_regex",
											content="Bot regex matches:"
										)#
										<div class="controls">
											#html.textArea(
												name="ag_portal_hits_bot_regex", 
												value=prc.agSettings.ag_portal_hits_bot_regex, 
												rows="4",
												class="form-control"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-hdd-o fa-lg"></i> Portal Caching</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_cache_enable",
											content="Enable portal caching:"
										)#
										<div class="controls">
											#html.checkbox(
												name = "ag_portal_cache_enable_toggle",
												data = { toggle: 'toggle', match: 'ag_portal_cache_enable' },
												checked	= prc.agSettings.ag_portal_cache_enable
											)#
											#html.hiddenField(
												name = "ag_portal_cache_enable",
												value = prc.agSettings.ag_portal_cache_enable
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_cache_name",
											content="Portal cache provider:"
										)#
										<div class="controls">
											<small>Choose the CacheBox provider to cache portal content into.</small><br/>
											#html.select(
												name="ag_portal_cache_name",
												options=prc.cacheNames,
												selectedValue=prc.agSettings.ag_portal_cache_name,
												class="input-sm"
											)#
										</div>
									</div>
									<div class="form-group">
										<label class="control-label" for="ag_portal_cache_timeout">
											Portal cache timeouts:
											<span class="badge badge-info" id="ag_portal_cache_timeout_label">#prc.agSettings.ag_portal_cache_timeout#</span>
										</label>
										<div class="controls">
											<small>The number of minutes portal content is cached for.</small><br/>
											<strong class="margin10">5</strong>
											<input type="text"
												id="ag_portal_cache_timeout"
												name="ag_portal_cache_timeout"
												class="slider"
												data-slider-value="#prc.agSettings.ag_portal_cache_timeout#"
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
										<label class="control-label" for="ag_portal_cache_timeout_idle">
											Portal cache idle timeouts:
											<span class="badge badge-info" id="ag_portal_cache_timeout_idle_label">#prc.agSettings.ag_portal_cache_timeout_idle#</span>
										</label>
										<div class="controls">
											<small>The number of idle minutes allowed for cached portal content to live. Usually this is less than the timeout you selected above</small><br/>
											<strong class="margin10">5</strong>
											<input 	type="text"
												id="ag_portal_cache_timeout_idle"
												name="ag_portal_cache_timeout_idle"
												class="slider"
												data-slider-value="#prc.agSettings.ag_portal_cache_timeout_idle#"
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
							<div class="tab-pane" id="rss_options">
								<fieldset>
									<legend><i class="fa fa-rss fa-lg"></i> RSS Feed Options</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_enable",
											content="Enable rss feed:"
										)#
										<div class="controls">
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
											content="Feed title:"
										)#
										<div class="controls">
											<small>The title of the rss feed</small><br/>
											#html.textField(
												name = "ag_rss_title",
												required="required",
												value = prc.agSettings.ag_rss_title,
												class = "form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_description",
											content="Feed description:" 
										)#
										<div class="controls">
											<small>The description of the rss feed</small><br/>
											#html.textArea(
												name="ag_rss_description",
												value=prc.agSettings.ag_rss_description,
												rows="4",
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_generator",
											content="Feed generator:" 
										)#
										<div class="controls">
											<small>The generator of the rss feed</small><br/>
											#html.textField(
												name="ag_rss_generator",
												required="required",
												value=prc.agSettings.ag_rss_generator,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_copyright",
											content="Feed copyright:" 
										)#
										<div class="controls">
											<small>The copyright of the rss feed</small><br/>
											#html.textField(
												name="ag_rss_copyright",
												required="required",
												value=prc.agSettings.ag_rss_copyright,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_webmaster",
											content="Feed webmaster:" 
										)#
										<div class="controls">
											<small>The rss feed webmaster. Ex: myemail@mysite.com (Site Administrator)</small><br/>
											#html.textField(
												name="ag_rss_webmaster",
												value=prc.agSettings.ag_rss_webmaster,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										<label class="control-label" for="ag_rss_max_items">
											Max rss content items:
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
									<legend><i class="fa fa-hdd-o fa-lg"></i> RSS Caching</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_cache_enable",
											content="Enable rss feed caching:"
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
										#html.label(
											class="control-label",
											field="ag_rss_cache_name",
											content="Feed cache provider:"
										)#
										<div class="controls">
											<small>Choose the CacheBox provider to cache feed content into.</small><br/>
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
											Feed cache timeouts:
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
											Feed cache idle timeouts:
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