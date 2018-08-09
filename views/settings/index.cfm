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
							<li role="presentation" class="active">
								<a href="##portal" data-toggle="tab">
									<i class="fa fa-newspaper-o fa-lg"></i> Portal
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
							<div class="tab-pane active" id="portal">
								<fieldset>
									<legend><i class="fa fa-newspaper-o fa-lg"></i> Portal Options</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_name",
											content="Portal Name:"
										)#
										<div class="controls">
											<small>The name used for the portal.</small>
											#html.textField(
												name="ag_portal_name",
												value=prc.agSettings.ag_portal_name,
												class="form-control",
												maxlength="100"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_tagline",
											content="Portal Tag Line:"
										)#
										<div class="controls">
											<small>The tag line used for the portal.</small>
											#html.textField(
												name="ag_portal_tagline",
												value=prc.agSettings.ag_portal_tagline,
												class="form-control",
												maxlength="100"
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
											field="ag_portal_description",
											content="Portal Description:"
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
											content="Portal Keywords:"
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
											content="Feeds Page Title:"
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
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-file-text-o fa-lg"></i> Item Options</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_item_link_behavior",
											content="Link Behavior:"
										)#
										<div class="controls">
											<small>The default behavior when clicking on a feed item.</small>
											#html.select(
												name="ag_portal_item_link_behavior",
												options=prc.linkOptions,
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_portal_item_link_behavior,
												class="form-control input-sm"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_item_featured_image_behavior",
											content="Featured Image Behavior:"
										)#
										<div class="controls">
											<small>The default behavior when a feed item does not have a featured image.</small>
											#html.select(
												name="ag_portal_item_featured_image_behavior",
												options=prc.featuredImageOptions,
												column="value",
												nameColumn="name",
												selectedValue=prc.agSettings.ag_portal_item_featured_image_behavior,
												class="form-control"
											)#
										</div>
									</div>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_portal_item_featured_image_default",
											content="Default Featured Image:"
										)#
										<div><small class="text-left">Use the tool below to select a default featured image.</small></div>
										<div class="controls text-center">
											<a class="btn btn-primary" href="javascript:loadAssetChooser( 'defaultImageCallback' )">Select Image</a>
											<div class="<cfif !len( prc.agSettings.ag_portal_item_featured_image_default ) >hide</cfif> form-group" id="default_image_controls">
												<a class="btn btn-danger" href="javascript:cancelDefaultImage()">Clear Image</a>
												#html.hiddenField(
													name="ag_portal_item_featured_image_default",
													value=prc.agSettings.ag_portal_item_featured_image_default
												)#
												#html.hiddenField(
													name="ag_portal_item_featured_image_default_url",
													value=prc.agSettings.ag_portal_item_featured_image_default_url
												)#
												<div class="margin10">
													<cfif len( prc.agSettings.ag_portal_item_featured_image_default_url ) >
														<img id="default_image_preview" src="#prc.agSettings.ag_portal_item_featured_image_default_url#" class="img-thumbnail" height="75" />
													<cfelse>
														<img id="default_image_preview" class="img-thumbnail" height="75" />
													</cfif>
												</div>
											</div>
										</div>
									</div>
								</fieldset>
								<fieldset>
									<legend><i class="fa fa-copy fa-lg"></i> Paging Options</legend>
									<div class="form-group">
										<label class="control-label" for="ag_portal_paging_max_items">
											Max Feed Items:
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
											Max Feeds:
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
											content="Enable Portal Caching:"
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
											content="Portal Cache Provider:"
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
											Portal Cache Timeouts:
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
											Portal Cache Idle Timeouts:
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
							<div class="tab-pane" id="importing">
								<fieldset>
									<legend><i class="fa fa-download fa-lg"></i> Importing Options</legend>
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
									<legend><i class="fa fa-file-text-o fa-lg"></i> Item Defaults</legend>
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
									<legend><i class="fa fa-filter fa-lg"></i> Keyword Filtering</legend>
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
									<legend><i class="fa fa-image fa-lg"></i> Image Settings</legend>
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_importing_featured_image_enable",
											content="Import Featured Images:"
										)#
										<div>
											<small>If enabled, an image will be saved locally as the featured image for each feed item when imported.</small>
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
											field="ag_importing_image_import_enable",
											content="Import All Images:"
										)#
										<div>
											<small>If enabled, all images will be saved locally for each feed item when imported.</small>
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
									<legend><i class="fa fa-tags fa-lg"></i> Taxonomies</legend>
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
														<small>Assign the following categories to feed items using the matching method and keywords below.</small>
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
															<a title="Remove Taxonomy" class="input-group-addon btn btn-danger removeTaxonomy" href="javascript:void(0);" data-original-title="Remove Taxonomy" data-container="body">
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
															class="form-control input-sm"
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
															class="form-control",
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
									<legend><i class="fa fa-globe fa-lg"></i> Global HTML</legend>
									<p>These global HTML snippets will be rendered by your theme's layouts and views at the specific points specified below.</p>
									#html.textarea(
										name="ag_html_pre_index_display",
										label="Before Portal Index:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_pre_index_display,
										wrapper="div class=controls",
										labelClass="control-label",
										groupWrapper="div class=form-group"
									)#
									#html.textarea(
										name="ag_html_post_index_display",
										label="After Portal Index:",
										rows="6",
										class="form-control",
										value=prc.agSettings.ag_html_post_index_display,
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
									<legend><i class="fa fa-rss fa-lg"></i> RSS Feed Options</legend>
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
									<div class="form-group">
										#html.label(
											class="control-label",
											field="ag_rss_content_enable",
											content="Include Item Content:"
										)#
										<div><small>If enabled, the feed item content as well as description will be included in the rss feed.</small></div>
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
									<legend><i class="fa fa-hdd-o fa-lg"></i> RSS Caching</legend>
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
<div id="taxonomyTemplate" style="display:none;">
	<div class="taxonomy">
		<div class="form-group">
			#html.label(
				class="control-label",
				field="ag_importing_taxonomies.templateIndex.categories",
				content="Categories:"
			)#
			<div class="controls">
				<small>Assign the following categories to feed items using the matching method and keywords below.</small><br/>
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
					class="form-control input-sm"
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
					class="form-control",
					placeholder="Comma delimited list of words or phrases",
					maxlength="255"
				)#
			</div>
		</div>
		<hr />
	</div>
</div>
</cfoutput>