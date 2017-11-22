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
	**							PROPERTIES									
	********************************************************************* */

	property name="url"
		notnull="true"
		length="255";

	property name="excerpt"
		notnull="false"
		ormtype="text"
		length="8000";

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

	property name="defaultStatus"
		notnull="true"
		length="10"
		default="draft";

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

	/* *********************************************************************
	**							RELATIONSHIPS									
	********************************************************************* */

	// O2M -> Feed imports
	property name="feedImports"
		singularName="feedImport"
		fieldtype="one-to-many"
		type="array"
		lazy="extra"
		batchsize="25"
		orderby="importedDate DESC"
		cfc="FeedImport"
		fkcolumn="FK_feedID"
		inverse="true"
		cascade="all-delete-orphan";

	// TODO: Overwrite properties?  From feed? - Same as import feeds

	// TODO: Private feed properties that we get from the feed itself.  Possible put into json as meta data?, as bulk import use in main fields?
	<!--- Stuff such as:
		Title - Usually title of the web site
		Description 
		Link - Usually to the home page of the website
		Copyright
		pubDate
		lastBuildDate
		Categories
		managingEditor
		webMaster
		image
	--->

<!---
Limit
<div class="wprss-tooltip-content" id="wprss-tooltip-field_wprss_limit">
<p>The maximum number of imported items from this feed to keep stored.</p>
<p>When new items are imported and the limit is exceeded, the oldest feed items will be deleted to make room for new ones.</p>
<p>If you already have items imported from this feed source, setting this option now may delete some of your items, in order to comply with the limit.</p>
</div>
Link to enclosure
<div class="wprss-tooltip-content" id="wprss-tooltip-field_wprss_enclosure">
<p>Tick this box to make feed items link to the URL in the enclosure tag, rather than link to the original article.</p>
<p>Enclosure tags are RSS tags that may be included with a feed items. These tags typically contain links to images, audio, videos, attachment files or even flash content.</p>
<p>If you are not sure leave this setting blank.</p>
</div>
Link Source
All keywords
Any keywords
None keywords
Apply the above filtering methods on the:
Filter title
Filter feed content
-----------------
Feed processing
-----------------
Feed state 
<div class="wprss-tooltip-content" id="wprss-tooltip-field_wprss_state">
<p>State of the feed, active or paused.</p>
<p>If active, the feed source will fetch items periodically, according to the settings below.</p>
<p>If paused, the feed source will not fetch feed items periodically.</p>
</div>
Activate feed: immediately
<div class="wprss-tooltip-content" id="wprss-tooltip-field_wprss_activate_feed">
<p>You can set a time, in UTC, in the future when the feed source will become active, if it is paused.</p>
<p>Leave blank to activate immediately.</p>
</div>
Pause feed: never
<div class="wprss-tooltip-content" id="wprss-tooltip-field_wprss_pause_feed">
<p>You can set a time, in UTC, in the future when the feed source will become paused, if it is active.</p>
<p>Leave blank to never pause.</p>
</div>
Update interval: Default 
<div class="wprss-tooltip-content" id="wprss-tooltip-field_wprss_update_interval">
<p>How frequently the feed source should check for new items and fetch if needed.</p>
<p>If left as <em>Default</em>, the interval in the global settings is used.</p>
</div>
Delete old feed items number - unit
<div class="wprss-tooltip-content" id="wprss-tooltip-field_wprss_age_limit">
<p>The maximum age allowed for feed items. Very useful if you are only concerned with, say, last week's news.</p>
<p>Items already imported will be deleted if they eventually exceed this age limit.</p>
<p>Also, items in the RSS feed that are already older than this age will not be imported at all.</p>
<p>Leaving empty to use the <em>Limit feed items by age</em> option in the general settings.</p>
</div>
--->

	this.constraints["url"] = { required=true, type="url", size="1..255" };
	this.constraints["filterByAny"] = { required=false, size="1..255" };
	this.constraints["filterByAll"] = { required=false, size="1..255" };
	this.constraints["filterByNone"] = { required=false, size="1..255" };
	this.constraints["startDate"] = { required=false, type="date" };
	this.constraints["stopDate"] = { required=false, type="date" };

	Feed function init() {
		super.init();
		categories = [];
		createdDate = now();
		contentType = "Feed";
		return this;
	}

	array function getFeedItems() {
		return getChildren();
	}

	boolean function hasFeedItem() {
		return hasChild();
	}

	numeric function getNumberOfFeedItems() {
		return getNumberOfChildren();
	}

	boolean function isActive() {
		return getIsActive() && ( !isDate( getStartDate() ) || getStartDate() LTE now() ) && ( !isDate( getStopDate() ) || getStopDate() GTE now() );
	}

	boolean function autoPublishItems() {
		return getDefaultStatus() EQ "published";
	}

	Feed function addStartTime( required string hour, required string minute ) {
		if ( isDate( getStartDate() ) ) { 
			if ( !len( arguments.hour ) ) arguments.hour = "0";
			if ( !len( arguments.minute ) ) arguments.minute = "00";
			var time = timeformat( "#arguments.hour#:#arguments.minute#", "hh:mm tt" );
			setStartDate( getStartDate() & " " & time );
		}
		return this;
	}

	Feed function addJoinedStartTime( required string timeString ) {
		var splitTime = listToArray( arguments.timeString, ":" );
		if( arrayLen( splitTime ) == 2 ) {
			return addStartTime( splitTime[ 1 ], splitTime[ 2 ] );
		} else {
			return this;
		}
	}

	string function getStartDateForEditor( boolean showTime=false ) {
		var sDate = getStartDate();
		if ( isNull( sDate ) ) { sDate = ""; }
		var fDate = dateFormat( sDate, "yyyy-mm-dd" );
		if ( arguments.showTime ) {
			fDate &= " " & timeFormat( sDate, "hh:mm tt" );
		}
		return fDate;
	}

	Feed function addStopTime( required string hour, required string minute ) {
		if ( isDate( getStopDate() ) ) { 
			if ( !len( arguments.hour ) ) arguments.hour = "0";
			if ( !len( arguments.minute ) ) arguments.minute = "00";
			var time = timeformat( "#arguments.hour#:#arguments.minute#", "hh:mm tt" );
			setStopDate( getStopDate() & " " & time );
		}
		return this;
	}

	Feed function addJoinedStopTime( required string timeString ) {
		var splitTime = listToArray( arguments.timeString, ":" );
		if( arrayLen( splitTime ) == 2 ) {
			return addStopTime( splitTime[ 1 ], splitTime[ 2 ] );
		} else {
			return this;
		}
	}

	string function getStopDateForEditor( boolean showTime=false ) {
		var sDate = getStopDate();
		if ( isNull( sDate ) ) { sDate = ""; }
		var fDate = dateFormat( sDate, "yyyy-mm-dd" );
		if ( arguments.showTime ) {
			fDate &= " " & timeFormat( sDate, "hh:mm tt" );
		}
		return fDate;
	}

	any function getLastImportedDate() {
		if ( hasFeedImport() ) {
			return getFeedImports()[1].getImportedDate();
		} else {
			return "";
		}
	}

	string function getDisplayLastImportedDate() {
		var lastImportedDate = getLastImportedDate();
		return dateFormat( lastImportedDate, "dd mmm yyyy" ) & " " & timeFormat( lastImportedDate, "hh:mm tt" );
	}

	array function validate() {

		var errors = [];

		HTMLKeyWords = trim( left( HTMLKeywords, 160 ) );
		HTMLDescription = trim( left( HTMLDescription, 160 ) );
		title = trim( left( title, 200 ) );
		slug = trim( left( slug, 200 ) );

		matchAnyFilter = trim( left( matchAnyFilter, 255 ) );
		matchAllFilter = trim( left( matchAllFilter, 255 ) );
		matchNoneFilter = trim( left( matchNoneFilter, 255 ) );

		// TODO: Validate dates?
		// TODO: excerpt

		if( !len( title ) ) { arrayAppend( errors, "Title is required" ); }
		if( !len( slug ) ) { arrayAppend( errors, "Slug is required" ); }

		return errors;

	}

}