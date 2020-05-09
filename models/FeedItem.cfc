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

	// Note: These should be one-to-one relationships but
	// Hibernate 3.5 doesn't allow optional one-to-one relationships,
	// change when Lucee upgrades to version 5

	// O2M -> Podcast
	property name="podcasts"
		singularName="podcast"
		fieldtype="one-to-many"
		type="array"
		lazy="extra"
		batchsize="25"
		orderby="feedItemPodcastID DESC"
		cfc="FeedItemPodcast"
		fkcolumn="FK_feedItemID"
		inverse="true"
		cascade="all-delete-orphan";

	// O2M -> Video
	property name="videos"
		singularName="video"
		fieldtype="one-to-many"
		type="array"
		lazy="extra"
		batchsize="25"
		orderby="feedItemVideoID DESC"
		cfc="FeedItemVideo"
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
		variables.videos = [];
		variables.podcasts = [];
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
	 * Gets the url of the featured or alternative image if one exists
	 * @return The url of the featured or alternative image
	 */
	string function getFeaturedOrAltImageUrl() {

		if ( len( getFeaturedImageUrl() ) && fileExists( getFeaturedImage() ) ) {
			return getFeaturedImageUrl();
		} else {
			var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
			var feed = getFeed();
			var behavior = len( feed.getSetting( "feed_items_featured_image_behavior", "" ) ) ? feed.getSetting( "feed_items_featured_image_behavior", "" ) : settings.feed_items_featured_image_behavior;
			if ( behavior == "feed" ) {
				return feed.getFeaturedOrAltImageUrl();
			} else if ( behavior == "default" && len( settings.feed_items_featured_image_default_url ) && fileExists( settings.feed_items_featured_image_default ) ) {
				return settings.feed_items_featured_image_default_url;
			} else {
				return "";
			}
		}

	}

	/**
	 * Gets the path of the featured or alternative image if one exists
	 * @return The path of the featured or alternative image
	 */
	string function getFeaturedOrAltImage() {

		if ( len( getFeaturedImage() ) && fileExists( getFeaturedImage() ) ) {
			return getFeaturedImage();
		} else  {
			var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
			var feed = getFeed();
			var behavior = len( feed.getSetting( "feed_items_featured_image_behavior", "" ) ) ? feed.getSetting( "feed_items_featured_image_behavior", "" ) : settings.feed_items_featured_image_behavior;
			if ( behavior == "feed" ) {
				return feed.getFeaturedOrAltImage();
			} else if ( behavior == "default" && len( settings.feed_items_featured_image_default ) && fileExists( settings.feed_items_featured_image_default ) ) {
				return settings.feed_items_featured_image_default;
			} else {
				return "";
			}
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
		if ( isVideo() ) {
			return "video";
		} else if ( isPodcast() ) {
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
		return hasVideo();
	}

	/**
	 * Gets the attached video if one exists
	 * @return The attached video if one exists, null if not
	 */
	any function getVideo() {
		if ( isVideo() ) {
			return getVideos()[1];
		}
		return javaCast( "null", "" );
	}

	/**
	 * Gets the video url if an attached video exists
	 * @return The video url if an attached video exists
	 */
	string function getVideoUrl() {
		if ( isVideo() ) {
			return getVideo().getVideoUrl();
		}
		return "";
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
		return hasPodcast();
	}

	/**
	 * Gets the attached podcast if one exists
	 * @return The attached podcast if one exists, null if not
	 */
	any function getPodcast() {
		if ( isPodcast() ) {
			return getPodcasts()[1];
		}
		return javaCast( "null", "" );
	}

	/**
	 * Gets the podcast url if an attached podcast exists
	 * @return The podcast url if an attached podcast exists
	 */
	string function getPodcastUrl() {
		if ( isPodcast() ) {
			return getPodcast().getPodcastUrl();
		}
		return "";
	}

	/**
	 * Gets the mime type if the feed item is a podcast or contains a podcast
	 * @return The podcast mime type if the feed item is a podcast or contains a podcast
	 */
	string function getPodcastMimeType() {
		if ( isPodcast() ) {
			return getPodcast().getMimeType();
		}
		return "";
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