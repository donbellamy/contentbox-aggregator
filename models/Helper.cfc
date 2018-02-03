component accessors="true" singleton threadSafe {

	property name="controller" inject="coldbox";
	property name="cb" inject="cbhelper@cb";

	function init() {
		return this;
	}

	/************************************** Settings *********************************************/

	function getPortalEntryPoint() {
		var prc = cb.getPrivateRequestCollection();
		return prc.agEntryPoint;
	}

	/************************************** Context Methods *********************************************/

	function getCurrentFeedItems() {
		var prc = cb.getPrivateRequestCollection();
		if( structKeyExists( prc, "feedItems" ) ) { 
			return prc.feedItems; 
		} else {
			throw(
				message="Feed items not found in collection",
				detail="This probably means you are trying to use the feed items in an non-index page.",
				type="aggregator.helper.InvalidFeedItemsContext"
			);
		}
	}

	/************************************** Link Methods *********************************************/

	function linkPortal( boolean ssl=cb.getRequestContext().isSSL() ) {
		return cb.getRequestContext().buildLink( linkto=len( cb.siteRoot() ) ? cb.siteRoot() & "." & getPortalEntryPoint() : getPortalEntryPoint(), ssl=arguments.ssl );
	}

	function linkFeedItem( required feedItem, boolean ssl=cb.getRequestContext().isSSL(), format="html" ) {
		var outputFormat = ( arguments.format NEQ "html" ? ".#arguments.format#" : "" );
		return cb.getRequestContext().buildLink( linkto=len( cb.siteRoot() ) ? cb.siteRoot() & "." & getPortalEntryPoint() & "." & arguments.feedItem.getSlug() : getPortalEntryPoint() & "." & arguments.feedItem.getSlug() , ssl=arguments.ssl ) & outputFormat;
	}

	/************************************** Quick HTML *********************************************/

	function quickPaging() {
		var prc = cb.getPrivateRequestCollection();
		if( NOT structKeyExists( prc,"oPaging" ) ) {
			throw(
				message = "Paging object is not in the collection",
				detail = "This probably means you are trying to use the paging object in an non-index page.",
				type = "aggregator.helper.InvalidPagingContext" 
			);
		}
		return prc.oPaging.renderit(
			foundRows = prc.itemCount, 
			link = prc.pagingLink, 
			pagingMaxRows = 10 //setting( "cb_paging_maxentries" ) 
			// TODO: should default to setting, but allow to be passed in via theme
		);
	}

	function quickFeedItems( string template="feeditem", string collectionAs="feeditem", struct args=structnew() ) {
		var feedItems = getCurrentFeedItems();
		return controller.getRenderer().renderView(
			//view = "#cb.themeName()#/templates/aggregator/#arguments.template#", 
			// TODO: Need to create functions to check for theme file, if not found use indluded files ?
			view = "../themes/default/templates/aggregator/#arguments.template#",
			collection = feedItems,
			collectionAs = arguments.collectionAs,
			args = arguments.args
		);
	}

}