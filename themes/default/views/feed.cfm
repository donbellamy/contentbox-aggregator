<cfoutput>
<cfset bodyHeaderStyle = "" />
<cfset bodyHeaderH1Style = "" />
<cfif cb.themeSetting( 'overrideHeaderColors' ) >
	<cfif len( cb.themeSetting( 'overrideHeaderBGColor' ) ) >
		<cfset bodyHeaderStyle = bodyHeaderStyle & 'background-color: ' & cb.themeSetting( 'overrideHeaderBGColor' ) & ';' />
	</cfif>
	<cfif len( cb.themeSetting( 'overrideHeaderTextColor' ) ) >
		<cfset bodyHeaderH1Style = bodyHeaderH1Style & 'color: ' & cb.themeSetting( 'overrideHeaderTextColor' ) & ';' />
	</cfif>
</cfif>
<div id="body-header" style="#bodyHeaderStyle#">
	<div class="container">
		<div class="underlined-title">
			<h1 style="#bodyHeaderH1Style#">#prc.feed.getTitle()#</h1>
			<cfif len( prc.feed.getTagLine() ) >
				<div class="text-center">#prc.feed.getTagLine()#</div>
			</cfif>
		</div>
	</div>
</div>
<section id="body-main">
	<div class="container">
		<div class="row">
			<div class="<cfif args.sidebar >col-sm-9<cfelse>col-sm-12</cfif>">
				#cb.event( "aggregator_preFeedDisplay" )#
				<cfif len( rc.author ) >
					<div class="alert alert-info">
						<a class="btn btn-primary pull-right btn-sm" href="#ag.linkFeed( prc.feed )#" title="Clear author and view all items">Clear Author</a>
						<strong>#rc.author#</strong>
						<br/><small>Author Results</small>
					</div>
				</cfif>
				<cfif prc.itemCount >
					#ag.quickFeedItems()#
					<div class="contentBar">
						#ag.quickPaging()#
					</div>
				<cfelse>
					<div>No results found.</div>
				</cfif>
				#cb.event( "aggregator_postFeedDisplay" )#
			</div>
			<cfif args.sidebar >
				<div class="col-sm-3" id="blog-sidenav">
					#cb.quickView( view="_aggregator_sidebar", args=args )#
				</div>
			</cfif>
		</div>
	</div>
</div>
</cfoutput>