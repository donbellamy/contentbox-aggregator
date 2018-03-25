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
			<h1 style="#bodyHeaderH1Style#">#prc.agSettings.ag_portal_title#</h1>
		</div>
	</div>
</div>
<section id="body-main">
	<div class="container">
		<div class="row">
			<div class="<cfif args.sidebar >col-sm-9<cfelse>col-sm-12</cfif>">
				#cb.event( "aggregator_preArchivesDisplay" )#
				<cfif val( rc.year ) >
					<div class="alert alert-info">
						<a class="btn btn-primary pull-right btn-sm" href="#ag.linkPortal()#" title="Clear archives and view all items">Clear Archives</a>
						<strong>#prc.formattedDate#</strong>
						<br/><small>Archives</small>
					</div>
				</cfif>
				<cfif prc.itemCount >
					#ag.quickFeedItems()#
					<div class="contentBar">
						#ag.quickPaging()#
					</div>
				<cfelse>
					<div>No results found.</div>
				</cfif>
				#cb.event( "aggregator_postArchivesDisplay" )#
			</div>
			<cfif args.sidebar >
				<div class="col-sm-3" id="blog-sidenav">
					#renderView( view="../themes/default/views/_aggregator_sidebar", args=args )#
				</div>
			</cfif>
		</div>
	</div>
</div>
</cfoutput>