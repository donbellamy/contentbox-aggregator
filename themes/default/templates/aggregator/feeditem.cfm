<cfparam name="args.openNewWindow" default="#ag.setting('ag_display_link_new_window',true)#" />
<cfparam name="args.useNoFollow" default="#ag.setting('ag_display_link_as_nofollow',true)#" />
<cfparam name="args.showSource" default="#ag.setting('ag_display_source_show',true)#" />
<cfparam name="args.showAuthor" default="#ag.setting('ag_display_author_show',true)#" />
<cfparam name="args.showExcerpt" default="#ag.setting('ag_display_excerpt_show',true)#" />
<cfparam name="args.characterLimit" default="#ag.setting('ag_display_excerpt_character_limit',500)#" />
<cfparam name="args.excerptEnding" default="#ag.setting('ag_display_excerpt_ending','...')#" />
<cfparam name="args.showReadMore" default="#ag.setting('ag_display_read_more_show',true)#" />
<cfparam name="args.readMoreText" default="#ag.setting('ag_display_read_more_text','Read more...')#" />

<cfoutput>

<div class="post" id="feeditem_#feedItem.getContentID()#">
	<div class="post-title">
		<h2>
			<a href="#ag.linkFeedItem( feedItem )#"
				<cfif args.openNewWindow >target="_blank"</cfif>
				<cfif args.useNoFollow >rel="nofollow"</cfif>
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
				<time datetime="#feedItem.getDisplayDatePublished()#" title="#feedItem.getDisplayDatePublished()#">#ag.timeAgo( feedItem.getDisplayDatePublished() )#</time>
			</div>
		</div>
	</div>
	<cfif args.showExcerpt >
		<cfset featuredImageUrl = ag.getFeedItemFeaturedImageUrl( feedItem ) />
		<div class="post-content row">
			<cfif len( featuredImageUrl ) >
				<div class="col-sm-3">
					<a class="thumbnail" href="#ag.linkFeedItem( feedItem )#"
					<cfif args.openNewWindow >target="_blank"</cfif>
					<cfif args.useNoFollow >rel="nofollow"</cfif>
					title="#encodeForHtmlAttribute( feedItem.getTitle() )#"><img title="#encodeForHtmlAttribute( feedItem.getTitle() )#" src="#featuredImageUrl#" /></a>
				</div>
			</cfif>
			<div class="<cfif len( featuredImageUrl ) >col-sm-9<cfelse>col-sm-12</cfif>">
				<cfif feedItem.hasExcerpt() >
					#feedItem.renderExcerpt()#
				<cfelse>
					#ag.renderContentExcerpt( feedItem, val( args.characterLimit ), args.excerptEnding )#
				</cfif>
				<cfif args.showReadMore >
					<div class="post-more">
						<a href="#ag.linkFeedItem( feedItem )#"
							<cfif args.openNewWindow >target="_blank"</cfif>
							<cfif args.useNoFollow >rel="nofollow"</cfif>
							title="#encodeForHtmlAttribute( feedItem.getTitle() )#"><button class="btn btn-success">#args.readMoreText#</button></a>
					</div>
				</cfif>
			</div>
		</div>
	</cfif>
</div>

</cfoutput>