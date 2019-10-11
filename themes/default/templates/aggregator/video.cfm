<cfparam name="args" default="#structNew()#" />
<cfset linkBehavior =
	len( feedItem.getFeed().getLinkBehavior() ) ?
	feedItem.getFeed().getLinkBehavior() :
	ag.setting("ag_site_item_link_behavior") />
<cfset directLink = linkBehavior EQ "link" ? true : false />
<cfparam name="args.openNewWindow" default="#linkBehavior EQ 'interstitial' ? true : false#" />
<cfset imageUrl = feedItem.getFeaturedImageUrl() />
<cfoutput>
<div class="col-md-6 col-sm-12 col-xs-12">
	<iframe height="240" src="#feedItem.getVideoUrl()#" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
	<h5>
		<a href="#ag.linkFeedItem( feedItem=feedItem, directLink=directLink )#"
			<cfif args.openNewWindow >target="_blank"</cfif>
			<cfif directLink >class="direct-link"</cfif>
			title="#encodeForHtmlAttribute( feedItem.getTitle() )#"
			rel="nofollow<cfif args.openNewWindow > noopener</cfif>">#feedItem.getTitle()#</a>
	</h5>
	<div class="text-muted small">
		<i class="fa fa-youtube-play"></i>
		<a href="#ag.linkFeed( feedItem.getFeed() )#" title="#encodeForHTMLAttribute( feeditem.getFeed().getTitle() )#">#feeditem.getFeed().getTitle()#</a><br/>
		<i class="fa fa-calendar"></i>
		#ag.timeAgo( feedItem.getDisplayPublishedDate() )#
	</div>
</div>
</cfoutput>