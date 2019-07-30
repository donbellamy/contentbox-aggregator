<cfoutput>
<div class="row">
	<div class="col-md-12">
		<h1 class="h1">
			<i class="fa fa-ban fa-lg"></i>
			RSS Aggregator - Blacklisted Items
		</h1>
	</div>
</div>
<div class="row">
	<div class="col-md-9">
		#getModel( "messagebox@cbMessagebox" ).renderit()#
		#html.startForm( name="blacklistedItemForm", action=prc.xehBlacklistedItemRemove )#
			#html.hiddenField( name="blacklistedItemID", value="" )#
			#html.hiddenField( name="feed", id="feedFilter", value="#rc.feed#" )#
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
													data-title="Delete Selected Blacklisted Items?"
													data-message="This will delete the blacklisted items, are you sure?">
													<i class="fa fa-trash-o"></i> Delete Selected
												</a>
											</li>
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
								<option value=""<cfif !len( rc.feed ) > selected="selected"</cfif>>All Feeds</option>
								<cfloop array="#prc.feeds#" index="feed">
									<option value="#feed.getContentID()#"<cfif rc.feed EQ feed.getContentID() > selected="selected"</cfif>>#feed.getTitle()#</option>
								</cfloop>
							</select>
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
</cfoutput>