
<cfparam name="args.includeFeedItems" default="false" />
<cfparam name="args.showFeedImage" default="true" />
<cfparam name="args.showWebsite" default="true" />
<cfparam name="args.showFeedRSS" default="true" />
<cfset imageUrl = args.feed.getFeaturedImageUrl() />
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
			<cfif args.showFeedWebsite || args.showFeedRSS >
				<div class="row">
					<cfif args.showFeedWebsite >
						<div class="col-sm-7 pull-left">
							<i class="fa fa-external-link"></i>
							<a href="#args.feed.getWebsiteUrl()#" target="_blank" title="#encodeForHtmlAttribute( args.feed.getTitle() )#">#listFirst( reReplaceNoCase( args.feed.getWebsiteUrl(), "https?://" , "" ), "/" )#</a>
						</div>
					</cfif>
					<cfif args.showFeedRSS >
						<div class="col-sm-5 pull-right text-right">
							<i class="fa fa-rss"></i>
							<a href="#ag.linkFeedRSS( args.feed )#" title="RSS Feed">RSS Feed</a>
						</div>
					</cfif>
				</div>
			</cfif>
			<cfif args.includeFeedItems && args.feed.getNumberOfPublishedChildren() >
				<!---<cfset linkBehavior =
					len( feed.getSetting( "feed_items_link_behavior", "" ) ) ?
					feed.getSetting( "feed_items_link_behavior", "" ) :
					ag.setting("feed_items_link_behavior") />--->
				<!---<cfset directLink = args.linkBehavior EQ "link" ? true : false />--->
				<cfparam name="args.linkBehavior" default="forward" />
				<cfparam name="args.openNewWindow" default="#args.linkBehavior EQ 'interstitial' ? true : false#" />
				<div class="row feeditems">
					<div class="col-md-12">
						<cfloop array="#args.feed.getLatestFeedItems()#" index="feedItem" >
							<h4>
								<a href="#ag.linkFeedItem( feedItem=feedItem )#"
									<cfif args.openNewWindow >target="_blank"</cfif>
									<cfif args.linkBehavior EQ "link" >class="direct-link"</cfif>
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