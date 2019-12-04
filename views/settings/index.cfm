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
	<div class="col-md-9">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
		#html.startForm( name="settingsForm", action="#prc.xehAggregatorSettingsSave#", novalidate="novalidate" )#
			#html.anchor( name="top" )#
			<div class="panel panel-default">
				<div class="panel-body">
					<div class="tab-wrapper tab-left tab-primary">
						<ul class="nav nav-tabs">
							<li role="presentation" class="active">
								<a href="##site" data-toggle="tab">
									<i class="fa fa-cog fa-lg"></i> Site Options
								</a>
							</li>
							<li role="presentation" >
								<a href="##importing" data-toggle="tab">
									<i class="fa fa-download fa-lg"></i> Importing
								</a>
							</li>
							<li role="presentation" >
								<a href="##global_html" data-toggle="tab">
									<i class="fa fa-globe fa-lg"></i> Global HTML
								</a>
							</li>
							<li role="presentation" >
								<a href="##rss" data-toggle="tab">
									<i class="fa fa-rss fa-lg"></i> RSS Feed
								</a>
							</li>
						</ul>
						<div class="tab-content">
							<div class="tab-pane active" id="site">
								<fieldset>
									<legend>
										<i class="fa fa-cog fa-lg"></i>
										Site Options
									</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feeds_entrypoint",
											content="Feeds Page:"
										)#
										<div class="controls">
											<small>The page used in the site to display the list of feeds.</small>
											#html.select(
												name="ag_site_feeds_entrypoint",
												options=prc.pages,
												column="slug",
												nameColumn="title",
												selectedValue=prc.agSettings.ag_site_feeds_entrypoint,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_entrypoint",
											content="Feed Items Page:"
										)#
										<div class="controls">
											<small>The page used in the site to display the imported feed items.</small>
											#html.select(
												name="ag_site_feed_items_entrypoint",
												options=prc.pages,
												column="slug",
												nameColumn="title",
												selectedValue=prc.agSettings.ag_site_feed_items_entrypoint,
												class="form-control"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend>
										<i class="fa fa-file-text-o fa-lg"></i>
										Feed Options
									</legend>
									<p><small>These options determine the way feeds are listed on the feeds page.  The current theme must support these settings or they will not work.</small></p>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feeds_include_items",
											content="Include Feed Items:"
										)#
										<p><small>If enabled, the latest feed items will also be displayed within the list of feeds.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feeds_include_items_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feeds_include_items' },
												checked=prc.agSettings.ag_site_feeds_include_items
											)#
											#html.hiddenField(
												name="ag_site_feeds_include_items",
												value=prc.agSettings.ag_site_feeds_include_items
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feeds_show_featured_image",
											content="Show Featured Image:"
										)#
										<p><small>If enabled, the feed's featured image will be displayed if one exists.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feeds_show_featured_image_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feeds_show_featured_image' },
												checked=prc.agSettings.ag_site_feeds_show_featured_image
											)#
											#html.hiddenField(
												name="ag_site_feeds_show_featured_image",
												value=prc.agSettings.ag_site_feeds_show_featured_image
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feeds_show_website",
											content="Show Website Link:"
										)#
										<p><small>If enabled, a link to the feed's website will be displayed within the list of feeds.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feeds_show_website_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feeds_show_website' },
												checked=prc.agSettings.ag_site_feeds_show_website
											)#
											#html.hiddenField(
												name="ag_site_feeds_show_website",
												value=prc.agSettings.ag_site_feeds_show_website
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feeds_show_rss",
											content="Show RSS Link:"
										)#
										<p><small>If enabled, a link to the feed's rss will be displayed within the list of feeds.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feeds_show_rss_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feeds_show_rss' },
												checked=prc.agSettings.ag_site_feeds_show_rss
											)#
											#html.hiddenField(
												name="ag_site_feeds_show_rss",
												value=prc.agSettings.ag_site_feeds_show_rss
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend>
										<i class="fa fa-file-text-o fa-lg"></i>
										Feed Item Options
									</legend>
									<p><small>These options determine the way feed items are listed on the feed items page.  The current theme must support these settings or they will not work.</small></p>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_include_entries",
											content="Include Blog Entries:"
										)#
										<p><small>If enabled, blog entries will also be displayed with the feed items and any feed item that has a related blog entry will not display.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_include_entries_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_include_entries' },
												checked=prc.agSettings.ag_site_feed_items_include_entries
											)#
											#html.hiddenField(
												name="ag_site_feed_items_include_entries",
												value=prc.agSettings.ag_site_feed_items_include_entries
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_group_by_date",
											content="Group By Date:"
										)#
										<p><small>If enabled, feed items will be grouped by date on the feed items page.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_group_by_date_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_group_by_date' },
												checked=prc.agSettings.ag_site_feed_items_group_by_date
											)#
											#html.hiddenField(
												name="ag_site_feed_items_group_by_date",
												value=prc.agSettings.ag_site_feed_items_group_by_date
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_show_video_player",
											content="Show Video Player:"
										)#
										<p><small>If enabled, an inline video player will be displayed for videos.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_show_video_player_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_show_video_player' },
												checked=prc.agSettings.ag_site_feed_items_show_video_player
											)#
											#html.hiddenField(
												name="ag_site_feed_items_show_video_player",
												value=prc.agSettings.ag_site_feed_items_show_video_player
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_show_audio_player",
											content="Show Audio Player:"
										)#
										<p><small>If enabled, an inline audio player will be displayed for podcasts.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_show_audio_player_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_show_audio_player' },
												checked=prc.agSettings.ag_site_feed_items_show_audio_player
											)#
											#html.hiddenField(
												name="ag_site_feed_items_show_audio_player",
												value=prc.agSettings.ag_site_feed_items_show_audio_player
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_show_source",
											content="Show Source:"
										)#
										<p><small>If enabled, the feed source will be displayed for each feed item.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_show_source_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_show_source' },
												checked=prc.agSettings.ag_site_feed_items_show_source
											)#
											#html.hiddenField(
												name="ag_site_feed_items_show_source",
												value=prc.agSettings.ag_site_feed_items_show_source
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_show_author",
											content="Show Author:"
										)#
										<p><small>If enabled, the author will be displayed for each feed item.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_show_author_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_show_author' },
												checked=prc.agSettings.ag_site_feed_items_show_author
											)#
											#html.hiddenField(
												name="ag_site_feed_items_show_author",
												value=prc.agSettings.ag_site_feed_items_show_author
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_show_categories",
											content="Show Categories:"
										)#
										<p><small>If enabled, the categories will be displayed for each feed item.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_show_categories_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_show_categories' },
												checked=prc.agSettings.ag_site_feed_items_show_categories
											)#
											#html.hiddenField(
												name="ag_site_feed_items_show_categories",
												value=prc.agSettings.ag_site_feed_items_show_categories
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_show_excerpt",
											content="Show Excerpt:"
										)#
										<p><small>If enabled, an excerpt will be displayed for each feed item.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_show_excerpt_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_show_excerpt' },
												checked=prc.agSettings.ag_site_feed_items_show_excerpt
											)#
											#html.hiddenField(
												name="ag_site_feed_items_show_excerpt",
												value=prc.agSettings.ag_site_feed_items_show_excerpt
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_excerpt_limit",
											content="Excerpt Character Limit:"
										)#
										<div class="controls">
											<small>The maximum number of characters to display in the feed item excerpt.</small>
											#html.inputField(
												name="ag_site_feed_items_excerpt_limit",
												type="number",
												value=prc.agSettings.ag_site_feed_items_excerpt_limit,
												class="form-control counter",
												placeholder="No limit",
												min="0"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_excerpt_ending",
											content="Excerpt Ending:"
										)#
										<div class="controls">
											<small>The ending text displayed when the length of the excerpt is larger than the character limit.</small>
											#html.textField(
												name="ag_site_feed_items_excerpt_ending",
												value=prc.agSettings.ag_site_feed_items_excerpt_ending,
												class="form-control",
												maxlength="10"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_show_read_more",
											content="Show Read More:"
										)#
										<p><small>If enabled, a link to the feed item will be displayed after the feed item excerpt.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_show_read_more_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_show_read_more' },
												checked=prc.agSettings.ag_site_feed_items_show_read_more
											)#
											#html.hiddenField(
												name="ag_site_feed_items_show_read_more",
												value=prc.agSettings.ag_site_feed_items_show_read_more
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_read_more_text",
											content="Read More Text:"
										)#
										<div class="controls">
											<small>The text used when the read more link is enabled.</small>
											#html.textField(
												name="ag_site_feed_items_read_more_text",
												required="required",
												value=prc.agSettings.ag_site_feed_items_read_more_text,
												class="form-control",
												maxlength="30"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_link_behavior",
											content="Link Behavior:"
										)#
										<div class="controls">
											<small>The default behavior when clicking on a feed item.</small>
											#html.select(
												name="ag_site_feed_items_link_behavior",
												options=prc.linkOptions,
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_site_feed_items_link_behavior,
												class="form-control input-sm"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_open_new_window",
											content="Open New Window:"
										)#
										<p><small>If enabled, links to feed items will be open in a new window (tab).</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_open_new_window_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_open_new_window' },
												checked=prc.agSettings.ag_site_feed_items_open_new_window
											)#
											#html.hiddenField(
												name="ag_site_feed_items_open_new_window",
												value=prc.agSettings.ag_site_feed_items_open_new_window
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_show_featured_image",
											content="Show Featured Image:"
										)#
										<p><small>If enabled, the feed item's featured image will be displayed if one exists.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_feed_items_show_featured_image_toggle",
												data={ toggle: 'toggle', match: 'ag_site_feed_items_show_featured_image' },
												checked=prc.agSettings.ag_site_feed_items_show_featured_image
											)#
											#html.hiddenField(
												name="ag_site_feed_items_show_featured_image",
												value=prc.agSettings.ag_site_feed_items_show_featured_image
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_featured_image_behavior",
											content="Featured Image Behavior:"
										)#
										<div class="controls">
											<small>The default behavior when a feed item does not have a featured image.</small>
											#html.select(
												name="ag_site_feed_items_featured_image_behavior",
												options=prc.featuredImageOptions,
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_site_feed_items_featured_image_behavior,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_feed_items_featured_image_default",
											content="Default Featured Image:"
										)#
										<div><small class="text-left">Use the tool below to select a default featured image.</small></div>
										<div class="controls text-center">
											<a class="btn btn-primary" href="javascript:loadAssetChooser( 'defaultImageCallback' )">Select Image</a>
											<div class="<cfif !len( prc.agSettings.ag_site_feed_items_featured_image_default ) >hide</cfif> form-group" id="default_image_controls">
												<a class="btn btn-danger" href="javascript:cancelDefaultImage()">Clear Image</a>
												#html.hiddenField(
													name="ag_site_feed_items_featured_image_default",
													value=prc.agSettings.ag_site_feed_items_featured_image_default
												)#
												#html.hiddenField(
													name="ag_site_feed_items_featured_image_default_url",
													value=prc.agSettings.ag_site_feed_items_featured_image_default_url
												)#
												<div class="margin10">
													<cfif len( prc.agSettings.ag_site_feed_items_featured_image_default_url ) >
														<img id="default_image_preview" src="#prc.agSettings.ag_site_feed_items_featured_image_default_url#" class="img-thumbnail" height="75" />
													<cfelse>
														<img id="default_image_preview" class="img-thumbnail" height="75" />
													</cfif>
												</div>
											</div>
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend>
										<i class="fa fa-copy fa-lg"></i>
										Paging Options
									</legend>
									<div class="form-group">
										<label class="control-label" for="ag_site_paging_max_feeds">
											Max Feeds:
											<span class="badge badge-info" id="ag_site_paging_max_feeds_label">#prc.agSettings.ag_site_paging_max_feeds#</span>
										</label>
										<div class="controls">
											<small>The number of feeds displayed on the feeds page before paging..</small><br />
											<strong class="margin10">10</strong>
											<input type="text"
												id="ag_site_paging_max_feeds"
												name="ag_site_paging_max_feeds"
												class="slider"
												data-slider-value="#prc.agSettings.ag_site_paging_max_feeds#"
												data-provide="slider"
												data-slider-min="10"
												data-slider-max="50"
												data-slider-step="10"
												data-slider-tooltip="hide" />
											<strong class="margin10">50</strong>
										</div>
									</div>
									<div class="form-group">
										<label class="control-label" for="ag_site_paging_max_feed_items">
											Max Feed Items:
											<span class="badge badge-info" id="ag_site_paging_max_feed_items_label">#prc.agSettings.ag_site_paging_max_feed_items#</span>
										</label>
										<div class="controls">
											<small>The number of feed items displayed on the feed items page and feed page before paging.</small><br />
											<strong class="margin10">10</strong>
											<input type="text"
												id="ag_site_paging_max_feed_items"
												name="ag_site_paging_max_feed_items"
												class="slider"
												data-slider-value="#prc.agSettings.ag_site_paging_max_feed_items#"
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
									<legend>
										<i class="fa fa-hdd-o fa-lg"></i>
										Site Caching
									</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_cache_enable",
											content="Enable Site Caching:"
										)#
										<p><small>If enabled, site content will be cached once it has been translated and rendered.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_site_cache_enable_toggle",
												data={ toggle: 'toggle', match: 'ag_site_cache_enable' },
												checked=prc.agSettings.ag_site_cache_enable
											)#
											#html.hiddenField(
												name="ag_site_cache_enable",
												value=prc.agSettings.ag_site_cache_enable
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_site_cache_name",
											content="Site Cache Provider:"
										)#
										<div class="controls">
											<small>Choose the CacheBox provider to cache site content into.</small><br/>
											#html.select(
												name="ag_site_cache_name",
												options=prc.cacheNames,
												selectedValue=prc.agSettings.ag_site_cache_name,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										<label class="control-label" for="ag_site_cache_timeout">
											Site Cache Timeouts:
											<span class="badge badge-info" id="ag_site_cache_timeout_label">#prc.agSettings.ag_site_cache_timeout#</span>
										</label>
										<div class="controls">
											<small>The number of minutes site content is cached for.</small><br/>
											<strong class="margin10">5</strong>
											<input type="text"
												id="ag_site_cache_timeout"
												name="ag_site_cache_timeout"
												class="slider"
												data-slider-value="#prc.agSettings.ag_site_cache_timeout#"
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
										<label class="control-label" for="ag_site_cache_timeout_idle">
											Site Cache Idle Timeouts:
											<span class="badge badge-info" id="ag_site_cache_timeout_idle_label">#prc.agSettings.ag_site_cache_timeout_idle#</span>
										</label>
										<div class="controls">
											<small>The number of idle minutes allowed for cached site content to live. Usually this is less than the timeout you selected above</small><br/>
											<strong class="margin10">5</strong>
											<input type="text"
												id="ag_site_cache_timeout_idle"
												name="ag_site_cache_timeout_idle"
												class="slider"
												data-slider-value="#prc.agSettings.ag_site_cache_timeout_idle#"
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
							<div class="tab-pane" id="importing">
								<fieldset>
									<legend>
										<i class="fa fa-download fa-lg"></i>
										Importing Options
									</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_import_interval",
											content="Import Interval:"
										)#
										<div class="controls">
											<small>
												How frequently the feeds should be checked for updates and imported.
												Select "Never" if you plan to manually import feeds.
											</small>
											#html.select(
												name="ag_importing_import_interval",
												options=prc.intervals,
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_importing_import_interval,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_import_start_date",
											content="Start Date:"
										)#
										<div><small>The date and time to begin importing feeds.</small></div>
										<div class="controls row">
											<div class="col-md-6">
												<div class="input-group">
													#html.inputField(
														size="9",
														name="ag_importing_import_start_date",
														value=prc.agSettings.ag_importing_import_start_date,
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
													<input type="text" class="form-control inline" value="#prc.agSettings.ag_importing_import_start_time#" name="ag_importing_import_start_time" id="ag_importing_import_start_time" />
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
											field="ag_importing_secret_key",
											content="Secret Key:"
										)#
										<div class="controls">
											<small>The secret key used to secure the automated feed import process.</small>
											#html.textField(
												name="ag_importing_secret_key",
												value=prc.agSettings.ag_importing_secret_key,
												class="form-control",
												maxlength="100"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_max_feed_imports",
											content="Import History Limit:"
										)#
										<div class="controls">
											<small>
												The maximum number of records to keep in the feed import history.
												When feeds are imported and this limit is exceeded, the oldest record will be deleted to make room for the new one.
											</small>
											#html.inputField(
												name="ag_importing_max_feed_imports",
												type="number",
												value=prc.agSettings.ag_importing_max_feed_imports,
												class="form-control counter",
												placeholder="No limit",
												min="0"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend>
										<i class="fa fa-file-text-o fa-lg"></i>
										Item Defaults
									</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_item_author",
											content="Item Author:"
										)#
										<div class="controls">
											<small>The account used as the feed item author during the automated feed import process.</small>
											<select name="ag_importing_item_author" id="ag_importing_item_author" class="form-control">
												<cfloop array="#prc.authors#" index="author">
													<option value="#author.getAuthorID()#"<cfif prc.agSettings.ag_importing_item_author EQ author.getAuthorID() > selected="selected"</cfif>>#author.getName()#</option>
												</cfloop>
											</select>
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_item_status",
											content="Item Status:"
										)#
										<div class="controls">
											<small>The status used for imported feed items.</small>
											#html.select(
												name="ag_importing_item_status",
												options=[{name="Draft",value="draft"},{name="Published",value="published"}],
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_importing_item_status,
												class="form-control input-sm"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_item_pub_date",
											content="Published Date:"
										)#
										<div class="controls">
											<small>The value used as the published date for imported feed items.</small>
											#html.select(
												name="ag_importing_item_pub_date",
												options=[{name="Original published date",value="original"},{name="Imported date",value="imported"}],
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_importing_item_pub_date,
												class="form-control input-sm"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend>
										<i class="fa fa-list-ol fa-lg"></i>
										Item Limits
									</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_max_age",
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
													name="ag_importing_max_age",
													type="number",
													value=prc.agSettings.ag_importing_max_age,
													class="form-control counter",
													placeholder="No limit",
													min="0"
												)#
											</div>
											<div class="col-sm-6">
												#html.select(
													name="ag_importing_max_age_unit",
													options=prc.limitUnits,
													selectedValue=prc.agSettings.ag_importing_max_age_unit,
													class="form-control"
												)#
											</div>
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_max_items",
											content="Limit items by number:"
										)#
										<div class="controls">
											<small>
												The maximum number of feed items to keep per feed.
												When feeds are imported and this limit is exceeded, the oldest feed items will be deleted first to make room for the new ones.
											</small>
											#html.inputField(
												name="ag_importing_max_items",
												type="number",
												value=prc.agSettings.ag_importing_max_items,
												class="form-control counter",
												placeholder="No limit",
												min="0"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend>
										<i class="fa fa-filter fa-lg"></i>
										Keyword Filtering
									</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_match_any_filter",
											content="Contains any of these kewords:"
										)#
										<div class="controls">
											<small>
												Only feed items that contain any of these kewords in the title or body will be imported.
												Existing feed items that do not contain any of these kewords in the title or body will be deleted.
											</small>
											#html.textArea(
												name="ag_importing_match_any_filter",
												value=prc.agSettings.ag_importing_match_any_filter,
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
											field="ag_importing_match_all_filter",
											content="Contains all of these kewords:"
										)#
										<div class="controls">
											<small>
												Only feed items that contain all of these kewords in the title or body will be imported.
												Existing feed items that do not contain all of these kewords in the title or body will be deleted.
											</small>
											#html.textArea(
												name="ag_importing_match_all_filter",
												value=prc.agSettings.ag_importing_match_all_filter,
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
											field="ag_importing_match_none_filter",
											content="Contains none of these kewords:"
										)#
										<div class="controls">
											<small>
												Only feed items that do not contain any of these kewords in the title or body will be imported.
												Existing feed items that contain any of these kewords in the title or body will be deleted.
											</small>
											#html.textArea(
												name="ag_importing_match_none_filter",
												value=prc.agSettings.ag_importing_match_none_filter,
												rows="3",
												class="form-control",
												placeholder="Comma delimited list of words or phrases",
												maxlength="255"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend>
										<i class="fa fa-image fa-lg"></i>
										Image Settings
									</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_featured_image_enable",
											content="Import Featured Images:"
										)#
										<p><small>If enabled, an image will be saved locally as the featured image for each feed item when imported.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_importing_featured_image_enable_toggle",
												data={ toggle: 'toggle', match: 'ag_importing_featured_image_enable' },
												checked=prc.agSettings.ag_importing_featured_image_enable
											)#
											#html.hiddenField(
												name="ag_importing_featured_image_enable",
												value=prc.agSettings.ag_importing_featured_image_enable
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_all_images_enable",
											content="Import All Images:"
										)#
										<p><small>If enabled, all images will be saved locally for each feed item when imported.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_importing_all_images_enable_toggle",
												data={ toggle: 'toggle', match: 'ag_importing_all_images_enable' },
												checked=prc.agSettings.ag_importing_all_images_enable
											)#
											#html.hiddenField(
												name="ag_importing_all_images_enable",
												value=prc.agSettings.ag_importing_all_images_enable
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_image_minimum_width",
											content="Minimum Width:"
										)#

										<div class="controls">
											<small>Images smaller than the minimum width below will not be imported.</small>
											#html.inputField(
												name="ag_importing_image_minimum_width",
												type="number",
												value=prc.agSettings.ag_importing_image_minimum_width,
												class="form-control counter",
												placeholder="No minimum width",
												min="0"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_image_minimum_height",
											content="Minimum Height:"
										)#

										<div class="controls">
											<small>Images smaller than the minimum height below will not be imported.</small>
											#html.inputField(
												name="ag_importing_image_minimum_height",
												type="number",
												value=prc.agSettings.ag_importing_image_minimum_height,
												class="form-control counter",
												placeholder="No minimum height",
												min="0"
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend>
										<i class="fa fa-tags fa-lg"></i>
										Taxonomies
									</legend>
									<p><small>Taxonomies are used to automatically assign categories to feed items.</small></p>
									<div id="taxonomies">
										<cfloop from="1" to="#arrayLen( prc.agSettings.ag_importing_taxonomies )#" index="idx">
											<cfset taxonomy = prc.agSettings.ag_importing_taxonomies[idx] />
											<div class="taxonomy">
												<div class="form-group">
													#html.label(
														class="control-label",
														field="ag_importing_taxonomies.#idx#.categories",
														content="Categories:"
													)#
													<div class="controls">
														<small>Assign the following categories to feed items using the matching method below.</small>
														<div class="input-group">
															#html.select(
																name="ag_importing_taxonomies.#idx#.categories",
																options=prc.categories,
																column="categoryID",
																nameColumn="category",
																selectedValue=taxonomy.categories,
																class="form-control input-sm multiselect",
																style="margin-bottom:0px;",
																multiple="true"
															)#
															<a class="input-group-addon btn btn-danger removeTaxonomy" href="javascript:void(0);" data-original-title="Remove Taxonomy" data-container="body">
																<i class="fa fa-trash-o"></i>
															</a>
														</div>
													</div>
												</div>
												<div class="form-group">
													#html.label(
														class="control-label",
														field="ag_importing_taxonomies.#idx#.method",
														content="Matching Method:"
													)#
													<div class="controls">
														<small>Use the following method when matching feed items to the above categories.</small>
														#html.select(
															name="ag_importing_taxonomies.#idx#.method",
															options=prc.matchOptions,
															column="value",
															nameColumn="name",
															selectedValue=taxonomy.method,
															class="form-control input-sm input-methods"
														)#
													</div>
												</div>
												<div class="form-group">
													#html.label(
														class="control-label",
														field="ag_importing_taxonomies.#idx#.keywords",
														content="Keywords:"
													)#
													<div class="controls">
														<small>Use the following keywords when matching feed items to the above categories.</small>
														#html.textArea(
															name="ag_importing_taxonomies.#idx#.keywords",
															value=taxonomy.keywords,
															rows="2",
															class="form-control input-keywords",
															placeholder="Comma delimited list of words or phrases",
															maxlength="255"
														)#
													</div>
												</div>
												<hr />
											</div>
										</cfloop>
									</div>
									<div>
										<button id="addTaxonomy" class="btn btn-sm btn-primary" onclick="return false;">
											<i class="fa fa-plus"></i> Add
										</button>
										<button id="removeAll" class="btn btn-sm btn-danger" onclick="return false;">
											<i class="fa fa-trash-o"></i> Remove All
										</button>
									</div>
								</fieldset>
							</div>
							<div class="tab-pane" id="global_html">
								<fieldset>
									<legend>
										<i class="fa fa-globe fa-lg"></i>
										Global HTML
									</legend>
									<p>These global HTML snippets will be rendered by your theme's layouts and views at the specific points specified below.</p>
									#html.textarea(
										name="ag_html_pre_feed_items_display",
										label="Before Feed Items:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_feed_items_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_feed_items_display",
										label="After Feed Items:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_feed_items_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_pre_feeds_display",
										label="Before Feeds Index:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_feeds_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_feeds_display",
										label="After Feeds Index:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_feeds_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_pre_feed_display",
										label="Before Feed:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_feed_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_feed_display",
										label="After Feed:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_feed_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_pre_feeditem_display",
										label="Before Feed Item:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_feeditem_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_feeditem_display",
										label="After Feed Item:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_feeditem_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_pre_archives_display",
										label="Before Archives:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_archives_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_archives_display",
										label="After Archives:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_archives_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_pre_sidebar_display",
										label="Before Sidebar:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_sidebar_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_sidebar_display",
										label="After Sidebar:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_sidebar_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
								</fieldset>
							</div>
							<div class="tab-pane" id="rss">
								<fieldset>
									<legend>
										<i class="fa fa-rss fa-lg"></i>
										RSS Feed Options
									</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_enable",
											content="Enable RSS Feed:"
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
											content="Feed Title:"
										)#
										<div class="controls">
											<small>The title of the rss feed</small><br/>
											#html.textField(
												name="ag_rss_title",
												required="required",
												value=prc.agSettings.ag_rss_title,
												class="form-control",
												maxlength="100"
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
											#html.textArea(
												name="ag_rss_description",
												value=prc.agSettings.ag_rss_description,
												rows="3",
												class="form-control",
												maxlength="255"
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
												maxlength="100"
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
												maxlength="100"
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
												maxlength="100"
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
											<input type="text"
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
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_content_enable",
											content="Include Item Content:"
										)#
										<p><small>If enabled, the feed item content as well as description will be included in the rss feed.</small></p>
										<div class="controls">
											#html.checkbox(
												name="ag_rss_content_enable_toggle",
												data={ toggle: 'toggle', match: 'ag_rss_content_enable' },
												checked=prc.agSettings.ag_rss_content_enable
											)#
											#html.hiddenField(
												name="ag_rss_content_enable",
												value=prc.agSettings.ag_rss_content_enable
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend>
										<i class="fa fa-hdd-o fa-lg"></i>
										RSS Caching
									</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_cache_enable",
											content="Enable RSS Feed Caching:"
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
											content="Feed Cache Provider:"
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
											<input type="text"
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
								<br />#html.submitButton( value="Save Settings", class="btn btn-danger" )#
							</div>
						</div>
					</div>
				</div>
			</div>
		#html.endForm()#
	</div>
	<div class="col-md-3">
		#renderview( view="sidebar/help", module="contentbox-aggregator" )#
	</div>
</div>
<div id="taxonomyTemplate" style="display:none;">
	<div class="taxonomy">
		<div class="form-group">
			#html.label(
				class="control-label",
				field="ag_importing_taxonomies.templateIndex.categories",
				content="Categories:"
			)#
			<div class="controls">
				<small>Assign the following categories to feed items using the matching method below.</small><br/>
				#html.select(
					name="ag_importing_taxonomies.templateIndex.categories",
					options=prc.categories,
					column="categoryID",
					nameColumn="category",
					class="form-control input-sm multiselecttemplateIndex",
					multiple="true"
				)#
			</div>
		</div>
		<div class="form-group">
			#html.label(
				class="control-label",
				field="ag_importing_taxonomies.templateIndex.method",
				content="Matching Method:"
			)#
			<div class="controls">
				<small>Use the following method when matching feed items to the above categories.</small>
				#html.select(
					name="ag_importing_taxonomies.templateIndex.method",
					options=prc.matchOptions,
					column="value",
					nameColumn="name",
					class="form-control input-sm input-methods"
				)#
			</div>
		</div>
		<div class="form-group">
			#html.label(
				class="control-label",
				field="ag_importing_taxonomies.templateIndex.keywords",
				content="Keywords:"
			)#
			<div class="controls">
				<small>Use the following keywords when matching feed items to the above categories.</small>
				#html.textArea(
					name="ag_importing_taxonomies.templateIndex.keywords",
					rows="2",
					class="form-control input-keywords",
					placeholder="Comma delimited list of words or phrases",
					maxlength="255"
				)#
			</div>
		</div>
		<hr />
	</div>
</div>
</cfoutput>