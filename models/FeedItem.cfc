component persistent="true"
	entityname="cbFeedItem"
	table="cb_feeditem"
	batchsize="25"
	cachename="cbFeedItem"
	cacheuse="read-write"
	extends="contentbox.models.content.BaseContent"
	joincolumn="contentID"
	discriminatorValue="FeedItem" {

	property name="excerpt"
		notnull="false"
		ormtype="text"
		length="8000";

	property name="url"
		notnull="true"
		length="255";

	property name="uniqueId"
		notnull="true"
		length="255"
		index="idx_uniqueId";

	property name="author"
		notnull="false"
		length="255";

	property name="datePublished"
		notnull="true"
		ormtype="timestamp"
		index="idx_datePublished";

	property name="dateUpdated"
		notnull="true"
		ormtype="timestamp";

	property name="metaInfo"
		notnull="false"
		ormtype="text";

	this.constraints["url"] = { required=true, type="url", size="1..255" };
	this.constraints["uniqueId"] = { required=true, size="1..255" };
	this.constraints["author"] = { required=false, size="1..255" };
	this.constraints["datePublished"] = { required=true, type="date" };
	this.constraints["dateUpdated"] = { required=false, type="date" };

	FeedItem function init() {
		super.init();
		categories = [];
		createdDate = now();
		contentType = "FeedItem";
		return this;
	}

	Feed function getFeed() {
		return getParent();
	}

	string function getDisplayDatePublished() {
		var datePublished = getDatePublished();
		return dateFormat( datePublished, "dd mmm yyyy" ) & " " & timeFormat( datePublished, "hh:mm tt" );
	}

	array function validate() {

		var errors = [];

		//TODO: validate item

		return errors;

	}

}