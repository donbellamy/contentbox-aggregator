<cfoutput>

#cb.event( "cbui_BeforeSideBar" )#

<cfif cb.themeSetting( "showCategoriesBlogSide", true )>
	<div class="panel panel-default">
		<div class="panel-heading">
			<h4>Categories</h4>
		</div>
		<ul>
			#ag.quickCategories()#		
		</ul>
	</div>
	</cfif>

<cfif cb.themeSetting( "showRecentEntriesBlogSide", true ) >
	<div class="panel panel-default">
		<div class="panel-heading">
			<h4>Recent Items</h4>
		</div>
		#cb.widget( "RecentItems@contentbox-rss-aggregator" )#
	</div>
</cfif>

#cb.event( "cbui_afterSideBar" )#

</cfoutput>