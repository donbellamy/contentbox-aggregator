/**
 * ContentBox Aggregator
 * Aggregator Helper
 * @author Don Bellamy <don@perfectcode.com>
 */
component accessors="true" singleton threadSafe {

	// Dependencies
	property name="controller" inject="coldbox";
	property name="cb" inject="cbhelper@cb";

	/**
	 * Constructor
	 * @return Helper
	 */
	Helper function init() {
		return this;
	}

	/************************************** Settings *********************************************/

	/**
	 * Gets an aggregator setting value by key or by default value
	 * @key The setting key to get
	 * @value The default value to return if not found
	 * @return The setting value or default value if found
	 */
	string function setting( required key, value ) {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc.agSettings, arguments.key ) ) {
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

	/**
	 * Gets the news entry point
	 * @return The news entry point
	 */
	string function getNewsEntryPoint() {
		return setting("ag_site_news_entrypoint");
	}

	/**
	 * Gets the feeds entry point
	 * @return The feeds entry point
	 */
	string function getFeedsEntryPoint() {
		return setting("ag_site_feeds_entrypoint");
	}

	/************************************** Context Methods *********************************************/

	/**
	 * Checks to see if the current event equals site.index
	 * @return True if the current event equals site.index, false if not
	 */
	boolean function isNewsView() {
		var event = cb.getRequestContext();
		return ( event.getCurrentEvent() EQ "contentbox-aggregator:site.index" );
	}

	/**
	 * Checks to see if the current event equals site.index and a search term is present
	 * @return True if the current event equals site.index and a search term is present, false if not
	 */
	boolean function isSearchView() {
		var rc = cb.getRequestCollection();
		return ( isNewsView() AND structKeyExists( rc, "q" ) AND len( rc.q ) );
	}

	/**
	 * Checks to see if the current event equals site.index and a category is present
	 * @return True if the current event equals site.index and a category is present, false if not
	 */
	boolean function isCategoryView() {
		var rc = cb.getRequestCollection();
		return ( isNewsView() AND structKeyExists( rc, "category" ) AND len( rc.category ) );
	}

	/**
	 * Checks to see if the current event equals site.index and a feed is present
	 * @return True if the current event equals site.index and a feed is present, false if not
	 */
	boolean function isFeedSearchView() {
		var rc = cb.getRequestCollection();
		return ( isNewsView() AND structKeyExists( rc, "feed" ) AND len( rc.feed ) );
	}

	/**
	 * Checks to see if the current event equals site.index and a type is present
	 * @return True if the current event equals site.index and a type is present, false if not
	 */
	boolean function isTypeView() {
		var rc = cb.getRequestCollection();
		return ( isNewsView() AND structKeyExists( rc, "type" ) AND len( rc.type ) );
	}

	/**
	 * Checks to see if the current event equals site.archives
	 * @return True if the current event equals site.archives, false if not
	 */
	boolean function isArchivesView() {
		var event = cb.getRequestContext();
		return ( event.getCurrentEvent() EQ "contentbox-aggregator:site.archives" );
	}

	/**
	 * Checks to see if the current event equals site.feeds
	 * @return True if the current event equals site.feeds, false if not
	 */
	boolean function isFeedsView() {
		var event = cb.getRequestContext();
		return ( event.getCurrentEvent() EQ "contentbox-aggregator:site.feeds" );
	}

	/**
	 * Checks to see if the current event equals site.feeds and a category is present
	 * @return True if the current event equals site.feeds and a category is present, false if not
	 */
	boolean function isFeedsCategoryView() {
		var rc = cb.getRequestCollection();
		return ( isFeedsView() AND structKeyExists( rc, "category" ) AND len( rc.category ) );
	}

	/**
	 * Checks to see if the current event equals site.feed
	 * @return True if the current event equals site.feed, false if not
	 */
	boolean function isFeedView() {
		var event = cb.getRequestContext();
		return ( event.getCurrentEvent() EQ "contentbox-aggregator:site.feed" );
	}

	/**
	 * Checks to see if the current event equals site.feeditem
	 * @return True if the current event equals site.feeditem, false if not
	 */
	boolean function isFeedItemView() {
		var event = cb.getRequestContext();
		return ( event.getCurrentEvent() EQ "contentbox-aggregator:site.feeditem" );
	}

	/**
	 * Gets the search term if present in the current request
	 * @return The search term if it exists, an empty string if not
	 */
	string function getSearchTerm() {
		return cb.getRequestContext().getValue( "q", "" );
	}

	/**
	 * Gets the page if present in the current request
	 * @return The page if it exists
	 */
	Page function getCurrentPage() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "page" ) ) {
			return prc.page;
		} else {
			throw(
				message = "Page not found in collection",
				detail = "This probably means you are trying to use the page in a non-page.",
				type = "aggregator.helper.InvalidFeedContext"
			);
		}
	}

	/**
	 * Gets the feed if present in the current request
	 * @return The feed if it exists
	 */
	Feed function getCurrentFeed() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "feed" ) ) {
			return prc.feed;
		} else {
			throw(
				message = "Feed not found in collection",
				detail = "This probably means you are trying to use the feed in an non-feed page.",
				type = "aggregator.helper.InvalidFeedContext"
			);
		}
	}

	/**
	 * Gets the feed collection if present in the current request
	 * @return The feed collection if it exists
	 */
	array function getCurrentFeeds() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "feeds" ) ) {
			return prc.feeds;
		} else {
			throw(
				message = "Feeds not found in collection",
				detail = "This probably means you are trying to use the feeds in an non-index page.",
				type = "aggregator.helper.InvalidFeedsContext"
			);
		}
	}

	/**
	 * Gets the feed item if present in the current request
	 * @return The feed item if it exists
	 */
	FeedItem function getCurrentFeedItem() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "feedItem" ) ) {
			return prc.feedItem;
		} else {
			throw(
				message = "Feed item not found in collection",
				detail = "This probably means you are trying to use the feed item in an non-feed item page.",
				type = "aggregator.helper.InvalidFeedItemContext"
			);
		}
	}

	/**
	 * Gets the feed item collection if present in the current request
	 * @return The feed item collection if it exists
	 */
	array function getCurrentFeedItems() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "feedItems" ) ) {
			return prc.feedItems;
		} else {
			throw(
				message = "Feed items not found in collection",
				detail = "This probably means you are trying to use the feed items in an non-index page.",
				type = "aggregator.helper.InvalidFeedItemsContext"
			);
		}
	}

	/**
	 * Gets the archive date if present in the current request
	 * @return The archive date if it exists
	 */
	string function getCurrentArchiveDate() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "archiveDate" ) ) {
			return prc.archiveDate;
		} else {
			throw(
				message = "Archive date not found in collection",
				detail = "This probably means you are trying to use the archive date in an non-index page.",
				type = "aggregator.helper.InvalidArchiveDateContext"
			);
		}
	}

	/**
	 * Gets the formatted archive date if present in the current request
	 * @return The formatted archive date if it exists
	 */
	string function getCurrentFormattedArchiveDate() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "formattedDate" ) ) {
			return prc.formattedDate;
		} else {
			throw(
				message = "Formatted date not found in collection",
				detail = "This probably means you are trying to use the formatted date in an non-index page.",
				type = "aggregator.helper.InvalidFormattedDateContext"
			);
		}
	}

	/**
	 * Gets the category if present in the current request
	 * @return The category if it exists
	 */
	Category function getCurrentCategory() {
		var prc = cb.getPrivateRequestCollection();
		if ( structKeyExists( prc, "category" ) ) {
			return prc.category;
		} else {
			throw(
				message = "Category not found in collection",
				detail = "This probably means you are trying to use the category in an non-index page.",
				type = "aggregator.helper.InvalidCategoryContext"
			);
		}
	}

	/**
	 * Gets the type if present in the current request
	 * @return The type if it exists
	 */
	string function getCurrentType() {
		var rc = cb.getRequestCollection();
		if ( structKeyExists( rc, "type" ) && len( rc.type ) ) {
			return rc.type;
		} else {
			throw(
				message = "Type not found in collection",
				detail = "This probably means you are trying to use the type in an non-index page.",
				type = "aggregator.helper.InvalidTypeContext"
			);
		}
	}

	/**
	 * Gets the related content if present in the current request
	 * @return The related content if it exists
	 */
	array function getCurrentRelatedContent() {
		var relatedContent = cb.getCurrentRelatedContent();
		if ( !arrayLen( relatedContent ) ) {
			if ( isFeedView() && getCurrentFeed().hasRelatedContent() ) {
				relatedContent = getCurrentFeed().getRelatedContent();
			} else if ( isFeedItemView() && getCurrentFeedItem().hasRelatedContent() ) {
				relatedContent = getCurrentFeedItem().getRelatedContent();
			}
		}
		return relatedContent;
	}

	/************************************** Link Methods *********************************************/

	/**
	 * Gets the news link
	 * @ssl Whether or not to use ssl
	 * @return The news link
	 */
	string function linkNews( boolean ssl=cb.getRequestContext().isSSL() ) {
		return cb.linkHome( ssl=arguments.ssl ) & getNewsEntryPoint();
	}

	/**
	 * Gets the feeds link
	 * @ssl Whether or not to use ssl
	 * @return The feeds link
	 */
	string function linkFeeds( boolean ssl=cb.getRequestContext().isSSL() ) {
		return cb.linkHome( ssl=arguments.ssl ) & getFeedsEntryPoint();
	}

	/**
	 * Gets the feeds rss link
	 * @ssl Whether or not to use ssl
	 * @return The feeds rss link
	 */
	string function linkFeedsRSS( boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkFeeds( ssl=arguments.ssl ) & "/rss";
	}

	/**
	 * Gets the category link
	 * @category The category to link to
	 * @ssl Whether or not to use ssl
	 * @return The category link
	 */
	string function linkCategory( any category="", boolean ssl=cb.getRequestContext().isSSL() ) {
		var slug = "";
		if ( isSimpleValue( arguments.category ) ) {
			slug = arguments.category;
		} else {
			slug = category.getSlug();
		}
		return linkNews( ssl=arguments.ssl ) & "/category/" & slug;
	}

	/**
	 * Gets the archive link
	 * @year The year to filter on
	 * @month The month to filter on
	 * @day The day to filter on
	 * @ssl Whether or not to use ssl
	 * @return The archive link
	 */
	string function linkArchive( string year="", string month="", string day="", boolean ssl=cb.getRequestContext().isSSL() ) {
		var link = linkNews( ssl=arguments.ssl ) & "/archives";
		if ( val( arguments.year ) ) { link &= "/#arguments.year#"; }
		if ( val( arguments.month ) ) { link &= "/#arguments.month#"; }
		if ( val( arguments.day ) ) { link &= "/#arguments.day#"; }
		return link;
	}

	/**
	 * Gets the feed link
	 * @feed The feed to link to
	 * @ssl Whether or not to use ssl
	 * @format The format to link to, defaults to html
	 * @return The feed link
	 */
	string function linkFeed( required Feed feed, boolean ssl=cb.getRequestContext().isSSL(), string format="html" ) {
		return linkFeeds( ssl=arguments.ssl ) & "/#arguments.feed.getSlug()#" & ( arguments.format NEQ "html" ? "." & arguments.format : "" );
	}

	/**
	 * Gets the feed rss link
	 * @feed The feed to link to
	 * @ssl Whether or not to use ssl
	 * @return The feed rss link
	 */
	string function linkFeedRSS( required Feed feed, boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkFeeds( ssl=arguments.ssl ) & "/#arguments.feed.getSlug()#/rss";
	}

	/**
	 * Gets the feed author link
	 * @feedItem The feed item to use
	 * @ssl Whether or not to use ssl
	 * @return The feed author link
	 */
	string function linkFeedAuthor( required FeedItem feedItem, boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkFeed( feed=arguments.feedItem.getFeed(), ssl=arguments.ssl ) & "?author=" & encodeForURL( arguments.feedItem.getItemAuthor() );
	}

	/**
	 * Gets the feeds category link
	 * @category The category to link to
	 * @ssl Whether or not to use ssl
	 * @return The feeds category link
	 */
	string function linkFeedsCategory( any category="", boolean ssl=cb.getRequestContext().isSSL() ) {
		var slug = "";
		if ( isSimpleValue( arguments.category ) ) {
			slug = arguments.category;
		} else {
			slug = category.getSlug();
		}
		return linkFeeds( ssl=ssl=arguments.ssl ) & "/category/" & slug;
	}

	/**
	 * Gets the feeds admin link
	 * @ssl Whether or not to use ssl
	 * @return The feeds admin link
	 */
	string function linkFeedsAdmin( boolean ssl=cb.getRequestContext().isSSL() ) {
		return cb.linkAdmin( ssl=arguments.ssl ) & "module/aggregator/feeds";
	}

	/**
	 * Gets the feed form link
	 * @feed The feed to link to
	 * @ssl Whether or not to use ssl
	 * @return The feed form link
	 */
	string function linkFeedForm( any feed, boolean ssl=cb.getRequestContext().isSSL() ) {
		if ( structKeyExists( arguments, "feed" ) ) {
			return linkFeedsAdmin( ssl=arguments.ssl ) & "/editor/contentID/" & arguments.feed.getContentID();
		} else {
			return linkFeedsAdmin( ssl=arguments.ssl ) & "/editor";
		}
	}

	/**
	 * Gets the feed item link
	 * @feedItem The feed item or entry to link to
	 * @ssl Whether or not to use ssl
	 * @format The format to link to, defaults to html
	 * @directLink Whether or not to return the actual item url
	 * @return The feed item link
	 */
	string function linkFeedItem( required any feedItem, boolean ssl=cb.getRequestContext().isSSL(), string format="html", boolean directLink=false ) {
		if ( arguments.feedItem.getContentType() == "FeedItem" ) {
			if ( arguments.directLink ) {
				return arguments.feedItem.getItemUrl();
			} else {
				return linkNews( ssl=arguments.ssl ) & "/" & arguments.feedItem.getSlug() & ( arguments.format NEQ "html" ? "." & arguments.format : "" );
			}
		} else {
			return cb.linkEntry( arguments.feedItem );
		}
	}

	/**
	 * Gets the feed items admin link
	 * @contentID The feed contentID to link to if provided
	 * @ssl Whether or not to use ssl
	 * @return The feed items admin link
	 */
	string function linkFeedItemsAdmin( any contentID, string type, boolean ssl=cb.getRequestContext().isSSL() ) {
		var link = cb.linkAdmin( ssl=arguments.ssl ) & "module/aggregator/feeditems";
		if ( structKeyExists( arguments, "contentID" ) && isNumeric( arguments.contentID ) ) {
			link &= "?feed=" & arguments.contentID;
		}
		if ( structKeyExists( arguments, "type" ) ) {
			link &= "&type=" & arguments.type;
		}
		return link;
	}

	/**
	 * Gets the feed item form link
	 * @feed The feed item to link to
	 * @ssl Whether or not to use ssl
	 * @return The feed item form link
	 */
	string function linkFeedItemForm( any feedItem, boolean ssl=cb.getRequestContext().isSSL() ) {
		var link = linkFeedItemsAdmin( ssl=arguments.ssl ) & "/editor";
		if ( structKeyExists( arguments, "feedItem" ) ) {
			link &= "/contentID/" & arguments.feedItem.getContentID();
		}
		return link;
	}

	/**
	 * Gets the rss link
	 * @ssl Whether or not to use ssl
	 * @return The rss link
	 */
	string function linkRSS( boolean ssl=cb.getRequestContext().isSSL() ) {
		return linkNews( ssl=arguments.ssl ) & "/rss";
	}

	/**
	 * Gets the content export link
	 * @format The format to use, defaults to html
	 * @ssl Whether or not to use ssl
	 * @return The export link
	 */
	string function linkExport( required string format, boolean ssl=cb.getRequestContext().isSSL() ) {
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

	/**
	 * Gets the content link
	 * @content The content to link to
	 * @ssl Whether or not to use ssl
	 * @format The format to link to, defaults to html
	 * @return The content link
	 */
	string function linkContent( required any content, boolean ssl=cb.getRequestContext().isSSL(), format="html" ) {
		switch ( arguments.content.getContentType() ) {
			case "entry":
				return cb.linkEntry( arguments.content, arguments.ssl, arguments.format );
				break;
			case "page":
				return cb.linkPage( arguments.content, arguments.ssl, arguments.format );
				break;
			case "feed":
				return linkFeed( arguments.content, arguments.ssl, arguments.format );
				break;
			case "feedItem":
				return linkFeedItem( arguments.content, arguments.ssl, arguments.format );
				break;
		}
	}

	/**
	 * Gets the module import link
	 * @ssl Whether or not to use ssl
	 * @return The immport link
	 */
	string function linkImport( boolean ssl=cb.getRequestContext().isSSL(), boolean importAll=false, boolean importActive=false ) {
		var link = cb.linkHome( ssl=arguments.ssl ) & "aggregator/feeds/import?key=" & setting("ag_importing_secret_key");
		if ( arguments.importAll ) link &= "&importAll=true";
		else if ( arguments.importActive ) link &= "&importActive=true";
		return link;
	}

	/**
	 * Gets the module import feed link
	 * @feed The feed to import
	 * @author The author to use when importing
	 * @ssl Whether or not to use ssl
	 * @return The immport feed link
	 */
	string function linkImportFeed( required Feed feed, required Author author, boolean ssl=cb.getRequestContext().isSSL() ) {
		return cb.linkHome( ssl=arguments.ssl ) & "aggregator/feeds/importFeed?key=" & setting("ag_importing_secret_key") & "&contentID=" & arguments.feed.getContentID() & "&authorID=" & arguments.author.getAuthorID();
	}

	/************************************** Quick HTML *********************************************/

	/**
	 * Creates the category links for a feed item
	 * @feedItem The feed item to create the category links
	 * @return The category links html
	 */
	string function quickCategoryLinks( required FeedItem feedItem ) {

		// Check for categories
		if ( NOT arguments.feedItem.hasCategories() ) {
			return "";
		}

		// Set vars
		var cats = arguments.feedItem.getCategories();
		var catList = [];

		// iterate and create links
		for ( var x=1; x LTE arrayLen( cats ); x++ ) {
			var link = '<a href="#linkCategory( cats[x] )#" title="Filter items by ''#cats[x].getCategory()#''">#cats[x].getCategory()#</a>';
			arrayAppend( catList, link );
		}

		// Return links
		return replace( arrayToList( catList ), ",", ", ", "all" );

	}

	/**
	 * Renders the paging links
	 * @maxRows The maximum number of rows to return
	 * @label The content type label to use, defaults to "items"
	 * @return The paging links html
	 */
	string function quickPaging( numeric maxRows, string label="items" ) {
		var prc = cb.getPrivateRequestCollection();
		if ( NOT structKeyExists( prc,"oPaging" ) ) {
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
				foundRows = prc.itemCount,
				link = prc.pagingLink,
				label = arguments.label
			);
		} else {
			return "";
		}
	}

	/**
	 * Renders the feeds list
	 * @template The theme template used to render the feeds, defaults to "feed"
	 * @collectionAs The variable name used in the template for each feed, defaults to "feed"
	 * @args A structure of arguments to pass to the template
	 * @return The feeds list html
	 */
	string function quickFeeds( string template="feed", string collectionAs="feed", struct args=structnew() ) {
		var feeds = getCurrentFeeds();
		return controller.getRenderer().renderView(
			view = "#cb.themeName()#/templates/aggregator/#arguments.template#",
			collection = feeds,
			collectionAs = arguments.collectionAs,
			args = arguments.args,
			module = cb.themeRecord().module
		);
	}

	/**
	 * Renders the feed items list
	 * @template The theme template used to render the feed items, defaults to "feeditem"
	 * @collectionAs The variable name used in the template for each feed item, defaults to "feeditem"
	 * @groupByDate Whether or not to group the feed items by published date, defaults to false
	 * @args A structure of arguments to pass to the template
	 * @return The feed items list html
	 */
	string function quickFeedItems(
		string template="feeditem",
		string collectionAs="feeditem",
		boolean groupByDate=false,
		struct args=structnew() ) {
		var feedItems = getCurrentFeedItems();
		if ( arguments.groupByDate ) {
			var html = "";
			var currentDate = "";
			for ( var feedItem IN feedItems ) {
				var publishedDate = feedItem.getPublishedDateNoTime();
				if ( currentDate != publishedDate ) {
					currentDate = publishedDate;
					arguments.args.showGroupByDate = true;
				} else {
					arguments.args.showGroupByDate = false;
				}
				html &= controller.getRenderer().renderView(
					view = "#cb.themeName()#/templates/aggregator/#arguments.template#",
					collection = [ feedItem ],
					collectionAs = arguments.collectionAs,
					args = arguments.args,
					module = cb.themeRecord().module
				);
			}
			return html;
		} else {
			return controller.getRenderer().renderView(
				view = "#cb.themeName()#/templates/aggregator/#arguments.template#",
				collection = feedItems,
				collectionAs = arguments.collectionAs,
				args = arguments.args,
				module = cb.themeRecord().module
			);
		}
	}

	/**
	 * Renders the main view of the current event
	 * @args A structure of arguments to pass to the view
	 */
	function mainView( struct args=structNew() ) {
		if ( cb.isPageView() ) {
			return controller.getRenderer().renderView(
				view = "#cb.themeName()#/views/aggregator/page",
				args = arguments.args,
				module = cb.themeRecord().module
			);
		} else {
			return cb.mainView( argumentCollection=arguments );
		}
	}

	/************************************** MENUS *********************************************/

	/**
	 * Creates the breadcrumb html for the site
	 * @separator Breadcrumb separator, defaults to ">"
	 * @return The breadcrumb html
	 */
	string function breadCrumbs( string separator=">" ) {
		var bc = "";
		if ( isNewsView() || isArchivesView() ) {
			var page = getCurrentPage();
			bc &= '#arguments.separator# <a href="#linkNews()#">#page.getTitle()#</a></a> ';
		}
		if ( isCategoryView() ) {
			var category = getCurrentCategory();
			bc &= '#arguments.separator# <a href="#linkCategory( category )#">#category.getCategory()#</a> ';
		}
		if ( isFeedSearchView() ) {
			var feed = getCurrentFeed();
			if ( isCategoryView() ) {
				bc &= '#arguments.separator# <a href="#linkCategory( category )#?feed=#feed.getSlug()#">#feed.getTitle()#</a> ';
			} else {
				bc &= '#arguments.separator# <a href="#linkNews()#?feed=#feed.getSlug()#">#feed.getTitle()#</a> ';
			}
		}
		if ( isTypeView() ) {
			var type = getCurrentType();
			var typeLabel = uCase( left( type, 1 ) ) & right( type, len( type ) - 1 ) & "s";
			if ( isCategoryView() ) {
				bc &= '#arguments.separator# <a href="#linkCategory( category )#?type=#type#">#typeLabel#</a> ';
			} else {
				bc &= '#arguments.separator# <a href="#linkNews()#?type=#type#">#typeLabel#</a> ';
			}
		}
		if ( isSearchView() ) {
			var searchTerm = getSearchTerm();
			if ( isCategoryView() ) {
				bc &= '#arguments.separator# <a href="#linkCategory( category )#?q=#searchTerm#">#reReplace( searchTerm, "(^[a-z])","\U\1", "ALL" )#</a> ';
			} else {
				bc &= '#arguments.separator# <a href="#linkNews()#?q=#searchTerm#">#reReplace( searchTerm, "(^[a-z])","\U\1", "ALL" )#</a> ';
			}
		}
		if ( isArchivesView() ) {
			var archiveDate = getCurrentArchiveDate();
			if ( isDate( archiveDate ) ) {
				var rc = cb.getRequestCollection();
				bc &= '#arguments.separator# <a href="#linkArchive( rc.year, rc.month, rc.day )#">#getCurrentFormattedArchiveDate()#</a> ';
			}
		}
		if ( isFeedsView() || isFeedView() ) {
			var page = getCurrentPage();
			bc &= '#arguments.separator# <a href="#linkFeeds()#">#page.getTitle()#</a> ';
		}
		if ( isFeedsCategoryView() ) {
			var category = getCurrentCategory();
			bc &= '#arguments.separator# <a href="#linkFeedsCategory( category )#">#category.getCategory()#</a> ';
		}
		if ( isFeedView() ) {
			var feed = getCurrentFeed();
			bc &= '#arguments.separator# <a href="#linkFeed( feed )#">#feed.getTitle()#</a> ';
			var rc = cb.getRequestCollection();
			if ( structKeyExists( rc, "author" ) AND len( rc.author ) ) {
				bc &= '#arguments.separator# <a href="#linkFeed( feed )#?author=#rc.author#">#rc.author#</a> ';
			}
		}
		if ( isFeedItemView() ) {
			var feedItem = getCurrentFeedItem();
			bc &= '#arguments.separator# <a href="#linkFeedItem( feedItem )#">#feedItem.getTitle()#</a> ';
		}
		return bc;
	}

	/************************************** UTILITIES *********************************************/

	/**
	 * Returns a fuzzy timestamp of the provided date/time
	 * @time The date/time value to use when creating the fuzzy timestamp
	 * @return The fuzzy timestamp, or passed date/time if older than a month
	 */
	string function timeAgo( required date time ) {

		// Strings
		var strings = {
			"seconds" = "less than a minute ago",
			"minute" = "about a minute ago",
			"minutes" = "%d minutes ago",
			"hour" = "about an hour ago",
			"hours" = "%d hours ago",
			"day" = "about a day ago",
			"days" = "%d days ago",
			"week" = "about a week ago",
			"weeks" = "%d weeks ago",
			"month" = "about a month ago",
			"months" = "%d months ago",
			"year" = "about a year ago",
			"years" = "%d years ago"
		};

		// Time differences
		var seconds = dateDiff( "s", arguments.time, now() );
		var minutes = seconds / 60;
		var hours = minutes / 60;
		var days = hours / 24;
		var weeks = days / 7;
		var years = days / 365;

		// Set the fuzzy timestamp
		var timestamp = "";
		// Less than a minute
		if ( seconds LT 45 ) {
			timestamp = strings["seconds"];
		// A minute
		} else if ( seconds LT 90 ) {
			timestamp = strings["minute"];
		// X minutes
		} else if ( minutes < 45 ) {
			timestamp = replace( strings["minutes"], "%d", round( minutes ) );
		// An hour
		} else if ( minutes LT 90 ) {
			timestamp = strings["hour"];
		// X hours
		} else if ( hours LT 24 ) {
			timestamp = replace( strings["hours"], "%d", round( hours ) );
		// A day
		} else if ( hours LT 36 ) {
			timestamp = strings["day"];
		// X days
		} else if ( days LT 7 ) {
			timestamp = replace( strings["days"], "%d", round( days ) );
		// A week
		} else if ( days LT 11 ) {
			timestamp = strings["week"];
		// X weeks
		} else if ( weeks LT 4 ) {
			timestamp = replace( strings["weeks"], "%d", round( weeks ) );
		// A month
		} else if ( weeks LT 6 ) {
			timestamp = strings["month"];
		// Over a month old, so return the actual date
		} else {
			timestamp = arguments.time;
		}

		return timestamp;

	}

}