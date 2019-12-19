<cfoutput>
<div class="btn-group btn-group-xs">
	<button class="btn btn-sm btn-info" onclick="window.location.href='#event.buildLink( prc.xehFeeds )#';return false;">
		<i class="fa fa-reply"></i> Back
	</button>
	<button class="btn btn-sm btn-info dropdown-toggle" data-toggle="dropdown" title="Quick Actions">
		<span class="fa fa-cog"></span>
	</button>
	<ul class="dropdown-menu">
		<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN" ) >
			<li><a href="javascript:quickPublish( false )"><i class="fa fa-globe"></i> Publish</a></li>
		</cfif>
		<li><a href="javascript:quickPublish( true )"><i class="fa fa-eraser"></i> Publish as Draft</a></li>
		<li><a href="javascript:quickSave()"><i class="fa fa-save"></i> Quick Save</a></li>
		<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN,FEEDS_IMPORT" ) && prc.feed.isLoaded() >
			<li><a href="javascript:importFeed()"><i class="fa fa-rss"></i> Quick Import</a></li>
		</cfif>
		<cfif prc.feed.isLoaded() >
			<li><a href="#prc.agHelper.linkFeed( prc.feed )#" target="_blank"><i class="fa fa-eye"></i> Open In Site</a></li>
			<li><a href="#prc.feed.getWebsiteUrl()#" target="_blank"><i class="fa fa-external-link"></i> Visit Website</a></li>
		</cfif>
	</ul>
</div>
#html.startForm(
	action=prc.xehFeedSave,
	name="feedForm",
	novalidate="novalidate",
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
					<li role="presentation">
						<a href="##site" aria-controls="site" role="tab" data-toggle="tab">
							<i class="fa fa-cog"></i> Site Options
						</a>
					</li>
					<li role="presentation">
						<a href="##importing" aria-controls="importing" role="tab" data-toggle="tab">
							<i class="fa fa-download"></i> Importing
						</a>
					</li>
					<li role="presentation">
						<a href="##global_html" aria-controls="global_html" role="tab" data-toggle="tab">
							<i class="fa fa-globe"></i> Global HTML
						</a>
					</li>
					<li role="presentation">
						<a href="##seo" aria-controls="seo" role="tab" data-toggle="tab">
							<i class="fa fa-cloud"></i> SEO
						</a>
					</li>
					<cfif prc.feed.isLoaded() >
						<li role="presentation">
							<a href="##history" aria-controls="history" role="tab" data-toggle="tab">
								<i class="fa fa-history"></i> History
							</a>
						</li>
						<cfif prc.feed.hasFeedImport() >
							<li role="presentation">
								<a href="##imports" aria-controls="imports" role="tab" data-toggle="tab">
									<i class="fa fa-rss"></i> Imports
								</a>
							</li>
						</cfif>
					</cfif>
				</ul>
			</div>
			<div class="panel-body tab-content">
				<div role="tabpanel" class="tab-pane active" id="editor">
					#html.textfield(
						label="Title:",
						name="title",
						bind=prc.feed,
						maxlength="200",
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
							<i class="fa fa-cloud" title="Convert title to permalink" onclick="createPermalink()"></i>
							<small>#prc.agHelper.linkFeeds()#/</small>
						</label>
						<div class="controls">
							<div id='slugCheckErrors'></div>
							<div class="input-group">
								#html.textfield(
									name="slug",
									bind=prc.feed,
									maxlength="200",
									class="form-control",
									title="The URL permalink for this feed",
									disabled="#prc.feed.isLoaded() && prc.feed.getIsPublished() ? 'true' : 'false'#"
								)#
								<a title="Lock/Unlock Permalink" class="input-group-addon" href="javascript:void(0);" onclick="togglePermalink(); return false;" data-original-title="Lock/Unlock Permalink" data-container="body">
									<i id="togglePermalink" class="fa fa-#prc.feed.isLoaded() && prc.feed.getIsPublished() ? 'lock' : 'unlock'#"></i>
								</a>
							</div>
						</div>
					</div>
					<div class="form-group">
						<label for="feedUrl" class="control-label">
							Feed URL:
						</label>
						<p><small>The URL of the feed source.  Be sure to include the <code>http(s)://</code> prefix in the url.</small></p>
						<div class="controls">
							<div class="input-group">
								#html.inputfield(
									type="url",
									name="feedUrl",
									bind=prc.feed,
									maxlength="255",
									required="required",
									title="The url for this feed",
									class="form-control"
								)#
								<a id="validateFeed" title="Validate Feed URL" class="input-group-addon" href="javascript:void(0);" data-original-title="Validate Feed URL" data-container="body">
									<i class="fa fa-rss"></i>
								</a>
							</div>
						</div>
					</div>
					#html.textfield(
						label="Tag Line:",
						name="tagLine",
						bind=prc.feed,
						maxlength="255",
						title="The tag line for this feed",
						class="form-control",
						wrapper="div class=controls",
						labelClass="control-label",
						groupWrapper="div class=form-group"
					)#
					<div class="form-group">
						#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/content/markup", args={ content=prc.feed } )#
						#html.textarea(
							name="content",
							bind=prc.feed,
							rows="25",
							class="form-control"
						)#
					</div>
				</div>
				<div role="tabpanel" class="tab-pane" id="site">
					<fieldset>
						<legend><i class="fa fa-file-text-o fa-lg"></i> Feed Options</legend>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feeds_include_feed_items",
								content="Include Feed Items:"
							)#
							<p><small>If enabled, the latest feed items will also be displayed within the list of feeds for this feed.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feeds_include_feed_items",
									options=prc.includeFeedItemOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feeds_include_feed_items",""),
									class="form-control"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feeds_show_featured_image",
								content="Show Featured Image:"
							)#
							<p><small>If enabled, the feed's featured image will be displayed if one exists for this feed.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feeds_show_featured_image",
									options=prc.feedFeaturedImageOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feeds_show_featured_image",""),
									class="form-control"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feeds_show_website",
								content="Show Website Link:"
							)#
							<p><small>If enabled, a link to the feed's website will be displayed for this feed.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feeds_show_website",
									options=prc.showWebsiteOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feeds_show_website",""),
									class="form-control"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feeds_show_rss",
								content="Show RSS Link:"
							)#
							<p><small>If enabled, a link to the feed's rss will be displayed for this feed.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feeds_show_rss",
									options=prc.showRSSOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feeds_show_rss",""),
									class="form-control"
								)#
							</div>
						</div>
					</fieldset>
					<fieldset>
						<legend><i class="fa fa-file-o fa-lg"></i> Feed Item Options</legend>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_show_video_player",
								content="Show Video Player:"
							)#
							<p><small>If enabled, an inline video player will be displayed for videos.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feed_items_show_video_player",
									options=prc.showVideoOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feed_items_show_video_player",""),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_show_audio_player",
								content="Show Audio Player:"
							)#
							<p><small>If enabled, an inline audio player will be displayed for podcasts.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feed_items_show_audio_player",
									options=prc.showAudioOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feed_items_show_audio_player",""),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_show_source",
								content="Show Source:"
							)#
							<p><small>If enabled, the feed source will be displayed for each feed item.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feed_items_show_source",
									options=prc.showSourceOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feed_items_show_source",""),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_show_author",
								content="Show Author:"
							)#
							<p><small>If enabled, the author will be displayed for each feed item.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feed_items_show_author",
									options=prc.showAuthorOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feed_items_show_author",""),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_show_categories",
								content="Show Categories:"
							)#
							<p><small>If enabled, the categories will be displayed for each feed item.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feed_items_show_categories",
									options=prc.showCategoryOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feed_items_show_categories",""),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_show_excerpt",
								content="Show Excerpt:"
							)#
							<p><small>If enabled, an excerpt will be displayed for each feed item.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feed_items_show_excerpt",
									options=prc.showExcerptOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feed_items_show_excerpt",""),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_excerpt_limit",
								content="Excerpt Character Limit:"
							)#
							<p><small>The maximum number of characters to display in the feed item excerpt.</small></p>
							<div class="controls">
								#html.inputField(
									name="settings_feed_items_excerpt_limit",
									type="number",
									value=prc.feed.getSetting("feed_items_excerpt_limit",""),
									class="form-control counter",
									placeholder="Use the default setting - #prc.agSettings.feed_items_excerpt_limit#",
									min="0"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_excerpt_ending",
								content="Excerpt Ending:"
							)#
							<p><small>The ending text displayed when the length of the excerpt is larger than the character limit.</small></p>
							<div class="controls">
								#html.inputField(
									name="settings_feed_items_excerpt_ending",
									value=prc.feed.getSetting("feed_items_excerpt_ending",""),
									class="form-control counter",
									placeholder="Use the default setting - #prc.agSettings.feed_items_excerpt_ending#"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_show_read_more",
								content="Show Read More:"
							)#
							<p><small>If enabled, a link to the feed item will be displayed after the feed item excerpt.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feed_items_show_read_more",
									options=prc.showReadMoreOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feed_items_show_read_more",""),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_read_more_text",
								content="Read More Text:"
							)#
							<p><small>The text used when the read more link is enabled.</small></p>
							<div class="controls">
								#html.inputField(
									name="settings_feed_items_read_more_text",
									value=prc.feed.getSetting("feed_items_read_more_text",""),
									class="form-control counter",
									placeholder="Use the default setting - #prc.agSettings.feed_items_read_more_text#"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="linkBehavior",
								content="Link Behavior:"
							)#
							<p><small>The default behavior when clicking on a feed item.</small></p>
							<div class="controls">
								#html.select(
									name="settings_linkBehavior",
									id="linkBehavior",
									options=prc.linkOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getLinkBehavior(),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_open_new_window",
								content="Open New Window:"
							)#
							<p><small>If enabled, links to feed items will be opened in a new window (tab).</small></p>
							<div class="controls">
								#html.select(
									name="settings_feed_items_open_new_window",
									options=prc.openWindowOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feed_items_open_new_window",""),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="settings_feed_items_show_featured_image",
								content="Show Featured Image:"
							)#
							<p><small>If enabled, the feed item's featured image will be displayed if one exists.</small></p>
							<div class="controls">
								#html.select(
									name="settings_feed_items_show_featured_image",
									options=prc.showFeaturedImageOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getSetting("feed_items_show_featured_image",""),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="featuredImageBehavior",
								content="Featured Image Behavior:"
							)#
							<p><small>The default behavior when a feed item has no featured image.</small></p>
							<div class="controls">
								#html.select(
									name="settings_featuredImageBehavior",
									id="featuredImageBehavior",
									options=prc.featuredImageOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getFeaturedImageBehavior(),
									class="form-control"
								)#
							</div>
						</div>
					</fieldset>
					<fieldset>
						<legend><i class="fa fa-copy fa-lg"></i> Paging Options</legend>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="pagingMaxItems",
								content="Max Feed Items:"
							)#
							<p><small>The number of feed items displayed on the feed page before paging.</small></p>
							<div class="controls">
								#html.inputField(
									name="settings_pagingMaxItems",
									id="pagingMaxItems",
									type="number",
									value=prc.feed.getPagingMaxItems(),
									class="form-control counter",
									placeholder="Use the default setting - #prc.agSettings.paging_max_feed_items#",
									min="0"
								)#
							</div>
						</div>
					</fieldset>
				</div>
				<div role="tabpanel" class="tab-pane" id="importing">
					<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN" ) >
						<fieldset>
							<legend><i class="fa fa-download fa-lg"></i> Importing Options</legend>
							<div class="form-group">
								#html.label(
									class="control-label",
									field="isActive",
									content="Import State"
								)#
								<p><small>When active, this feed will be included in the automated feed import process.</small></p>
								<div class="controls">
									#html.select(
										name="isActive",
										options=[{name="Active",value="true"},{name="Paused",value="false"}],
										column="value",
										nameColumn="name",
										selectedValue=prc.feed.getIsActive(),
										class="form-control input-sm"
									)#
								</div>
							</div>
							<div class="form-group">
								#html.label(
									class="control-label",
									field="startDate",
									content="Start Date"
								)#
								<p><small>The date and time to begin importing this feed.</small></p>
								<div class="controls row">
									<div class="col-md-6">
										<div class="input-group">
											#html.inputField(
												size="9",
												name="startDate",
												value=prc.feed.getStartDateForEditor(),
												class="form-control datepicker",
												placeholder="Immediately"
											)#
											<span class="input-group-addon">
												<span class="fa fa-calendar"></span>
											</span>
										</div>
									</div>
									<cfscript>
										theTime = "";
										hour = prc.ckHelper.ckHour( prc.feed.getStartDateForEditor( showTime=true ) );
										minute = prc.ckHelper.ckMinute( prc.feed.getStartDateForEditor( showTime=true ) );
										if ( len( hour ) && len( minute ) ) {
											theTime = hour & ":" & minute;
										}
									</cfscript>
									<div class="col-md-6">
										<div class="input-group clockpicker" data-placement="left" data-align="top" data-autoclose="true">
											<input type="text" class="form-control inline" value="#theTime#" name="startTime" />
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
									field="stopDate",
									content="Stop Date"
								)#
								<p><small>The date and time to stop importing this feed.</small></p>
								<div class="controls row">
									<div class="col-md-6">
										<div class="input-group">
											#html.inputField(
												size="9",
												name="stopDate",
												value=prc.feed.getStopDateForEditor(),
												class="form-control datepicker",
												placeholder="Never"
											)#
											<span class="input-group-addon">
												<span class="fa fa-calendar"></span>
											</span>
										</div>
									</div>
									<cfscript>
										theTime = "";
										hour = prc.ckHelper.ckHour( prc.feed.getStopDateForEditor( showTime=true ) );
										minute = prc.ckHelper.ckMinute( prc.feed.getStopDateForEditor( showTime=true ) );
										if ( len( hour ) && len( minute ) ) {
											theTime = hour & ":" & minute;
										}
									</cfscript>
									<div class="col-md-6">
										<div class="input-group clockpicker" data-placement="left" data-align="top" data-autoclose="true">
											<input type="text" class="form-control inline" value="#theTime#" name="stopTime" />
											<span class="input-group-addon">
												<span class="fa fa-clock-o"></span>
											</span>
										</div>
									</div>
								</div>
							</div>
						</fieldset>
					</cfif>
					<fieldset>
						<legend><i class="fa fa-file-o fa-lg"></i> Feed Item Defaults</legend>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="itemStatus",
								content="Item Status"
							)#
							<p><small>The status used for imported feed items.</small></p>
							<div class="controls">
								#html.select(
									name="settings_itemStatus",
									id="itemStatus",
									options=prc.itemStatuses,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getItemStatus(),
									class="form-control input-sm"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="ItemPubDate",
								content="Published Date:"
							)#
							<p><small>The value used as the published date for imported feed items.</small></p>
							<div class="controls">
								#html.select(
									name="settings_itemPubDate",
									id="itemPubDate",
									options=prc.itemPubDates,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getItemPubDate(),
									class="form-control input-sm"
								)#
							</div>
						</div>
					</fieldset>
					<fieldset>
						<legend><i class="fa fa-list-ol fa-lg"></i> Feed Item Limits</legend>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="maxAge",
								content="Limit items by age:"
							)#
							<p><small>The maximum age allowed for feed items.  Existing feed items will be deleted once they exceed this age limit.</small></p>
							<div class="controls row">
								<div class="col-sm-6">
									#html.inputField(
										name="settings_maxAge",
										id="maxAge",
										type="number",
										value=prc.feed.getMaxAge(),
										class="form-control counter",
										placeholder="No limit",
										min="0"
									)#
								</div>
								<div class="col-sm-6">
									#html.select(
										name="settings_maxAgeUnit",
										id="maxAgeUnit",
										options=prc.limitUnits,
										selectedValue=prc.feed.getMaxAgeUnit(),
										class="form-control"
									)#
								</div>
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="maxItems",
								content="Limit items by number:"
							)#
							<p><small>The maximum number of feed items to keep per feed.  When feeds are imported and this limit is exceeded, the oldest feed items will be deleted first to make room for the new ones.</small></p>
							<div class="controls">
								#html.inputField(
									name="settings_maxItems",
									id="maxItems",
									type="number",
									value=prc.feed.getMaxItems(),
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
								field="matchAnyFilter",
								content="Contains any of these keywords:"
							)#
							<p><small>Only feed items that contain any of these keywords in the title or body will be imported.  Existing feed items that do not contain any of these keywords in the title or body will be deleted.</small></p>
							<div class="controls">
								#html.textArea(
									name="settings_matchAnyFilter",
									id="matchAnyFilter",
									value=prc.feed.getMatchAnyFilter(),
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
								field="matchAllFilter",
								content="Contains all of these keywords:"
							)#
							<p><small>Only feed items that contain all of these keywords in the title or body will be imported.  Existing feed items that do not contain all of these keywords in the title or body will be deleted.</small></p>
							<div class="controls">
								#html.textArea(
									name="settings_matchAllFilter",
									id="matchAllFilter",
									value=prc.feed.getMatchAllFilter(),
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
								field="matchNoneFilter",
								content="Contains none of these keywords:"
							)#
							<p><small>Only feed items that do not contain any of these keywords in the title or body will be imported.  Existing feed items that contain any of these keywords in the title or body will be deleted.</small></p>
							<div class="controls">
								#html.textArea(
									name="settings_matchNoneFilter",
									id="matchNoneFilter",
									value=prc.feed.getMatchNoneFilter(),
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
								field="importFeaturedImages",
								content="Import Featured Images:"
							)#
							<p><small>If enabled, an image will be saved locally as the featured image for each feed item when imported.</small></p>
							<div class="controls">
								#html.select(
									name="settings_importFeaturedImages",
									id="importFeaturedImages",
									options=prc.importFeaturedImageOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getImportFeaturedImages(),
									class="form-control"
								)#
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="importAllImages",
								content="Import All Images:"
							)#
							<p><small>If enabled, all images will be saved locally for each feed item when imported.</small></p>
							<div class="controls">
								#html.select(
									name="settings_importAllImages",
									id="importAllImages",
									options=prc.importImageOptions,
									column="value",
									nameColumn="name",
									selectedValue=prc.feed.getImportAllImages(),
									class="form-control"
								)#
							</div>
						</div>
					</fieldset>
					<fieldset>
						<legend><i class="fa fa-tags fa-lg"></i> Taxonomies</legend>
						<p><small>Taxonomies are used to automatically assign categories to feed items.  The taxonomies defined here will be used in addition to taxonomies defined in the general settings.</small></p>
						<div id="taxonomies">
							<cfloop from="1" to="#arrayLen( prc.feed.getTaxonomies() )#" index="idx">
								<cfset taxonomy = prc.feed.getTaxonomies()[idx] />
								<div class="taxonomy">
									<div class="form-group">
										#html.label(
											class="control-label",
											field="taxonomies_#idx#_categories",
											content="Categories:"
										)#
										<p><small>Assign the following categories to feed items using the matching method below.</small></p>
										<div class="controls">
											<div class="input-group">
												#html.hiddenField( name="taxonomies_#idx#_categories", value="" )#
												#html.select(
													name="taxonomies_#idx#_categories",
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
											field="taxonomies_#idx#_method",
											content="Matching Method:"
										)#
										<p><small>Use the following method when matching feed items to the above categories.</small></p>
										<div class="controls">
											#html.select(
												name="taxonomies_#idx#_method",
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
											field="taxonomies_#idx#_keywords",
											content="Keywords:"
										)#
										<p><small>Use the following keywords when matching feed items to the above categories.</small></p>
										<div class="controls">
											#html.textArea(
												name="taxonomies_#idx#_keywords",
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
				<div role="tabpanel" class="tab-pane" id="global_html">
					<fieldset>
						<legend><i class="fa fa-globe fa-lg"></i> Global HTML</legend>
						<p><small>These HTML snippets will be rendered by your theme's layouts and views at the specific points specified below.</small></p>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="preFeedDisplay",
								content="Before Feed:"
							)#
							<div class="controls">
								#html.textarea(
									name="settings_preFeedDisplay",
									id="preFeedDisplay",
									value=prc.feed.getPreFeedDisplay(),
									rows="6",
									class="form-control"
								)#
								<small>
									You may use the following placeholders in the feed snippet:<br />
									<table width="100%">
										<tbody>
											<tr>
												<td title="The feed title.">@feed_title@</td>
												<td title="The local feed URL.">@feed_url@</td>
												<td title="The remote rss feed URL.">@feed_rss_url@</td>
												<td title="The URL of the website providing the feed.">@feed_website_url@</td>
											</tr>
										</tbody>
									</table>
								</small>
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="postFeedDisplay",
								content="After Feed:"
							)#
							<div class="controls">
								#html.textarea(
									name="settings_postFeedDisplay",
									id="postFeedDisplay",
									value=prc.feed.getPostFeedDisplay(),
									rows="6",
									class="form-control"
								)#
								<small>
									You may use the following placeholders in the feed snippet:<br />
									<table width="100%">
										<tbody>
											<tr>
												<td title="The feed title.">@feed_title@</td>
												<td title="The local feed URL.">@feed_url@</td>
												<td title="The remote rss feed URL.">@feed_rss_url@</td>
												<td title="The URL of the website providing the feed.">@feed_website_url@</td>
											</tr>
										</tbody>
									</table>
								</small>
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="preFeedItemDisplay",
								content="Before Feed Item:"
							)#
							<div class="controls">
								#html.textarea(
									name="settings_preFeedItemDisplay",
									id="preFeedItemDisplay",
									value=prc.feed.getPreFeedItemDisplay(),
									rows="6",
									class="form-control"
								)#
								<small>
									You may use the following placeholders in the feed item snippet:<br />
									<table width="100%">
										<tbody>
											<tr>
												<td title="The feed title.">@feed_title@</td>
												<td title="The local feed URL.">@feed_url@</td>
												<td title="The remote rss feed URL.">@feed_rss_url@</td>
												<td title="The URL of the website providing the feed.">@feed_website_url@</td>
											</tr>
											<tr>
												<td title="The feed item title.">@feed_item_title@</td>
												<td title="The local feed item URL.">@feed_item_url@</td>
												<td title="The remote original feed item URL.">@feed_item_original_url@</td>
												<td title="The feed item imported date.">@feed_item_import_date@</td>
											</tr>
											<tr>
												<td title="The feed item published date.">@feed_item_publish_date@</td>
												<td title="The feed item author name.">@feed_item_author_name@</td>
											</tr>
										</tbody>
									</table>
								</small>
							</div>
						</div>
						<div class="form-group">
							#html.label(
								class="control-label",
								field="postFeedItemDisplay",
								content="After Feed Item:"
							)#
							<div class="controls">
								#html.textarea(
									name="settings_postFeedItemDisplay",
									id="postFeedItemDisplay",
									value=prc.feed.getPostFeedItemDisplay(),
									rows="6",
									class="form-control"
								)#
								<small>
									You may use the following placeholders in the feed item snippet:<br />
									<table width="100%">
										<tbody>
											<tr>
												<td title="The feed title.">@feed_title@</td>
												<td title="The local feed URL.">@feed_url@</td>
												<td title="The remote rss feed URL.">@feed_rss_url@</td>
												<td title="The URL of the website providing the feed.">@feed_website_url@</td>
											</tr>
											<tr>
												<td title="The feed item title.">@feed_item_title@</td>
												<td title="The local feed item URL.">@feed_item_url@</td>
												<td title="The remote original feed item URL.">@feed_item_original_url@</td>
												<td title="The feed item imported date.">@feed_item_import_date@</td>
											</tr>
											<tr>
												<td title="The feed item published date.">@feed_item_publish_date@</td>
												<td title="The feed item author name.">@feed_item_author_name@</td>
											</tr>
										</tbody>
									</table>
								</small>
							</div>
						</div>
					</fieldset>
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
				<cfif prc.feed.isLoaded() >
					<div role="tabpanel" class="tab-pane" id="history">
						#prc.versionsViewlet#
					</div>
					<cfif prc.feed.hasFeedImport() >
						<div role="tabpanel" class="tab-pane" id="imports">
							<p>
								Below are the most recent feed imports.
								You can view the import record by clicking the view icon.
								The current import history limit of <strong>#prc.agSettings.importing_max_feed_imports#</strong> records can be changed in the <a href="#event.buildLink(prc.xehAggregatorSettings)#">settings</a>.
							</p>
							<table id="feedImportsTable" width="100%" class="table table-hover table-condensed table-striped" border="0">
								<thead>
									<tr>
										<th width="160" class="text-center">Date</th>
										<th width="130" class="text-center">Item Count</th>
										<th width="130" class="text-center">Imported Count</th>
										<th width="130" class="text-center">Failed</th>
										<th class="text-left">Imported By</th>
										<th width="100" class="text-center">Actions</th>
									</tr>
								</thead>
								<tbody>
									<cfloop array="#prc.feed.getFeedImports()#" index="feedImport">
										<tr id="import_row_#feedImport.getFeedImportID()#" data-feedImportID="#feedImport.getFeedImportID()#"<cfif feedImport.failed() > class="danger" title="A fatal error occurred."</cfif>>
											<td class="text-center">#feedImport.getDisplayImportedDate()#</td>
											<td class="text-center">#feedImport.getItemCount()#</td>
											<td class="text-center">#feedImport.getImportedCount()#</td>
											<td class="text-center">#YesNoFormat(feedImport.failed())#</td>
											<td><a href="mailto:#feedImport.getImporter().getEmail()#">#feedImport.getImporter().getName()#</a></td>
											<td class="text-center">
												<a href="javascript:openRemoteModal('#event.buildLink(prc.xehFeedImportView)#/feedImportID/#feedImport.getFeedImportID()#');" title="View Feed Import">
													<i class="fa fa-eye fa-lg"></i>
												</a>
												<a href="javascript:removeImport('#feedImport.getFeedImportID()#')" title="Remove Feed Import" class="confirmIt"
													data-title="<i class='fa fa-trash-o'></i> Remove Feed Import"
													data-message="Do you really want to remove this feed import?">
													<i class="fa fa-trash-o fa-lg" id="import_delete_#feedImport.getFeedImportID()#"></i>
												</a>
											</td>
										</tr>
									</cfloop>
								</tbody>
							</table>
						</div>
					</cfif>
				</cfif>
			</div>
			#announceInterception( "aggregator_feedEditorInBody" )#
		</div>
		#announceInterception( "aggregator_feedEditorFooter" )#
	</div>
	<div class="col-md-4" id="main-content-sidebar">
		<div class="panel panel-primary">
			<div class="panel-heading">
				<h3 class="panel-title"><i class="fa fa-info-circle"></i> Feed Details</h3>
			</div>
			<div class="panel-body">
				#renderExternalView( view="/contentbox/modules/contentbox-admin/views/_tags/content/publishing", args={ content=prc.feed } )#
				<div id="accordion" class="panel-group accordion" data-stateful="feed-sidebar">
					<cfif prc.feed.isLoaded() >
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a class="accordion-toggle" data-toggle="collapse" data-parent="##accordion" href="##feedInfo">
										<i class="fa fa-info-circle fa-lg"></i> Info
									</a>
								</h4>
							</div>
							<div id="feedInfo" class="panel-collapse collapse in">
								<div class="panel-body">
									<table class="table table-hover table-condensed table-striped size12">
										<tr>
											<th class="col-md-4">Last Imported:</th>
											<td class="col-md-8">
												<cfif isDate( prc.feed.getImportedDate() ) >
													#prc.feed.getDisplayImportedDate()#
												<cfelse>
													Never imported
												</cfif>
											</td>
										</tr>
										<cfif prc.feed.hasChild() >
											<tr>
												<th class="col-md-4">Feed Type:</th>
												<td class="col-md-8">#prc.feed.getFeedType()#</td>
											</tr>
											<tr>
												<th class="col-md-4">Feed Items:</th>
												<td class="col-md-8">
													<a href="#prc.agHelper.linkFeedItemsAdmin( prc.feed.getContentID() )#">#prc.feed.getNumberOfChildren()#</a>
												</td>
											</tr>
											<cfif val( prc.feed.getNumberOfArticles() ) >
												<tr>
													<th class="col-md-4">Articles:</th>
													<td class="col-md-8">
														<a href="#prc.agHelper.linkFeedItemsAdmin( prc.feed.getContentID(), "article" )#">#prc.feed.getNumberOfArticles()#</a>
													</td>
												</tr>
											</cfif>
											<cfif val( prc.feed.getNumberOfPodcasts() ) >
												<tr>
													<th class="col-md-4">Podcasts:</th>
													<td class="col-md-8">
														<a href="#prc.agHelper.linkFeedItemsAdmin( prc.feed.getContentID(), "podcast" )#">#prc.feed.getNumberOfPodcasts()#</a>
													</td>
												</tr>
											</cfif>
											<cfif val( prc.feed.getNumberOfVideos() ) >
												<tr>
													<th class="col-md-4">Videos:</th>
													<td class="col-md-8">
														<a href="#prc.agHelper.linkFeedItemsAdmin( prc.feed.getContentID(), "video" )#">#prc.feed.getNumberOfVideos()#</a>
													</td>
												</tr>
											</cfif>
										</cfif>
										<tr>
											<th class="col-md-4">Created By:</th>
											<td class="col-md-8">
												<a href="mailto:#prc.feed.getCreatorEmail()#">#prc.feed.getCreatorName()#</a>
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Created On:</th>
											<td class="col-md-8">
												#prc.feed.getDisplayCreatedDate()#
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Published On:</th>
											<td class="col-md-8">
												#prc.feed.getDisplayPublishedDate()#
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Version:</th>
											<td class="col-md-8">
												#prc.feed.getActiveContent().getVersion()#
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Last Edit By:</th>
											<td class="col-md-8">
												<a href="mailto:#prc.feed.getAuthorEmail()#">#prc.feed.getAuthorName()#</a>
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Last Edit On:</th>
											<td class="col-md-8">
												#prc.feed.getActiveContent().getDisplayCreatedDate()#
											</td>
										</tr>
										<tr>
											<th class="col-md-4">Views:</th>
											<td class="col-md-8">
												#prc.feed.getNumberOfHits()#
											</td>
										</tr>
									</table>
								</div>
							</div>
						</div>
						<div class="panel panel-default">
							<div class="panel-heading">
								<h4 class="panel-title">
									<a class="accordion-toggle collapsed" data-toggle="collapse" data-parent="##accordion" href="##preview">
										<i class="fa fa-rss fa-lg"></i> Feed Preview
									</a>
								</h4>
							</div>
							<div id="preview" class="panel-collapse collapse">
								<div class="panel-body">
									<cfif prc.feed.hasFeedItem() >
										<table class="table table-condensed table-hover table-striped" width="100%">
											<thead>
												<tr>
													<th>Title</th>
													<th width="100" class="text-center">Date</th>
												</tr>
											</thead>
											<tbody>
												<cfloop array="#prc.feedItems#" index="feedItem">
													<tr
														<cfif feedItem.isExpired() >
															class="danger"
														<cfelseif feedItem.isPublishedInFuture() >
															class="success"
														<cfelseif !feedItem.isContentPublished() >
															class="warning"
														<cfelseif !feedItem.getNumberOfActiveVersions() >
															class="danger" title="No active content versions found, please publish one."
														</cfif>
													>
														<td>
															<cfif prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN,FEED_ITEMS_EDITOR" ) >
																<a href="#event.buildLink( prc.xehFeedItemEditor )#/contentID/#feedItem.getContentID()#">#feedItem.getTitle()#</a>
															<cfelse>
																#feedItem.getTitle()#
															</cfif>
														</td>
														<td class="text-center">#feedItem.getDisplayPublishedDate()#</td>
													</tr>
												</cfloop>
											</tbody>
										</table>
									<cfelse>
										<p>No items imported.</p>
									</cfif>
								</div>
							</div>
						</div>
					</cfif>
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
										#html.textField(
											name="featuredImage",
											bind=prc.feed,
											class="form-control",
											readonly=true
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
					#announceInterception( "aggregator_feedEditorSidebarAccordion" )#
				</div>
				#announceInterception( "aggregator_feedEditorSidebar" )#
			</div>
		</div>
		#renderview( view="sidebar/help", module="contentbox-aggregator" )#
		#announceInterception( "aggregator_feedEditorSidebarFooter" )#
	</div>
</div>
#html.endForm()#
<div id="taxonomyTemplate" style="display:none;">
	<div class="taxonomy">
		<div class="form-group">
			#html.label(
				class="control-label",
				field="taxonomies_templateIndex_categories",
				content="Categories:"
			)#
			<p><small>Assign the following categories to feed items using the matching method below.</small></p>
			<div class="controls">
				#html.hiddenField( name="taxonomies_templateIndex_categories", value="" )#
				#html.select(
					name="taxonomies_templateIndex_categories",
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
				field="taxonomies_templateIndex_method",
				content="Matching Method:"
			)#
			<p><small>Use the following method when matching feed items to the above categories.</small></p>
			<div class="controls">
				#html.select(
					name="taxonomies_templateIndex_method",
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
				field="taxonomies_templateIndex_keywords",
				content="Keywords:"
			)#
			<p><small>Use the following keywords when matching feed items to the above categories.</small></p>
			<div class="controls">
				#html.textArea(
					name="taxonomies_templateIndex_keywords",
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