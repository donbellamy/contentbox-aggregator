<cfoutput>

<div class="row">
	<div class="col-md-12">
		<h1 class="h1">
			<i class="fa fa-rss fa-lg"></i>
			Feeds
		</h1>
	</div>
</div>

<div class="row">
	<div class="col-md-9">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
		<!--- TODO: Form action --->
		#html.startForm( name="feedForm", action="" )#
			<div class="panel panel-default">
				<div class="panel-heading">
					<div class="row">
						<div class="col-md-6">
							<div class="form-group form-inline no-margin">
								#html.textField( 
									name="feedSearch",
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
		</div>
	</div>
</div>

</cfoutput>