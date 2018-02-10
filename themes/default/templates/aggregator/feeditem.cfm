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
		<!--- TODO: featured image --->
		<h2>
			<a href="#ag.linkFeedItem( feedItem )#" 
				title="#encodeForHtmlAttribute( feedItem.getTitle() )#" 
				target="_blank"
				rel="nofollow">#feedItem.getTitle()#</a>
		</h2>
		<div class="row">
			<div class="col-sm-7 pull-left">
				<a href="#ag.linkFeed( feedItem.getFeed() )#" title="#encodeForHTMLAttribute( feeditem.getFeed().getTitle() )#">#feeditem.getFeed().getTitle()#</a>
				<cfif len( feedItem.getItemAuthor() )  >
					<span class="text-muted">-</span>
					<i class="icon-user"></i>
					<a href="#ag.linkFeedItemAuthor( feedItem )#" title="#encodeForHTMLAttribute( feedItem.getItemAuthor() )#">#feedItem.getItemAuthor()#</a>
					<!--- TODO: link author /news/?author=XXXX ? ag.linkAuthor() --->
					<!--- TODO: link feed /news/feeds/feed-slug ? ag.linkFeed() --->
				</cfif>
			</div>
			<div class="col-sm-5 pull-right text-right">
				<i class="fa fa-calendar"></i>
				#feedItem.getDisplayDatePublished()#
			</div>
		</div>
		<div class="post-content">
			<!--- If we've taken the time to create an excerpt, just display it --->
			<cfif feedItem.hasExcerpt() > 
				#feedItem.renderExcerpt()#
				<div class="post-more">
					<a href="#ag.linkFeedItem( feedItem )#" 
						title="#encodeForHtmlAttribute( feedItem.getTitle() )#"
						target="_blank"
						rel="nofollow"><button class="btn btn-success">Read More...</button></a>
				</div>
			<cfelse>
				#feedItem.renderContent()#
				<!--- TODO: this should strip html and display x no of chars --->
				<!--- TODO: Should have a read more link --->
			</cfif>
		</div>
	</div>
</div>

</cfoutput>