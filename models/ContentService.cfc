/**
 * ContentBox RSS Aggregator
 * Content Service
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="contentbox.models.content.ContentService" singleton {

	// Dependencies
	property name="moduleSettings" inject="coldbox:setting:modules";

	/**
	 * Constructor
	 * @entityName The entity to bind this service to
	 * @return ContentService
	 */
	ContentService function init( required string entityName="cbContent" ) {

		super.init( argumentCollection=arguments );

		return this;

	}

	/**
	 * Saves the content
	 * @param The entity to save
	 * @transactional Use transactions or not, defaults to true
	 * @return ContentService
	 */
	ContentService function save( required any entity, boolean transactional=true ) {

		// Check for unique slug
		if ( !isSlugUnique( arguments.entity.getSlug(), arguments.entity.getContentID() ) ) {
			// Set the slug
			arguments.entity.setSlug( getUniqueSlug( arguments.entity.getSlug() ) );
		}

		// Save
		super.save( entity=arguments.entity, transactional=arguments.transactional );

		return this;

	}

	/**
	 * Generates a unique slug using counts rather than a random string
	 * @slug The slug to make unique
	 * @return The unique slug
	 */
	string function getUniqueSlug( required string slug ) {

		// Set vars
		var count = 1;
		var uniqueSlug = arguments.slug;
		var existing = findWhere( { slug=uniqueSlug } );

		// Set unique slug as needed
		while ( !isNull( existing ) ) {
			uniqueSlug = arguments.slug & "-" & count;
			existing = findWhere( { slug=uniqueSlug } );
			count++;
		}

		return uniqueSlug;

	}

	/**
	 * Checks to see if the image is in use by any other content
	 * @imageURl The image url to check
	 * @contentID The contentID of the content being deleted
	 * @return True if in use elsewhere, false if not
	 */
	boolean function isImageInUse( required string imagePath, any contentID="" ) {

		// Set imageUrl
		var imageUrl = arguments.imagePath;

		// Check image path
		var fileObject = createObject( "java", "java.io.File" ).init( javaCast( "string", arguments.imagePath ) );
		if ( fileObject.isAbsolute() ) {
			imageUrl = getImageUrlFromPath( arguments.imagePath );
		}

		// Check for length
		if ( len( trim( imageUrl ) ) ) {

			// New criteria
			var c = newCriteria().createAlias( "contentVersions", "cv" );

			// Check featured image url or content
			c.or(
				c.restrictions.like( "featuredImageURL", "%#imageUrl#%" ),
				c.restrictions.like( "cv.content", "%#imageUrl#%" )
			);

			// Filter on contentID
			if ( len( arguments.contentID ) ) {
				c.ne( "contentID", javaCast( "int", arguments.contentID ) );
			}

			// Return found
			return ( c.count() GT 0 ? false : true );

		} else {

			// False
			return false;

		}

	}

	/**
	 * Returns the relative image url from the absolute iamge path
	 * @imagePath The image path to convert
	 * @return The relative image url
	 */
	string function getImageUrlFromPath( required string imagePath ) {

		// Set vars
		var imageUrl = "";
		var entryPoint = moduleSettings["contentbox-ui"].entryPoint;
		var directoryPath = expandPath( settingService.getSetting( "cb_media_directoryRoot" ) );

		// Make sure imagePath contains the directory path
		if ( findNoCase( directoryPath, arguments.imagePath ) ) {

			// Remove the directory path and fix the slashes
			imageUrl = replace( replaceNoCase( arguments.imagePath, directoryPath, "", "ALL" ), "\", "/", "ALL" );

			// Add the entry point and media folders
			imageUrl = ( len( entryPoint ) ? "/" & entryPoint : "" ) & "/__media" & imageUrl;
		}

		return imageUrl;

	}

}