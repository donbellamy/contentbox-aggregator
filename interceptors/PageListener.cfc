/**
 * ContentBox Aggregator
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
		if ( page.getSlug() != originalSlug && ( settings.feed_items_entrypoint == originalSlug || settings.feeds_entrypoint == originalSlug ) ) {

			// Feed items or feeds slug
			if ( settings.feed_items_entrypoint == originalSlug ) {
				settings.feed_items_entrypoint = page.getSlug();
			} else {
				settings.feeds_entrypoint = page.getSlug();
			}

			// Update the site routes
			routingService.setRoutes(
				routingService.getRoutes().map( function( item ) {
					if ( item.namespaceRouting IS "aggregator-feed-items" ) {
						item.pattern = item.regexpattern = replace( settings.feed_items_entrypoint, "/", "-", "all" ) & "/";
					}
					if ( item.namespaceRouting IS "aggregator-feeds" ) {
						item.pattern = item.regexpattern = replace( settings.feeds_entrypoint, "/", "-", "all" ) & "/";
					}
					return item;
				})
			);

			// Save settings
			var setting = settingService.findWhere( { name = "aggregator" } );
			setting.setValue( serializeJSON( settings ) );
			settingService.save( setting );

			// Clear cache
			settingService.flushSettingsCache();

		}
	}

}