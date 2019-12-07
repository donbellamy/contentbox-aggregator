/**
 * ContentBox Aggregator
 * FeedItem Model
 * @author Don Bellamy <don@perfectcode.com>
 */
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
	**                            PROPERTIES
	********************************************************************* */

	property name="excerpt"
		notnull="false"
		ormtype="text";

	property name="uniqueId"
		notnull="true"
		length="510"
		index="idx_uniqueId";

	property name="itemAuthor"
		notnull="false"
		length="255";

	property name="itemUrl"
		notnull="true"
		length="510";

	property name="videoUrl"
		notnull="false"
		length="510";

	property name="podcastUrl"
		notnull="false"
		length="510";

	property name="metaInfo"
		notnull="false"
		ormtype="text";

	/* *********************************************************************
	**                            RELATIONSHIPS
	********************************************************************* */

	// O2M -> Attachments
	property name="attachments"
		singularName="Attachment"
		fieldtype="one-to-many"
		type="array"
		lazy="extra"
		batchsize="25"
		orderby="feedItemAttachmentID DESC"
		cfc="FeedItemAttachment"
		fkcolumn="FK_feedItemID"
		inverse="true"
		cascade="all-delete-orphan";

	/* *********************************************************************
	**                            DI INJECTIONS
	********************************************************************* */

	property name="settingService"
		inject="settingService@cb"
		persistent="false";

	/* *********************************************************************
	**                            NON PERSISTED PROPERTIES
	********************************************************************* */

	property name="renderedExcerpt"
		persistent="false"
		default="";

	/* *********************************************************************
	**                            CONSTRAINTS
	********************************************************************* */

	this.constraints["uniqueId"] = { required=true, size="1..510" };
	this.constraints["itemUrl"] = { required=true, type="url", size="1..510" };
	this.constraints["itemAuthor"] = { required=false, size="1..255" };

	/**
	 * Constructor
	 * @return FeedItem
	 */
	FeedItem function init() {
		super.init();
		variables.allowComments = false;
		variables.categories = [];
		variables.renderedExcerpt = "";
		variables.createdDate = now();
		variables.contentType = "FeedItem";
		variables.attachments = [];
		variables.videodUrl = "";
		variables.podcastUrl = "";
		setMetaInfo({});
		return this;
	}

	/**
	 * Sets the meta info property
	 * @metaInfo A structure of meta data to set on the feed item
	 * @return FeedItem
	 */
	FeedItem function setMetaInfo( required any metaInfo ) {
		if ( isStruct( arguments.metaInfo ) ) {
			arguments.metaInfo = serializeJSON( arguments.metaInfo );
		}
		variables.metaInfo = arguments.metaInfo;
		return this;
	}

	/**
	 * Gets the meta info property
	 * @return A structure of meta data
	 */
	struct function getMetaInfo() {
		return ( !isNull( variables.metaInfo ) && isJSON( variables.metaInfo ) ) ? deserializeJSON( variables.metaInfo ) : {};
	}

	/**
	 * Gets the parent feed
	 * @return Feed
	 */
	Feed function getFeed() {
		return getParent();
	}

	/**
	 * Checks to see if the feed item has an excerpt
	 * @return True if an excerpt exists, false if not
	 */
	boolean function hasExcerpt() {
		return len( trim( getExcerpt() ) );
	}

	/**
	 * Renders the feed item excerpt
	 * @return The rendered excerpt
	 */
	string function renderExcerpt() {

		if ( hasExcerpt() AND NOT len( variables.renderedExcerpt ) ) {
			lock name="contentbox.excerptrendering.#getContentID()#" type="exclusive" throwontimeout="true" timeout="10" {
				var b = createObject( "java","java.lang.StringBuilder" ).init( getExcerpt() );
				var iData = {
					builder = b,
					content	= this
				};
				interceptorService.processState( "cb_onContentRendering", iData );
				variables.renderedExcerpt = b.toString();
			}
		}

		return variables.renderedExcerpt;

	}

	/**
	 * Gets the shortened and cleaned version of the excerpt taken from the feed item body
	 * @count The number of characters to include in the excerpt
	 * @excerptEnding The characters to display at the end of the excerpt
	 * @return The generated content excerpt
	 */
	string function getContentExcerpt( numeric count=255, string excerptEnding="..." ) {

		// Remove html from content
		var content = reReplaceNoCase( getContent(), "<[^>]*>", "", "ALL" );

		// Trim the content
		content = trim( left( content, arguments.count ) );

		// Add the content ending
		content = content & ( right( content, 1 ) NEQ "." ? arguments.excerptEnding : "" );

		// Add paragraph tags and return
		return "<p>" & content & "</p>";

	}

	/**
	 * Gets the url of the featured image
	 * @getAltImageUrl Whether or not to check and return the alt featured image if one exists
	 * @return The url of the featured image
	 */
	string function getFeaturedImageUrl( boolean getAltImageUrl=true ) {

		if ( len( super.getFeaturedImageUrl() ) ) {
			return super.getFeaturedImageUrl();
		} else if ( arguments.getAltImageUrl ) {
			var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
			var feed = getFeed();
			var behavior = len( feed.getFeaturedImageBehavior() ) ? feed.getFeaturedImageBehavior() : settings.feed_items_featured_image_behavior;
			if ( behavior == "feed" ) {
				return feed.getFeaturedImageUrl();
			} else if ( behavior == "default" ) {
				return settings.feed_items_featured_image_default_url;
			} else {
				return "";
			}
		} else {
			return "";
		}

	}

	/**
	 * Gets a flat representation of the feed item for UI response format which restricts the data displayed
	 * @slugCache A cache of slugs to prevent infinite recursions
	 * @showAuthor Whether or not to include the author
	 * @showComments Whether or not to include the comments
	 * @showCustomFields Whether or not to include the custom fields
	 * @showParent Whether or not to include the parent
	 * @showChildren Whether or not to include the children
	 * @showCategories Whether or not to include the categories
	 * @showRelatedContent Whether or not to include the related content
	 * @return A structure containing the feed item properties
	 */
	struct function getResponseMemento(
		required array slugCache=[],
		boolean showAuthor=false,
		boolean showComments=false,
		boolean showCustomFields=false,
		boolean showParent=false,
		boolean showChildren=false,
		boolean showCategories=true,
		boolean showRelatedContent=false
	) {

		// Included properties
		arguments.properties = [
			"uniqueId",
			"itemUrl",
			"itemAuthor"
		];

		// Grab the base content response memento
		var result = super.getResponseMemento( argumentCollection=arguments );

		// Set custom properties
		result["excerpt"] = renderExcerpt();
		result["feed"] = {
			"slug" = getFeed().getSlug(),
			"title" = getFeed().getTitle()
		};

		return result;

	}

	/**
	 * Gets a flat representation of the feed item
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
	 * @return A structure containing the feed item properties
	 */
	struct function getMemento(
		required array slugCache = [],
		boolean showAuthor=true,
		boolean showComments=true,
		boolean showCustomFields=true,
		boolean showContentVersions=true,
		boolean showParent=false,
		boolean showChildren=true,
		boolean showCategories=true,
		boolean showRelatedContent=true,
		boolean showStats=true
	) {

		// Included properties
		arguments.properties = [
			"uniqueId",
			"itemUrl",
			"itemAuthor",
			"excerpt"
		];

		// Grab the base content memento
		var result = super.getMemento( argumentCollection=arguments );

		// Set custom properties
		result["feed"] = {
			"contentID" = getFeed().getContentID(),
			"slug" = getFeed().getSlug(),
			"title" = getFeed().getTitle()
		};
		result["metaInfo"] = getMetaInfo();

		return result;

	}

	/**
	 * Gets the feed item type
	 * @return The feed item type
	 */
	string function getType() {
		if ( len( getVideoUrl() ) ) {
			return "video";
		} else if ( len( getPodcastUrl() ) ) {
			return "podcast";
		} else {
			return "article";
		}
	}

	/**
	 * Shorthand function for checking if the feed item is a video
	 * @return Whether or not the feed item is a video
	 */
	boolean function isVideo() {
		return len( getVideoUrl() );
	}

	/**
	 * Shorthand function for checking if the feed item is a bitchute video
	 * @return Whether or not the feed item is a bitchute video
	 */
	boolean function isBitchute() {
		return isVideo() && reFindNoCase( "bitchute\.com", getVideoUrl() );
	}

	/**
	 * Shorthand function for checking if the feed item is a vimeo video
	 * @return Whether or not the feed item is a vimeo video
	 */
	boolean function isVimeo() {
		return isVideo() && reFindNoCase( "vimeo\.com", getVideoUrl() );
	}

	/**
	 * Shorthand function for checking if the feed item is a youtube video
	 * @return Whether or not the feed item is a youtube video
	 */
	boolean function isYouTube() {
		return isVideo() && reFindNoCase( "youtube\.com", getVideoUrl() );
	}

	/**
	 * Shorthand function for checking if the feed item is a podcast or contains a podcast
	 * @return Whether or not the feed item is a podcast or contains a podcast
	 */
	boolean function isPodcast() {
		return len( getPodcastUrl() );
	}

	/**
	 * Gets the mime type if the feed item is a podcast or contains a podcast
	 * @return The podcast mime type if the feed item is a podcast or contains a podcast
	 */
	string function getPodcastMimeType() {

		// Set var
		var mimeType = "";

		// Check if item contains a podcast
		if ( isPodCast() ) {

			// Set vars
			var podcastUrl = getPodcastUrl();
			var results = reFindNoCase( "(\.mp3|\.m4a|\.mp4|\.acc|\.oga|\.ogg|\.wav)(&|\?)?(.*)$", podcastUrl, 1, true );
			var ext = mid( podcastUrl, results.pos[2], results.len[2] );
			var mimeTypes = {
				".mp3" = "audio/mpeg",
				".m4a" = "audio/mp4",
				".mp4" = "audio/mp4",
				".aac" = "audio/mp4",
				".oga" = "audio/ogg",
				".ogg" = "audio/ogg",
				".wav" = "audio/wav"
			};

			// Set mime type
			mimeType = mimeTypes[ ext ];

		}

		// Return mime type
		return mimeType;

	}

	/**
	 * Gets the published date without the time
	 * @return The published date
	 */
	date function getPublishedDateNoTime() {
		var publishedDate = getPublishedDate();
		return createDate( datePart( "yyyy", publishedDate ), datePart( "m", publishedDate ), datePart( "d", publishedDate ) );
	}

	/**
	 * Validates the feed item
	 * @return An array of errors or an empty array if no error is found
	 */
	array function validate() {

		var errors = [];

		variables.title = trim( left( variables.title, 200 ) );
		variables.slug = trim( left( variables.slug, 200 ) );

		if ( !len( variables.title ) ) { arrayAppend( errors, "Title is required" ); }
		if ( !len( variables.slug ) ) { arrayAppend( errors, "Slug is required" ); }

		return errors;

	}

}