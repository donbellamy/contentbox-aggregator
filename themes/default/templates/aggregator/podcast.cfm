<cfparam name="args" default="#structNew()#" />
<cfset linkBehavior =
	len( feedItem.getFeed().getLinkBehavior() ) ?
	feedItem.getFeed().getLinkBehavior() :
	ag.setting("ag_site_item_link_behavior") />
<cfset directLink = linkBehavior EQ "link" ? true : false />
<cfparam name="args.openNewWindow" default="#linkBehavior EQ 'interstitial' ? true : false#" />
<cfset imageUrl = feedItem.getFeaturedImageUrl() />
<cfoutput>
<div class="col-md-4 col-sm-6 col-xs-6">
	<cfif len( imageUrl ) >
		<div class="text-center">
			<a href="#ag.linkFeedItem( feedItem=feedItem, directLink=directLink )#"
				<cfif args.openNewWindow >target="_blank"</cfif>
				<cfif directLink >class="direct-link"</cfif>
				title="#encodeForHtmlAttribute( feedItem.getTitle() )#"
				rel="nofollow<cfif args.openNewWindow > noopener</cfif>">
				<img src="#imageUrl#" class="img-thumbnail" alt="#encodeForHtmlAttribute( feedItem.getTitle() )#" />
			</a>
		</div>
	</cfif>
	<h5>
		<a href="#ag.linkFeedItem( feedItem=feedItem, directLink=directLink )#"
			<cfif args.openNewWindow >target="_blank"</cfif>
			<cfif directLink >class="direct-link"</cfif>
			title="#encodeForHtmlAttribute( feedItem.getTitle() )#"
			rel="nofollow<cfif args.openNewWindow > noopener</cfif>">#feedItem.getTitle()#</a>
	</h5>
	<div class="text-muted small">
		<p>
			<i class="fa fa-microphone"></i>
			<a href="#ag.linkFeed( feedItem.getFeed() )#" title="#encodeForHTMLAttribute( feeditem.getFeed().getTitle() )#">#feeditem.getFeed().getTitle()#</a><br/>
			<i class="fa fa-calendar"></i>
			#ag.timeAgo( feedItem.getDisplayPublishedDate() )#
		</p>
	</div>
	<audio controls="controls">
		<source src="#feedItem.getPodcastUrl()#" type="#feedItem.getPodcastMimeType()#">
	</audio>
</div>
</cfoutput>