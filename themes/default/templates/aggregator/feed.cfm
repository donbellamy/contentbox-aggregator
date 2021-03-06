
<cfparam name="args.includeFeedItems" default="false" />
<cfparam name="args.showWebsite" default="true" />
<cfparam name="args.showRSS" default="true" />
<cfparam name="args.showFeedImage" default="true" />
<cfset imageUrl = args.feed.getFeaturedOrAltImageUrl() />
<cfset showFeaturedImage = args.showFeedImage && len( imageUrl ) />
<cfoutput>
<div class="post feed" id="feed_#args.feed.getContentID()#">
	<div class="row">
		<cfif showFeaturedImage >
			<div class="col-md-3">
				<a href="#ag.linkFeed( args.feed )#" title="#encodeForHtmlAttribute( args.feed.getTitle() )#"><img class="img-thumbnail" title="#encodeForHtmlAttribute( args.feed.getTitle() )#" src="#imageUrl#" /></a>
			</div>
		</cfif>
		<div class="post-title <cfif showFeaturedImage >col-md-9<cfelse>col-md-12</cfif>">
			<h2><a href="#ag.linkFeed( args.feed )#" title="#encodeForHtmlAttribute( args.feed.getTitle() )#">#args.feed.getTitle()#</a></h2>
			<cfif args.showWebsite || args.showRSS >
				<div class="row">
					<cfif args.showWebsite >
						<div class="col-sm-7 pull-left">
							<i class="fa fa-external-link"></i>
							<a href="#args.feed.getWebsiteUrl()#" target="_blank" title="#encodeForHtmlAttribute( args.feed.getTitle() )#">#listFirst( reReplaceNoCase( args.feed.getWebsiteUrl(), "https?://" , "" ), "/" )#</a>
						</div>
					</cfif>
					<cfif args.showRSS >
						<div class="col-sm-5 pull-right text-right">
							<i class="fa fa-rss"></i>
							<a href="#ag.linkFeedRSS( args.feed )#" title="RSS Feed">RSS Feed</a>
						</div>
					</cfif>
				</div>
			</cfif>
			<cfif args.includeFeedItems && args.feed.getNumberOfPublishedChildren() >
				<cfparam name="args.linkBehavior" default="forward" />
				<cfparam name="args.openNewWindow" default="#args.linkBehavior EQ 'interstitial' ? true : false#" />
				<div class="row feeditems">
					<div class="col-md-12">
						<cfloop array="#args.feed.getLatestFeedItems()#" index="feedItem" >
							<h4>
								<a href="#ag.linkFeedItem( feedItem=feedItem, linkBehavior=args.linkBehavior )#"
									<cfif args.openNewWindow >target="_blank"</cfif>
									<cfif args.linkBehavior IS "link" >class="direct-link"</cfif>
									title="#encodeForHtmlAttribute( feedItem.getTitle() )#"
									rel="nofollow<cfif args.openNewWindow > noopener</cfif>">#feedItem.getTitle()#</a>
							</h4>
						</cfloop>
					</div>
				</div>
			</cfif>
		</div>
	</div>
</div>
</cfoutput>