<!--- TODO: 
Gettting this all working before adding in display settings
<cfparam name="args.linkTitle" default="#ag.getSetting('ag_display_title_link',true)#" />
<cfparam name="args.showAuthor" default="#ag.getSetting('ag_display_author_show',true)#" />
<cfparam name="args.showAuthor" default="#ag.getSetting('ag_display_author_show',true)#" />
<cfparam name="args.showSummary" default="#ag.getSetting('ag_display_author_show',true)#" />
--->

<cfoutput>

<div class="post" id="feeditem_#feedItem.getContentID()#">
	<div class="post-title">
		<h2>
			<a href="#ag.linkFeedItem( feedItem )#" 
				title="#encodeForHtmlAttribute( feedItem.getTitle() )#" 
				target="_blank"
				rel="nofollow">#feedItem.getTitle()#</a>
		</h2>
		<div class="row">
			<div class="col-sm-7 pull-left">
				<i class="fa fa-rss"></i>
				<a href="#ag.linkFeed( feedItem.getFeed() )#" title="#encodeForHTMLAttribute( feeditem.getFeed().getTitle() )#">#feeditem.getFeed().getTitle()#</a>
				<cfif len( feedItem.getItemAuthor() )  >
					<span class="text-muted">-</span>
					<i class="fa fa-user"></i>
					<a href="#ag.linkFeedItemAuthor( feedItem )#" title="#encodeForHTMLAttribute( feedItem.getItemAuthor() )#">#feedItem.getItemAuthor()#</a>
				</cfif>
			</div>
			<div class="col-sm-5 pull-right text-right">
				<i class="fa fa-calendar"></i>
				<time datetime="#feedItem.getDisplayDatePublished()#" title="#feedItem.getDisplayDatePublished()#">#ag.timeAgo( feedItem.getDisplayDatePublished() )#</time>
			</div>
		</div>
	</div>
		<div class="post-content">
			<cfif feedItem.hasExcerpt() > 
				#feedItem.renderExcerpt()#
			<cfelse>
				#ag.renderContentExcerpt( feedItem, 500 )#...
			</cfif>
			<div class="post-more">
				<a href="#ag.linkFeedItem( feedItem )#"
					title="#encodeForHtmlAttribute( feedItem.getTitle() )#"
					target="_blank"
					rel="nofollow"><button class="btn btn-success">Read More...</button></a>
			</div>
		</div>
</div>

</cfoutput>