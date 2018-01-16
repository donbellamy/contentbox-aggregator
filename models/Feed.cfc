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

	property name="feedUrl"
		notnull="true"
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

	this.constraints["feedUrl"] = { required=true, type="url", size="1..255" };
	this.constraints["startDate"] = { required=false, type="date" };
	this.constraints["stopDate"] = { required=false, type="date" };
	this.constraints["defaultStatus"] = { required=true, regex="(draft|published)" };
	this.constraints["maxAge"] = { required=false, type="numeric" };
	this.constraints["maxAgeUnit"] = { required=false, regex="(days|weeks|months|years)" };
	this.constraints["maxItems"] = { required=false, type="numeric" };
	this.constraints["matchAnyFilter"] = { required=false, size="1..255" };
	this.constraints["matchAllFilter"] = { required=false, size="1..255" };
	this.constraints["matchNoneFilter"] = { required=false, size="1..255" };

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

		feedUrl = trim( left( feedUrl, 255 ) );
		title = trim( left( title, 200 ) );
		slug = trim( left( slug, 200 ) );
		
		HTMLKeyWords = trim( left( HTMLKeywords, 160 ) );
		HTMLDescription = trim( left( HTMLDescription, 160 ) );

		matchAnyFilter = trim( left( matchAnyFilter, 255 ) );
		matchAllFilter = trim( left( matchAllFilter, 255 ) );
		matchNoneFilter = trim( left( matchNoneFilter, 255 ) );

		if( !len( feedUrl ) ) { arrayAppend( errors, "Feed URL is required" ); }
		if( !len( title ) ) { arrayAppend( errors, "Title is required" ); }
		if( !len( slug ) ) { arrayAppend( errors, "Slug is required" ); }

		return errors;

	}

}