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
		#html.startForm( name="settingsForm", action="#prc.xehAggregatorSettingsSave#", novalidate="novalidate" )#
			#html.anchor( name="top" )#
			<div class="panel panel-default">
				<div class="panel-body">
					<div class="tab-wrapper tab-left tab-primary">
						<ul class="nav nav-tabs">
							<li class="active">
								<a href="##portal_options" data-toggle="tab"><i class="fa fa-newspaper-o fa-lg"></i> Portal</a>
							</li>
							<li>
								<a href="##importing_options" data-toggle="tab"><i class="fa fa-download fa-lg"></i> Importing</a>
							</li>
							<li>
								<a href="##global_html" data-toggle="tab"><i class="fa fa-globe fa-lg"></i> HTML</a>
							</li>
							<li>
								<a href="##rss_options" data-toggle="tab"><i class="fa fa-rss fa-lg"></i> RSS Feed</a>
							</li>
						</ul>
						<div class="tab-content">
							<div class="tab-pane active" id="portal_options">
								<fieldset>
									<legend><i class="fa fa-newspaper-o fa-lg"></i> Portal Options</legend>
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
												class="form-control",
												maxlength="100"
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
											<small>The title used for the portal.</small>
											#html.textField(
												name="ag_portal_title",
												value=prc.agSettings.ag_portal_title,
												class="form-control",
												maxlength="100"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_description",
											content="Portal description:"
										)#
										<div class="controls">
											<small>The default description used in the meta tags of the portal.</small><br/>
											#html.textarea(
												name="ag_portal_description",
												value=prc.agSettings.ag_portal_description,
												rows=3,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_keywords",
											content="Portal keywords:"
										)#
										<div class="controls">
											<small>The default keywords used in the meta tags of the portal.</small><br/>
											#html.textarea(
												name="ag_portal_keywords",
												value=prc.agSettings.ag_portal_keywords,
												rows=3,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_feeds_title",
											content="Feeds title:"
										)#
										<div class="controls">
											<small>The title used for the feeds page.</small>
											#html.textField(
												name="ag_portal_feeds_title",
												value=prc.agSettings.ag_portal_feeds_title,
												class="form-control",
												maxlength="100"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_use_interstitial_page",
											content="Use interstitial page:"
										)#
										<div><small>If enabled, an interstitial page will be displayed when a user clicks on a feed item before leaving the site.</small></div>
										<div class="controls">
											#html.checkbox(
												name="ag_portal_use_interstitial_page_toggle",
												data={ toggle: 'toggle', match: 'ag_portal_use_interstitial_page' },
												checked=prc.agSettings.ag_portal_use_interstitial_page
											)#
											#html.hiddenField(
												name="ag_portal_use_interstitial_page",
												value=prc.agSettings.ag_portal_use_interstitial_page
											)#
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-copy fa-lg"></i> Paging Options</legend>
									<div class="form-group">
										<label class="control-label" for="ag_portal_paging_max_items">
											Max feed items:
											<span class="badge badge-info" id="ag_portal_paging_max_items_label">#prc.agSettings.ag_portal_paging_max_items#</span>
										</label>
										<div class="controls">
											<small>The number of feed items displayed on the main portal page and feed page before paging.</small><br />
											<strong class="margin10">10</strong>
											<input 	type="text"
												id="ag_portal_paging_max_items"
												name="ag_portal_paging_max_items"
												class="slider"
												data-slider-value="#prc.agSettings.ag_portal_paging_max_items#"
												data-provide="slider"
												data-slider-min="10"
												data-slider-max="50"
												data-slider-step="10"
												data-slider-tooltip="hide" />
											<strong class="margin10">50</strong>
										</div>
									</div>
									<div class="form-group">
										<label class="control-label" for="ag_portal_paging_max_feeds">
											Max feeds:
											<span class="badge badge-info" id="ag_portal_paging_max_feeds_label">#prc.agSettings.ag_portal_paging_max_feeds#</span>
										</label>
										<div class="controls">
											<small>The number of feeds displayed on the feeds page before paging..</small><br />
											<strong class="margin10">10</strong>
											<input 	type="text"
												id="ag_portal_paging_max_feeds"
												name="ag_portal_paging_max_feeds"
												class="slider"
												data-slider-value="#prc.agSettings.ag_portal_paging_max_feeds#"
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
									<legend><i class="fa fa-hdd-o fa-lg"></i> Portal Caching</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_cache_enable",
											content="Enable portal caching:"
										)#
										<div><small>If enabled, portal content will be cached once it has been translated and rendered.</small></div>
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
							<div class="tab-pane" id="importing_options">
								<fieldset>
									<legend><i class="fa fa-download fa-lg"></i> Importing Options</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_import_interval",
											content="Import interval:"
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
											content="Start date:"
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
											field="ag_importing_default_creator",
											content="Default creator:"
										)#
										<div class="controls">
											<small>The account used during the automated feed import process.</small>
											<select name="ag_importing_default_creator" id="ag_importing_default_creator" class="form-control">
												<cfloop array="#prc.authors#" index="author">
													<option value="#author.getAuthorID()#"<cfif prc.agSettings.ag_importing_default_creator EQ author.getAuthorID() > selected="selected"</cfif>>#author.getName()#</option>
												</cfloop>
											</select>
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_secret_key",
											content="Secret key:"
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
											content="Import history limit:"
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
									<legend><i class="fa fa-filter fa-lg"></i> Keyword Filtering</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_match_any_filter",
											content="Contains any of these words/phrases:"
										)#
										<div class="controls">
											<small>
												Only feed items that contain any of these words/phrases in the title or body will be imported.
												Existing feed items that do not contain any of these words/phrases in the title or body will be deleted.
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
											content="Contains all of these words/phrases:"
										)#
										<div class="controls">
											<small>
												Only feed items that contain all of these words/phrases in the title or body will be imported.
												Existing feed items that do not contain all of these words/phrases in the title or body will be deleted.
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
											content="Contains none of these words/phrases:"
										)#
										<div class="controls">
											<small>
												Only feed items that do not contain any of these words/phrases in the title or body will be imported.
												Existing feed items that contain any of these words/phrases in the title or body will be deleted.
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
									<legend><i class="fa fa-list-ol fa-lg"></i> Item Limits</legend>
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
									<legend><i class="fa fa-image fa-lg"></i> Image Settings</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_image_import_enable",
											content="Import images:"
										)#
										<div>
											<small>
												If enabled, all images will be saved locally for each feed item when imported.
											</small>
										</div>
										<div class="controls">
											#html.checkbox(
												name="ag_importing_image_import_enable_toggle",
												data={ toggle: 'toggle', match: 'ag_importing_image_import_enable' },
												checked=prc.agSettings.ag_importing_image_import_enable
											)#
											#html.hiddenField(
												name="ag_importing_image_import_enable",
												value=prc.agSettings.ag_importing_image_import_enable
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_image_minimum_width",
											content="Minimum width:"
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
											content="Minimum height:"
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
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_featured_image_enable",
											content="Enable featured images:"
										)#
										<div>
											<small>
												If enabled, an image will be saved locally as the featured image for each feed item when imported.
											</small>
										</div>
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
											field="ag_importing_featured_image_behavior",
											content="Featured image behavior:"
										)#
										<div class="controls">
											<small>
												The default behavior when a feed item has no featured image.
											</small>
											#html.select(
												name="ag_importing_featured_image_behavior",
												options=prc.featuredImageOptions,
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_importing_featured_image_behavior,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_featured_image_default",
											content="Default featured image:"
										)#
										<div class="controls text-center">
											<a class="btn btn-primary" href="javascript:loadAssetChooser( 'defaultImageCallback' )">Select Image</a>
											<div class="<cfif !len( prc.agSettings.ag_importing_featured_image_default ) >hide</cfif> form-group" id="default_image_controls">
												<a class="btn btn-danger" href="javascript:cancelDefaultImage()">Clear Image</a>
												#html.hiddenField(
													name="ag_importing_featured_image_default",
													value=prc.agSettings.ag_importing_featured_image_default
												)#
												#html.hiddenField(
													name="ag_importing_featured_image_default_url",
													value=prc.agSettings.ag_importing_featured_image_default_url
												)#
												<div class="margin10">
													<cfif len( prc.agSettings.ag_importing_featured_image_default_url ) >
														<img id="default_image_preview" src="#prc.agSettings.ag_importing_featured_image_default_url#" class="img-thumbnail" height="75" />
													<cfelse>
														<img id="default_image_preview" class="img-thumbnail" height="75" />
													</cfif>
												</div>
											</div>
										</div>
									</div>
								</fieldset>
								<fieldset>
								</fieldset>
							</div>
							<div class="tab-pane" id="global_html">
								<fieldset>
									<legend><i class="fa fa-globe fa-lg"></i> Global HTML</legend>
									<p>These global HTML snippets will be rendered by your theme's layouts and views at the specific points specified below.</p>
									#html.textarea(
										name="ag_html_pre_index_display",
										label="Before portal index:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_index_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_index_display",
										label="After portal index:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_index_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_pre_feeds_display",
										label="Before feeds index:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_feeds_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_feeds_display",
										label="After feeds index:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_feeds_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_pre_feed_display",
										label="Before feed:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_feed_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_feed_display",
										label="After feed:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_feed_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_pre_archives_display",
										label="Before archives:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_archives_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_archives_display",
										label="After archives:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_archives_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_pre_sidebar_display",
										label="Before sidebar:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_sidebar_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_sidebar_display",
										label="After sidebar:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_sidebar_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
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
												class="form-control",
												maxlength="100"
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
											content="Feed generator:"
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
											content="Feed copyright:"
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
											content="Feed webmaster:"
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
								<br />#html.submitButton( value="Save Settings", class="btn btn-danger" )#
							</div>
						</div>
					</div>
				</div>
			</div>
		#html.endForm()#
	</div>
</div>
</cfoutput>