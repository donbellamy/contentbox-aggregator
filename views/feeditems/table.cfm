<cfoutput>
<table name="feedItems" id="feedItems" class="table table-striped table-hover table-condensed" cellspacing="0" width="100%">
	<thead>
		<tr>
			<th id="checkboxHolder" class="{sorter:false} text-center" width="15"><input type="checkbox" onClick="checkAll(this.checked,'contentID')"/></th>
			<th>Name</th>
			<th width="125">Feed</th>
			<th width="100">Published Date</th>
			<th width="40" class="text-center"><i class="fa fa-globe fa-lg" title="Published Status"></i></th>
			<th width="40" class="text-center"><i class="fa fa-signal fa-lg" title="Hits"></i></th>
			<th width="100" class="text-center {sorter:false}">Actions</th>
		</tr>
	</thead>
	<tbody>
		<cfloop array="#prc.feedItems#" index="feedItem">
			<tr data-contentID="#feedItem.getContentID()#" 
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
				<td class="text-center">
					<input type="checkbox" name="contentID" id="contentID" value="#feedItem.getContentID()#" />
				</td>
				<td>
					<!--- TODO: Permissions?
					<cfif prc.oCurrentAuthor.checkPermission( "ENTRIES_EDITOR,ENTRIES_ADMIN" )>--->
						<a href="#event.buildLink( prc.xehFeedItemEditor )#/contentID/#feedItem.getContentID()#" title="Edit Feed Item">#feedItem.getTitle()#</a>
						<!--- TODO: leadin & thumbnail preview ? --->
					<!---<cfelse>
						#entry.getTitle()#
					</cfif>--->
					<!---<cfif entry.isPasswordProtected()>
						<i class="fa fa-lock" title="Password Protected Content"></i>
					</cfif>--->
					<br/><small><i class="fa fa-tag"></i> #feedItem.getCategoriesList()#</small>
				</td>
				<td><a href="#event.buildLink( prc.xehFeedEditor )#/contentID/#feedItem.getFeed().getContentID()#" title="Edit Feed">#feedItem.getFeed().getTitle()#</a></td>
				<td nowrap="nowrap">#feedItem.getDisplayDatePublished()#</td>
				<td class="text-center">
					<cfif feedItem.isExpired() >
						<i id="status_#feedItem.getContentID()#" class="fa fa-clock-o fa-lg textRed" title="Feed item expired on (#feedItem.getDisplayExpireDate()#)"></i>
						<span class="hidden">expired</span>
					<cfelseif feedItem.isPublishedInFuture() >
						<i id="status_#feedItem.getContentID()#" class="fa fa-fighter-jet fa-lg textBlue" title="Feed item will be published on (#feedItem.getDisplayPublishedDate()#)"></i>
						<span class="hidden">published in future</span>
					<cfelseif feedItem.isContentPublished() >
						<i id="status_#feedItem.getContentID()#" class="fa fa-circle-o fa-lg textGreen" title="Feed Item Published!"></i>
						<span class="hidden">published</span>
					<cfelse>
						<i id="status_#feedItem.getContentID()#" class="fa fa-circle-o fa-lg textRed" title="Feed Item Draft!"></i>
						<span class="hidden">draft</span>
					</cfif>
				</td>
				<td class="text-center"><span class="badge badge-info">#feedItem.getNumberOfHits()#</span></td>
				<td class="text-center">
					<a 	class="btn btn-sm btn-info popovers" data-contentID="#feedItem.getContentID()#" data-toggle="popover"><i class="fa fa-info-circle fa-lg"></i></a>
					<div id="infoPanel_#feedItem.getContentID()#" class="hide">
						<!--- TODO: what do we want here? --->
					</div>
					<div class="btn-group btn-group-sm">
						<a class="btn btn-primary dropdown-toggle" data-toggle="dropdown" href="##" title="Feed Item Actions"><i class="fa fa-cogs fa-lg"></i></a>
						<ul class="dropdown-menu text-left pull-right">
							<!--- TODO: Permissions ?
							<cfif prc.oCurrentAuthor.checkPermission( "ENTRIES_EDITOR,ENTRIES_ADMIN" )> --->
								<!---<li><a href="javascript:openCloneDialog('#entry.getContentID()#','#URLEncodedFormat(entry.getTitle())#')"><i class="fa fa-copy fa-lg"></i> Clone</a></li>--->
								<li><a href="#event.buildLink( prc.xehFeedItemEditor )#/contentID/#feedItem.getContentID()#"><i class="fa fa-edit fa-lg"></i> Edit</a></li>
								<!---<cfif prc.oCurrentAuthor.checkPermission( "ENTRIES_ADMIN" )>--->
									<li><a href="javascript:remove('#feedItem.getContentID()#')" class="confirmIt" data-title="<i class='fa fa-trash-o'></i> Delete Feed Item?"><i id="delete_#feedItem.getContentID()#" class="fa fa-trash-o fa-lg" ></i> Delete</a></li>
								<!---</cfif>--->
							<!---</cfif>--->
							<!--- TODO: Export ?
							<cfif prc.oCurrentAuthor.checkPermission( "ENTRIES_ADMIN,TOOLS_EXPORT" )>
								<li><a href="#event.buildLink(linkto=prc.xehEntryExport)#/contentID/#entry.getContentID()#.json" target="_blank"><i class="fa fa-download"></i> Export as JSON</a></li>
								<li><a href="#event.buildLink(linkto=prc.xehEntryExport)#/contentID/#entry.getContentID()#.xml" target="_blank"><i class="fa fa-download"></i> Export as XML</a></li>
							</cfif>--->
							<!--- TODO: History ?
							<li><a href="#event.buildLink(prc.xehEntryHistory)#/contentID/#entry.getContentID()#"><i class="fa fa-clock-o fa-lg"></i> History</a></li>--->
							<li><a href="javascript:resetHits('#feedItem.getContentID()#')"><i class="fa fa-refresh fa-lg"></i> Reset Hits</a></li>
							<!--- TODO: use portal url? --->
							<li><a href="#feedItem.getUrl()#" target="_blank"><i class="fa fa-eye fa-lg"></i> Open In Site</a></li>
						</ul>
					</div>
				</td>
			</tr>
		</cfloop>
	</tbody>
</table>
<cfif prc.feedItemsCount >
	<cfif !rc.showAll && prc.feedItemsCount GT prc.cbSettings.cb_paging_maxrows >
		#prc.oPaging.renderit( foundRows=prc.feedItemsCount, link=prc.pagingLink, asList=true )#
	<cfelse>
		<span class="label label-info">Total Feed Items: #prc.feedItemsCount#</span>
	</cfif>
</cfif>
</cfoutput>