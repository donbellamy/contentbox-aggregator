<cfoutput>
#cb.event("aggregator_preSideBarDisplay")#
<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Feed Categories</h4>
	</div>
	#cb.widget("FeedCategories@contentbox-aggregator")#
</div>
<div class="panel panel-default">
	<div class="panel-heading">
		<h4>News Categories</h4>
	</div>
	#cb.widget("Categories@contentbox-aggregator",{useDropdown=true})#
</div>
<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Recent News</h4>
	</div>
	#cb.widget("FeedItemsList@contentbox-aggregator")#
</div>
<div class="panel panel-default">
	<div class="panel-heading">
		<h4>News Archives</h4>
	</div>
	#cb.widget("Archives@contentbox-aggregator",{useDropdown=true})#
</div>
<cfif ag.setting("rss_enable") >
	<div class="panel panel-default">
		<div class="panel-heading">
			<h4>News Updates</h4>
		</div>
		#cb.widget("RSS@contentbox-aggregator")#
	</div>
</cfif>
<div class="panel panel-default">
	<div class="panel-heading">
		<h4>Search</h4>
	</div>
	#cb.widget("SearchForm@contentbox-aggregator")#
</div>
#cb.event("aggregator_postSideBarDisplay")#
</cfoutput>