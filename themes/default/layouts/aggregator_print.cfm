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
			#ag.mainView( args={ sidebar=false, print=true } )#
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