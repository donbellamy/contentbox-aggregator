<cfoutput>
<cfloop array="#prc.topContent#" index="item">
	<tr>
		<td>
			<a href="#prc.agHelper.linkContent( item )#">#item.getTitle()#</a>
		</td>
		<td class="text-center">#item.getNumberOfHits()#</td>
	</tr>
</cfloop>
</cfoutput>