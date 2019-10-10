<cfparam name="args" default="#structNew()#" />
<cfparam name="args.print" default="false" />
<cfparam name="args.title" default="" />
<cfparam name="args.titleLevel" default="2" />
<cfoutput>
<cfif len( args.title ) >
	<h#args.titleLevel#>#args.title#</h#args.titleLevel#>
</cfif>
#cb.event("aggregator_preFeedItemsDisplay")#
<cfif prc.itemCount >
	#ag.quickFeedItems( args=args )#
	<cfif !args.print >
		<div class="contentBar">
			#ag.quickPaging()#
		</div>
	</cfif>
<cfelse>
	<div>No results found.</div>
</cfif>
#cb.event("aggregator_postFeedItemsDisplay")#
</cfoutput>