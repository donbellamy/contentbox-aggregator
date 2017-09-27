<cfoutput>
<table name="entries" id="entries" class="table table-striped table-hover table-condensed" cellspacing="0" width="100%">
	<thead>
		<tr>
			<th id="checkboxHolder" class="{sorter:false} text-center" width="15"><input type="checkbox" onClick="checkAll(this.checked,'contentID')"/></th>
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
			<!--- TODO: Do we really need these classes with the feeds? --->
			<tr data-contentID="#feed.getContentID()#" 
				<cfif feed.isExpired() >
					class="danger"
				<cfelseif feed.isPublishedInFuture() >
					class="success"
				<cfelseif !feed.isContentPublished() >
					class="warning"
				<cfelseif feed.getNumberOfActiveVersions() eq 0 >
					class="danger" title="No active content versions found, please publish one."
				</cfif>
			>
				<td class="text-center">
					<input type="checkbox" name="contentID" id="contentID" value="#feed.getContentID()#" />
				</td>
				<td>
					<!--- TODO: Permissions?
					<cfif prc.oCurrentAuthor.checkPermission( "ENTRIES_EDITOR,ENTRIES_ADMIN" )>--->
						<a href="#event.buildLink( prc.xehFeedEditor )#/contentID/#feed.getContentID()#" title="Edit Feed">#feed.getTitle()#</a>
					<!---<cfelse>
						#entry.getTitle()#
					</cfif>--->
					<!---<cfif entry.isPasswordProtected()>
						<i class="fa fa-lock" title="Password Protected Content"></i>
					</cfif>--->
					<br/><small><i class="fa fa-tag"></i> #feed.getCategoriesList()#</small>
				</td>
				<td class="text-center">
					<cfif feed.isExpired() >
						<i class="fa fa-clock-o fa-lg textRed" title="Feed expired on (#feed.getDisplayExpireDate()#)"></i>
						<span class="hidden">expired</span>
					<cfelseif feed.isPublishedInFuture() >
						<i class="fa fa-fighter-jet fa-lg textBlue" title="Feed will be published on (#feed.getDisplayPublishedDate()#)"></i>
						<span class="hidden">published in future</span>
					<cfelseif feed.isContentPublished() >
						<i class="fa fa-circle-o fa-lg textGreen" title="Feed Published!"></i>
						<span class="hidden">published</span>
					<cfelse>
						<i class="fa fa-circle-o fa-lg textRed" title="Feed Draft!"></i>
						<span class="hidden">draft</span>
					</cfif>
				</td>
				<td class="text-center">
					<cfif feed.isActive() >
						<i class="fa fa-play-circle-o fa-lg textGreen" title="Feed Active!"></i>
						<span class="hidden">active</span>
					<cfelse>
						<i class="fa fa-pause-circle-o fa-lg textRed" title="Feed Paused!"></i>
						<span class="hidden">paused</span>
					</cfif>
				</td>
				<td class="text-center"><span class="badge badge-info">0</span></td><!--- TODO: Number of items --->
				<td class="text-center"><span class="badge badge-info">#feed.getNumberOfHits()#</span></td>
			</tr>
		</cfloop>
	</tbody>
</table>
</cfoutput>