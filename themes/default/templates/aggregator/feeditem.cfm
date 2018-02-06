<cfoutput>
<!--- post --->
<div class="post" id="feeditem_#feedItem.getContentID()#">
	<!--- Title --->
	<div class="post-title">
		<!--- TODO: featured image --->
		<h2><a href="#ag.linkFeedItem( feedItem )#" title="#feedItem.getTitle()#">#feedItem.getTitle()#</a></h2>
		<!--- TODO: link, rel ? --->
		<div class="row">
			<cfif len( feedItem.getItemAuthor() ) >
				<div class="col-sm-7 pull-left">
					<span class="text-muted">Posted by</span>
					<i class="icon-user"></i>
					#feedItem.getItemAuthor()#
				</div>
			</cfif>
			<div class="col-sm-5 pull-right text-right">
				<i class="fa fa-calendar"></i>
				#feedItem.getDisplayPublishedDate()#
			</div>
		</div>
		<div class="post-content">
			<!--- excerpt or content --->
			<cfif feedItem.hasExcerpt() >
				#feedItem.renderExcerpt()#
				<div class="post-more">
					<a href="#ag.linkFeedItem( feedItem )#" title="#feedItem.getTitle()#"><button class="btn btn-success">Read More...</button></a>
				</div>
			<cfelse>
				#feedItem.renderContent()#
			</cfif>
		</div>
	</div>
</div>
</cfoutput>