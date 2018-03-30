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
			<h1 style="#bodyHeaderH1Style#">News Feeds</h1>
		</div>
	</div>
</div>
<section id="body-main">
	<div class="container">
		<div class="row">
			<div class="<cfif args.sidebar >col-sm-9<cfelse>col-sm-12</cfif>">
				#cb.event( "aggregator_preFeedsDisplay" )#
				<cfif prc.itemCount >
					#ag.quickFeeds()#
					<div class="contentBar">
						#ag.quickPaging()#
					</div>
				<cfelse>
					<div>No results found.</div>
				</cfif>
				#cb.event( "aggregator_postFeedsDisplay" )#
			</div>
			<cfif args.sidebar >
				<div class="col-sm-3" id="blog-sidenav">
					#cb.quickView( view="_portalsidebar", args=args )#
				</div>
			</cfif>
		</div>
	</div>
</div>
</cfoutput>