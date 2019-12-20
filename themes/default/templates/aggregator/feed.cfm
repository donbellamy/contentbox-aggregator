<cfparam name="args" default="#structNew()#" />
<cfparam name="args.showImage" default="true" />
<cfparam name="args.showWebsite" default="true" />
<cfparam name="args.showRSS" default="true" />
<cfparam name="args.includeItems" default="false" />
<cfset imageUrl = feed.getFeaturedImageUrl() />
<cfset showFeaturedImage = args.showImage && len( imageUrl ) />
<cfoutput>
<div class="post feed" id="feed_#feed.getContentID()#">
	<div class="row">
		<cfif showFeaturedImage >
			<div class="col-md-3">
				<a href="#ag.linkFeed( feed )#" title="#encodeForHtmlAttribute( feed.getTitle() )#"><img class="img-thumbnail" title="#encodeForHtmlAttribute( feed.getTitle() )#" src="#imageUrl#" /></a>
			</div>
		</cfif>
		<div class="post-title <cfif showFeaturedImage >col-md-9<cfelse>col-md-12</cfif>">
			<h2><a href="#ag.linkFeed( feed )#" title="#encodeForHtmlAttribute( feed.getTitle() )#">#feed.getTitle()#</a></h2>
			<cfif args.showWebsite || args.showRSS >
				<div class="row">
					<cfif args.showWebsite >
						<div class="col-sm-7 pull-left">
							<i class="fa fa-external-link"></i>
							<a href="#feed.getWebsiteUrl()#" target="_blank" title="#encodeForHtmlAttribute( feed.getTitle() )#">#listFirst( reReplaceNoCase( feed.getWebsiteUrl(), "https?://" , "" ), "/" )#</a>
						</div>
					</cfif>
					<cfif args.showRSS >
						<div class="col-sm-5 pull-right text-right">
							<i class="fa fa-rss"></i>
							<a href="#ag.linkFeedRSS( feed )#" title="RSS Feed">RSS Feed</a>
						</div>
					</cfif>
				</div>
			</cfif>
			<cfif args.includeItems && feed.getNumberOfPublishedChildren() >
				<cfset linkBehavior =
					len( feed.getSetting( "feed_items_link_behavior", "" ) ) ?
					feed.getSetting( "feed_items_link_behavior", "" ) :
					ag.setting("feed_items_link_behavior") />
				<cfset directLink = linkBehavior EQ "link" ? true : false />
				<cfparam name="args.openNewWindow" default="#linkBehavior EQ 'interstitial' ? true : false#" />
				<div class="row feeditems">
					<div class="col-md-12">
						<cfloop array="#feed.getLatestFeedItems()#" index="feedItem" >
							<h4>
								<a href="#ag.linkFeedItem( feedItem=feedItem )#"
									<cfif args.openNewWindow >target="_blank"</cfif>
									<cfif directLink >class="direct-link"</cfif>
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