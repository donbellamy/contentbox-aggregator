<cfparam name="args.print" default="false" />
<cfparam name="args.title" default="" />
<cfparam name="args.titleLevel" default="2" />
<cfoutput>
<cfif len( args.title ) >
	<h#args.titleLevel#>#args.title#</h#args.titleLevel#>
</cfif>
#cb.event("aggregator_preFeedsDisplay")#
<cfif prc.itemCount >
	#ag.quickFeeds( args=args )#
	<cfif !args.print >
		<div class="contentBar">
			#ag.quickPaging( label="feeds" )#
		</div>
	</cfif>
<cfelse>
	<div>No results found.</div>
</cfif>
#cb.event("aggregator_postFeedsDisplay")#
</cfoutput>