<cfoutput>

<div class="row">
	<div class="col-md-12">
		<h1 class="h1">
			<i class="fa fa-sliders fa-lg"></i>
			RSS Aggregator - Settings
		</h1>
	</div>
</div>

<div class="row">
	<div class="col-md-12">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
		#html.startForm( name="settingsForm", action="#prc.xehSettingsSave#", novalidate="novalidate" )#
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
											field="ag_general_import_interval",
											content="Import interval:"
										)#
										<div class="controls">
											#html.select(
												name="ag_general_import_interval",
												options=prc.intervals,
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_general_import_interval,
												class="form-control"
											)#
										</div>
										<!--- <div class="wprss-tooltip-content" id="wprss-tooltip-setting-cron-interval">
										<p>How frequently should the feed sources (that do not have their own update interval) check for updates and fetch items accordingly.</p>
										<p>It is recommended to not have more than 20 feed sources that use this global update interval. Having too many feed sources updating precisely at the same time can cause the WP Cron System to crash.</p>
										</div>--->
									</div>
									<div class="start-date-group"<cfif !len( prc.agSettings.ag_general_import_interval ) > style="display:none;"</cfif>>
										<div class="form-group">
											#html.label(
												class="control-label",
												field="ag_general_import_start_date",
												content="Start Date:"
											)#
											<div class="controls row">
												<div class="col-md-6">
													<div class="input-group">
														#html.inputField(
															size="9", 
															name="ag_general_import_start_date",
															value=prc.agSettings.ag_general_import_start_date, 
															class="form-control datepicker",
															placeholder="Immediately"
														)#
														<span class="input-group-addon">
															<span class="fa fa-calendar"></span>
														</span>
													</div>
												</div>
												<div class="col-md-6">
													<div class="input-group clockpicker" data-placement="left" data-align="top" data-autoclose="true">
														<input type="text" class="form-control inline" value="#prc.agSettings.ag_general_import_start_time#" name="ag_general_import_start_time" />
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
												field="ag_general_default_creator",
												content="Default creator:"
											)#
											<div class="controls">
												<select name="ag_general_default_creator" id="crag_general_default_creatoreator" class="form-control">
													<cfloop array="#prc.authors#" index="author">
														<option value="#author.getAuthorID()#"<cfif prc.agSettings.ag_general_default_creator EQ author.getAuthorID() > selected="selected"</cfif>>#author.getName()#</option>
													</cfloop>
												</select>
											</div>
											<!--- Selecte default creator used when importing items
											<div class="wprss-tooltip-content" id="wprss-tooltip-setting-cron-interval">
											<p>How frequently should the feed sources (that do not have their own update interval) check for updates and fetch items accordingly.</p>
											<p>It is recommended to not have more than 20 feed sources that use this global update interval. Having too many feed sources updating precisely at the same time can cause the WP Cron System to crash.</p>
											</div>--->
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-list-ol fa-lg"></i> Item Limits</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_max_age",
											content="Limit items by age:"
										)#
										<div class="controls row">
											<div class="col-sm-6">
												#html.inputField(
													name="ag_general_max_age",
													type="number",
													value=prc.agSettings.ag_general_max_age,
													class="form-control counter",
													placeholder="No limit",
													min="0"
												)#
											</div>
											<div class="col-sm-6">
												#html.select(
													name="ag_general_max_age_unit",
													options=prc.limitUnits,
													selectedValue=prc.agSettings.ag_general_max_age_unit,
													class="form-control"
												)#
											</div>
										</div>
										<!--- 
										<div class="wprss-tooltip-content" id="wprss-tooltip-setting-limit-feed-items-by-age">
										<p>The maximum age allowed for feed items.</p>
										<hr>
										<p>Items already imported will be deleted if they eventually exceed this age limit.</p>
										<p>Also, items in the RSS feed that are already older than this age will not be imported at all.</p>
										<hr>
										<p><em>Leave empty for no limit.</em></p>
										</div>--->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_max_items",
											content="Limit items by number:"
										)#
										<div class="controls">
											#html.inputField(
												name="ag_general_max_items",
												type="number",
												value=prc.agSettings.ag_general_max_items,
												class="form-control counter",
												placeholder="No limit",
												min="0"
											)#
										</div>
									</div>
									<!---<div class="wprss-tooltip-content" id="wprss-tooltip-setting-limit-feed-items-imported">
									<p>The maximum number of imported items to keep stored, for feed sources that do not have their own limit.</p>
									<hr>
									<p>When new items are imported and the limit for a feed source is exceeded, the oldest feed items for that feed source will be deleted to make room for the new ones.</p>
									<p>If you already have items imported from this feed source, setting this option now may delete some of your items, in order to comply with the limit.</p>
									<hr>
									<p><em>Use 0 or leave empty for no limit.</em></p>
									</div>--->
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-filter fa-lg"></i> Keyword Filtering</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_match_any_filter",
											content="Contains any of these words/phrases:"
										)#
										<div class="controls">
											#html.textArea(
												name="ag_general_match_any_filter", 
												value=prc.agSettings.ag_general_match_any_filter,
												rows="3",
												class="form-control",
												placeholder="Comma delimited list of words or phrases"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_match_all_filter",
											content="Contains all of these words/phrases:"
										)#
										<div class="controls">
											#html.textArea(
												name="ag_general_match_all_filter", 
												value=prc.agSettings.ag_general_match_all_filter,
												rows="3",
												class="form-control",
												placeholder="Comma delimited list of words or phrases"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_match_none_filter",
											content="Contains none of these words/phrases:"
										)#
										<div class="controls">
											#html.textArea(
												name="ag_general_match_none_filter", 
												value=prc.agSettings.ag_general_match_none_filter, 
												rows="3",
												class="form-control",
												placeholder="Comma delimited list of words or phrases"
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
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_general_log_file_name",
											content="Log file name:"
										)#
										<div class="controls">
											#html.textField(
												name="ag_general_log_file_name",
												value=prc.agSettings.ag_general_log_file_name,
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
												name="ag_display_title_link_toggle",
												data={ toggle: 'toggle', match: 'ag_display_title_link' },
												checked	= prc.agSettings.ag_display_title_link
											)#
											#html.hiddenField( 
												name="ag_display_title_link", 
												value=prc.agSettings.ag_display_title_link 
											)#
										</div>
<!---<div class="wprss-tooltip-content" id="wprss-tooltip-setting-link-enable">
<p>Check this box to make the feed item titles link to the original article.</p>
</div>--->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_author_show",
											content="Show author:"
										)#
										<div class="controls">
											#html.checkbox(
												name="ag_display_author_show_toggle",
												data={ toggle: 'toggle', match: 'ag_display_author_show' },
												checked=prc.agSettings.ag_display_author_show
											)#
											#html.hiddenField( 
												name="ag_display_author_show", 
												value=prc.agSettings.ag_display_author_show 
											)#
										</div>
<!---<div class="wprss-tooltip-content" id="wprss-tooltip-setting-authors-enable">
<p>Check this box to show the author for each feed item, if it is available.</p>
</div>--->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_source_show",
											content="Show source:"
										)#
										<div class="controls">
											#html.checkbox(
												name="ag_display_source_show_toggle",
												data={ toggle: 'toggle', match: 'ag_display_source_show' },
												checked=prc.agSettings.ag_display_source_show
											)#
											#html.hiddenField( 
												name="ag_display_source_show", 
												value=prc.agSettings.ag_display_source_show 
											)#
										</div>
									</div>
<!---<div class="wprss-tooltip-content" id="wprss-tooltip-setting-source-enable">
<p>Enable this option to show the feed source name for each feed item.</p>
</div>--->
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_source_link",
											content="Link source:"
										)#
										<div class="controls">
											#html.checkbox(
												name="ag_display_source_link_toggle",
												data={ toggle: 'toggle', match: 'ag_display_source_link' },
												checked=prc.agSettings.ag_display_source_link
											)#
											#html.hiddenField( 
												name="ag_display_source_link", 
												value=prc.agSettings.ag_display_source_link 
											)#
										</div>
<!---<div class="wprss-tooltip-content" id="wprss-tooltip-setting-source-link">
<p>Enable this option to link the feed source name to the RSS feed's source site.</p>
</div>--->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_link_new_window",
											content="Open links in new window:"
										)#
										<div class="controls">
											#html.checkbox(
												name="ag_display_link_new_window_toggle",
												data={ toggle: 'toggle', match: 'ag_display_link_new_window' },
												checked=prc.agSettings.ag_display_link_new_window
											)#
											#html.hiddenField( 
												name="ag_display_link_new_window", 
												value=prc.agSettings.ag_display_link_new_window 
											)#
										</div>
<!---<div class="wprss-tooltip-content" id="wprss-tooltip-setting-open-dd"> - options lightbox/new window/self
<p>Choose how you want links to be opened. This applies to the feed item title and the source link.</p>
</div>--->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_link_as_nofollow",
											content="Set links as nofollow:"
										)#
										<div class="controls">
											#html.checkbox(
												name="ag_display_link_as_nofollow_toggle",
												data={ toggle: 'toggle', match: 'ag_display_link_as_nofollow' },
												checked=prc.agSettings.ag_display_link_as_nofollow
											)#
											#html.hiddenField( 
												name="ag_display_link_as_nofollow", 
												value=prc.agSettings.ag_display_link_as_nofollow 
											)#
										</div>
<!---<div class="wprss-tooltip-content" id="wprss-tooltip-setting-follow-dd">
<p>Enable this option to set all links displayed as "NoFollow".</p>
<hr>
<p>"Nofollow" provides a way to tell search engines to <em>not</em> follow certain links, such as links to feed items in this case.</p>
</div>--->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_video_link",
											content="Link videos:"
										)#
										<div class="controls">
											#html.checkbox(
												name="ag_display_video_link_toggle",
												data={ toggle: 'toggle', match: 'ag_display_video_link' },
												checked=prc.agSettings.ag_display_video_link
											)#
											#html.hiddenField( 
												name="ag_display_video_link", 
												value=prc.agSettings.ag_display_video_link 
											)#
										</div>
<!---<select id="video-links" name="wprss_settings_general[video_link]">
<option value="false" selected="selected">Original page link</option><option value="true">Embedded video player link</option>		</select>
<div class="wprss-tooltip-content" id="wprss-tooltip-setting-video-links">
<p>For feed items from YouTube, Vimeo or Dailymotion, you can choose whether you want to have the items link to the original page link, or a link to the embedded video player only.</p>
</div>--->
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
												name="ag_display_excerpt_show_toggle",
												data={ toggle: 'toggle', match: 'ag_display_excerpt_show' },
												checked=prc.agSettings.ag_display_excerpt_show
											)#
											#html.hiddenField( 
												name="ag_display_excerpt_show", 
												value=prc.agSettings.ag_display_excerpt_show 
											)#
										</div>
										<!---Check this box to enable excerpt functionality--->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_excerpt_word_limit",
											content="Word limit:"
										)#
										<div class="controls">
											#html.inputField(
												type="number",
												min="0",
												placeholder="No Limit",
												name="ag_display_excerpt_word_limit",
												value=prc.agSettings.ag_display_excerpt_word_limit,
												class="form-control counter"
											)#
										</div>
										<!---The number of words used in the excerpt displayed--->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_excerpt_ending",
											content="Excerpt ending:"
										)#
										<div class="controls">
											#html.textField(
												name="ag_display_excerpt_ending",
												value=prc.agSettings.ag_display_excerpt_ending,
												class="form-control"
											)#
										</div>
										<!--- Characters appearing at end of excerpt --->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_read_more_show",
											content="Show read more:"
										)#
										<div class="controls">
											#html.checkbox(
												name="ag_display_read_more_show_toggle",
												data={ toggle: 'toggle', match: 'ag_display_read_more_show' },
												checked=prc.agSettings.ag_display_read_more_show
											)#
											#html.hiddenField( 
												name="ag_display_read_more_show", 
												value=prc.agSettings.ag_display_read_more_show 
											)#
										</div>
										<!--- Check this box to enable 'Read more' link functionality--->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_read_more_text",
											content="Read more text:"
										)#
										<div class="controls">
											#html.textField(
												name="ag_display_read_more_text",
												value=prc.agSettings.ag_display_read_more_text,
												class="form-control"
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
												name="ag_display_thumbnail_enable_toggle",
												data={ toggle: 'toggle', match: 'ag_display_thumbnail_enable' },
												checked=prc.agSettings.ag_display_thumbnail_enable
											)#
											#html.hiddenField( 
												name="ag_display_thumbnail_enable", 
												value=prc.agSettings.ag_display_thumbnail_enable 
											)#
										</div>
										<!--- Check this box to enable thumbnail functionality --->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_thumbnail_link",
											content="Link thumbnail:"
										)#
										<div class="controls">
											#html.checkbox(
												name="ag_display_thumbnail_link_toggle",
												data={ toggle: 'toggle', match: 'ag_display_thumbnail_link' },
												checked=prc.agSettings.ag_display_thumbnail_link
											)#
											#html.hiddenField( 
												name="ag_display_thumbnail_link", 
												value=prc.agSettings.ag_display_thumbnail_link 
											)#
										</div>
										<!--- Check this box to link the thumbnail to the feed item's permalink --->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_thumbnail_width",
											content="Thumbnail width:"
										)#
										<div class="controls">
											#html.inputField(
												type="number",
												min="50",
												max="300",
												name="ag_display_thumbnail_width",
												value=prc.agSettings.ag_display_thumbnail_width,
												class="form-control"
											)#
										</div>
										<!--- The thumbnail width in pixels --->
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_display_thumbnail_height",
											content="Thumbnail height:"
										)#
										<div class="controls">
											#html.inputField(
												type="number",
												min="50",
												max="300",
												name="ag_display_thumbnail_height",
												value=prc.agSettings.ag_display_thumbnail_height,
												class="form-control"
											)#
										</div>
										<!--- The thumbnail height in pixels --->
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
<!--- <div class="wprss-tooltip-content" id="wprss-tooltip-setting-feed-limit">
<p>The maximum number of feed items to display when using the shortcode.</p>
<p>This enables pagination if set to a number smaller than the number of items to be displayed.</p>
</div>--->
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
<!---<select id="pagination" name="wprss_settings_general[pagination]">
<option value="default" selected="selected">"Older posts" and "Newer posts" links</option>
<option value="numbered">Page numbers with "Next" and "Previous" page links</option></select>--->
<!---<div class="wprss-tooltip-content" id="wprss-tooltip-setting-pagination">
<p>The type of pagination to use when showing feed items on multiple pages.</p>
<p>The first shows two links, "Older" and "Newer", which allow you to navigate through the pages.</p>
<p>The second shows links for all the pages, together with links for the next and previous pages.</p>
</div>--->
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
												name="ag_portal_enable_toggle",
												data={ toggle: 'toggle', match: 'ag_portal_enable' },
												checked=prc.agSettings.ag_portal_enable
											)#
											#html.hiddenField( 
												name="ag_portal_enable", 
												value=prc.agSettings.ag_portal_enable 
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
												name="ag_portal_title",
												value=prc.agSettings.ag_portal_title,
												class="form-control"
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
												name="ag_portal_hits_track_toggle",
												data={ toggle: 'toggle', match: 'ag_portal_hits_track' },
												checked=prc.agSettings.ag_portal_hits_track
											)#
											#html.hiddenField( 
												name="ag_portal_hits_track", 
												value=prc.agSettings.ag_portal_hits_track 
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
												name="ag_portal_hits_ignore_bots_toggle",
												data={ toggle: 'toggle', match: 'ag_portal_hits_ignore_bots' },
												checked=prc.agSettings.ag_portal_hits_ignore_bots
											)#
											#html.hiddenField( 
												name="ag_portal_hits_ignore_bots", 
												value=prc.agSettings.ag_portal_hits_ignore_bots 
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
												name="ag_portal_cache_enable_toggle",
												data={ toggle: 'toggle', match: 'ag_portal_cache_enable' },
												checked=prc.agSettings.ag_portal_cache_enable
											)#
											#html.hiddenField(
												name="ag_portal_cache_enable",
												value=prc.agSettings.ag_portal_cache_enable
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
												class="form-control"
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
												name="ag_rss_enable_toggle",
												data={ toggle: 'toggle', match: 'ag_rss_enable' },
												checked=prc.agSettings.ag_rss_enable
											)#
											#html.hiddenField( 
												name="ag_rss_enable", 
												value=prc.agSettings.ag_rss_enable 
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
												name="ag_rss_title",
												required="required",
												value=prc.agSettings.ag_rss_title,
												class="form-control"
											)#
										</div>
<!---Latest imported feed items on WP RSS Aggregator Simple Demo Dashboard
<div class="wprss-tooltip-content" id="wprss-tooltip-setting-custom-feed-title">
<p>The title of the custom feed.</p>
<p>This title will be included in the RSS source of the custom feed, in a <code>&lt;title&gt;</code> tag.</p>
</div>--->
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
<!---<div class="wprss-tooltip-content" id="wprss-tooltip-setting-custom-feed-limit">
<p>The maximum number of feed items in the custom feed.</p>
</div>--->
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
												name="ag_rss_cache_enable_toggle",
												data={ toggle: 'toggle', match: 'ag_rss_cache_enable' },
												checked=prc.agSettings.ag_rss_cache_enable
											)#
											#html.hiddenField(
												name="ag_rss_cache_enable",
												value=prc.agSettings.ag_rss_cache_enable
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
												class="form-control"
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