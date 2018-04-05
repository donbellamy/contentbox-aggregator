<cfoutput>
#cb.event("aggregator_preSideBarDisplay")#
<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Categories</h4>
	</div>
	#cb.widget("Categories@contentbox-rss-aggregator")#
</div>
<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Recent Items</h4>
	</div>
	#cb.widget("FeedItems@contentbox-rss-aggregator")#
</div>
<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Archives</h4>
	</div>
	#cb.widget("Archives@contentbox-rss-aggregator")#
</div>
<cfif ag.setting("ag_rss_enable") >
	<div class="panel panel-default">
		<div class="panel-heading">
			<h4>News Updates</h4>
		</div>
		#cb.widget("RSS@contentbox-rss-aggregator")#
	</div>
</cfif>
<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Search</h4>
	</div>
	#cb.widget("SearchForm@contentbox-rss-aggregator")#
</div>
#cb.event("aggregator_postSideBarDisplay")#
</cfoutput>