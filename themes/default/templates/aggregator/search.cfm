<cfparam name="args" default="#structNew()#" />
<cfoutput>
<div class="searchResults">
	<div class="well well-sm searchResultsCount">
		Found <strong>#args.total#</strong> results in <strong>#args.time#</strong>ms!
	</div>
	<cfloop array="#args.items#" index="item">
		<div class="panel panel-default">
			<div class="panel-heading">
				<a href="#ag.linkContent(item)#" class="panel-title">#item.getTitle()#</a>
			</div>
			<div class="panel-body">
				<p>#highlightSearchTerm( args.searchTerm, stripHTML( item.renderContent() ))#</p>
				<cite><span class="label label-primary">#item.getContentType()#</span> : <a href="#ag.linkContent(item)#">#ag.linkContent(item)#</a></cite><br/>
			</div>
			<cfif item.hasCategories() >
				<div class="panel-footer">
					<cite>
						Categories:
						<cfloop list="#item.getCategoriesList()#" index="category">
							<span class="label label-primary">#category#</span>
						</cfloop>
					</cite>
				</div>
			</cfif>
		</div>
	</cfloop>
</div>
</cfoutput>
<cfscript>
private function stripHTML( string stringTarget="" ) {
	return REReplaceNoCase( arguments.stringTarget, "<[^>]*>", "", "ALL" );
}
function highlightSearchTerm( required string term, required string content ) {
	var match = findNoCase( arguments.term, arguments.content );
	var end	= 0;
	var excerpt = "";
	if ( match LTE 250 ) {
		match = 1;
	}
	end = match + len( arguments.term ) + 500;
	if( len( arguments.content ) GT 500 ) {
		if ( match GT 1 ) {
			excerpt = "..." & mid( arguments.content, match-250, end-match );
		} else {
			excerpt = left( arguments.content, end );
		}
		if ( len( arguments.content ) GT end ) {
			excerpt &= "...";
		}
	} else {
		excerpt = arguments.content;
	}
	try{
		excerpt = reReplaceNoCase( excerpt, "(#arguments.term#)", "<strong>\1</strong>", "all" );
	} catch ( any e ) {}
	return excerpt;
}
</cfscript>