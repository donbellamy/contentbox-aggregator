/**
 * ContentBox RSS Aggregator
 * Feed item taxonomies
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="categoryService" inject="categoryService@cb";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";

	/**
	 * Fired after feed import
	 */
	function aggregator_postFeedImport( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		var taxonomies = feed.getTaxonomies();
		applyTaxonomies( taxonomies, feed );
	}

	/**
	 * Fired after feed save
	 */
	function aggregator_postFeedSave( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		var taxonomies = feed.getTaxonomies();
		var originalTaxonomies = arguments.interceptData.originalTaxonomies;
		if ( !taxonomies.equals( originalTaxonomies ) ) {
			applyTaxonomies( taxonomies, feed );
		}
	}

	/**
	 * Fired after settings save
	 */
	function aggregator_postSettingsSave( event, interceptData ) {
		var taxonomies = arguments.interceptData.newSettings.ag_importing_taxonomies;
		var originalTaxonomies = arguments.interceptData.oldSettings.ag_importing_taxonomies;
		if ( !taxonomies.equals( originalTaxonomies ) ) {
			applyTaxonomies( taxonomies );
		}
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Applies taxonomies to the feed items
	 * @taxonomies An array of taxonomies to apply to the feed items
	 * @feed The feed to use when applying the taxonomies
	 */
	private function applyTaxonomies( required array taxonomies, any feed ) {

		// TODO: add date to this so we arent querying all items every time...

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var feed IN feeds ) {

			// Loop over taxonomies
			for ( var taxonomy IN arguments.taxonomies ) {

				var categoryIds = listToArray( taxonomy.categories );
				var keywords = listToArray( taxonomy.keywords );

				// Check for categories and keywords
				if ( arrayLen( categoryIds ) && arrayLen( keywords ) ) {

					// Query on keywords
					var hql = "select fi from cbFeedItem fi join fi.activeContent ac where fi.parent = :parent and ( ";
					// TODO: where c.categoryID not in ( categoryIds )
					var params = { parent=feed };
					var count = 1;
					for ( var keyword IN keywords ) {
						hql &= "( fi.title like :keyword#count# or ac.content like :keyword#count# )";
						params["keyword#count#"] = "%#trim(keyword)#%";
						if ( arrayLen( keywords ) GT count ) hql &= ( taxonomy.method == "all" ? " and " : " or " );
						count++;
					}
					hql &= " )";

					// Get feedItems
					var feedItems = feedItemService.executeQuery( query=hql, params=params, asQuery=false );

					// Check results
					if ( arrayLen( feedItems ) ) {

						// Create the categories
						var categories = [];
						for ( var categoryId IN categoryIds ) {
							arrayAppend( categories, categoryService.get( categoryId ) );
						}

						// Loop over feed items
						for ( var feedItem IN feedItems ) {

							// Loop over categories
							for ( var category IN categories ) {

								// Add category
								if ( !feedItem.hasCategories( category ) ) {
									feedItem.addCategories( category );
									feedItemService.save( feedItem );
									// TODO: log info
								}

							}

						}

					}

				}

			}

		}

	}

}