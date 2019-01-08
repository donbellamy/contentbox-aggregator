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
			<h1 style="#bodyHeaderH1Style#">#prc.agSettings.ag_portal_name#</h1>
		</div>
	</div>
</div>
<section id="body-main">
	<div class="container">
		<div class="row text-center">
			<h3>Thanks for visiting #cb.siteName()#</h3>
			<p>We're transferring you to <a href="#prc.feedItem.getItemUrl()#" rel="nofollow" title="#encodeForHtmlAttribute( prc.feedItem.getFeed().getTitle() )#">#prc.feedItem.getFeed().getTitle()#</a>.</p>
		</div>
		<div class="row text-center hidden" id="message">
			<p>
				<strong>Article Not Loading?</strong><br/>
				Try clicking <a href="#prc.feedItem.getItemUrl()#" rel="nofollow" title="#encodeForHtmlAttribute( prc.feedItem.getTitle() )#">here</a>.
			</p>
		</div>
	</div>
</section>
<noscript>
	<meta http-equiv="Refresh" content="1; URL=#prc.feedItem.getItemUrl()#" />
</noscript>
<script>
	var conf = {
		url: "#prc.feedItem.getItemUrl()#",
		delay: 1000,
		timeout: 5000
	};
	(function() {
		function redirect() {
			setTimeout( doRedirect, conf.delay );
			setTimeout( displayMessage, conf.timeout );
		}
		function doRedirect() {
			if ( typeof( window.location.replace ) == "function" ) {
				window.location.replace( conf.url );
				return;
			}
			if ( typeof( window.location.assign ) == "function" ) {
				window.location.assign( conf.url );
				return;
			}
			window.location.href = conf.url;
		}
		function displayMessage() {
			var element = document.getElementById("message");
			element.className = element.className.replace(/\bhidden\b/g, "");
		}
		window.onload=redirect;
	})();
</script>
</cfoutput>