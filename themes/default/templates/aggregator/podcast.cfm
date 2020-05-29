<cfparam name="args.showGroupedDate" default="false" />
<cfparam name="args.showVideoPlayer" default="true" />
<cfparam name="args.showAudioPlayer" default="true" />
<cfparam name="args.showSource" default="true" />
<cfparam name="args.showAuthor" default="false" />
<cfparam name="args.showCategories" default="false" />
<cfparam name="args.showExcerpt" default="true" />
<cfparam name="args.excerptLimit" default="255" />
<cfparam name="args.excerptEnding" default="..." />
<cfparam name="args.showReadMore" default="true" />
<cfparam name="args.readMoreText" default="Read more..." />
<cfparam name="args.linkBehavior" default="forward" />
<cfparam name="args.openNewWindow" default="false" />
<cfparam name="args.showImage" default="true" />
<cfoutput>
<cfif args.showGroupedDate >
	<div class="post-date col-sm-12">
		<h4>#dateFormat( args.feedItem.getPublishedDate(), "dddd, mmmm d, yyyy" )#</h4>
	</div>
</cfif>
<div class="col-md-4 col-sm-6 col-xs-12 post podcast" id="feeditem_#args.feedItem.getContentID()#">
	<cfif args.showImage >
		<cfset imageUrl = args.feedItem.getFeaturedOrAltImageUrl() />
		<cfif len( imageUrl ) >
			<div class="text-center">
				<a href="#ag.linkFeedItem( feedItem=args.feedItem, linkBehavior=args.linkBehavior )#"
					<cfif args.openNewWindow >target="_blank"</cfif>
					<cfif args.linkBehavior IS "link" >class="direct-link" data-slug="#args.feedItem.getSlug()#"</cfif>
					title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#"
					rel="nofollow<cfif args.openNewWindow > noopener</cfif>">
					<img src="#imageUrl#" class="img-thumbnail" alt="#encodeForHtmlAttribute( args.feedItem.getTitle() )#" />
				</a>
			</div>
		</cfif>
	</cfif>
	<h4>
		<a href="#ag.linkFeedItem( feedItem=args.feedItem, linkBehavior=args.linkBehavior )#"
			<cfif args.openNewWindow >target="_blank"</cfif>
			<cfif args.linkBehavior IS "link" >class="direct-link" data-slug="#args.feedItem.getSlug()#"</cfif>
			title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#"
			rel="nofollow<cfif args.openNewWindow > noopener</cfif>">#args.feedItem.getTitle()#</a>
	</h4>
	<div class="row text-muted small">
			<cfif args.showSource >
				<div class="col-sm-12">
					<i class="fa fa-microphone"></i>
					<a href="#ag.linkFeed( args.feedItem.getFeed() )#" title="#encodeForHTMLAttribute( args.feedItem.getFeed().getTitle() )#">#args.feedItem.getFeed().getTitle()#</a>
				</div>
			</cfif>
			<div class="col-sm-12">
				<i class="fa fa-calendar"></i>
				<time datetime="#args.feedItem.getDisplayPublishedDate()#" title="#args.feedItem.getDisplayPublishedDate()#">#ag.timeAgo( args.feedItem.getDisplayPublishedDate() )#</time>
			</div>
	</div>
	<cfif args.feedItem.isPodcast() && args.showAudioPlayer >
		<div class="audio-player-wrapper">
			<audio controls="controls" class="audio-player" data-slug="#args.feedItem.getSlug()#">
				<source src="#args.feedItem.getPodcastUrl()#" type="#args.feedItem.getPodcastMimeType()#">
			</audio>
		</div>
	<cfelseif args.showReadMore >
		<a class="btn btn-success btn-sm" href="#ag.linkFeedItem( feedItem=args.feedItem, linkBehavior=args.linkBehavior )#"
			<cfif args.openNewWindow >target="_blank"</cfif>
			<cfif args.linkBehavior IS "link" >class="direct-link"</cfif>
			rel="nofollow<cfif args.openNewWindow > noopener</cfif>"
			title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#">#args.readMoreText#</a>
	</cfif>
</div>
</cfoutput>