<cfparam name="args.linkTitle" default="#ag.getSetting('ag_display_title_link',true)#" />
<cfparam name="args.showAuthor" default="#ag.getSetting('ag_display_author_show',true)#" />
<!--- Link author --->
<cfparam name="args.showSummary" default="#ag.getSetting('ag_display_author_show',true)#" />

<cfoutput>

<div class="post" id="feeditem_#feedItem.getContentID()#">
	<div class="post-title">
		<!--- TODO: featured image --->
		<h2>
			<cfif args.linkTitle >
				<a href="#ag.linkFeedItem( feedItem )#" title="#feedItem.getTitle()#">#feedItem.getTitle()#</a>
			<cfelse>
				#feedItem.getTitle()#
			</cfif>
		</h2>
		<!--- TODO: link, rel ? --->
		<div class="row">
			<cfif len( feedItem.getItemAuthor() ) >
				<div class="col-sm-7 pull-left">
					<span class="text-muted">Posted by</span>
					<i class="icon-user"></i>
					#feedItem.getItemAuthor()#
					<!--- TODO: link author /news/?author=XXXX ? ag.linkAuthor() --->
					<!--- TODO: link feed /news/feeds/feed-slug ? ag.linkFeed() --->
				</div>
			</cfif>
			<div class="col-sm-5 pull-right text-right">
				<i class="fa fa-calendar"></i>
				#feedItem.getDisplayDatePublished()#
			</div>
		</div>
		<cfif ag.getSetting("display_excerpts") >
		<div class="post-content">
			<!--- If we've taken the time to create an excerpt, just display it --->
			<cfif feedItem.hasExcerpt() > 
				#feedItem.renderExcerpt()#
				<div class="post-more">
					<a href="#ag.linkFeedItem( feedItem )#" title="#feedItem.getTitle()#"><button class="btn btn-success">Read More...</button></a>
				</div>
			<cfelse>
				#feedItem.renderContent()#
				<!--- TODO: this should strip html and display x no of chars --->
				<!--- TODO: Should have a read more link --->
			</cfif>
		</div>
		</cfif>
	</div>
</div>

</cfoutput>


<!---
	if ( showSummary ) {
		
	}
--->