component persistent="true"
	entityname="cbFeedItem"
	table="cb_feeditem"
	batchsize="25"
	cachename="cbFeedItem"
	cacheuse="read-write"
	extends="contentbox.models.content.BaseContent"
	joincolumn="contentID"
	discriminatorValue="FeedItem" {

	property name="link"
		notnull="true"
		length="255";

	property name="author"
		notnull="false"
		length="255";

	property name="pubDate"
		notnull="true"
		ormtype="timestamp" 
		index="idx_pubDate";

	property name="metaData"
		notnull="false"
		ormtype="text";

<!--- 
title	The title of the item.	Venice Film Festival Tries to Quit Sinking
link	The URL of the item.	http://nytimes.com/2004/12/07FEST.html
description     	The item synopsis.	Some of the most heated chatter at the Venice Film Festival this week was about the way that the arrival of the stars at the Palazzo del Cinema was being staged.
author	Email address of the author of the item. More.	oprah\@oxygen.net
category	Includes the item in one or more categories. More.	 
comments	URL of a page for comments relating to the item. More.	http://www.myblog.org/cgi-local/mt/mt-comments.cgi?entry_id=290
enclosure	Describes a media object that is attached to the item. More.	
guid	A string that uniquely identifies the item. More.	http://inessential.com/2002/09/01.php#a2
pubDate	Indicates when the item was published. More.	Sun, 19 May 2002 15:21:36 GMT
source	The RSS channel that the item came from. More.
--->

	Item function init() {
		super.init();
		categories = [];
		createdDate = now();
		contentType = "FeedItem";
		return this;
	}

	Feed function getFeed() {
		return getParent();
	}

}