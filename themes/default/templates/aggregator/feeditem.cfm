<cfparam name="args" default="#structNew()#" />
<cfset contentType = feedItem.getContentType() />
<cfif contentType EQ "FeedItem" >
	<cfset linkBehavior =
		len( feedItem.getFeed().getLinkBehavior() ) ?
		feedItem.getFeed().getLinkBehavior() :
		ag.setting("ag_site_item_link_behavior") />
	<cfset directLink = linkBehavior EQ "link" ? true : false />
	<cfparam name="args.openNewWindow" default="#linkBehavior EQ 'interstitial' ? true : false#" />
<cfelse>
	<cfset directLink = false />
	<cfparam name="args.openNewWindow" default="false" />
</cfif>
<cfparam name="args.showSource" default="true" />
<cfparam name="args.showAuthor" default="false" />
<cfparam name="args.showImage" default="true" />
<cfparam name="args.showPlayer" default="true" />
<cfparam name="args.showExcerpt" default="true" />
<cfparam name="args.characterLimit" default="255" />
<cfparam name="args.excerptEnding" default="..." />
<cfparam name="args.showReadMore" default="true" />
<cfparam name="args.readMoreText" default="Read more..." />
<cfparam name="args.showCategories" default="false" />
<cfset imageUrl = feedItem.getFeaturedImageUrl() />
<cfset showFeaturedImage = args.showImage && len( imageUrl ) />
<cfset showVideoPlayer = args.showPlayer && feedItem.isVideo() />
<cfset showAudioPlayer = args.showPlayer && feedItem.isPodcast() />
<cfoutput>
<div class="post feeditem" id="feeditem_#feedItem.getContentID()#">
	<div class="row">
		<cfif !args.showExcerpt && ( showImage || showVideoPlayer ) >
			<div class="col-sm-3">
				<cfif feedItem.isVideo() && showPlayer >
				<cfelse>
					<a href="#ag.linkFeedItem( feedItem )#"
						<cfif args.openNewWindow >target="_blank"</cfif>
						<cfif directLink >class="direct-link"</cfif>
						rel="<cfif contentType EQ "FeedItem" >nofollow<cfif args.openNewWindow > noopener</cfif><cfelse>bookmark</cfif>"
						title="#encodeForHtmlAttribute( feedItem.getTitle() )#"><img class="img-thumbnail" title="#encodeForHtmlAttribute( feedItem.getTitle() )#" src="#imageUrl#" /></a>
				</cfif>
			</div>
		</cfif>
		<div class="post-title <cfif !args.showExcerpt && args.showImage && len( imageUrl ) >col-sm-9<cfelse>col-sm-12</cfif>">
			<h2>
				<a href="#ag.linkFeedItem( feedItem=feedItem, directLink=directLink )#"
					<cfif args.openNewWindow >target="_blank"</cfif>
					<cfif directLink >class="direct-link"</cfif>
					rel="<cfif contentType EQ "FeedItem" >nofollow<cfif args.openNewWindow > noopener</cfif><cfelse>bookmark</cfif>"
					title="#encodeForHtmlAttribute( feedItem.getTitle() )#">#feedItem.getTitle()#</a>
			</h2>
			<div class="row">
				<cfif args.showSource OR args.showAuthor >
					<div class="col-sm-7 pull-left">
						<cfif args.showSource >
							<i class="fa fa-rss"></i>
							<cfif contentType EQ "FeedItem">
								<a href="#ag.linkFeed( feedItem.getFeed() )#" title="#encodeForHTMLAttribute( feeditem.getFeed().getTitle() )#">#feeditem.getFeed().getTitle()#</a>
							<cfelse>
								<a href="#cb.linkBlog()#" title="#encodeForHTMLAttribute( cb.siteName() )#">#cb.siteName()#</a>
							</cfif>
						</cfif>
						<cfif args.showAuthor && ( ( contentType EQ "FeedItem" && len( feedItem.getItemAuthor() ) ) || contentType EQ "Entry" ) >
							<cfif args.showSource ><span class="text-muted">-</span></cfif>
							<i class="fa fa-user"></i>
							<cfif contentType EQ "FeedItem">
								<a href="#ag.linkFeedAuthor( feedItem )#" title="#encodeForHTMLAttribute( feedItem.getItemAuthor() )#">#feedItem.getItemAuthor()#</a>
							<cfelse>
								<a href="##">#feedItem.getAuthorName()#</a><!--- TODO: Fix this? --->
							</cfif>
						</cfif>
					</div>
				</cfif>
				<div class="col-sm-5 pull-right text-right">
					<i class="fa fa-calendar"></i>
					<time datetime="#feedItem.getDisplayPublishedDate()#" title="#feedItem.getDisplayPublishedDate()#">#ag.timeAgo( feedItem.getDisplayPublishedDate() )#</time>
				</div>
			</div>
		</div>
	</div>
	<cfif args.showExcerpt >
		<cfset imageUrl = feedItem.getFeaturedImageUrl() />
		<div class="post-content row">
			<cfif args.showImage && len( imageUrl ) >
				<div class="col-sm-3">
					<a class="thumbnail" href="#ag.linkFeedItem( feedItem=feedItem, directLink=directLink )#"
						<cfif args.openNewWindow >target="_blank"</cfif>
						<cfif directLink >class="direct-link"</cfif>
						rel="<cfif contentType EQ "FeedItem" >nofollow<cfif args.openNewWindow > noopener</cfif><cfelse>bookmark</cfif>"
						title="#encodeForHtmlAttribute( feedItem.getTitle() )#"><img title="#encodeForHtmlAttribute( feedItem.getTitle() )#" src="#imageUrl#" /></a>
				</div>
			</cfif>
			<cfif args.showExcerpt >
				<div class="<cfif args.showImage && len( imageUrl ) >col-sm-9<cfelse>col-sm-12</cfif>">
					<cfif feedItem.hasExcerpt() >
						#feedItem.renderExcerpt()#
					<cfelse>
						<cfif contentType EQ "FeedItem" >
							#feedItem.getContentExcerpt( val( args.characterLimit ), args.excerptEnding )#
						<cfelse>
							#feedItem.renderContent()#
						</cfif>
					</cfif>
					<cfif args.showReadMore >
						<div class="post-more">
							<a href="#ag.linkFeedItem( feedItem=feedItem, directLink=directLink )#"
								<cfif args.openNewWindow >target="_blank"</cfif>
								<cfif directLink >class="direct-link"</cfif>
								rel="<cfif contentType EQ "FeedItem" >nofollow<cfif args.openNewWindow > noopener</cfif><cfelse>bookmark</cfif>"
								title="#encodeForHtmlAttribute( feedItem.getTitle() )#"><button class="btn btn-success">#args.readMoreText#</button></a>
						</div>
					</cfif>
				</div>
			</cfif>
		</div>
	</cfif>
	<cfif args.showCategories && feedItem.hasCategories() >
		<div class="row">
			<div class="col-sm-12">
				<i class="fa fa-tag"></i>
				#ag.quickCategoryLinks( feeditem )#
			</div>
		</div>
	</cfif>
</div>
</cfoutput>