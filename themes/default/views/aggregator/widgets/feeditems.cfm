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
	<cfif prc.template EQ "feeditem" >
		#ag.quickFeedItems( template=prc.template, groupByDate=prc.groupByDate, args=args )#
	<cfelse>
		<div class="row display-flex">
			#ag.quickFeedItems( template=prc.template, groupByDate=prc.groupByDate, args=args )#
		</div>
	</cfif>
	<cfif !args.print >
		<div class="contentBar">
			#ag.quickPaging( label=prc.pagingLabel )#
		</div>
	</cfif>
<cfelse>
	<div>No results found.</div>
</cfif>
#cb.event("aggregator_postFeedItemsDisplay")#
</cfoutput>