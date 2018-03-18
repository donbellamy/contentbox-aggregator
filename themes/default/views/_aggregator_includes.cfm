<cfoutput>
<title>#cb.getContentTitle()#</title>
<!--- ********************************************************************************* --->
<!--- 					CSS 															--->
<!--- ********************************************************************************* --->

<!--- Swatch and Skin --->
<link rel="stylesheet" href="#cb.themeRoot()#/includes/css/bootstrap/swatches/#lcase( cb.themeSetting( 'cbBootswatchTheme', 'green' ))#/bootstrap.min.css?v=1" />
<link rel="stylesheet" href="#cb.themeRoot()#/includes/css/bootstrap/swatches/#lcase( cb.themeSetting( 'cbBootswatchTheme', 'green' ))#/skin.css?v=1" />

<!-- injector:css -->
<link rel="stylesheet" href="#cb.themeRoot()#/includes/css/218c7e65.theme.min.css">
<!-- endinjector -->

<cfif len( cb.themeSetting( 'cssStyleOverrides' ) )>
<style>
	#cb.themeSetting( 'cssStyleOverrides' )#
</style>
</cfif>

<!--- ********************************************************************************* --->
<!--- 					JAVASCRIPT														--->
<!--- ********************************************************************************* --->
<!-- injector:js -->
<script src="#cb.themeRoot()#/includes/js/ae19f5c3.theme.min.js"></script>
</cfoutput>