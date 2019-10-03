<cfparam name="args" default="#structNew()#" />
<cfparam name="args.title" default="" />
<cfparam name="args.titleLevel" default="2" />
<cfoutput>
<cfif len( args.title ) >
	<h#args.titleLevel#>#args.title#</h#args.titleLevel#>
</cfif>
#cb.event("aggregator_preFeedItemsDisplay")#
<cfif prc.itemCount >
	<div class="row display-flex">
		#ag.quickFeedItems( template="podcast", args=args )#
	</div>
	<div class="contentBar">
		#ag.quickPaging()#
	</div>
<cfelse>
	<div>No results found.</div>
</cfif>
#cb.event("aggregator_postFeedItemsDisplay")#
<style>
	audio {
		max-width: 95%;
	}
	.img-thumbnail {
		width: 200px;
		height: 200px;
	}
	.row.display-flex {
		display: flex;
		flex-wrap: wrap;
	}
	.row.display-flex > [class*='col-'] {
		display: flex;
		flex-direction: column;
		margin-bottom: 2rem;
	}
</style>
</cfoutput>