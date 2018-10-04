/**
 * The base content service
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="contentbox.models.content.ContentService" singleton {

	/**
	 * Constructor
	 * @entityName The entity to bind this service to
	 * @return ContentService
	 */
	ContentService function init( required string entityName ) {

		super.init( argumentCollection=arguments );

		return this;

	}

	/**
	 * Save the content
	 * @param entity The entity to save
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
	 * Generate a unique slug
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

}