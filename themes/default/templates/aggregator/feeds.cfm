<cfparam name="args" default="#structNew()#" />
<cfoutput>
<!--- TODO: title --->
<cfif prc.itemCount >
	#ag.quickFeeds()#
	<div class="contentBar">
		#ag.quickPaging( type="feeds" )#
	</div>
<cfelse>
	<div>No results found.</div>
</cfif>
</cfoutput>