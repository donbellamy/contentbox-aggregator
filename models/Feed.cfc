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

	property name="siteUrl"
		notnull="true"
		length="255";

	property name="feedUrl"
		notnull="true"
		length="255";

	property name="tagLine"
		notnull="false"
		length="255";

	property name="linkBehavior"
		notnull="false"
		length="10";

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

	property name="lastImportedDate"
		formula="select max(fi.importedDate) from cb_feedimport fi where fi.FK_feedID=contentID"
		default="";

	property name="isFailing"
		formula="select fi.importFailed from cb_feedimport fi where fi.FK_feedID=contentID and fi.importedDate = ( select max(fi.importedDate) from cb_feedimport fi where fi.FK_feedID=contentID )"
		default="";

	/* *********************************************************************
	**                            CONSTRAINTS
	********************************************************************* */

	// TODO: Update this
	this.constraints["siteUrl"] = { required=true, type="url", size="1..255" };
	this.constraints["feedUrl"] = { required=true, type="url", size="1..255" };
	this.constraints["tagLine"] = { required=false, size="1..255" };
	this.constraints["startDate"] = { required=false, type="date" };
	this.constraints["stopDate"] = { required=false, type="date" };
	this.constraints["itemStatus"] = { required=true, regex="(draft|published)" };
	this.constraints["ItemPubDate"] = { required=true, regex="(original|imported)" };
	this.constraints["maxAge"] = { required=false, type="numeric" };
	this.constraints["maxAgeUnit"] = { required=false, regex="(days|weeks|months|years)" };
	this.constraints["maxItems"] = { required=false, type="numeric" };
	this.constraints["matchAnyFilter"] = { required=false, size="1..255" };
	this.constraints["matchAllFilter"] = { required=false, size="1..255" };
	this.constraints["matchNoneFilter"] = { required=false, size="1..255" };
	this.constraints["featuredImageBehavior"] = { required=false, regex="(default|feed|none)" };

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

	Feed function setTaxonomies( required any taxonomies ) {
		if ( isArray( arguments.taxonomies ) ) {
			arguments.taxonomies = serializeJSON( arguments.taxonomies );
		}
		variables.taxonomies = arguments.taxonomies;
		return this;
	}

	array function getTaxonomies() {
		return ( !isNull( taxonomies ) && isJSON( taxonomies ) ) ? deserializeJSON( taxonomies ) : [];
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

	boolean function canImport() {
		return getIsActive() && ( !isDate( getStartDate() ) || getStartDate() LTE now() ) && ( !isDate( getStopDate() ) || getStopDate() GTE now() );
	}

	boolean function autoPublishItems() {
		return getItemStatus() EQ "published";
	}

	boolean function isFailing() {
		return getIsFailing();
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

	string function getDisplayLastImportedDate( string dateFormat="dd mmm yyyy", string timeFormat="hh:mm tt" ) {
		var lastImportedDate = getLastImportedDate();
		return dateFormat( lastImportedDate, arguments.dateFormat ) & " " & timeFormat( lastImportedDate, arguments.timeFormat );
	}

	struct function getResponseMemento(
		required array slugCache=[],
		boolean showAuthor=false,
		boolean showComments=false,
		boolean showCustomFields=false,
		boolean showContentVersions=false,
		boolean showParent=false,
		boolean showChildren=false,
		boolean showCategories=true,
		boolean showRelatedContent=false,
		boolean showStats=false,
		boolean showCommentSubscriptions=false,
		excludes="activeContent,linkedContent,commentSubscriptions,isDeleted,allowComments"
	) {

		var result 	= super.getResponseMemento( argumentCollection=arguments );

		result["siteUrl"] = getSiteUrl();
		result["feedUrl"] = getFeedUrl();
		result["tagLine"] = getTagLine();
		result["lastImportedDate"] = getDisplayLastImportedDate();
		result["isActive"] = canImport();

		/*
		"startDate"
		"stopDate"
		"itemStatus"
		"ItemPubDate"
		"matchAnyFilter"
		"matchAllFilter"
		"matchNoneFilter"
		"maxAge"
		"maxAgeUnit"
		"maxItems"
		"importImages"
		"importFeaturedImages"
		"featuredImageBehavior"
		*/

		return result;

	}

	// TODO: Update this
	array function validate() {

		var errors = [];

		HTMLKeyWords = trim( left( HTMLKeywords, 160 ) );
		HTMLDescription = trim( left( HTMLDescription, 160 ) );
		title = trim( left( title, 200 ) );
		slug = trim( left( slug, 200 ) );

		siteUrl = trim( left( siteUrl, 255 ) );
		feedUrl = trim( left( feedUrl, 255 ) );
		tagLine = trim( left( tagLine, 255 ) );
		matchAnyFilter = trim( left( matchAnyFilter, 255 ) );
		matchAllFilter = trim( left( matchAllFilter, 255 ) );
		matchNoneFilter = trim( left( matchNoneFilter, 255 ) );

		if( !len( title ) ) { arrayAppend( errors, "Title is required" ); }
		if( !len( slug ) ) { arrayAppend( errors, "Slug is required" ); }
		if( !len( siteUrl ) ) { arrayAppend( errors, "Site URL is required" ); }
		if( !len( feedUrl ) ) { arrayAppend( errors, "Feed URL is required" ); }


		return errors;

	}

}