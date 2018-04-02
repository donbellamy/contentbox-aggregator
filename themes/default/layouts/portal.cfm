<cfoutput>
<!--- Global Layout Arguments --->
<cfparam name="args.print" default="false" />
<cfparam name="args.sidebar" default="true" />
<!DOCTYPE html>
<html lang="en">
<head>
	<!--- Portal includes --->
	#cb.quickView( "_portalincludes" )#
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
	<!--- TODO: USe an ag.mainView() soo we can override the page view if home page? --->
	<!--- TODO: YES!!! Greate our own version of the page view? that way we call in our sidebar, etc...  then can also have the portal widget in the content area --->
	<!--- Wont work - page view is hard set in page.cfc handler --->
	<!--- But maybe it can be overriden? --->
	#cb.mainView( args=args )#
	#ag.mainView( args=args )#

	<!--- What we can do is move the sidebar to this layout ? --->

	<!--- ContentBoxEvent --->
	#cb.event( "cbui_afterContent" )#
	<!--- Footer --->
	#cb.quickView( view='_footer' )#
	<!--- ContentBoxEvent --->
	#cb.event( "cbui_beforeBodyEnd" )#
</body>
</html>
</cfoutput>