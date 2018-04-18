<cfoutput>
<div class="row">
	<div class="col-md-12">
		<h1 class="h1">
			<i class="fa fa-rss fa-lg"></i>
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
			<div class="panel panel-default">
				<div class="panel-heading">
					<div class="row">
						<div class="col-md-6">
							<div class="form-group form-inline no-margin">
								#html.textField(
									name="search",
									class="form-control",
									placeholder="Quick Search"
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
											<li><a href="javascript:changeStatus('draft');"><i class="fa fa-ban"></i> Draft Selected</a></li>
											<li><a href="javascript:changeStatus('publish');"><i class="fa fa-check"></i> Publish Selected</a></li>
											<li><a href="javascript:resetHits();"><i class="fa fa-refresh"></i> Reset Hits Selected</a></li>
											<li><a href="javascript:categoryChooser();"><i class="fa fa-tags"></i> Assign Categories</a></li>
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
						<p class="text-center"><i id="feedLoader" class="fa fa-spinner fa-spin fa-lg icon-4x"></i></p>
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
							<label for="creator" class="control-label">Feeds:</label>
							<select name="feed" id="feed" class="form-control input-sm">
								<option value="all" selected="selected">All Feeds</option>
								<cfloop array="#prc.feeds#" index="feed">
									<option value="#feed.getContentID()#">#feed.getTitle()#</option>
								</cfloop>
							</select>
						</div>
						<div class="form-group">
							<label for="category" class="control-label">Categories:</label>
							<div class="controls">
								<select name="category" id="category" class="form-control input-sm valid">
									<option value="all">All Categories</option>
									<option value="none">Uncategorized</option>
									<cfloop array="#prc.categories#" index="category">
										<option value="#category.getCategoryID()#">#category.getCategory()#</option>
									</cfloop>
								</select>
							</div>
						</div>
						<div class="form-group">
							<label for="status" class="control-label">Status:</label>
							<div class="controls">
								<select name="status" id="status" class="form-control input-sm valid">
									<option value="any">Any Status</option>
									<option value="published">Published</option>
									<option value="expired">Expired</option>
									<option value="draft">Draft</option>
								</select>
							</div>
						</div>
						<a class="btn btn-info btn-sm" href="javascript:contentFilter()">Apply Filters</a>
						<a class="btn btn-sm btn-default" href="javascript:resetFilter( true )">Reset</a>
					#html.endForm()#
				</div>
			</div>
		</div>
	</div>
</div>
<cfif prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN" ) >
	#renderView( view="feeditems/categories" )#
</cfif>
</cfoutput>