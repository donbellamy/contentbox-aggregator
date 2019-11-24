<cfparam name="args" default="#structNew()#" />
<cfset linkBehavior =
	len( feedItem.getFeed().getLinkBehavior() ) ?
	feedItem.getFeed().getLinkBehavior() :
	ag.setting("ag_site_items_link_behavior") />
<cfset directLink = linkBehavior EQ "link" ? true : false />
<cfparam name="args.openNewWindow" default="#linkBehavior EQ 'interstitial' ? true : false#" />
<cfparam name="args.showGroupByDate" default="false" />
<cfparam name="args.showImage" default="true" />
<cfparam name="args.showSource" default="true" />
<cfparam name="args.showPlayer" default="true" />
<cfparam name="args.showReadMore" default="true" />
<cfparam name="args.readMoreText" default="Read more..." />
<cfoutput>
<cfif args.showGroupByDate >
	<div class="post-date col-sm-12">
		<h4>#dateFormat( feedItem.getPublishedDate(), "dddd, mmmm d, yyyy" )#</h4>
	</div>
</cfif>
<div class="col-md-4 col-sm-6 col-xs-12 post podcast" id="feeditem_#feedItem.getContentID()#">
	<cfif args.showImage >
		<cfset imageUrl = feedItem.getFeaturedImageUrl() />
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
				<div class="col-sm-12">
					<i class="fa fa-microphone"></i>
					<a href="#ag.linkFeed( feedItem.getFeed() )#" title="#encodeForHTMLAttribute( feeditem.getFeed().getTitle() )#">#feeditem.getFeed().getTitle()#</a>
				</div>
			</cfif>
			<div class="col-sm-12">
				<i class="fa fa-calendar"></i>
				<time datetime="#feedItem.getDisplayPublishedDate()#" title="#feedItem.getDisplayPublishedDate()#">#ag.timeAgo( feedItem.getDisplayPublishedDate() )#</time>
			</div>
	</div>
	<cfif feedItem.isPodcast() && args.showPlayer >
		<div class="audio-player">
			<audio controls="controls">
				<source src="#feedItem.getPodcastUrl()#" type="#feedItem.getPodcastMimeType()#">
			</audio>
		</div>
	<cfelseif args.showReadMore >
		<a class="btn btn-success btn-sm" href="#ag.linkFeedItem( feedItem=feedItem, directLink=directLink )#"
			<cfif args.openNewWindow >target="_blank"</cfif>
			<cfif directLink >class="direct-link"</cfif>
			rel="nofollow<cfif args.openNewWindow > noopener</cfif>"
			title="#encodeForHtmlAttribute( feedItem.getTitle() )#">#args.readMoreText#</a>
	</cfif>
</div>
</cfoutput>