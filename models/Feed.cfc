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

	property name="linkBehavior"
		notnull="false"
		length="15";

	property name="featuredImageBehavior"
		notnull="false"
		length="10";

	property name="pagingMaxItems"
		notnull="false"
		ormtype="long";

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

	property name="itemStatus"
		notnull="false"
		length="10";

	property name="ItemPubDate"
		notnull="false"
		length="10";

	property name="maxAge"
		notnull="false"
		ormtype="long";

	property name="maxAgeUnit"
		notnull="false"
		length="10";

	property name="maxItems"
		notnull="false"
		ormtype="long";

	property name="matchAnyFilter"
		notnull="false"
		length="255";

	property name="matchAllFilter"
		notnull="false"
		length="255";

	property name="matchNoneFilter"
		notnull="false"
		length="255";

	property name="importFeaturedImages"
		notnull="false"
		ormtype="boolean";

	property name="importAllImages"
		notnull="false"
		ormtype="boolean";

	property name="taxonomies"
		notnull="false"
		ormtype="text";

	property name="preFeedDisplay"
		notnull="false"
		ormtype="text";

	property name="postFeedDisplay"
		notnull="false"
		ormtype="text";

	property name="preFeedItemDisplay"
		notnull="false"
		ormtype="text";

	property name="postFeedItemDisplay"
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
	**                            CALCULATED FIELDS
	********************************************************************* */

	property name="importedDate"
		formula="select max(fi.createdDate) from cb_feedimport fi where fi.FK_feedID = contentID"
		default="";

	property name="isFailing"
		formula="select fi.importFailed from cb_feedimport fi where fi.FK_feedID = contentID and fi.feedImportID = ( select max(fi.feedImportID) from cb_feedimport fi where fi.FK_feedID=contentID )"
		default="false";

	property name="numberOfArticles"
		formula="select count(*) from cb_content c inner join cb_feeditem fi on c.contentID = fi.contentID where c.FK_parentID = contentID and ( fi.podcastUrl = '' or fi.podcastUrl IS NULL ) and ( fi.videoUrl = '' or fi.videoUrl IS NULL )"
		default="0";

	property name="numberOfPodcasts"
		formula="select count(*) from cb_content c inner join cb_feeditem fi on c.contentID = fi.contentID where c.FK_parentID = contentID and fi.podcastUrl > ''"
		default="0";

	property name="numberOfVideos"
		formula="select count(*) from cb_content c inner join cb_feeditem fi on c.contentID = fi.contentID where c.FK_parentID = contentID and fi.videoUrl > ''"
		default="0";

	property name="numberOfPublishedChildren"
		formula="select count(*) from cb_content c where c.FK_parentID = contentID and c.isPublished = 1 and c.publishedDate < now() and ( c.expireDate is null or c.expireDate > now() )"
		default="0";

	property name="lastPublishedDate"
		formula="select max(c.publishedDate) from cb_content c where c.FK_parentID = contentID and c.isPublished = 1 and c.publishedDate < now() and ( c.expireDate is null or c.expireDate > now() )"
		default="";

	/* *********************************************************************
	**                            CONSTRAINTS
	********************************************************************* */

	this.constraints["feedUrl"] = { required=true, type="url", size="1..255" };
	this.constraints["tagLine"] = { required=false, size="1..255" };
	this.constraints["linkBehavior"] = { required=false, regex="(forward|interstitial|display)" };
	this.constraints["featuredImageBehavior"] = { required=false, regex="(default|feed|none)" };
	this.constraints["pagingMaxItems"] = { required=false, type="numeric" };
	this.constraints["startDate"] = { required=false, type="date" };
	this.constraints["stopDate"] = { required=false, type="date" };
	this.constraints["itemStatus"] = { required=false, regex="(draft|published)" };
	this.constraints["itemPubDate"] = { required=false, regex="(original|imported)" }
	this.constraints["maxAge"] = { required=false, type="numeric" };
	this.constraints["maxAgeUnit"] = { required=false, regex="(days|weeks|months|years)" };
	this.constraints["maxItems"] = { required=false, type="numeric" };
	this.constraints["matchAnyFilter"] = { required=false, size="1..255" };
	this.constraints["matchAllFilter"] = { required=false, size="1..255" };
	this.constraints["matchNoneFilter"] = { required=false, size="1..255" };

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
		setTaxonomies([]);
		return this;
	}

	/**
	 * Sets the taxomomies property
	 * @taxonomies An array of taxonomies to set on the feed
	 * @return Feed
	 */
	Feed function setTaxonomies( required any taxonomies ) {
		if ( isArray( arguments.taxonomies ) ) {
			arguments.taxonomies = serializeJSON( arguments.taxonomies );
		}
		variables.taxonomies = arguments.taxonomies;
		return this;
	}

	/**
	 * Gets the taxonomies property
	 * @return An array of taxonomies if defined
	 */
	array function getTaxonomies() {
		return ( !isNull( variables.taxonomies ) && isJSON( variables.taxonomies ) ) ? deserializeJSON( variables.taxonomies ) : [];
	}

	/**
	 * Gets the latest feed import
	 * @return The latest feed import if exists, null if not
	 */
	any function getLatestFeedImport() {
		if ( arrayLen( getFeedImports() ) ) {
			return getFeedImports()[1];
		}
		return javaCast( "null", "" );
	}

	/**
	 * Gets the latest successful feed import
	 * @return The latest successful feed import if exists, null if not
	 */
	any function getLatestSuccessfulFeedImport() {
		if ( arrayLen( getFeedImports() ) ) {
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
	 * Gets the latest feed items
	 * @numberOfItems The number of feed items to return
	 * @return An array of feed items
	 */
	// TODO: This is taking too long per feed, just need a few props, maybe a query or struct from query?
	// TODO: Also not returning in the correct order, should be newest to oldest...
	array function getLatestFeedItems( required numeric numberOfItems=5 ) {
		var feedItems = [];
		for ( var feedItem IN getFeedItems() ) {
			if ( feedItem.isContentPublished() && !feedItem.isExpired() ) {
				arrayAppend( feedItems, feedItem );
				if ( arrayLen( feedItems ) EQ arguments.numberOfItems ) {
					break;
				}
			}
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
	 * Checks to see if feed items should be published when importing
	 * @return True if feed items should be published, false if not
	 */
	boolean function autoPublishItems() {
		return getItemStatus() EQ "published";
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
			"linkBehavior",
			"featuredImageBehavior",
			"pagingMaxItems",
			"startDate",
			"stopDate",
			"itemStatus",
			"ItemPubDate",
			"maxAge",
			"maxAgeUnit",
			"maxItems",
			"matchAnyFilter",
			"matchAllFilter",
			"matchNoneFilter",
			"importFeaturedImages",
			"importAllImages",
			"preFeedDisplay",
			"postFeedDisplay",
			"preFeedItemDisplay",
			"postFeedItemDisplay"
		];

		// Grab the base content memento
		var result = super.getMemento( argumentCollection=arguments );

		// Set custom properties
		result["websiteUrl"] = getWebsiteUrl();
		result["importedDate"] = getDisplayImportedDate();
		result["isActive"] = canImport();
		result["taxonomies"] = getTaxonomies();
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
		variables.matchAnyFilter = trim( left( matchAnyFilter, 255 ) );
		variables.matchAllFilter = trim( left( matchAllFilter, 255 ) );
		variables.matchNoneFilter = trim( left( matchNoneFilter, 255 ) );

		if ( !len( variables.title ) ) { arrayAppend( errors, "Title is required" ); }
		if ( !len( variables.slug ) ) { arrayAppend( errors, "Slug is required" ); }
		if ( !len( variables.feedUrl ) ) { arrayAppend( errors, "Feed URL is required" ); }

		return errors;

	}

}