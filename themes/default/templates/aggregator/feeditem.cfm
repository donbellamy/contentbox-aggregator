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
<cfset contentType = args.feedItem.getContentType() />
<cfif contentType EQ "Entry" >
	<cfset args.openNewWindow = false />
</cfif>
<cfset imageUrl = args.feedItem.getFeaturedImageUrl() />
<cfset showFeaturedImage = args.showImage && len( imageUrl ) />
<cfset showVideoPlayer = args.showVideoPlayer && args.feedItem.isVideo() />
<cfset showAudioPlayer = args.showAudioPlayer && args.feedItem.isPodcast() />
<cfoutput>
<cfif args.groupByDate && structKeyExists( args, "groupDate" ) >
	<div class="post-date">
		<h4>#dateFormat( args.feedItem.getPublishedDate(), "dddd, mmmm d, yyyy" )#</h4>
	</div>
</cfif>
<div class="post feeditem" id="feeditem_#args.feedItem.getContentID()#">
	<div class="row">
		<cfif !args.showExcerpt && ( showFeaturedImage || showVideoPlayer ) >
			<div class="col-md-3">
				<cfif showVideoPlayer >
					<div class="video-player" data-id="#listLast(args.feedItem.getVideoUrl(),"/")#" data-url="#args.feedItem.getVideoUrl()#" data-image="#imageUrl#"></div>
				<cfelseif showFeaturedImage >
					<a href="#ag.linkFeedItem( feedItem=feedItem, linkBehavior=args.linkBehavior )#"
						<cfif args.openNewWindow >target="_blank"</cfif>
						<cfif args.linkBehavior EQ "link" >class="direct-link"</cfif>
						rel="<cfif contentType EQ "FeedItem" >nofollow<cfif args.openNewWindow > noopener</cfif><cfelse>bookmark</cfif>"
						title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#"><img class="img-thumbnail" title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#" src="#imageUrl#" /></a>
				</cfif>
			</div>
		</cfif>
		<div class="post-title <cfif !args.showExcerpt && ( showFeaturedImage || showVideoPlayer ) >col-md-9<cfelse>col-md-12</cfif>">
			<h2>
				<a href="#ag.linkFeedItem( feedItem=args.feedItem, linkBehavior=args.linkBehavior )#"
					<cfif args.openNewWindow >target="_blank"</cfif>
					<cfif args.linkBehavior EQ "link" >class="direct-link"</cfif>
					rel="<cfif contentType EQ "FeedItem" >nofollow<cfif args.openNewWindow > noopener</cfif><cfelse>bookmark</cfif>"
					title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#">#args.feedItem.getTitle()#</a>
			</h2>
			<div class="row">
				<cfif args.showSource OR args.showAuthor >
					<div class="col-sm-7 pull-left">
						<cfif args.showSource >
							<i class="fa fa-rss"></i>
							<cfif contentType EQ "FeedItem">
								<a href="#ag.linkFeed( args.feedItem.getFeed() )#" title="#encodeForHTMLAttribute( args.feedItem.getFeed().getTitle() )#">#args.feedItem.getFeed().getTitle()#</a>
							<cfelse>
								<a href="#cb.linkBlog()#" title="#encodeForHTMLAttribute( cb.siteName() )#">#cb.siteName()#</a>
							</cfif>
						</cfif>
						<cfif args.showAuthor && ( ( contentType EQ "FeedItem" && len( args.feedItem.getItemAuthor() ) ) || contentType EQ "Entry" ) >
							<cfif args.showSource ><span class="text-muted">-</span></cfif>
							<i class="fa fa-user"></i>
							<cfif contentType EQ "FeedItem">
								<a href="#ag.linkFeedAuthor( feedItem )#" title="#encodeForHTMLAttribute( args.feedItem.getItemAuthor() )#">#args.feedItem.getItemAuthor()#</a>
							<cfelse>
								<a href="##">#args.feedItem.getAuthorName()#</a>
							</cfif>
						</cfif>
					</div>
				</cfif>
				<div class="col-sm-5 pull-right text-right">
					<i class="fa fa-calendar"></i>
					<time datetime="#args.feedItem.getDisplayPublishedDate()#" title="#args.feedItem.getDisplayPublishedDate()#">#ag.timeAgo( args.feedItem.getDisplayPublishedDate() )#</time>
				</div>
			</div>
			<cfif !args.showExcerpt && showAudioPlayer >
				<div class="row">
					<div class="col-sm-12">
						<div class="audio-player">
							<audio controls="controls">
								<source src="#args.feedItem.getPodcastUrl()#" type="#args.feedItem.getPodcastMimeType()#">
							</audio>
						</div>
					</div>
				</div>
			</cfif>
		</div>
	</div>
	<cfif args.showExcerpt >
		<div class="post-content row">
			<cfif showFeaturedImage || showVideoPlayer >
				<div class="col-md-3">
					<cfif showVideoPlayer >
						<div class="video-player" data-id="#listLast(args.feedItem.getVideoUrl(),"/")#" data-url="#args.feedItem.getVideoUrl()#" data-image="#imageUrl#"></div>
					<cfelseif showFeaturedImage >
						<a class="thumbnail" href="#ag.linkFeedItem( feedItem=args.feedItem, linkBehavior=args.linkBehavior )#"
							<cfif args.openNewWindow >target="_blank"</cfif>
							<cfif args.linkBehavior EQ "link" >class="direct-link"</cfif>
							rel="<cfif contentType EQ "FeedItem" >nofollow<cfif args.openNewWindow > noopener</cfif><cfelse>bookmark</cfif>"
							title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#"><img title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#" src="#imageUrl#" /></a>
					</cfif>
				</div>
			</cfif>
			<div class="<cfif showFeaturedImage || showVideoPlayer >col-md-9<cfelse>col-md-12</cfif>">
				<cfif args.feedItem.hasExcerpt() >
					#args.feedItem.renderExcerpt()#
				<cfelse>
					<cfif contentType EQ "FeedItem" >
						#args.feedItem.getContentExcerpt( val( args.excerptLimit ), args.excerptEnding )#
					<cfelse>
						#args.feedItem.renderContent()#
					</cfif>
				</cfif>
				<cfif showAudioPlayer >
					<div class="audio-player">
						<audio controls="controls">
							<source src="#args.feedItem.getPodcastUrl()#" type="#args.feedItem.getPodcastMimeType()#">
						</audio>
					</div>
				</cfif>
				<cfif args.showReadMore >
					<div class="post-more">
						<a href="#ag.linkFeedItem( feedItem=args.feedItem, linkBehavior=args.linkBehavior )#"
							<cfif args.openNewWindow >target="_blank"</cfif>
							<cfif args.linkBehavior EQ "link" >class="direct-link"</cfif>
							rel="<cfif contentType EQ "FeedItem" >nofollow<cfif args.openNewWindow > noopener</cfif><cfelse>bookmark</cfif>"
							title="#encodeForHtmlAttribute( args.feedItem.getTitle() )#"><button class="btn btn-success">#args.readMoreText#</button></a>
					</div>
				</cfif>
			</div>
		</div>
	</cfif>
	<cfif args.showCategories && args.feedItem.hasCategories() >
		<div class="row">
			<div class="col-sm-12">
				<i class="fa fa-tag"></i>
				#ag.quickCategoryLinks( feeditem )#
			</div>
		</div>
	</cfif>
</div>
</cfoutput>