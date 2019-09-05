<cfparam name="args" default="#structNew()#" />
<cfoutput>
<!--- TODO: title --->
<cfif prc.itemCount >
	#ag.quickFeedItems( args=args )#
	<div class="contentBar">
		#ag.quickPaging()#
	</div>
<cfelse>
	<div>No results found.</div>
</cfif>
</cfoutput>