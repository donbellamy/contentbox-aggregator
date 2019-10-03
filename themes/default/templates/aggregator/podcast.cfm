<cfparam name="args" default="#structNew()#" />
<cfset linkBehavior =
	len( feedItem.getFeed().getLinkBehavior() ) ?
	feedItem.getFeed().getLinkBehavior() :
	ag.setting("ag_site_item_link_behavior") />
<cfset directLink = linkBehavior EQ "link" ? true : false />
<cfparam name="args.openNewWindow" default="#linkBehavior EQ 'interstitial' ? true : false#" />

<cfset imageUrl = feedItem.getFeaturedImageUrl() />
<cfoutput>
<div class="col-md-4 col-sm-6 col-xs-6">
	<a href="" target="" class="text-center" title="title="#encodeForHtmlAttribute( feedItem.getTitle() )#"">
		<img width="200" height="200" src="#imageUrl#" class="img-thumbnail" alt="#encodeForHtmlAttribute( feedItem.getTitle() )#" />
	</a>
	<h4><a href="" class="" target="">#feedItem.getTitle()#</a></h4>
	<audio controls="controls">
		<source src="#feedItem.getPodcastUrl()#" type="#feedItem.getPodcastMimeType()#">
	</audio>
	<!---<div>
		<span class="entry-date">
			<span class="glyphicon glyphicon-calendar"></span>
			<time datetime="2019-10-01T20:12:35+01:00">3 hours ago</time>
		</span>
	</div>--->
</div>
</cfoutput>