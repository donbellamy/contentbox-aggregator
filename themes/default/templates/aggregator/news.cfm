<cfparam name="args" default="#structNew()#" />
<cfoutput>
<!--- TODO: title --->
#cb.event("aggregator_preFeedItemsDisplay")#
<cfif prc.itemCount >
	#ag.quickFeedItems( args=args )#
	<div class="contentBar">
		#ag.quickPaging()#
	</div>
<cfelse>
	<div>No results found.</div>
</cfif>
#cb.event("aggregator_postFeedItemsDisplay")#
</cfoutput>