<cfparam name="args.groupByDate" default="false" />
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
<!---<cfif args.showGroupByDate >
	<div class="post-date col-sm-12">
		<h4>#dateFormat( args.feedItem.getPublishedDate(), "dddd, mmmm d, yyyy" )#</h4>
	</div>
</cfif>--->
<div class="col-md-6 col-sm-12 col-xs-12 post video" id="feeditem_#args.feedItem.getContentID()#">
	<cfif args.showImage || args.showVideoPlayer >
		<cfset imageUrl = args.feedItem.getFeaturedImageUrl() />
		<cfif args.feedItem.isVideo() && args.showVideoPlayer >
			<div class="video-player" data-id="#listLast(args.feedItem.getVideoUrl(),"/")#" data-url="#args.feedItem.getVideoUrl()#" data-image="#imageUrl#">
				<img class="img-thumbnail" title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#" src="#imageUrl#" />
			</div>
		<cfelseif len( imageUrl ) && args.showImage >
			<div class="video-image">
				<a href="#ag.linkFeedItem( feedItem=args.feedItem, linkBehavior=args.linkBehavior )#"
					<cfif args.openNewWindow >target="_blank"</cfif>
					<cfif args.linkBehavior EQ "link" >class="direct-link"</cfif>
					title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#"
					rel="nofollow<cfif args.openNewWindow > noopener</cfif>">
					<img class="img-thumbnail" title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#" src="#imageUrl#" />
				</a>
			</div>
		</cfif>
	</cfif>
	<h4>
		<a href="#ag.linkFeedItem( feedItem=args.feedItem, linkBehavior=args.linkBehavior )#"
			<cfif args.openNewWindow >target="_blank"</cfif>
			<cfif args.linkBehavior EQ "link" >class="direct-link"</cfif>
			title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#"
			rel="nofollow<cfif args.openNewWindow > noopener</cfif>">#args.feedItem.getTitle()#</a>
	</h4>
	<div class="row text-muted small">
		<cfif args.showSource >
			<div class="col-sm-7 pull-left">
				<i class="fa fa-youtube-play"></i>
				<a href="#ag.linkFeed( args.feedItem.getFeed() )#" title="#encodeForHTMLAttribute( args.feedItem.getFeed().getTitle() )#">#args.feedItem.getFeed().getTitle()#</a>
			</div>
		</cfif>
		<div class="col-sm-5 pull-right text-right">
			<i class="fa fa-calendar"></i>
			<time datetime="#args.feedItem.getDisplayPublishedDate()#" title="#args.feedItem.getDisplayPublishedDate()#">#ag.timeAgo( args.feedItem.getDisplayPublishedDate() )#</time>
		</div>
	</div>
</div>
</cfoutput>