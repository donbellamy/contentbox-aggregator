<cfparam name="args" default="#structNew()#" />
<cfparam name="args.title" default="" />
<cfparam name="args.titleLevel" default="2" />
<cfoutput>
<cfif len( args.title ) >
	<h#args.titleLevel#>#args.title#</h#args.titleLevel#>
</cfif>
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