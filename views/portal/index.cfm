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
		<!--- Title --->
		<div class="underlined-title">
			<h1 style="#bodyHeaderH1Style#">News</h1><!--- TODO: Make setting --->
		</div>
	</div>
</div>
<!--- Body Main --->
<section id="body-main">
	<div class="container">	
		<div class="row">
			<!--- Content --->
			<div class="col-sm-9">
				#cb.event( "agportal_preIndexDisplay" )#
				<!---#cb.quickEntries()#--->
				#cb.event( "agportal_postIndexDisplay" )#
			</div>
		</div>
	</div>
</div>
</cfoutput>