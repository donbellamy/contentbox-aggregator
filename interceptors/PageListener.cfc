/**
 * ContentBox RSS Aggregator
 * Page listener
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="settingService" inject="settingService@cb";
	property name="routingService" inject="coldbox:routingService";

	/**
	 * Fired after page save
	 */
	function cbadmin_postPageSave( event, interceptData ) {

		// Set vars
		var page = arguments.interceptData.page;
		var originalSlug = arguments.interceptData.originalSlug;
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		// Check if page slugs have changed
		if ( page.getSlug() != originalSlug && ( settings.ag_site_news_entryPoint == originalSlug || settings.ag_site_feeds_entryPoint == originalSlug ) ) {

			// News or feeds slug
			if ( settings.ag_site_news_entryPoint == originalSlug ) {
				settings.ag_site_news_entryPoint = page.getSlug();
			} else {
				settings.ag_site_feeds_entryPoint = page.getSlug();
			}

			// Update the site routes
			routingService.setRoutes(
				routingService.getRoutes().map( function( item ) {
					if ( item.namespaceRouting EQ "aggregator-news" ) {
						item.pattern = item.regexpattern = replace( settings.ag_site_news_entrypoint, "/", "-", "all" ) & "/";
					}
					if ( item.namespaceRouting EQ "aggregator-feeds" ) {
						item.pattern = item.regexpattern = replace( settings.ag_site_feeds_entrypoint, "/", "-", "all" ) & "/";
					}
					return item;
				})
			);

			// Save settings
			var setting = settingService.findWhere( { name="aggregator" } );
			setting.setValue( serializeJSON( settings ) );
			settingService.save( setting );

			// Clear cache
			settingService.flushSettingsCache();

		}
	}

}