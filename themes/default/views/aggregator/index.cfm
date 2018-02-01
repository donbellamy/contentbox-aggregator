<cfoutput>
	<cfset bodyHeaderStyle = "" />
	<cfset bodyHeaderH1Style = "" />
	<cfif cb.themeSetting( 'overrideHeaderColors' ) >
		<cfif len( cb.themeSetting( 'overrideHeaderBGColor' ) ) >
			<cfset bodyHeaderStyle = bodyHeaderStyle & 'background-color: ' & cb.themeSetting( 'overrideHeaderBGColor' ) & ';'>
		</cfif>
		<cfif len( cb.themeSetting( 'overrideHeaderTextColor' ) ) >
			<cfset bodyHeaderH1Style = bodyHeaderH1Style & 'color: ' & cb.themeSetting( 'overrideHeaderTextColor' ) & ';'>
		</cfif>
	</cfif>		
	<div id="body-header" style="#bodyHeaderStyle#">
		<div class="container">
			<div class="underlined-title">
				<h1 style="#bodyHeaderH1Style#">#prc.agSettings.ag_portal_title#</h1>
			</div>
		</div>
	</div>
	<!--- Body Main --->
	<section id="body-main">
		<div class="container">	
			<div class="row">
				<!--- Content --->
				<div class="col-sm-9">

					#cb.event( "aggregator_prePortalIndexDisplay" )#
					
					<!--- TODO: Entries
						#cb.quickEntries()# --->

					<!--- TODO: Pagination --->
					<cfif prc.feedItemsCount >
						<div class="contentBar">
							<!---#ag.quickPaging()#--->
						</div>
					</cfif>

					#cb.event( "aggregator_postPortalIndexDisplay" )#

				</div>

				<!--- TODO: SideBar --->
				<!---<cfif args.sidebar>
					<div class="col-sm-3" id="blog-sidenav">
						#cb.quickView( view='_blogsidebar', args=args )#
					</div>
				</cfif>--->
				
			</div>
		</div>
	</div>
	</cfoutput>