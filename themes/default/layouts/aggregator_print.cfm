<cfparam name="args.print" default="true" />
<cfparam name="args.sidebar" default="false" />
<!--- Append prc.args since we can't pass them to the layout/view (bug?) --->
<cfif structKeyExists( prc, "args" ) >
	<cfset args.append( prc.args ) />
</cfif>
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
	<!--- Page Includes --->
	#cb.quickView( "aggregator/_includes" )#
	<!--- ContentBoxEvent --->
	#cb.event("cbui_beforeHeadEnd")#
</head>
<body>
	<!--- ContentBoxEvent --->
	#cb.event("cbui_afterBodyStart")#
	<!--- Main Body --->
	<section id="body-main">
		<div class="container">
			<!--- ContentBoxEvent --->
			#cb.event("cbui_beforeContent")#
			<!--- Main View --->
			#ag.mainView( args=args )#
			<!--- ContentBoxEvent --->
			#cb.event("cbui_afterContent")#
		</div>
	</section>
	#cb.quickView(view='_footer')#
	<!--- ContentBoxEvent --->
	#cb.event( "cbui_beforeBodyEnd" )#
</body>
</html>
</cfoutput>