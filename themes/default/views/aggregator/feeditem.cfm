<cfparam name="args.print" default="false" />
<cfparam name="args.sidebar" default="true" />
<cfparam name="args.showSource" default="true" />
<cfparam name="args.showAuthor" default="true" />
<cfoutput>
<cfset bodyHeaderStyle = "" />
<cfset bodyHeaderH1Style = "" />
<cfif cb.themeSetting( 'overrideHeaderColors' ) >
	<cfif len( cb.themeSetting( 'overrideHeaderBGColor' ) ) >
		<cfset bodyHeaderStyle = bodyHeaderStyle & 'background-color: ' & cb.themeSetting( 'overrideHeaderBGColor' ) & ';' />
	</cfif>
	<cfif len( cb.themeSetting( 'overrideHeaderTextColor' ) ) >
		<cfset bodyHeaderH1Style = bodyHeaderH1Style & 'color: ' & cb.themeSetting( 'overrideHeaderTextColor' ) & ';' />
	</cfif>
</cfif>
<div id="body-header" style="#bodyHeaderStyle#">
	<div class="container">
		<div class="underlined-title">
			<h1 style="#bodyHeaderH1Style#">#prc.feedItem.getTitle()#</h1>
		</div>
	</div>
</div>
<section id="body-main">
	<div class="container">
		<cfif !args.print >
			<div id="body-breadcrumbs" class="col-sm-9">
				<i class="fa fa-home"></i> #ag.breadCrumbs( separator="<i class='fa fa-angle-right'></i> " )#
			</div>
			<cfif cb.setting("cb_content_uiexport") >
				<div class="btn-group pull-right">
					<button type="button" class="btn btn-success btn-sm dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" title="Export Page...">
						<i class="fa fa-print"></i> <span class="caret"></span>
					</button>
					<ul class="dropdown-menu">
						<li><a href="#ag.linkExport( "print" )#" target="_blank">Print Format</a></li>
						<li><a href="#ag.linkExport( "pdf" )#" target="_blank">PDF</a></li>
					</ul>
				</div>
			</cfif>
		</cfif>
		<div class="<cfif args.sidebar >col-sm-9<cfelse>col-sm-12</cfif>">
			#cb.event("aggregator_preFeedItemDisplay", { feedItem=prc.feedItem })#
			<div class="post" id="post_#prc.feedItem.getContentID()#">
				<div class="post-title">
					<h2><a href="#ag.linkFeedItem( prc.feedItem )#" rel="bookmark" title="#encodeForHTMLAttribute( prc.feedItem.getTitle() )#">#prc.feedItem.getTitle()#</a></h2>
					<div class="row">
						<div class="col-sm-7 pull-left">
							<cfif args.showSource >
								<i class="fa fa-rss"></i>
								<a href="#ag.linkFeed( prc.feedItem.getFeed() )#" title="#encodeForHTMLAttribute( prc.feeditem.getFeed().getTitle() )#">#prc.feeditem.getFeed().getTitle()#</a>
							</cfif>
							<cfif len( prc.feedItem.getItemAuthor() ) && args.showAuthor >
								<cfif args.showSource ><span class="text-muted">-</span></cfif>
								<i class="icon-user"></i>
								<a href="#ag.linkFeedAuthor( prc.feedItem )#">#prc.feedItem.getItemAuthor()#</a>
							</cfif>
						</div>
						<div class="col-sm-5 pull-right text-right">
							<i class="fa fa-calendar"></i> #prc.feedItem.getDisplayPublishedDate()#
						</div>
					</div>
					<div class="post-content">
						#prc.feedItem.renderContent()#
					</div>
					<div class="row">
						<cfif prc.feedItem.hasCategories() >
							<div class="col-xs-12 pull-left">
								<i class="fa fa-tag"></i> Tags: #ag.quickCategoryLinks( prc.feedItem )#
							</div>
						</cfif>
					</div>
				</div>
			</div>
			#cb.event("aggregator_postFeedItemDisplay", { feedItem=prc.feedItem })#
		</div>
		<cfif args.sidebar >
			<div class="col-sm-3" id="blog-sidenav">
				#cb.quickView( view="aggregator/_sidebar", args=args )#
			</div>
		</cfif>
	</div>
</section>
<style>
	.post-content img {
		max-width: 90% !important;
	}
</style>
</cfoutput>