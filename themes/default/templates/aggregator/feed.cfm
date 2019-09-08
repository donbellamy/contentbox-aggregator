<cfoutput>
<div class="post" id="feed_#feed.getContentID()#">
	<div class="post-title">
		<h2>
			<a href="#ag.linkFeed( feed )#" title="#encodeForHtmlAttribute( feed.getTitle() )#">#feed.getTitle()#</a>
		</h2>
		<div class="row">
			<div class="col-sm-7 pull-left">
				<i class="fa fa-external-link"></i>
				<a href="#feed.getWebsiteUrl()#" target="_blank" title="#encodeForHtmlAttribute( feed.getTitle() )#">#listFirst( reReplaceNoCase( feed.getWebsiteUrl(), "https?://" , "" ), "/" )#</a>
			</div>
			<div class="col-sm-5 pull-right text-right">
				<i class="fa fa-rss"></i>
				<a href="#ag.linkFeedRSS( feed )#" title="RSS Feed">RSS Feed</a>
			</div>
		</div>
	</div>
</div>
</cfoutput>