<cfoutput>
<ul>
	<li><a title="View Entries" href="#event.buildLink(prc.xehEntries)#">#prc.entriesCount# Entries</a> </li>
	<li><a title="View Pages" href="#event.buildLink(prc.xehPages)#">#prc.pagesCount# Pages</a> </li>
	<li><a title="View Categories" href="#event.buildLink(prc.xehCategories)#">#prc.categoriesCount# Categories</a></li>
	<li><a title="View Feeds" href="#event.buildLink(prc.xehFeeds)#">#prc.feedsCount# Feeds</a></li>
	<li><a title="View Feed Items" href="#event.buildLink(prc.xehFeedItems)#">#prc.feedItemsCount# Feed Items</a></li>
</ul>
</cfoutput>