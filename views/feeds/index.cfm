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
			#html.hiddenField (name="contentStatus", value="" )#
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
										<!--- TODO: Use builtin or add new permissions? --->
										<!--- FEEDS_ADMIN --->
										<!---<cfif prc.oCurrentAuthor.checkPermission( "PAGES_ADMIN" )>--->
										<!--- TODO: fix these javascript functions --->
										<li>
											<a href="javascript:bulkRemove()" 
												class="confirmIt" 
												data-title="Delete Selected Feeds?" 
												data-message="This will delete the feeds and all imported items, are you sure?">
												<i class="fa fa-trash-o"></i> Delete Selected
											</a>
										</li>
										<li><a href="javascript:bulkChangeStatus('draft')"><i class="fa fa-ban"></i> Draft Selected</a></li>
										<li><a href="javascript:bulkChangeStatus('publish')"><i class="fa fa-check"></i> Publish Selected</a></li>
										<!---</cfif>--->
										<li><a href="javascript:resetBulkHits()"><i class="fa fa-refresh"></i> Reset Hits Selected</a></li>
										<li><a href="javascript:contentShowAll()"><i class="fa fa-list"></i> Show All</a></li>
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
							<label for="creator" class="control-label">Creators:</label>
							<select name="creator" id="creator" class="form-control input-sm" title="Filter on feed creator">
								<option value="all" selected="selected">All Creators</option>
								<cfloop array="#prc.authors#" index="author">
									<option value="#author.getAuthorID()#">#author.getName()#</option>
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
									<option value="true">Published</option>
									<option value="false">Draft</option>
								</select>
							</div>
						</div>
						<div class="form-group">
							<label for="state" class="control-label">Import State:</label>
							<div class="controls">
								<select name="state" id="state" class="form-control input-sm valid">
									<option value="any">Any State</option>
									<option value="true">Active</option>
									<option value="false">Paused</option>
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

</cfoutput>