<cfoutput>
<cfloop array="#prc.topCommented#" index="item">
	<tr>
		<td>
			<a href="#prc.agHelper.linkContent( item )#">#item.getTitle()#</a>
		</td>
		<td class="text-center">#item.getNumberOfComments()#</td>
	</tr>
</cfloop>
</cfoutput>