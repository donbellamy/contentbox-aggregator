<cfoutput>
<!--- post --->
<div class="post" id="feeditem_#feedItem.getContentID()#">
	<!--- Title --->
	<div class="post-title">
		<h2><a href="#ag.linkFeedItem( feedItem )#" title="#feedItem.getTitle()#">#feedItem.getTitle()#</a></h2> 
		<!--- TODO: link, rel ? --->
	</div>
</div>
</cfoutput>