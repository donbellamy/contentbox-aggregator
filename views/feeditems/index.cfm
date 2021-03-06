<cfoutput>
<div class="row">
	<div class="col-md-12">
		<h1 class="h1">
			<i class="fa fa-newspaper-o fa-lg"></i>
			RSS Aggregator - Feed Items
		</h1>
	</div>
</div>
<div class="row">
	<div class="col-md-9">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
		#html.startForm( name="feedItemForm", action=prc.xehFeedItemRemove )#
			#html.hiddenField( name="contentStatus", value="" )#
			#html.hiddenField( name="contentID", value="" )#
			#html.hiddenField( name="feed", id="feedFilter", value="#rc.feed#" )#
			#html.hiddenField( name="category", id="categoryFilter", value="#rc.category#" )#
			#html.hiddenField( name="status", id="statusFilter", value="#rc.status#" )#
			#html.hiddenField( name="type", id="typeFilter", value="#rc.type#" )#
			<div class="panel panel-default">
				<div class="panel-heading">
					<div class="row">
						<div class="col-md-6">
							<div class="form-group form-inline no-margin">
								#html.textField(
									name="search",
									class="form-control",
									placeholder="Quick Search",
									value="#rc.search#"
								)#
							</div>
						</div>
						<div class="col-md-6">
							<div class="pull-right">
								<div class="btn-group btn-group-sm">
									<button class="btn dropdown-toggle btn-info" data-toggle="dropdown">
										Bulk Actions <span class="caret"></span>
									</button>
									<ul class="dropdown-menu">
										<cfif prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN" ) >
											<li>
												<a href="javascript:remove();"
													class="confirmIt"
													data-title="Delete Selected Feed Items?"
													data-message="This will delete the feed items, are you sure?">
													<i class="fa fa-trash-o"></i> Delete Selected
												</a>
											</li>
											<li><a href="javascript:changeStatus('draft');"><i class="fa fa-close"></i> Draft Selected</a></li>
											<li><a href="javascript:changeStatus('publish');"><i class="fa fa-check"></i> Publish Selected</a></li>
											<li>
												<a href="javascript:blacklist();"
													class="confirmIt"
													data-title="Blacklist Selected Feed Items?"
													data-message="This will delete the feed items and prevent them from being imported, are you sure?">
													<i class="fa fa-ban"></i> Blacklist Selected
												</a>
											</li>
											<li><a href="javascript:resetHits();"><i class="fa fa-refresh"></i> Reset Hits Selected</a></li>
											<li><a href="javascript:categoryChooser();"><i class="fa fa-tags"></i> Assign Categories</a></li>
											<li><a href="javascript:saveAsEntry();"><i class="fa fa-copy"></i> Save as Entry</a></li>
										</cfif>
										<li><a href="javascript:contentShowAll();"><i class="fa fa-list"></i> Show All</a></li>
									</ul>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div class="panel-body">
					<div id="feedItemsTableContainer">
						<p class="text-center"><i id="feedItemLoader" class="fa fa-spinner fa-spin fa-lg icon-4x"></i></p>
					</div>
				</div>
			</div>
		#html.endForm()#
	</div>
	<div class="col-md-3">
		<div class="panel panel-primary">
			<div class="panel-heading">
				<h3 class="panel-title"><i class="fa fa-filter"></i> Filters</h3>
			</div>
			<div class="panel-body">
				<div id="filterBox">
					#html.startForm( name="feedItemFilterForm", action=prc.xehFeedItemSearch, class="form-vertical", role="form" )#
						<div class="form-group">
							<label for="feed" class="control-label">Feeds:</label>
							<select name="feed" id="feed" class="form-control input-sm">
								<option value=""<cfif !len( rc.feed ) > selected="selected"</cfif>>All Feeds</option>
								<cfloop array="#prc.feeds#" index="feed">
									<option value="#feed.getContentID()#"<cfif rc.feed EQ feed.getContentID() > selected="selected"</cfif>>#feed.getTitle()#</option>
								</cfloop>
							</select>
						</div>
						<div class="form-group">
							<label for="category" class="control-label">Categories:</label>
							<div class="controls">
								<select name="category" id="category" class="form-control input-sm valid">
									<option value=""<cfif !len( rc.category ) > selected="selected"</cfif>>All Categories</option>
									<option value="none"<cfif rc.category IS "none" > selected="selected"</cfif>>Uncategorized</option>
									<cfloop array="#prc.feedItemCategories#" index="category">
										<option value="#category.getCategoryID()#"<cfif rc.category EQ category.getCategoryID() > selected="selected"</cfif>>#category.getCategory()#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div class="form-group">
							<label for="status" class="control-label">Status:</label>
							<div class="controls">
								<select name="status" id="status" class="form-control input-sm valid">
									<option value=""<cfif !len( rc.status ) > selected="selected"</cfif>>Any Status</option>
									<option value="published"<cfif rc.status IS "published" > selected="selected"</cfif>>Published</option>
									<option value="expired"<cfif rc.status IS "expired" > selected="selected"</cfif>>Expired</option>
									<option value="draft"<cfif rc.status IS "draft" > selected="selected"</cfif>>Draft</option>
								</select>
							</div>
						</div>
						<div class="form-group">
							<label for="type" class="control-label">Type:</label>
							<div class="controls">
								<select name="type" id="type" class="form-control input-sm valid">
									<option value=""<cfif !len( rc.type ) > selected="selected"</cfif>>Any Type</option>
									<option value="article"<cfif rc.type IS "article" > selected="selected"</cfif>>Article</option>
									<option value="podcast"<cfif rc.type IS "podcast" > selected="selected"</cfif>>Podcast</option>
									<option value="video"<cfif rc.type IS "video" > selected="selected"</cfif>>Video</option>
								</select>
							</div>
						</div>
						<a class="btn btn-info btn-sm" href="javascript:contentFilter()">Apply Filters</a>
						<a class="btn btn-sm btn-default" href="javascript:resetFilter(true)">Reset</a>
					#html.endForm()#
				</div>
			</div>
		</div>
		#renderview( view="sidebar/help", module="contentbox-aggregator" )#
	</div>
</div>
<cfif prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN" ) >
	#renderView( view="viewlets/categories" )#
</cfif>
</cfoutput>