<cfoutput>
#html.hiddenField( name="page", value="#rc.page#" )#
<table name="blacklistedItems" id="blacklistedItems" class="table table-striped table-hover table-condensed" cellspacing="0" width="100%">
	<thead>
		<tr>
			<th id="checkboxHolder" class="{sorter:false} text-center" width="15"><input type="checkbox" onClick="checkAll(this.checked,'blacklistedItemID')"/></th>
			<th>Title</th>
			<th width="150">Feed</th>
			<th width="125">Created Date</th>
			<th width="100" class="text-center {sorter:false}">Actions</th>
		</tr>
	</thead>
	<tbody>
		<cfloop array="#prc.blacklistedItems#" index="blacklistedItem">
			<tr data-contentID="#blacklistedItem.getBlacklistedItemID()#">
				<td class="text-center">
					<input type="checkbox" name="blacklistedItemID" id="blacklistedItemID" value="#blacklistedItem.getBlacklistedItemID()#" />
				</td>
				<td><a href="javascript:edit('#blacklistedItem.getBlacklistedItemID()#','#HTMLEditFormat( JSStringFormat( blacklistedItem.getTitle() ) )#','#HTMLEditFormat( JSStringFormat( blacklistedItem.getItemUrl() ) )#','#blacklistedItem.getFeed().getContentID()#');" title="Edit Blacklisted Item">#blacklistedItem.getTitle()#</a></td>
				<td><a href="#event.buildLink( prc.xehFeedEditor )#/contentID/#blacklistedItem.getFeed().getContentID()#" title="Edit Feed">#blacklistedItem.getFeed().getTitle()#</a></td>
				<td nowrap="nowrap">#blacklistedItem.getDisplayCreatedDate()#</td>
				<td class="text-center">
					<a class="btn btn-sm btn-info popovers" data-contentID="#blacklistedItem.getBlacklistedItemID()#" data-toggle="popover"><i class="fa fa-info-circle fa-lg"></i></a>
					<div id="infoPanel_#blacklistedItem.getBlacklistedItemID()#" class="hide">
						<i class="fa fa-user"></i>
						Created by: <a href="mailto:#blacklistedItem.getCreator().getEmail()#">#blacklistedItem.getCreator().getName()#</a> on
						#blacklistedItem.getDisplayCreatedDate()#
						<br />
					</div>
					<div class="btn-group btn-group-sm">
						<a class="btn btn-primary dropdown-toggle" data-toggle="dropdown" href="##" title="Blacklisted Item Actions"><i class="fa fa-cogs fa-lg"></i></a>
						<ul class="dropdown-menu text-left pull-right">
							<li><a href="javascript:edit('#blacklistedItem.getBlacklistedItemID()#','#HTMLEditFormat( JSStringFormat( blacklistedItem.getTitle() ) )#','#HTMLEditFormat( JSStringFormat( blacklistedItem.getItemUrl() ) )#','#blacklistedItem.getFeed().getContentID()#');"><i class="fa fa-edit fa-lg"></i> Edit</a></li>
							<cfif prc.oCurrentAuthor.checkPermission( "FEED_ITEMS_ADMIN" ) >
								<li>
									<a href="javascript:remove('#blacklistedItem.getBlacklistedItemID()#')"
										class="confirmIt"
										data-title="<i class='fa fa-trash-o'></i> Delete Blacklisted Item?"
										data-message="This will delete the blacklisted item, are you sure?">
										<i id="delete_#blacklistedItem.getBlacklistedItemID()#" class="fa fa-trash-o fa-lg" ></i> Delete
									</a>
								</li>
							</cfif>
							<li><a href="#blacklistedItem.getItemUrl()#" target="_blank"><i class="fa fa-external-link fa-lg"></i> View Item</a></li>
						</ul>
					</div>
				</td>
			</tr>
		</cfloop>
	</tbody>
</table>
<cfif prc.itemCount >
	<cfif !rc.showAll && prc.itemCount GT prc.cbSettings.cb_paging_maxrows >
		#prc.oPaging.renderit( foundRows=prc.itemCount, link=prc.pagingLink, asList=true )#
	<cfelse>
		<span class="label label-info">Total Blacklisted Items: #prc.itemCount#</span>
	</cfif>
</cfif>
</cfoutput>