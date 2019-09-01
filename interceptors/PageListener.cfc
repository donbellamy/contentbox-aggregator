/**
 * ContentBox RSS Aggregator
 * Page listener
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	/**
	 * Fired after page save
	 */
	function cbadmin_postPageSave( event, interceptData ) {
		var page = arguments.interceptData.page;
		var originalSlug = arguments.interceptData.originalSlug;
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		if ( page.getSlug() != originalSlug && ( settings.ag_site_news_entryPoint == originalSlug || settings.ag_site_feeds_entryPoint == originalSlug ) ) {
			var setting = settingService.findWhere( { name="aggregator" } );
			if ( settings.ag_site_news_entryPoint == originalSlug ) {
				settings.ag_site_news_entryPoint = page.getSlug();
			} else {
				settings.ag_site_feeds_entryPoint = page.getSlug();
			}
			setting.setValue( serializeJSON( settings ) );
			settingService.save( setting );
		}
	}

}