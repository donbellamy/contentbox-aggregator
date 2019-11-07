<cfparam name="args" default="#structNew()#" />
<cfset linkBehavior =
	len( feedItem.getFeed().getLinkBehavior() ) ?
	feedItem.getFeed().getLinkBehavior() :
	ag.setting("ag_site_item_link_behavior") />
<cfset directLink = linkBehavior EQ "link" ? true : false />
<cfparam name="args.openNewWindow" default="#linkBehavior EQ 'interstitial' ? true : false#" />
<cfparam name="args.showGroupByDate" default="false" />
<cfparam name="args.showImage" default="true" />
<cfparam name="args.showPlayer" default="true" />
<cfparam name="args.showSource" default="true" />
<cfoutput>
<cfif args.showGroupByDate >
	<div class="post-date col-sm-12">
		<h4>#dateFormat( feedItem.getPublishedDate(), "dddd, mmmm d, yyyy" )#</h4>
	</div>
</cfif>
<div class="col-md-6 col-sm-12 col-xs-12 post video" id="feeditem_#feedItem.getContentID()#">
	<cfif args.showImage || args.showPlayer >
		<cfset imageUrl = feedItem.getFeaturedImageUrl() />
		<cfif feedItem.isVideo() && args.showPlayer >
			<div class="video-player" data-id="#listLast(feedItem.getVideoUrl(),"/")#" data-url="#feedItem.getVideoUrl()#" data-image="#imageUrl#"></div>
		<cfelseif len( imageUrl ) && args.showImage >
			<div class="video-image">
				<a href="#ag.linkFeedItem( feedItem )#"
					rel="bookmark"
					title="#encodeForHtmlAttribute( feedItem.getTitle() )#"><img class="img-thumbnail" title="#encodeForHtmlAttribute( feedItem.getTitle() )#" src="#imageUrl#" /></a>
			</div>
		</cfif>
	</cfif>
	<h4>
		<a href="#ag.linkFeedItem( feedItem=feedItem, directLink=directLink )#"
			<cfif args.openNewWindow >target="_blank"</cfif>
			<cfif directLink >class="direct-link"</cfif>
			title="#encodeForHtmlAttribute( feedItem.getTitle() )#"
			rel="nofollow<cfif args.openNewWindow > noopener</cfif>">#feedItem.getTitle()#</a>
	</h4>
	<div class="row text-muted small">
		<cfif args.showSource >
			<div class="col-sm-7 pull-left">
				<i class="fa fa-youtube-play"></i>
				<a href="#ag.linkFeed( feedItem.getFeed() )#" title="#encodeForHTMLAttribute( feeditem.getFeed().getTitle() )#">#feeditem.getFeed().getTitle()#</a>
			</div>
		</cfif>
		<div class="col-sm-5 pull-right text-right">
			<i class="fa fa-calendar"></i>
			<time datetime="#feedItem.getDisplayPublishedDate()#" title="#feedItem.getDisplayPublishedDate()#">#ag.timeAgo( feedItem.getDisplayPublishedDate() )#</time>
		</div>
	</div>
</div>
</cfoutput>