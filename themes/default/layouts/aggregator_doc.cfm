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
			<div class="row">
				<div class="col-sm-12">
					<!--- ContentBoxEvent --->
					#cb.event("cbui_beforeContent")#
					<!--- Main View --->
					#ag.mainView( args={ sidebar=true, print=true } )#
					<!--- ContentBoxEvent --->
					#cb.event("cbui_afterContent")#
				</div>
			</div>
		</div>
	</section>
	#cb.quickView(view='_footer')#
	<!--- ContentBoxEvent --->
	#cb.event( "cbui_beforeBodyEnd" )#
</body>
</html>
</cfoutput>