<cfoutput>
<div class="row">
	<div class="col-md-12">
		<h1 class="h1">
			<i class="fa fa-rss fa-lg"></i>
			RSS Aggregator - Feeds
		</h1>
	</div>
</div>
<div class="row">
	<div class="col-md-9">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
		#html.startForm( name="feedForm", action=prc.xehFeedRemove )#
			#html.hiddenField(name="contentStatus", value="" )#
			#html.hiddenField(name="contentState", value="" )#
			#html.hiddenField( name="contentID", value="" )#
			#html.hiddenField( name="state", id="stateFilter", value="#rc.state#" )#
			#html.hiddenField( name="category", id="categoryFilter", value="#rc.category#" )#
			#html.hiddenField( name="status", id="statusFilter", value="#rc.status#" )#
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
										<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN" ) >
											<li>
												<a href="javascript:remove();"
													class="confirmIt"
													data-title="Delete Selected Feeds?"
													data-message="This will delete the feeds and all imported items, are you sure?">
													<i class="fa fa-trash-o"></i> Delete Selected
												</a>
											</li>
											<li><a href="javascript:changeStatus('draft');"><i class="fa fa-ban"></i> Draft Selected</a></li>
											<li><a href="javascript:changeStatus('publish');"><i class="fa fa-check"></i> Publish Selected</a></li>
											<li><a href="javascript:changeState('pause');"><i class="fa fa-pause-circle-o"></i> Pause Selected</a></li>
											<li><a href="javascript:changeState('active');"><i class="fa fa-play-circle-o"></i> Activate Selected</a></li>
										</cfif>
										<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN,FEEDS_IMPORT" ) >
											<li><a href="javascript:importFeed();"><i class="fa fa-rss"></i> Import Selected</a></li>
										</cfif>
										<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN" ) >
											<li><a href="javascript:resetHits();"><i class="fa fa-refresh"></i> Reset Hits Selected</a></li>
										</cfif>
										<li><a href="javascript:contentShowAll();"><i class="fa fa-list"></i> Show All</a></li>
										<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN,FEEDS_IMPORT" ) >
											<li><a href="javascript:importAll();"><i class="fa fa-download"></i> Import All</a></li>
										</cfif>
									</ul>
								</div>
								<button class="btn btn-primary btn-sm" onclick="return to( '#event.buildLink( linkTo=prc.xehFeedEditor )#' )">Create Feed</button>
							</div>
						</div>
					</div>
				</div>
				<div class="panel-body">
					<div id="feedsTableContainer">
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
					#html.startForm( name="feedFilterForm", action=prc.xehFeedSearch, class="form-vertical", role="form" )#
						<div class="form-group">
							<label for="state" class="control-label">Import State:</label>
							<div class="controls">
								<select name="state" id="state" class="form-control input-sm valid">
									<option value=""<cfif !len( rc.state ) > selected="selected"</cfif>>Any State</option>
									<option value="true"<cfif rc.state EQ "true" > selected="selected"</cfif>>Active</option>
									<option value="false"<cfif rc.state EQ "false" > selected="selected"</cfif>>Paused</option>
									<option value="failing"<cfif rc.state EQ "failing" > selected="selected"</cfif>>Failing</option>
								</select>
							</div>
						</div>
						<div class="form-group">
							<label for="category" class="control-label">Categories:</label>
							<div class="controls">
								<select name="category" id="category" class="form-control input-sm valid">
									<option value=""<cfif !len( rc.category ) > selected="selected"</cfif>>All Categories</option>
									<option value="none"<cfif rc.category EQ "none" > selected="selected"</cfif>>Uncategorized</option>
									<cfloop array="#prc.categories#" index="category">
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
									<option value="published"<cfif rc.status EQ "published" > selected="selected"</cfif>>Published</option>
									<option value="expired"<cfif rc.status EQ "expired" > selected="selected"</cfif>>Expired</option>
									<option value="draft"<cfif rc.status EQ "draft" > selected="selected"</cfif>>Draft</option>
								</select>
							</div>
						</div>
						<a class="btn btn-info btn-sm" href="javascript:contentFilter()">Apply Filters</a>
						<a class="btn btn-sm btn-default" href="javascript:resetFilter( true )">Reset</a>
					#html.endForm()#
				</div>
			</div>
		</div>
		#renderview( view="sidebar/help", module="contentbox-aggregator" )#
	</div>
</div>
</cfoutput>