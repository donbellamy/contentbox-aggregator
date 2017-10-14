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
		#html.startForm( name="feedForm", action=prc.xehFeedRemove )#
			#html.hiddenField(name="contentStatus", value="" )#
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
									</ul>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div class="panel-body">
					<div id="itemsTableContainer">
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
					#html.startForm( name="itemFilterForm", action=prc.xehFeedItemSearch, class="form-vertical", role="form" )#
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
									<option value="true">Published</option>
									<option value="false">Draft</option>
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