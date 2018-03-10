<cfoutput>

#cb.event( "cbui_BeforeSideBar" )#

<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Categories</h4>
	</div>
	#cb.widget( "Categories@contentbox-rss-aggregator" )#
</div>

<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Recent Items</h4>
	</div>
	#cb.widget( "FeedItems@contentbox-rss-aggregator" )#
</div>

<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Archives</h4>
	</div>
	#cb.widget( "Archives@contentbox-rss-aggregator" )#
</div>

<cfif ag.setting("ag_rss_enable") >
	<div class="panel panel-default">
		<div class="panel-heading">
			<h4>News Updates</h4>
		</div>
		<ul>
			<li><a href='#ag.linkRSS()#' title="Subscribe to our RSS Feed!"><i class="fa fa-rss"></i></a> <a href='#ag.linkRSS()#' title="Subscribe to our RSS Feed!">RSS Feed</a></li>
		</ul>
	</div>
</cfif>

<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Search</h4>
	</div>
	#cb.widget( "SearchForm@contentbox-rss-aggregator" )#
</div>

#cb.event( "cbui_afterSideBar" )#

</cfoutput>