component persistent="true" 
	entityname="cbFeed" //agFeed
	table="cb_feed" // ag_feed
	batchsize="25" 
	extends="contentbox.models.content.BaseContent" 
	cachename="cbFeed" 
	cacheuse="read-write" 	
	joincolumn="contentID" 
	discriminatorValue="Feed" {

	property name="url" 
		notnull="true"
		length="255";

	this.constraints["url"] = { required = true, type="url", size = "1..255" };

	function init() {
		super.init();
		createdDate = now();
		contentType = "Feed";
		return this;
	}

}