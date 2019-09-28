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

	property name="itemUrl"
		notnull="true"
		length="510";

	property name="itemAuthor"
		notnull="false"
		length="255";

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

	property name="containsVideo"
		persistent="false"
		default="";

	property name="videoEmbedUrl"
		persistent="false"
		default="";

	property name="containsPodcast"
		persistent="false"
		default="";

	property name="podcastUrl"
		persistent="false"
		default="";

	property name="podcastMimeType"
		persistent="false"
		default="";

	/* *********************************************************************
	**                            CONSTRAINTS
	********************************************************************* */

	this.constraints["uniqueId"] = { required=true, size="1..255" };
	this.constraints["itemUrl"] = { required=true, type="url", size="1..255" };
	this.constraints["itemAuthor"] = { required=false, size="1..255" };

	/**
	 * Constructor
	 * @return FeedItem
	 */
	FeedItem function init() {
		super.init();
		allowComments = false;
		categories = [];
		renderedContent = "";
		renderedExcerpt = "";
		createdDate = now();
		contentType = "FeedItem";
		attachments = [];
		containsVideo = "";
		videoEmbedUrl = "";
		containsPodcast = "";
		podcastUrl = "";
		podcastMimeType = "";
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

		if ( hasExcerpt() AND NOT len( renderedExcerpt ) ) {
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

	/**
	 * Gets the shortened and cleaned version of the excerpt taken from the feed item body
	 * @count The number of characters to include in the excerpt
	 * @excerptEnding The characters to display at the end of the excerpt
	 * @return The generated content excerpt
	 */
	string function getContentExcerpt( numeric count=500, string excerptEnding="..." ) {

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
	 * @return The url of the featured image
	 */
	string function getFeaturedImageUrl( boolean getAltImageUrl=true ) {

		if ( len( super.getFeaturedImageUrl() ) ) {
			return super.getFeaturedImageUrl();
		} else if ( arguments.getAltImageUrl ) {
			var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
			var feed = getFeed();
			var behavior = len( feed.getFeaturedImageBehavior() ) ? feed.getFeaturedImageBehavior() : settings.ag_site_item_featured_image_behavior;
			if ( behavior == "feed" ) {
				return feed.getFeaturedImageUrl();
			} else if ( behavior == "default" ) {
				return settings.ag_site_item_featured_image_default_url;
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
	 * Sets and checks whether or not the feed item is a video
	 * @return Whether or not the feed item is a video
	 */
	boolean function getContainsVideo() {

		// Check property and set if needed
		if ( !len( containsVideo ) ) {

			// Set default
			containsVideo = false;

			// Get the item url
			var itemUrl = getItemUrl();

			// Test the item url
			if ( reFindNoCase( "^http[s]?:\/\/(www\.)?(bitchute|vimeo|youtube)\.com\/(.*)$", itemUrl ) ) {
				containsVideo = true;
			}

		}

		// Return property
		return containsVideo;

	}

	/**
	 * Shorthand function for checking if the feed item is a video
	 * @return Whether or not the feed item is a video
	 */
	boolean function isVideo() {
		return getContainsVideo();
	}

	/**
	 * Sets and returns the video embed url if the feed item is a video
	 * @return The video embed url
	 */
	string function getVideoEmbedUrl() {

		// Check if item is a video
		if ( isVideo() && !len( videoEmbedUrl ) ) {

			// Set vars
			var itemUrl = getItemUrl();
			var results = reFindNoCase( "^http[s]?:\/\/(www\.)?(bitchute|vimeo|youtube)\.com\/(.*)$", itemUrl, 1, true );
			var videoType = mid( itemUrl, results.pos[3], results.len[3] );

			// Switch on video type
			switch( videoType ) {

				// Bitchute
				case "bitchute":
					var match = reFindNoCase( "(embed\/)(.*)$", itemUrl, 1, true );
					if ( match.len[1] ) videoEmbedUrl = "https://www.bitchute.com/embed/" & mid( itemUrl, match.pos[3], match.len[3] );
					break;

				// Vimeo
				case "vimeo":
					var match = reFindNoCase( "(\d*)$", itemUrl, 1, true );
					if ( match.len[1] ) videoEmbedUrl = "https://player.vimeo.com/video/" & mid( itemUrl, match.pos[1], match.len[1] );
					break;

				// Youtube
				case "youtube":
					var match = reFindNoCase( "(&|\?)v=([^&]+)$", itemUrl, 1, true );
					if ( match.len[1] ) videoEmbedUrl = "https://www.youtube.com/embed/" & mid( itemUrl, match.pos[3], match.len[3] );
					break;

			}

		}

		// Return the url
		return videoEmbedUrl;

	}

	/**
	 * Sets and checks if the feed item is a podcast or contains a podcast
	 * @return Whether or not the feed item is a podcast or contains a podcast
	 */
	boolean function getContainsPodCast() {

		// Check property
		if ( !len( containsPodcast ) ) {

			// Set default
			containsPodcast = false;

			// Get the item urls
			var itemUrls = getItemUrls();

			// Check urls for podcasts
			for ( var itemUrl IN itemUrls ) {
				if ( reFindNoCase( "(\.mp3|\.m4a|\.mp4|\.acc|\.oga|\.ogg|\.wav)(&|\?)?(.*)$", itemUrl ) ) {
					containsPodcast = true;
					break;
				}
			}

		}

		// Return property
		return containsPodcast;

	}

	/**
	 * Shorthand function for checking if the feed item is a podcast or contains a podcast
	 * @return Whether or not the feed item is a podcast or contains a podcast
	 */
	boolean function isPodcast() {
		return getContainsPodcast();
	}

	/**
	 * Sets and returns the podcast url if the feed item is a podcast or contains a podcast
	 * @return The podcast url if the feed item is a podcast or contains a podcast
	 */
	string function getPodcastUrl() {

		// Check if item contains a podcast and podcast url set
		if ( isPodcast() && !len( podcastUrl ) ) {

			// Set vars
			var itemUrls = getItemUrls();

			// Check urls for podcasts
			for ( var itemUrl IN itemUrls ) {
				if ( reFindNoCase( "(\.mp3|\.m4a|\.mp4|\.acc|\.oga|\.ogg|\.wav)(&|\?)?(.*)$", itemUrl ) ) {
					podcastUrl = itemUrl;
					break;
				}
			}

		}

		// Return url
		return podcastUrl;

	}

	/**
	 * Sets and returns the mime type if the feed item is a podcast or contains a podcast
	 * @return The podcast mime type if the feed item is a podcast or contains a podcast
	 */
	string function getPodcastMimeType() {

		// Check if item contains a podcast and mime type set
		if ( isPodCast() && !len( podcastMimeType ) ) {

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
			podcastMimeType = mimeTypes[ ext ];

		}

		// Return mime type
		return podcastMimeType;

	}

	/**
	 * Returns an array of all urls associated with the feed item
	 * @return The array of urls
	 */
	array function getItemUrls() {

		// Set vars
		var itemUrls = [ getItemUrl() ];
		var attachments = getAttachments();

		// Add attachment urls if any
		for ( var attachment IN attachments ) {
			arrayAppend( itemUrls, attachment.getAttachmentUrl() );
		}

		// Return urls
		return itemUrls;

	}

	/**
	 * Validates the feed item
	 * @return An array of errors or an empty array if no error is found
	 */
	array function validate() {

		var errors = [];

		title = trim( left( title, 200 ) );
		slug = trim( left( slug, 200 ) );

		if ( !len( title ) ) { arrayAppend( errors, "Title is required" ); }
		if ( !len( slug ) ) { arrayAppend( errors, "Slug is required" ); }

		return errors;

	}

}