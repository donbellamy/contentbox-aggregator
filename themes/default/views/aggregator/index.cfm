<cfparam name="args.print" default="false" />
<cfparam name="args.sidebar" default="true" />
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
			<h1 style="#bodyHeaderH1Style#">#prc.page.getTitle()#</h1>
		</div>
	</div>
</div>
<section id="body-main">
	<div class="container">
		<cfif !args.print >
			<div class="row">
				<div id="body-breadcrumbs" class="col-xs-12 col-sm-9">
					<i class="fa fa-home"></i> #ag.breadCrumbs( separator="<i class='fa fa-angle-right'></i> " )#
				</div>
				<cfif cb.setting("cb_content_uiexport") >
					<div class="hidden-xs col-sm-3">
						<div class="btn-group pull-right">
							<button type="button" class="btn btn-success btn-sm dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" title="Export Page...">
								<i class="fa fa-print"></i> <span class="caret"></span>
							</button>
							<ul class="dropdown-menu">
								<li><a href="#ag.linkExport( "print" )#" target="_blank">Print Format</a></li>
								<li><a href="#ag.linkExport( "pdf" )#" target="_blank">PDF</a></li>
							</ul>
						</div>
					</div>
				</cfif>
			</div>
		</cfif>
		<div class="row">
			<div class="<cfif args.sidebar >col-sm-9<cfelse>col-sm-12</cfif>">
				#cb.event("aggregator_preFeedItemsDisplay")#
				<cfif prc.itemCount >
					<cfif prc.template EQ "feeditem" >
						#ag.quickFeedItems( template=prc.template, args=args )#
					<cfelse>
						<div class="row display-flex">
							#ag.quickFeedItems( template=prc.template, args=args )#
						</div>
					</cfif>
					<cfif !args.print >
						<div class="contentBar">
							#ag.quickPaging( label=prc.pagingLabel )#
						</div>
					</cfif>
				<cfelse>
					<div>No results found.</div>
				</cfif>
				#cb.event("aggregator_postFeedItemsDisplay")#
			</div>
			<cfif args.sidebar >
				<div class="col-sm-3" id="blog-sidenav">
					#cb.quickView( view="aggregator/_sidebar", args=args )#
				</div>
			</cfif>
		</div>
	</div>
</section>
</cfoutput>