<cfoutput>
<!--- Global Layout Arguments --->
<cfparam name="args.print" default="false" />
<cfparam name="args.sidebar" default="true" />
<!DOCTYPE html>
<html lang="en">
<head>
	<!--- Portal includes --->
	#cb.quickView( "aggregator/_portalincludes" )#
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