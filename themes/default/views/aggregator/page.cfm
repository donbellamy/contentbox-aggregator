<cfoutput>
<cfparam name="args.print" default="false" />
<cfparam name="args.sidebar" default="true" />
<cfif cb.isHomePage() >
	<cfset styleHTML = "" />
	<cfif cb.themeSetting( 'hpHeaderImgBg' ) is not "" >
		<cfset styleHTML = styleHTML & 'background-image: url(' & cb.themeSetting( 'hpHeaderImgBg' ) & ');'>
	</cfif>
	<cfif cb.themeSetting( 'hpHeaderBgPos' ) is not "" >
		<cfset styleHTML = styleHTML & 'background-position: ' & cb.themeSetting( 'hpHeaderBgPos' ) & ';'>
	</cfif>
	<cfif cb.themeSetting( 'hpHeaderBgPaddingTop' ) is not "" >
		<cfset styleHTML = styleHTML & 'padding-top: ' & cb.themeSetting( 'hpHeaderBgPaddingTop' ) & ';'>
	</cfif>
	<cfif cb.themeSetting( 'hpHeaderBgPaddingBottom' ) is not "" >
		<cfset styleHTML = styleHTML & 'padding-bottom: ' & cb.themeSetting( 'hpHeaderBgPaddingBottom' ) & ';'>
	</cfif>
	<div class="body-header-jumbotron jumbotron #cb.themeSetting( 'hpHeaderBg' )#-bg" style="#styleHTML#">
		<div class="container">
			<h1>#cb.themeSetting( 'hpHeaderTitle' )#</h1>
			<p>#cb.themeSetting( 'hpHeaderText' )#</p>
			<cfif cb.themeSetting( 'hpHeaderBtnText' ) neq "">
				<p>
					<a class="btn btn-#cb.themeSetting( 'hpHeaderBtnStyle' )# btn-lg" href="#cb.themeSetting( 'hpHeaderLink' )#" role="button">
						#cb.themeSetting( 'hpHeaderBtnText' )#
					</a>
				</p>
			</cfif>
		</div>
	</div>
<cfelse>
	<cfset bodyHeaderStyle = "" />
	<cfset bodyHeaderH1Style = "" />
	<cfif cb.themeSetting( 'overrideHeaderColors' ) >
		<cfif len( cb.themeSetting( 'overrideHeaderBGColor' ) ) >
			<cfset bodyHeaderStyle = bodyHeaderStyle & 'background-color: ' & cb.themeSetting( 'overrideHeaderBGColor' ) & ';' />
		</cfif>
		<cfif len( cb.themeSetting( 'overrideHeaderTextColor' ) )>
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
</cfif>
#cb.event( "cbui_prePageDisplay" )#
<section id="body-main">
	<div class="container">
		<cfif !args.print AND !isNull( "prc.page" ) AND prc.page.getSlug() neq cb.getHomePage() >
			<div class="row">
				<div id="body-breadcrumbs" class="col-xs-12 col-sm-9">
					<i class="fa fa-home"></i>
					#cb.breadCrumbs( separator="<i class='fa fa-angle-right'></i> " )#
				</div>
				<cfif cb.setting("cb_content_uiexport") >
					<div class="hidden-xs col-sm-3">
						<div class="btn-group pull-right">
							<button type="button" class="btn btn-success btn-sm dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" title="Export Page...">
								<i class="fa fa-print"></i> <span class="caret"></span>
							</button>
							<ul class="dropdown-menu">
								<li><a href="#cb.linkPage( cb.getCurrentPage() )#.print" target="_blank">Print Format</a></li>
								<li><a href="#cb.linkPage( cb.getCurrentPage() )#.pdf" target="_blank">PDF</a></li>
							</ul>
						</div>
					</div>
				</cfif>
			</div>
		</cfif>
		<div class="row">
			<div class="<cfif args.sidebar >col-sm-9<cfelse>col-sm-12</cfif>">
				#prc.page.renderContent()#
				<cfif cb.isCommentsEnabled( prc.page ) >
					<section id="comments">
						#html.anchor( name="comments" )#
						<div class="post-comments">
							<div class="infoBar">
								<p><button class="button2" onclick="toggleCommentForm()"> <i class="icon-comments"></i> Add Comment (#prc.page.getNumberOfApprovedComments()#)</button></p>
							</div>
							<br/>
						</div>
						<div class="separator"></div>
						<div id="commentFormShell">
							<div class="row">
								<div class="col-sm-12">
									#cb.quickCommentForm( prc.page )#
								</div>
							</div>
						</div>
						<hr />
						<div id="comments">
							#cb.quickComments()#
						</div>
					</section>
				</cfif>
			</div>
			<cfif args.sidebar >
				<div class="col-sm-3" id="blog-sidenav">
					#cb.quickView( view='aggregator/_sidebar' )#
				</div>
			</cfif>
		</div>
	</div>
</section>
#cb.event("cbui_postPageDisplay")#
</cfoutput>