<cfparam name="args" default="#structNew()#" />
<cfoutput>
<!--- TODO: title --->
#cb.event("aggregator_preFeedsDisplay")#
<cfif prc.itemCount >
	#ag.quickFeeds()#
	<div class="contentBar">
		#ag.quickPaging( type="feeds" )#
	</div>
<cfelse>
	<div>No results found.</div>
</cfif>
#cb.event("aggregator_postFeedsDisplay")#
</cfoutput>