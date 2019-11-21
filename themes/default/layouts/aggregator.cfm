<cfparam name="args" default="#structNew()#" />
<cfparam name="args.print" default="false" />
<cfparam name="args.sidebar" default="true" />
<cfparam name="prc.args" default="#structNew()#" />
<cfset structAppend( args, prc.args ) />
<cfoutput>
<!DOCTYPE html>
<html lang="en">
<head>
	<!--- Portal includes --->
	#cb.quickView( "aggregator/_includes" )#
	<!--- ContentBoxEvent --->
	#cb.event( "cbui_beforeHeadEnd" )#
</head>
<body>
	<!--- ContentBoxEvent --->
	#cb.event( "cbui_afterBodyStart" )#
	<!--- Header --->
	#cb.quickView( view='_header' )#
	<!--- ContentBoxEvent --->
	#cb.event( "cbui_beforeContent" )#
	<!--- Main View --->
	#ag.mainView( args=args )#
	<!--- ContentBoxEvent --->
	#cb.event( "cbui_afterContent" )#
	<!--- Footer --->
	#cb.quickView( view='_footer' )#
	<!--- ContentBoxEvent --->
	#cb.event( "cbui_beforeBodyEnd" )#
</body>
</html>
</cfoutput>