<cfoutput>

#cb.event( "cbui_BeforeSideBar" )#

<cfif cb.themeSetting( "showCategoriesBlogSide", true )>
	<div class="panel panel-default">
		<div class="panel-heading">
			<h4>Categories</h4>
		</div>
		#cb.widget( "Categories@contentbox-rss-aggregator" )#
	</div>
</cfif>

<cfif cb.themeSetting( "showRecentEntriesBlogSide", true ) >
	<div class="panel panel-default">
		<div class="panel-heading">
			<h4>Recent Items</h4>
		</div>
		#cb.widget( "FeedItems@contentbox-rss-aggregator" )#
	</div>
</cfif>

<!--- TODO: if RSS is on --->
<cfif cb.themeSetting( "showSiteUpdatesBlogSide", true )>
	<div class="panel panel-default">
		<div class="panel-heading">
			<h4>News Updates</h4>
		</div>
		<ul>
			<li><a href='#ag.linkRSS()#' title="Subscribe to our RSS Feed!"><i class="fa fa-rss"></i></a> <a href='#ag.linkRSS()#' title="Subscribe to our RSS Feed!">RSS Feed</a></li>
		</ul>
	</div>
</cfif>

<!--- TODO: Archives --->
<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Archives</h4>
	</div>
	#cb.widget( "Archives@contentbox-rss-aggregator" )#
</div>

<!--- TODO: Search --->

#cb.event( "cbui_afterSideBar" )#

</cfoutput>