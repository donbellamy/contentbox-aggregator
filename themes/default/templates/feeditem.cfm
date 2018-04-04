<cfparam name="args.openNewWindow" default="#ag.setting('ag_portal_use_interstitial_page')#" />
<cfparam name="args.showSource" default="true" />
<cfparam name="args.showAuthor" default="true" />
<cfparam name="args.showExcerpt" default="true" />
<cfparam name="args.characterLimit" default="500" />
<cfparam name="args.excerptEnding" default="..." />
<cfparam name="args.showReadMore" default="true" />
<cfparam name="args.readMoreText" default="Read more..." />

<cfoutput>
<div class="post" id="feeditem_#feedItem.getContentID()#">
	<div class="post-title">
		<h2>
			<a href="#ag.linkFeedItem( feedItem )#"
				<cfif args.openNewWindow >target="_blank"</cfif>
				rel="nofollow<cfif args.openNewWindow > noopener</cfif>"
				title="#encodeForHtmlAttribute( feedItem.getTitle() )#">#feedItem.getTitle()#</a>
		</h2>
		<div class="row">
			<cfif args.showSource OR args.showAuthor >
				<div class="col-sm-7 pull-left">
					<cfif args.showSource >
						<i class="fa fa-rss"></i>
						<a href="#ag.linkFeed( feedItem.getFeed() )#" title="#encodeForHTMLAttribute( feeditem.getFeed().getTitle() )#">#feeditem.getFeed().getTitle()#</a>
					</cfif>
					<cfif len( feedItem.getItemAuthor() ) && args.showAuthor >
						<span class="text-muted">-</span>
						<i class="fa fa-user"></i>
						<a href="#ag.linkFeedItemAuthor( feedItem )#" title="#encodeForHTMLAttribute( feedItem.getItemAuthor() )#">#feedItem.getItemAuthor()#</a>
					</cfif>
				</div>
			</cfif>
			<div class="col-sm-5 pull-right text-right">
				<i class="fa fa-calendar"></i>
				<time datetime="#feedItem.getDisplayPublishedDate()#" title="#feedItem.getDisplayPublishedDate()#">#ag.timeAgo( feedItem.getDisplayPublishedDate() )#</time>
			</div>
		</div>
		<cfif feedItem.hasCategories() >
			<div class="row">
				<div class="col-sm-12">
					<i class="fa fa-tag"></i> #cb.quickCategoryLinks( feedItem )#
				</div>
			</div>
		</cfif>
	</div>
	<cfif args.showExcerpt >
		<cfset imageUrl = feedItem.getImageUrl() />
		<div class="post-content row">
			<cfif len( imageUrl ) >
				<div class="col-sm-3">
					<a class="thumbnail" href="#ag.linkFeedItem( feedItem )#"
						<cfif args.openNewWindow >target="_blank"</cfif>
						rel="nofollow<cfif args.openNewWindow > noopener</cfif>"
						title="#encodeForHtmlAttribute( feedItem.getTitle() )#"><img title="#encodeForHtmlAttribute( feedItem.getTitle() )#" src="#imageUrl#" /></a>
				</div>
			</cfif>
			<div class="<cfif len( imageUrl ) >col-sm-9<cfelse>col-sm-12</cfif>">
				<cfif feedItem.hasExcerpt() >
					#feedItem.renderExcerpt()#
				<cfelse>
					#feedItem.getContentExcerpt( val( args.characterLimit ), args.excerptEnding )#
				</cfif>
				<cfif args.showReadMore >
					<div class="post-more">
						<a href="#ag.linkFeedItem( feedItem )#"
							<cfif args.openNewWindow >target="_blank"</cfif>
							rel="nofollow<cfif args.openNewWindow > noopener</cfif>"
							title="#encodeForHtmlAttribute( feedItem.getTitle() )#"><button class="btn btn-success">#args.readMoreText#</button></a>
					</div>
				</cfif>
			</div>
		</div>
	</cfif>
</div>
</cfoutput>