component accessors="true" singleton threadSafe {

	property name="controller" inject="coldbox";
	property name="cb" inject="cbhelper@cb";

	function init() {
		return this;
	}

	/************************************** Settings *********************************************/

	function getSetting( required key, value ) {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc.agSettings, arguments.key ) ){
			return prc.agSettings[ key ];
		}
		if ( structKeyExists( arguments, "value" ) ) {
			return arguments.value;
		}
		throw(
			message = "Setting requested: #arguments.key# not found",
			detail = "Settings keys are #structKeyList( prc.agSettings )#",
			type = "aggregator.helper.InvalidSetting" 
		);
	}

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

	function linkFeed( required feed, boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkPortal( ssl=arguments.ssl ) & "/feeds/" & arguments.feed.getSlug();
	}

	function linkFeedItem( required feedItem, boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkPortal( arguments.ssl ) & "/" & arguments.feedItem.getSlug();
	}

	function linkFeedItemAuthor( required feedItem, boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkFeed( arguments.feedItem.getFeed(), arguments.ssl ) & "?author=" & encodeForURL( arguments.feedItem.getItemAuthor() );
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