component persistent="true"
	entityname="cbFeedItem"
	table="cb_feeditem"
	batchsize="25"
	cachename="cbFeedItem"
	cacheuse="read-write"
	extends="contentbox.models.content.BaseContent"
	joincolumn="contentID"
	discriminatorValue="FeedItem" {

	/* *********************************************************************
	**							PROPERTIES
	********************************************************************* */

	property name="excerpt"
		notnull="false"
		ormtype="text";

	property name="uniqueId"
		notnull="true"
		length="255"
		index="idx_uniqueId";

	property name="itemUrl"
		notnull="true"
		length="255";

	property name="itemAuthor"
		notnull="false"
		length="255";

	property name="metaInfo"
		notnull="false"
		ormtype="text";

	/* *********************************************************************
	**							DI INJECTIONS
	********************************************************************* */

	property name="settingService" inject="settingService@aggregator" persistent="false";

	/* *********************************************************************
	**							NON PERSISTED PROPERTIES
	********************************************************************* */

	property name="renderedExcerpt"
		persistent="false";

	/* *********************************************************************
	**							CONSTRAINTS
	********************************************************************* */

	this.constraints["itemUrl"] = { required=true, type="url", size="1..255" };
	this.constraints["uniqueId"] = { required=true, size="1..255" };
	this.constraints["author"] = { required=false, size="1..255" };

	FeedItem function init() {
		super.init();
		allowComments = false;
		categories = [];
		renderedContent = "";
		renderedExcerpt = "";
		renderedContentExcerpt = "";
		createdDate = now();
		contentType = "FeedItem";
		return this;
	}

	boolean function hasExcerpt() {
		return len( trim( getExcerpt() ) );
	}

	string function renderExcerpt() {

		// TODO: Should we empty this onsave? - look at entry onsave
		if ( len( getExcerpt() ) AND NOT len( renderedExcerpt ) ) {
			lock name="contentbox.excerptrendering.#getContentID()#" type="exclusive" throwontimeout="true" timeout="10" {
				var b = createObject( "java","java.lang.StringBuilder" ).init( getExcerpt() );
				var iData = {
					builder = b,
					content	= this
				};
				interceptorService.processState( "cb_onContentRendering", iData );
				renderedExcerpt = b.toString();
			}
		}

		return renderedExcerpt;

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
		excludes="activeContent,linkedContent,commentSubscriptions,isDeleted,allowComments,HTMLTitle,HTMLDescription,HTMLKeywords"
	) {

		var result 	= super.getResponseMemento( argumentCollection=arguments );

		result["excerpt"] = renderExcerpt();
		result["uniqueId"] = getUniqueId();
		result["itemUrl"] = getItemUrl();
		result["itemAuthor"] = getItemAuthor();
		result["feed"] = {
			"slug" = getParent().getSlug(),
			"title" = getParent().getTitle(),
			"contentType" = getParent().getContentType()
		};

		return result;

	}

	string function getImageUrl() {

		if ( len( getFeaturedImageUrl() ) ) {
			return getFeaturedImageUrl();
		} else {
			var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
			var feed = getFeed();
			var behavior = len( feed.getMissingImageBehavior() ) ? feed.getMissingImageBehavior() : settings.ag_importing_image_missing_behavior;
			if ( behavior == "feed" ) {
				return feed.getFeaturedImageUrl();
			} else if ( behavior == "default" ) {
				return settings.ag_importing_image_default_url;
			} else {
				return "";
			}
		}

	}

	Feed function getFeed() {
		return getParent();
	}

	array function validate() {

		var errors = [];

		title = trim( left( title, 200 ) );
		slug = trim( left( slug, 200 ) );

		if( !len( title ) ) { arrayAppend( errors, "Title is required" ); }
		if( !len( slug ) ) { arrayAppend( errors, "Slug is required" ); }

		return errors;

	}

}