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

	string function quickPaging( numeric maxRows=setting("ag_display_paging_max_rows") ) {
		var prc = cb.getPrivateRequestCollection();
		if( NOT structKeyExists( prc,"oPaging" ) ) {
			throw(
				message = "Paging object is not in the collection",
				detail = "This probably means you are trying to use the paging object in an non-index page.",
				type = "aggregator.helper.InvalidPagingContext"
			);
		}
		if ( prc.itemCount GT arguments.maxRows ) {
			return prc.oPaging.renderit(
				foundRows = prc.itemCount,
				link = prc.pagingLink,
				pagingMaxRows = arguments.maxRows
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

	/************************************** Feed Item Methods *********************************************/

	string function getFeedItemFeaturedImageUrl( required FeedItem feedItem ) {
		var feed = arguments.feedItem.getFeed();
		var behavior = len( feed.getMissingImageBehavior() ) ? feed.getMissingImageBehavior() : setting("ag_general_image_missing_behavior");
		if ( len( feedItem.getFeaturedImageUrl() ) ) {
			return feedItem.getFeaturedImageUrl();
		} else if ( behavior == "default" ) {
			return setting("ag_general_image_default_url");
		} else if ( behavior == "feed" ) {
			return feed.getFeaturedImageUrl();
		} else {
			return "";
		}
	}

	// TODO: Should probably rename this so it isn't confused with the actual renderedExcerpt
	string function renderContentExcerpt( required FeedItem feedItem, numeric count=500, string excerptEnding="..." ) {
		var content = trim( left( stripHtml( arguments.feedItem.getContent() ), arguments.count ) );
		return "<p>" & content & ( right( content, 1 ) NEQ "." ? arguments.excerptEnding : "" ) & "</p>";
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