component accessors="true" singleton threadSafe {

	property name="controller" inject="coldbox";
	property name="cb" inject="cbhelper@cb";

	Helper function init() {
		return this;
	}

	/************************************** Settings *********************************************/

	string function setting( required key, value ) {
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

	/************************************** Root Methods *********************************************/

	string function getPortalEntryPoint() {
		var prc = cb.getPrivateRequestCollection();
		return prc.agEntryPoint;
	}

	/************************************** Context Methods *********************************************/

	boolean function isIndexView() {
		var event = cb.getRequestContext();
		return ( event.getCurrentEvent() EQ "contentbox-rss-aggregator:portal.index" );
	}

	boolean function isArchivesView() {
		var event = cb.getRequestContext();
		return ( event.getCurrentEvent() EQ "contentbox-rss-aggregator:portal.archives" );
	}

	boolean function isFeedsView() {
		var event = cb.getRequestContext();
		return ( event.getCurrentEvent() EQ "contentbox-rss-aggregator:portal.feeds" );
	}

	boolean function isFeedView() {
		var event = cb.getRequestContext();
		return (
			// TODO: export?
			// If in static export, then mark as yes
			//event.getPrivateValue( "staticExport", false )
			//OR
			// In executing view
			event.getCurrentEvent() EQ "contentbox-rss-aggregator:portal.feed"
		);
	}

	Feed function getCurrentFeed() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "feed" ) ) {
			return prc.feed;
		} else {
			throw(
				message="Feed not found in collection",
				detail="This probably means you are trying to use the feed in an non-feed page.",
				type="aggregator.helper.InvalidFeedContext"
			);
		}
	}

	array function getCurrentFeeds() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "feeds" ) ) {
			return prc.feeds;
		} else {
			throw(
				message="Feeds not found in collection",
				detail="This probably means you are trying to use the feeds in an non-index page.",
				type="aggregator.helper.InvalidFeedsContext"
			);
		}
	}

	array function getCurrentFeedItems() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "feedItems" ) ) {
			return prc.feedItems;
		} else {
			throw(
				message="Feed items not found in collection",
				detail="This probably means you are trying to use the feed items in an non-index page.",
				type="aggregator.helper.InvalidFeedItemsContext"
			);
		}
	}

	/************************************** SEO Metadata *********************************************/

	/************************************** Link Methods *********************************************/

	string function linkPortal( boolean ssl=cb.getRequestContext().isSSL() ) {
		return cb.getRequestContext().buildLink( linkto=len( cb.siteRoot() ) ? cb.siteRoot() & "." & getPortalEntryPoint() : getPortalEntryPoint(), ssl=arguments.ssl );
	}

	string function linkArchive( string year="", string month="", string day="", boolean ssl=cb.getRequestContext().isSSL() ) {
		var link = linkPortal( ssl=arguments.ssl ) & "/archives";
		if ( len( arguments.year ) ) { link &= "/#arguments.year#"; }
		if ( len( arguments.month ) ) { link &= "/#arguments.month#"; }
		if ( len( arguments.day ) ) { link &= "/#arguments.day#"; }
		return link;
	}

	string function linkCategory( required any category, boolean ssl=cb.getRequestContext().isSSL() ) {
		var slug = "";
		if ( isSimpleValue( arguments.category ) ) {
			slug = arguments.category;
		} else {
			slug = category.getSlug();
		}
		return linkPortal( ssl=arguments.ssl ) & "/category/" & slug;
	}

	string function linkFeeds( boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkPortal( ssl=arguments.ssl ) & "/feeds";
	}

	string function linkFeed( required feed, boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkPortal( ssl=arguments.ssl ) & "/feeds/" & arguments.feed.getSlug();
	}

	string function linkFeedRSS( required feed, boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkPortal( ssl=arguments.ssl ) & "/feeds/" & arguments.feed.getSlug() & "/rss";
	}

	string function linkFeedForm( required feed, boolean ssl=cb.getRequestContext().isSSL() ) {
		return cb.linkAdmin( ssl=arguments.ssl ) & "module/aggregator/feeds/editor/contentID/" & arguments.feed.getContentID();
	}

	string function linkFeedItem( required feedItem, boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkPortal( ssl=arguments.ssl ) & "/" & arguments.feedItem.getSlug();
	}

	string function linkFeedItemAuthor( required feedItem, boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkFeed( feed=arguments.feedItem.getFeed(), ssl=arguments.ssl ) & "?author=" & encodeForURL( arguments.feedItem.getItemAuthor() );
	}

	string function linkRSS( boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkPortal() & "/rss";
	}

	/************************************** Quick HTML *********************************************/

	// TODO: put settings in views
	string function quickPaging( numeric maxRows ) {
		var prc = cb.getPrivateRequestCollection();
		if( NOT structKeyExists( prc,"oPaging" ) ) {
			throw(
				message = "Paging object is not in the collection",
				detail = "This probably means you are trying to use the paging object in an non-index page.",
				type = "aggregator.helper.InvalidPagingContext"
			);
		}
		if ( !structKeyExists( arguments, "maxRows" ) ) {
			arguments.maxRows = prc.oPaging.getPagingMaxRows();
		}
		if ( prc.itemCount GT arguments.maxRows ) {
			return prc.oPaging.renderit(
				foundRows=prc.itemCount,
				link=prc.pagingLink
			);
		} else {
			return "";
		}
	}

	string function quickFeeds( string template="feed", string collectionAs="feed", struct args=structnew() ) {
		var feeds = getCurrentFeeds();
		return controller.getRenderer().renderView(
			//view = "#cb.themeName()#/templates/aggregator/#arguments.template#",
			// TODO: Need to create functions to check for theme file, if not found use indluded files ?
			view = "../themes/default/templates/#arguments.template#",
			collection = feeds,
			collectionAs = arguments.collectionAs,
			args = arguments.args
		);
	}

	string function quickFeedItems( string template="feeditem", string collectionAs="feeditem", struct args=structnew() ) {
		var feedItems = getCurrentFeedItems();
		return controller.getRenderer().renderView(
			//view = "#cb.themeName()#/templates/aggregator/#arguments.template#",
			// TODO: Need to create functions to check for theme file, if not found use indluded files ?
			view = "../themes/default/templates/#arguments.template#",
			collection = feedItems,
			collectionAs = arguments.collectionAs,
			args = arguments.args
		);
	}

	/************************************** UTILITIES *********************************************/

	string function stripHtml( stringTarget ) {
		return reReplaceNoCase( arguments.stringTarget, "<[^>]*>", "", "ALL" );
	}

	string function timeAgo( required date time ) {

		var diff = dateDiff( "s", arguments.time, now() );

		// x minutes ago
		if ( diff LT 3600 ) {
			var minutes = round( diff / 60 );
			if ( minutes == 1 ) return "1 minute ago";
			else return minutes & " minutes ago";
		// x hours ago
		} else if ( diff LT ( 3600 * 24 ) ) {
			var hours = round( diff / 3600 );
			if ( hours == 1 ) return "1 hour ago";
			else return hours & " hours ago";
		// older than 24 hours, just return the time
		} else {
			return arguments.time;
		}

	}

}