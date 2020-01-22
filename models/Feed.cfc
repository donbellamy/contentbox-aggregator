/**
 * ContentBox Aggregator
 * Feed Model
 * @author Don Bellamy <don@perfectcode.com>
 */
component persistent="true"
	entityname="cbFeed"
	table="cb_feed"
	batchsize="25"
	cachename="cbFeed"
	cacheuse="read-write"
	extends="contentbox.models.content.BaseContent"
	joincolumn="contentID"
	discriminatorValue="Feed" {

	/* *********************************************************************
	**                            PROPERTIES
	********************************************************************* */

	property name="feedUrl"
		notnull="true"
		length="255";

	property name="tagLine"
		notnull="false"
		length="255";

	property name="isActive"
		notnull="true"
		ormtype="boolean"
		default="true"
		index="idx_isActive";

	property name="startDate"
		notnull="false"
		ormtype="timestamp"
		index="idx_startDate";

	property name="stopDate"
		notnull="false"
		ormtype="timestamp"
		index="idx_stopDate";

	property name="settings"
		notnull="false"
		ormtype="text";

	/* *********************************************************************
	**                            RELATIONSHIPS
	********************************************************************* */

	// O2M -> Feed imports
	property name="feedImports"
		singularName="FeedImport"
		fieldtype="one-to-many"
		type="array"
		lazy="extra"
		batchsize="25"
		orderby="feedImportID DESC"
		cfc="FeedImport"
		fkcolumn="FK_feedID"
		inverse="true"
		cascade="all-delete-orphan";

	// O2M -> Blacklisted items
	property name="blacklistedItems"
		singularName="BlacklistedItem"
		fieldtype="one-to-many"
		type="array"
		lazy="extra"
		batchsize="25"
		orderby="blacklistedItemID DESC"
		cfc="BlacklistedItem"
		fkcolumn="FK_feedID"
		inverse="true"
		cascade="all-delete-orphan";

	/* *********************************************************************
	**                            DI INJECTIONS
	********************************************************************* */

	property name="feedItemService"
		inject="feedItemService@aggregator"
		persistent="false";

	property name="settingService"
		inject="settingService@cb"
		persistent="false";

	/* *********************************************************************
	**                            CALCULATED FIELDS
	********************************************************************* */

	property name="importedDate"
		formula="select max(fi.createdDate) from cb_feedimport fi where fi.FK_feedID = contentID"
		default="";

	property name="isFailing"
		formula="select fi.importFailed from cb_feedimport fi
			where fi.FK_feedID = contentID
			and fi.feedImportID = ( select max(fi.feedImportID) from cb_feedimport fi where fi.FK_feedID=contentID )"
		default="false";

	property name="numberOfArticles"
		formula="select count(*) from cb_content c
			inner join cb_feeditem fi on c.contentID = fi.contentID
			where c.FK_parentID = contentID
			and ( select count(*) from cb_feeditemvideo fiv where fiv.FK_feedItemID = fi.contentID ) = 0
			and ( select count(*) from cb_feeditempodcast fip where fip.FK_feedItemID = fi.contentID ) = 0"
		default="0";

	property name="numberOfPodcasts"
		formula="select count(*)
			from cb_content c
			inner join cb_feeditem fi on c.contentID = fi.contentID
			inner join cb_feeditempodcast fip on fi.contentID = fip.FK_feedItemID
			where c.FK_parentID = contentID"
		default="0";

	property name="numberOfVideos"
		formula="select count(*)
			from cb_content c
			inner join cb_feeditem fi on c.contentID = fi.contentID
			inner join cb_feeditemvideo fiv on fi.contentID = fiv.FK_feedItemID
			where c.FK_parentID = contentID"
		default="0";

	property name="numberOfPublishedChildren"
		formula="select count(*)
			from cb_content c
			where c.FK_parentID = contentID
			and c.isPublished = 1
			and c.publishedDate < now()
			and ( c.expireDate is null or c.expireDate > now() )"
		default="0";

	property name="lastPublishedDate"
		formula="select max(c.publishedDate)
			from cb_content c
			where c.FK_parentID = contentID
			and c.isPublished = 1
			and c.publishedDate < now()
			and ( c.expireDate is null or c.expireDate > now() )"
		default="";

	/* *********************************************************************
	**                            CONSTRAINTS
	********************************************************************* */

	this.constraints["feedUrl"] = { required=true, type="url", size="1..255" };
	this.constraints["tagLine"] = { required=false, size="1..255" };
	this.constraints["startDate"] = { required=false, type="date" };
	this.constraints["stopDate"] = { required=false, type="date" };

	/**
	 * Constructor
	 * @return Feed
	 */
	Feed function init() {
		super.init();
		variables.allowComments = false;
		variables.categories = [];
		variables.renderedContent = "";
		variables.createdDate = now();
		variables.contentType = "Feed";
		variables.feedImports = [];
		variables.blacklistedItems = [];
		setSettings({});
		return this;
	}

	/**
	 * Sets the settings property
	 * @settings A structure of custom settings
	 * @return Feed
	 */
	Feed function setSettings( required any settings ) {
		if ( isStruct( arguments.settings ) ) {
			arguments.settings = serializeJSON( arguments.settings );
		}
		variables.settings = arguments.settings;
		return this;
	}

	/**
	 * Gets the settings property
	 * @return A structure of settings
	 */
	struct function getSettings() {
		return ( !isNull( variables.settings ) && isJSON( variables.settings ) ) ? deserializeJSON( variables.settings ) : {};
	}

	/**
	 * Gets a feed setting value by key or by default value
	 * @key The setting key to get
	 * @value The default value to return if not found
	 * @return The setting value or default value if found
	 */
	any function getSetting( required any key, value ) {
		var settings = getSettings();
		if ( structKeyExists( settings, arguments.key ) ) {
			return settings[ key ];
		}
		if ( structKeyExists( arguments, "value" ) ) {
			return arguments.value;
		}
		throw(
			message = "Setting requested: #arguments.key# not found",
			detail = "Settings keys are #structKeyList( settings )#",
			type = "aggregator.Feed.InvalidSetting"
		);
	}

	/**
	 * Gets the view args set on the feed
	 * @return A struct of the view args set on the feed
	 */
	struct function getViewArgs() {
		var args = {
			// Feeds
			"includeFeedItems" = getSetting( "feeds_include_feed_items", "" ),
			"showWebsite" = getSetting( "feeds_show_website", "" ),
			"showRSS" = getSetting( "feeds_show_rss", "" ),
			"showFeedImage" = getSetting( "feeds_show_featured_image", "" ),
			// Feed items
			"showVideoPlayer" = getSetting( "feed_items_show_video_player", "" ),
			"showAudioPlayer" = getSetting( "feed_items_show_audio_player", "" ),
			"showSource" = getSetting( "feed_items_show_source", "" ),
			"showAuthor" = getSetting( "feed_items_show_author", "" ),
			"showCategories" = getSetting( "feed_items_show_categories", "" ),
			"showExcerpt" = getSetting( "feed_items_show_excerpt", "" ),
			"excerptLimit" = getSetting( "feed_items_excerpt_limit", "" ),
			"excerptEnding" = getSetting( "feed_items_excerpt_ending", "" ),
			"showReadMore" = getSetting( "feed_items_show_read_more", "" ),
			"readMoreText" = getSetting( "feed_items_read_more_text", "" ),
			"linkBehavior" = getSetting( "feed_items_link_behavior", "" ),
			"openNewWindow" = getSetting( "feed_items_open_new_window", "" ),
			"showImage" = getSetting( "feed_items_show_featured_image", "" )
		};
		var viewArgs = {};
		for ( var arg IN args ) {
			if ( len( args[arg] ) ) {
				viewArgs[arg] = args[arg];
			}
		}
		return viewArgs;
	}

	/**
	 * Gets the latest feed import
	 * @return The latest feed import if exists, null if not
	 */
	any function getLatestFeedImport() {
		if ( hasFeedImport() ) {
			return getFeedImports()[1];
		}
		return javaCast( "null", "" );
	}

	/**
	 * Gets the latest successful feed import
	 * @return The latest successful feed import if exists, null if not
	 */
	any function getLatestSuccessfulFeedImport() {
		if ( hasFeedImport() ) {
			for ( var feedImport IN getFeedImports() ) {
				if ( !feedImport.failed() ) {
					return feedImport;
				}
			}
		}
		return javaCast( "null", "" );
	}

	/**
	 * Gets the website url from the latest feed import
	 * @return The website url if defined, the feed url if not
	 */
	string function getWebsiteUrl() {
		var wesiteUrl = "";
		var feedImport = getLatestSuccessfulFeedImport();
		if ( !isNull( feedImport ) && len( feedImport.getWebsiteUrl() ) ) {
			websiteUrl = feedImport.getWebsiteUrl();
		} else {
			websiteUrl = getFeedUrl();
		}
		return websiteUrl;
	}

	/**
	 * Gets the feed items
	 * @return An array of feed items if defined
	 */
	array function getFeedItems() {
		return getChildren();
	}

	/**
	 * Checks if the feed has a feed item
	 * @return True if the feed has any feed items, false if not
	 */
	boolean function hasFeedItem() {
		return hasChild();
	}

	/**
	 * Gets the number of feed items
	 * @return The number of feed items
	 */
	numeric function getNumberOfFeedItems() {
		return getNumberOfChildren();
	}

	/**
	 * Gets the latest published feed items
	 * @max The maximum number of feed items to return
	 * @return An array of feed items
	 */
	array function getLatestFeedItems( required numeric max=5 ) {
		var feeditems = [];
		if ( isLoaded() ) {
			feedItems = feedItemService.getPublishedFeedItems(
				feed=getContentID(),
				max=arguments.max
			).feedItems;
		}
		return feedItems;
	}

	/**
	 * Checks to see if the feed can import
	 * @return True if the feed can import, false if not
	 */
	boolean function canImport() {
		return getIsActive() && ( !isDate( getStartDate() ) || getStartDate() LTE now() ) && ( !isDate( getStopDate() ) || getStopDate() GTE now() );
	}

	/**
	 * Checks to see if the feed import routine is currently failing
	 * @return True if imports are failing, false if not
	 */
	boolean function isFailing() {
		if ( !isNull( getIsFailing() ) ) {
			return getIsFailing();
		}
		return false;
	}

	/**
	 * Checks to see if the feed contains mostly articles
	 * @return True if the feed contains mostly articles, false if not
	 */
	boolean function isArticleFeed() {
		return ( getNumberOfArticles() / getNumberOfFeedItems() ) GT .5;
	}

	/**
	 * Checks to see if the feed contains mostly podcasts
	 * @return True if the feed contains mostly podcasts, false if not
	 */
	boolean function isPodcastFeed() {
		return ( getNumberOfPodcasts() / getNumberOfFeedItems() ) GT .5;
	}

	/**
	 * Checks to see if the feed contains mostly videos
	 * @return True if the feed contains mostly videos, false if not
	 */
	boolean function isVideoFeed() {
		return ( getNumberOfVideos() / getNumberOfFeedItems() ) GT .5;
	}

	/**
	 * Gets the feed type based on the feed item types
	 * @return The feed type
	 */
	string function getFeedType() {
		if ( isArticleFeed() ) {
			return "article";
		} else if ( isPodcastFeed() ) {
			return "podcast";
		} else {
			return "video";
		}
	}

	/**
	 * Adds a timestamp to the start date property using separate hour and minute values
	 * @hour The hour value of the timestamp
	 * @minute The minute value of the timestamp
	 * @return Feed
	 */
	Feed function addStartTime( required string hour, required string minute ) {
		if ( isDate( getStartDate() ) ) {
			if ( !len( arguments.hour ) ) arguments.hour = "0";
			if ( !len( arguments.minute ) ) arguments.minute = "00";
			var time = timeformat( "#arguments.hour#:#arguments.minute#", "hh:mm tt" );
			setStartDate( getStartDate() & " " & time );
		}
		return this;
	}

	/**
	 * Adds a timestamp to the start date property using a timestring value
	 * @timeString The timestamp to use with the format hh:mm
	 * @return Feed
	 */
	Feed function addJoinedStartTime( required string timeString ) {
		var splitTime = listToArray( arguments.timeString, ":" );
		if ( arrayLen( splitTime ) == 2 ) {
			return addStartTime( splitTime[ 1 ], splitTime[ 2 ] );
		} else {
			return this;
		}
	}

	/**
	 * Gets the formatted start date
	 * @showTime Whether or not to include the time in the formatted start date
	 * @return The formatted start date
	 */
	string function getStartDateForEditor( boolean showTime=false ) {
		var sDate = getStartDate();
		if ( isNull( sDate ) ) { sDate = ""; }
		var fDate = dateFormat( sDate, "yyyy-mm-dd" );
		if ( arguments.showTime ) {
			fDate &= " " & timeFormat( sDate, "hh:mm tt" );
		}
		return fDate;
	}

	/**
	 * Adds a timestamp to the stop date property
	 * @hour The hour value of the timestamp
	 * @minute The minute value of the timestamp
	 * @return Feed
	 */
	Feed function addStopTime( required string hour, required string minute ) {
		if ( isDate( getStopDate() ) ) {
			if ( !len( arguments.hour ) ) arguments.hour = "0";
			if ( !len( arguments.minute ) ) arguments.minute = "00";
			var time = timeformat( "#arguments.hour#:#arguments.minute#", "hh:mm tt" );
			setStopDate( getStopDate() & " " & time );
		}
		return this;
	}

	/**
	 * Adds a timestamp to the stop date property using a timestring value
	 * @timeString The timestamp to use with the format hh:mm
	 * @return Feed
	 */
	Feed function addJoinedStopTime( required string timeString ) {
		var splitTime = listToArray( arguments.timeString, ":" );
		if ( arrayLen( splitTime ) == 2 ) {
			return addStopTime( splitTime[ 1 ], splitTime[ 2 ] );
		} else {
			return this;
		}
	}

	/**
	 * Gets the formatted stop date
	 * @showTime Whether or not to include the time in the formatted stop date
	 * @return The formatted start date
	 */
	string function getStopDateForEditor( boolean showTime=false ) {
		var sDate = getStopDate();
		if ( isNull( sDate ) ) { sDate = ""; }
		var fDate = dateFormat( sDate, "yyyy-mm-dd" );
		if ( arguments.showTime ) {
			fDate &= " " & timeFormat( sDate, "hh:mm tt" );
		}
		return fDate;
	}

	/**
	 * Gets the formatted last imported date
	 * @dateFormat The dateformat to use
	 * @timeFormat The timeformat to use
	 * @return The formatted last imported date
	 */
	string function getDisplayImportedDate( string dateFormat="dd mmm yyyy", string timeFormat="hh:mm tt" ) {
		var importedDate = getImportedDate();
		if ( isNull( importedDate ) ) importedDate = "";
		return dateFormat( importedDate, arguments.dateFormat ) & " " & timeFormat( importedDate, arguments.timeFormat );
	}

	/**
	 * Gets the url of the featured image
	 * @getAltImageUrl Whether or not to check and return the alt featured image if one exists
	 * @return The url of the featured image
	 */
	string function getFeaturedImageUrl( boolean getAltImageUrl=true ) {

		if ( len( super.getFeaturedImageUrl() ) ) {
			return super.getFeaturedImageUrl();
		} else if ( arguments.getAltImageUrl ) {
			var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
			var behavior = len( getSetting( "feed_featured_image_behavior", "" ) ) ? getSetting( "feed_featured_image_behavior", "" ) : settings.feed_featured_image_behavior;
			if ( behavior == "default" ) {
				return settings.feed_featured_image_default_url;
			} else {
				return "";
			}
		} else {
			return "";
		}

	}

	/**
	 * Gets a flat representation of the feed for UI response format which restricts the data displayed
	 * @slugCache A cache of slugs to prevent infinite recursions
	 * @showAuthor Whether or not to include the author
	 * @showComments Whether or not to include the comments
	 * @showCustomFields Whether or not to include the custom fields
	 * @showParent Whether or not to include the parent
	 * @showChildren Whether or not to include the children
	 * @showCategories Whether or not to include the categories
	 * @showRelatedContent Whether or not to include the related content
	 * @return A structure containing the feed properties
	 */
	struct function getResponseMemento(
		required array slugCache=[],
		boolean showAuthor=true,
		boolean showComments=false,
		boolean showCustomFields=false,
		boolean showParent=false,
		boolean showChildren=false,
		boolean showCategories=true,
		boolean showRelatedContent=false
	) {

		// Included properties
		arguments.properties = [
			"feedUrl",
			"tagLine"
		];

		// Grab the base content response memento
		var result = super.getResponseMemento( argumentCollection=arguments );

		// Set custom properties
		result["websiteUrl"] = getWebsiteUrl();
		result["importedDate"] = getDisplayImportedDate();
		result["isActive"] = canImport();
		result["feedItems"] = [];
		if ( hasFeedItem() ) {
			for ( var item IN children ) {
				arrayAppend(
					result["feedItems"],
					{
						"slug" = item.getSlug(),
						"title" = item.getTitle()
					}
				);
			}
		}

		return result;

	}

	/**
	 * Gets a flat representation of the feed
	 * @slugCache A cache of slugs to prevent infinite recursions
	 * @showAuthor Whether or not to include the author
	 * @showComments Whether or not to include the comments
	 * @showCustomFields Whether or not to include the custom fields
	 * @showContentVersions Whether or not to include the content versions
	 * @showParent Whether or not to include the parent
	 * @showChildren Whether or not to include the children
	 * @showCategories Whether or not to include the categories
	 * @showRelatedContent Whether or not to include the related content
	 * @showStats Whether or not to include the stats
	 * @return A structure containing the feed properties
	 */
	struct function getMemento(
		required array slugCache=[],
		boolean showAuthor=true,
		boolean showComments=true,
		boolean showCustomFields=true,
		boolean showContentVersions=true,
		boolean showParent=true,
		boolean showChildren=false,
		boolean showCategories=true,
		boolean showRelatedContent=true,
		boolean showStats=true
	) {

		// Included properties
		arguments.properties = [
			"feedUrl",
			"tagLine",
			"startDate",
			"stopDate"
		];

		// Grab the base content memento
		var result = super.getMemento( argumentCollection=arguments );

		// Set custom properties
		result["websiteUrl"] = getWebsiteUrl();
		result["importedDate"] = getDisplayImportedDate();
		result["isActive"] = canImport();
		result["settings"] = getSettings();
		result["feedItems"] = [];
		if ( hasFeedItem() ) {
			for ( var item IN children ) {
				arrayAppend( result["feedItems"], item.getMemento() );
			}
		}

		return result;

	}

	/**
	 * Validates the feed
	 * @return An array of errors or an empty array if no error is found
	 */
	array function validate() {

		var errors = [];

		variables.HTMLKeyWords = trim( left( HTMLKeywords, 160 ) );
		variables.HTMLDescription = trim( left( HTMLDescription, 160 ) );
		variables.title = trim( left( title, 200 ) );
		variables.slug = trim( left( slug, 200 ) );
		variables.feedUrl = trim( left( feedUrl, 255 ) );
		variables.tagLine = trim( left( tagLine, 255 ) );

		if ( !len( variables.title ) ) { arrayAppend( errors, "Title is required" ); }
		if ( !len( variables.slug ) ) { arrayAppend( errors, "Slug is required" ); }
		if ( !len( variables.feedUrl ) ) { arrayAppend( errors, "Feed URL is required" ); }

		return errors;

	}

}