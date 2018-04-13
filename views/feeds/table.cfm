<cfoutput>
<table name="feeds" id="feeds" class="table table-striped table-hover table-condensed" cellspacing="0" width="100%">
	<thead>
		<tr>
			<th id="checkboxHolder" class="{sorter:false} text-center" width="15">
				<input type="checkbox" onClick="checkAll(this.checked,'contentID')"/>
			</th>
			<th>Name</th>
			<th width="40" class="text-center"><i class="fa fa-globe fa-lg" title="Published Status"></i></th>
			<th width="40" class="text-center"><i class="fa fa-play-circle fa-lg" title="Import State"></i></th>
			<th width="40" class="text-center"><i class="fa fa-rss-square fa-lg" title="Feed Items"></i></th>
			<th width="40" class="text-center"><i class="fa fa-signal fa-lg" title="Hits"></i></th>
			<th width="75" class="text-center {sorter:false}">Actions</th>
		</tr>
	</thead>
	<tbody>
		<cfloop array="#prc.feeds#" index="feed">
			<tr data-contentID="#feed.getContentID()#"
				<cfif feed.isExpired() >
					class="danger"
				<cfelseif feed.isPublishedInFuture() >
					class="success"
				<cfelseif !feed.isContentPublished() >
					class="warning"
				<cfelseif !feed.getNumberOfActiveVersions() >
					class="danger" title="No active content versions found, please publish one."
				</cfif>
			>
				<td class="text-center">
					<input type="checkbox" name="contentID" id="contentID" value="#feed.getContentID()#" />
				</td>
				<td>
					<a href="#event.buildLink( prc.xehFeedEditor )#/contentID/#feed.getContentID()#" title="Edit Feed">#feed.getTitle()#</a>
					<br/><small><i class="fa fa-tag"></i> #feed.getCategoriesList()#</small>
				</td>
				<td class="text-center">
					<cfif feed.isExpired() >
						<i id="status_#feed.getContentID()#" class="fa fa-clock-o fa-lg textRed" title="Feed expired on (#feed.getDisplayExpireDate()#)"></i>
						<span class="hidden">expired</span>
					<cfelseif feed.isPublishedInFuture() >
						<i id="status_#feed.getContentID()#" class="fa fa-fighter-jet fa-lg textBlue" title="Feed will be published on (#feed.getDisplayPublishedDate()#)"></i>
						<span class="hidden">published in future</span>
					<cfelseif feed.isContentPublished() >
						<i id="status_#feed.getContentID()#" class="fa fa-circle-o fa-lg textGreen" title="Feed Published!"></i>
						<span class="hidden">published</span>
					<cfelse>
						<i id="status_#feed.getContentID()#" class="fa fa-circle-o fa-lg textRed" title="Feed Draft!"></i>
						<span class="hidden">draft</span>
					</cfif>
				</td>
				<td class="text-center">
					<cfif feed.getIsActive() >
						<i id="state_#feed.getContentID()#" class="fa fa-play-circle-o fa-lg textGreen" title="Feed Active!"></i>
						<span class="hidden">active</span>
					<cfelse>
						<i id="state_#feed.getContentID()#" class="fa fa-pause-circle-o fa-lg textRed" title="Feed Paused!"></i>
						<span class="hidden">paused</span>
					</cfif>
				</td>
				<td class="text-center"><span class="badge badge-info">#feed.getNumberOfChildren()#</span></td>
				<td class="text-center"><span class="badge badge-info">#feed.getNumberOfHits()#</span></td>
				<td class="text-center">
					<a 	class="btn btn-sm btn-info popovers" data-contentID="#feed.getContentID()#" data-toggle="popover"><i class="fa fa-info-circle fa-lg"></i></a>
					<div id="infoPanel_#feed.getContentID()#" class="hide">
						<i class="fa fa-rss"></i>
						Last imported:
						<cfif isDate( feed.getLastImportedDate() ) >
							#feed.getDisplayLastImportedDate()#
						<cfelse>
							Never imported
						</cfif>
						<br />
						<i class="fa fa-user"></i>
						Created by: <a href="mailto:#feed.getCreatorEmail()#">#feed.getCreatorName()#</a> on
						#feed.getDisplayCreatedDate()#
						<br />
						<i class="fa fa-calendar"></i>
						Last edit by: <a href="mailto:#feed.getAuthorEmail()#">#feed.getAuthorName()#</a> on
						#feed.getActiveContent().getDisplayCreatedDate()#
						<br />
					</div>
					<div class="btn-group btn-group-sm">
						<a class="btn btn-primary dropdown-toggle" data-toggle="dropdown" href="##" title="Feed Actions"><i class="fa fa-cogs fa-lg"></i></a>
						<ul class="dropdown-menu text-left pull-right">
							<li><a href="#event.buildLink( prc.xehFeedEditor )#/contentID/#feed.getContentID()#"><i class="fa fa-edit fa-lg"></i> Edit</a></li>
							<cfif prc.oCurrentAuthor.checkPermission( "FEEDS_ADMIN" ) >
								<li><a href="javascript:remove('#feed.getContentID()#')" class="confirmIt" data-title="<i class='fa fa-trash-o'></i> Delete Feed?"><i id="delete_#feed.getContentID()#" class="fa fa-trash-o fa-lg" ></i> Delete</a></li>
								<li><a href="javascript:importFeed('#feed.getContentID()#')"><i class="fa fa-rss fa-lg"></i> Import</a></li>
								<li><a href="javascript:resetHits('#feed.getContentID()#')"><i class="fa fa-refresh fa-lg"></i> Reset Hits</a></li>
							</cfif>
							<li><a href="#prc.agHelper.linkFeed( feed )#" target="_blank"><i class="fa fa-eye fa-lg"></i> Open In Site</a></li>
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
		<span class="label label-info">Total Feeds: #prc.itemCount#</span>
	</cfif>
</cfif>
</cfoutput>