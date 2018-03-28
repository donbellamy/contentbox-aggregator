component extends="contentbox.models.content.ContentService" singleton {

	ContentService function save( required any entity, boolean transactional=true ) {

		if ( !isSlugUnique( arguments.entity.getSlug(), arguments.entity.getContentID() ) ) {
			arguments.entity.setSlug( getUniqueSlug( arguments.entity.getSlug() ) );
		}

		super.save( entity=arguments.entity, transactional=arguments.transactional );

		return this;

	}

	string function getUniqueSlug( required string slug ) {

		var count = 1;
		var uniqueSlug = arguments.slug;
		var existing = findWhere( { slug=uniqueSlug } );

		while ( !isNull( existing ) ) {
			uniqueSlug = arguments.slug & "-" & count;
			existing = findWhere( { slug=uniqueSlug } );
			count++;
		}

		return uniqueSlug;

	}

}