<cfoutput>
	<nav class="navbar navbar-default" id="header-main">
		<div class="container">

			<div class="navbar-header" >
				<button type="button" id="cb-navbar-toggle" class="navbar-toggle collapsed" data-toggle="collapse" data-target="##cb-nav-collapse">
					<span class="sr-only">Toggle navigation</span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</button>
				<cfif !len( cb.themeSetting( 'headerLogo' ) ) >
					<a href="#cb.linkHome()#" class="navbar-brand" title="#cb.siteTagLine()#" data-toggle="tooltip"><strong>#cb.siteName()#</strong></a>
				<cfelse>
					<a href="#cb.linkHome()#" class="navbar-brand brand-img" title="#cb.siteTagLine()#" data-toggle="tooltip"><img src="#cb.themeSetting( 'headerLogo' )#" alt="#cb.siteName()#"></a>
				</cfif>
			</div>

			<!--- Generate Menu --->
			<div class="collapse navbar-collapse" id="cb-nav-collapse">
				<ul class="nav navbar-nav navbar-right">
					<cfset menuData = cb.rootMenu( type="data", levels="2" )>
					<!--- Iterate and build pages --->
					<cfloop array="#menuData#" index="menuItem">
						<cfif structKeyExists( menuItem, "subPageMenu" )>
							<li class="dropdown">
								<a href="#menuItem.link#" class="dropdown-toggle" data-toggle="dropdown">#menuItem.title# <b class="caret"></b></a>
								#buildSubMenu( menuData=menuItem.subPageMenu, parentLink=menuItem.link, parentTitle=menuItem.title )#
							</li>
						<cfelse>
							<li<cfif ag.isPageView() AND event.buildLink( cb.getCurrentPage().getSlug() ) eq menuItem.link> class="active"</cfif>>
								<a href="#menuItem.link#">#menuItem.title#</a>
							</li>
						</cfif>
					</cfloop>
					<!--- Blog Link, verify active --->
					<cfif ( !prc.cbSettings.cb_site_disable_blog )>
						<li<cfif cb.isBlogView()> class="active"</cfif>>
							<a href="#cb.linkBlog()#">Blog</a>
						</li>
					</cfif>
				</ul>

			</div>
		</div>
	</nav>

	<cfif cb.themeSetting( "showSiteSearch", true )>
	<!--- Search Bar --->
	<div id="body-search">
		<div class="container">
			<form id="searchForm" name="searchForm" method="post" action="#cb.linkContentSearch()#">
				<div class="input-group">
					<input type="text" class="form-control" placeholder="Enter search terms..." name="q" id="q" value="#cb.getSearchTerm()#">
					<span class="input-group-btn">
						<button type="submit" class="btn btn-default">Search</button>
					</span>
				</div>
			</form>
		</div>
	</div>
	</cfif>

	<cfscript>
	any function buildSubMenu( required menuData, required parentLink, required parentTitle ){
		var menu = '<ul class="dropdown-menu">';

		// Parent
		menu &= '<li><a href="#parentLink#"><i class="fa fa-chevron-down"></i> <strong>#parentTitle#</strong></a></li><li role="separator" class="divider"></li>';

		for( var menuItem in arguments.menuData ){
			if( !structKeyExists( menuItem, "subPageMenu" ) ){
				menu &= '<li><a href="#menuItem.link#">#menuItem.title#</a></li>';
			} else {
				menu &= '<li class="dropdown-submenu"><a href="#menuItem.link#" class="dropdown-toggle" data-toggle="dropdown">#menuItem.title#</a>';
				menu &= buildSubMenu( menuItem.subPageMenu, menuItem.link, menuItem.parentTitle );
				menu &= '</li>';
			}
		}
		menu &= '</ul>';

		return menu;
	}
	</cfscript>
	</cfoutput>