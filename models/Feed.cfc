/**
 * ContentBox RSS Aggregator
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

	property name="importImages"
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
		orderby="importedDate DESC"
		cfc="FeedImport"
		fkcolumn="FK_feedID"
		inverse="true"
		cascade="all-delete-orphan";

	/* *********************************************************************
	**                            CALCULATED FIELDS
	********************************************************************* */

	property name="importedDate"
		formula="select max(fi.importedDate) from cb_feedimport fi where fi.FK_feedID=contentID"
		default="";

	property name="isFailing"
		formula="select fi.importFailed from cb_feedimport fi where fi.FK_feedID=contentID and fi.importedDate = ( select max(fi.importedDate) from cb_feedimport fi where fi.FK_feedID=contentID )"
		default="false";

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
		allowComments = false;
		categories = [];
		renderedContent = "";
		createdDate = now();
		contentType = "Feed";
		feedImports = [];
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
		var feedImport = javaCast( "null", "" );
		if ( arrayLen( getFeedImports() ) ) {
			feedImport = getFeedImports()[1];
		}
		return feedImport;
	}

	/**
	 * Gets the site url from the latest feed import
	 * @return The siteUrl if defined, the feed url if not
	 */
	string function getWebsiteUrl() {
		var siteUrl = getFeedUrl();
		var feedImport = getLatestFeedImport();
		if ( !isNull( feedImport ) && len( feedImport.getWebsiteUrl() ) ) {
			siteUrl = feedImport.getWebsiteUrl();
		}
		return siteUrl;
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
		var failing = 0;
		if ( !isNull( getIsFailing() ) ) failing = getIsFailing();
		return failing;
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
		return dateFormat( importedDate, arguments.dateFormat ) & " " & timeFormat( importedDate, arguments.timeFormat );
	}

	/**
	 * Gets a flat representation of the feed for UI response format which restricts the data displayed
	 * @showAuthor Whether or not to include the feed author
	 * @showCategories Whether or not to include the categories
	 * @showFeedItems Whether or not to include the feed items
	 * @excludes A list of properties to exclude
	 * @return A structure containing the feed properties
	 */
	struct function getResponseMemento(
		boolean showAuthor=true,
		boolean showCategories=true,
		boolean showFeedItems=true,
		string excludes="allowComments,isDeleted,HTMLTitle,HTMLDescription,HTMLKeywords"
	) {

		// Set base content arguments defaults unrelated to feeds
		arguments.slugCache = [];
		arguments.showComments = false;
		arguments.showCustomFields = false;
		arguments.showParent = false;
		arguments.showChildren = false;
		arguments.showRelatedContent = false;

		// Grab the base content memento
		var result = super.getResponseMemento( argumentCollection=arguments );

		// Set feed properties
		result["websiteUrl"] = getWebsiteUrl();
		result["feedUrl"] = getFeedUrl();
		result["tagLine"] = getTagLine();
		result["importedDate"] = getDisplayImportedDate();
		result["isActive"] = canImport();

		if ( arguments.showFeedItems && hasFeedItem() ) {
			result["feedItems"] = [];
			for ( var item IN children ) {
				arrayAppend(
					result["feedItems"],
					{
						"slug" = item.getSlug(),
						"title" = item.getTitle()
					}
				);
			}
		} else if ( arguments.showFeedItems ) {
			result["feedItems"] = [];
		}

		return result;

	}

	/**
	 * Validates the feed
	 * @return An array of errors or an empty array if no error is found
	 */
	array function validate() {

		var errors = [];

		HTMLKeyWords = trim( left( HTMLKeywords, 160 ) );
		HTMLDescription = trim( left( HTMLDescription, 160 ) );
		title = trim( left( title, 200 ) );
		slug = trim( left( slug, 200 ) );
		feedUrl = trim( left( feedUrl, 255 ) );
		tagLine = trim( left( tagLine, 255 ) );
		matchAnyFilter = trim( left( matchAnyFilter, 255 ) );
		matchAllFilter = trim( left( matchAllFilter, 255 ) );
		matchNoneFilter = trim( left( matchNoneFilter, 255 ) );

		if ( !len( title ) ) { arrayAppend( errors, "Title is required" ); }
		if ( !len( slug ) ) { arrayAppend( errors, "Slug is required" ); }
		if ( !len( feedUrl ) ) { arrayAppend( errors, "Feed URL is required" ); }

		return errors;

	}

}