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

	boolean function isSearchView() {
		var rc = cb.getRequestCollection();
		return ( isIndexView() AND structKeyExists( rc, "q" ) AND len( rc.q ) );
	}

	boolean function isCategoryView() {
		var rc = cb.getRequestCollection();
		return ( isIndexView() AND structKeyExists( rc, "category" ) AND len( rc.category ) );
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
		return ( event.getCurrentEvent() EQ "contentbox-rss-aggregator:portal.feed" );
	}

	string function getSearchTerm() {
		return cb.getRequestContext().getValue( "q", "" );
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

	string function getCurrentArchiveDate() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "archiveDate" ) ) {
			return prc.archiveDate;
		} else {
			throw(
				message="Archive date not found in collection",
				detail="This probably means you are trying to use the archive date in an non-index page.",
				type="aggregator.helper.InvalidArchiveDateContext"
			);
		}
	}

	string function getCurrentFormattedArchiveDate() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "formattedDate" ) ) {
			return prc.formattedDate;
		} else {
			throw(
				message="Formatted date not found in collection",
				detail="This probably means you are trying to use the formatted date in an non-index page.",
				type="aggregator.helper.InvalidFormattedDateContext"
			);
		}
	}

	Category function getCurrentCategory() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "category" ) ) {
			return prc.category;
		} else {
			throw(
				message="Category not found in collection",
				detail="This probably means you are trying to use the category in an non-index page.",
				type="aggregator.helper.InvalidCategoryContext"
			);
		}
	}

	/************************************** Link Methods *********************************************/

	string function linkPortal( boolean ssl=cb.getRequestContext().isSSL() ) {
		return cb.getRequestContext().buildLink( linkto=len( cb.siteRoot() ) ? cb.siteRoot() & "." & getPortalEntryPoint() : getPortalEntryPoint(), ssl=arguments.ssl );
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

	string function linkArchive( string year="", string month="", string day="", boolean ssl=cb.getRequestContext().isSSL() ) {
		var link = linkPortal( ssl=arguments.ssl ) & "/archives";
		if ( val( arguments.year ) ) { link &= "/#arguments.year#"; }
		if ( val( arguments.month ) ) { link &= "/#arguments.month#"; }
		if ( val( arguments.day ) ) { link &= "/#arguments.day#"; }
		return link;
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
		return linkPortal( ssl=arguments.ssl ) & "/rss";
	}

	string function linkImport( boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkPortal( ssl=arguments.ssl ) & "/import?key=" & setting("ag_importing_secret_key");
	}

	string function linkExport( required format, boolean ssl=cb.getRequestContext().isSSL() ) {
		var event = cb.getRequestContext();
		var link = event.buildLink( linkTo=event.getCurrentRoutedURL(), ssl=arguments.ssl );
		if ( right( link, 1 ) EQ "/" ) {
			link = left( link, len( link ) - 1 );
		}
		link &= "." & arguments.format;
		if ( len( cgi.query_string ) ) {
			link &= "?" & cgi.query_string;
		}
		return link;
	}

	/************************************** Quick HTML *********************************************/

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
			view = "#cb.themeName()#/templates/#arguments.template#",
			collection = feeds,
			collectionAs = arguments.collectionAs,
			args = arguments.args
		);
	}

	string function quickFeedItems( string template="feeditem", string collectionAs="feeditem", struct args=structnew() ) {
		var feedItems = getCurrentFeedItems();
		return controller.getRenderer().renderView(
			view = "#cb.themeName()#/templates/#arguments.template#",
			collection = feedItems,
			collectionAs = arguments.collectionAs,
			args = arguments.args
		);
	}

	function mainView( struct args=structNew() ) {
		if ( cb.isPageView() ) {
			return controller.getRenderer().renderView(
				view = "#cb.themeName()#/views/portal",
				args = arguments.args
			);
		} else {
			return controller.getRenderer().renderView( view="", args=arguments.args );
		}
	}

	/************************************** MENUS *********************************************/

	string function breadCrumbs( string separator=">" ) {
		var bc = '#arguments.separator# <a href="#linkPortal()#">#setting("ag_portal_title")#</a> ';
		if ( isSearchView() ) {
			var searchTerm = getSearchTerm();
			bc &= '#arguments.separator# <a href="#linkPortal()#?q=#searchTerm#">#reReplace( searchTerm, "(^[a-z])","\U\1", "ALL" )#</a> ';
		}
		if ( isCategoryView() ) {
			var category = getCurrentCategory();
			bc &= '#arguments.separator# <a href="#linkCategory( category )#">#category.getCategory()#</a> ';
		}
		if ( isArchivesView() ) {
			var archiveDate = getCurrentArchiveDate();
			if ( isDate( archiveDate ) ) {
				rc = cb.getRequestCollection();
				bc &= '#arguments.separator# <a href="#linkArchive( rc.year, rc.month, rc.day )#">#getCurrentFormattedArchiveDate()#</a> ';
			}
		}
		if ( isFeedsView() || isFeedView() ) {
			bc &= '#arguments.separator# <a href="#linkFeeds()#">#setting("ag_portal_feeds_title")#</a> ';
		}
		if ( isFeedView() ) {
			var feed = getCurrentFeed();
			bc &= '#arguments.separator# <a href="#linkFeed( feed )#">#feed.getTitle()#</a> ';
			var rc = cb.getRequestCollection();
			if ( structKeyExists( rc, "author" ) AND len( rc.author ) ) {
				bc &= '#arguments.separator# <a href="#linkFeed( feed )#?author=#rc.author#">#rc.author#</a> ';
			}
		}
		return bc;
	}

	/************************************** UTILITIES *********************************************/

	string function stripHtml( string stringTarget="" ) {
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