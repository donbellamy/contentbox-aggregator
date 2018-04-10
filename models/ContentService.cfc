component extends="contentbox.models.content.ContentService" singleton {

	ContentService function init( entityName="cbContent", boolean useQueryCaching=true ) {

		super.init( argumentCollection=arguments );

		return this;

	}

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

	ContentService function clearAllCaches( boolean async=false ) {

		// Set vars
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		var cache = cacheBox.getCache( settings.ag_rss_cache_name );
		var cacheKey = "cb-content-aggregator";

		// Clear portal cache
		cache.clearByKeySnippet( keySnippet=cacheKey, async=false );

		// Clear content caches
		super.clearAllCaches( arguments.async );

		return this;

	}

}