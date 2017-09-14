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

	property name="excerpt"
		notnull="false"
		ormtype="text"
		length="8000";

	property name="filterByAny"
		notnull="false";

	property name="filterByAll"
		notnull="false";

	property name="filterByNone"
		notnull="false";

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
	this.constraints["stopDate"] = { required=true, type="date" };

	function init() {
		super.init();
		categories = [];
		createdDate = now();
		contentType = "Feed";
		return this;
	}

}