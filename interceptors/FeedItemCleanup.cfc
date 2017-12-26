component extends="coldbox.system.Interceptor" {

	property name="settingService" inject="settingService@cb";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="log" inject="logbox:logger:aggregator";

	function agadmin_postFeedImport( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		// TODO: Add keyword cleanup to import...
		doAgeCleanup( feed )
		doMaxItemCleanup( feed )
	}

	function agadmin_postFeedSave( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		doKeywordCleanup( feed );
		doAgeCleanup( feed );
		doMaxItemCleanup( feed );
	}

	function agadmin_postSettingsSave( event, interceptData ) {
		doKeywordCleanup();
		doAgeCleanup();
		doMaxItemCleanup();
	}

	private function doKeywordCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var item IN feeds ) {

			// Keyword filters
			var matchAnyFilter = listToArray( len( trim( item.getMatchAnyFilter() ) ) ? item.getMatchAnyFilter() : trim( settings.ag_general_match_any_filter ) );
			var matchAllFilter = listToArray( len( trim( item.getMatchAllFilter() ) ) ? item.getMatchAllFilter() : trim( settings.ag_general_match_all_filter ) );
			var matchNoneFilter = listToArray( len( trim( item.getMatchNoneFilter() ) ) ? item.getMatchNoneFilter() : trim( settings.ag_general_match_none_filter ) );

			// Filter out if any filters exist
			if ( len( matchAnyFilter ) || len( matchAllFilter ) || len( matchNoneFilter ) ) {

				if ( len( matchAnyFilter ) ) {
					var hql = "select fi from cbFeedItem fi join fi.activeContent ac where fi.parent = :parent and ( ";
					var params = { parent=item };
					var count = 1;
					for ( var keyword IN matchAnyFilter ) {
						hql &= "( fi.title not like :keyword#count# and ac.content not like :keyword#count# )";
						params["keyword#count#"] = "%#trim(keyword)#%";
						if ( arrayLen( matchAnyFilter ) GT count ) hql &= " and ";
						count++;
					}
					hql &= " )";
					var feedItems = feedItemService.executeQuery( query=hql, params=params, asQuery=false );
					for ( var feedItem IN feedItems ) {
						var uniqueId = feedItem.getUniqueId();
						feedItemService.deleteContent( feedItem );
						if ( log.canInfo() ) {
							log.info("Feed item ('#uniqueId#') filtered out using match any filter '#arrayToList(matchAnyFilter)#' for feed '#item.getTitle()#'");
						}
					}
				}

				if ( len( matchAllFilter ) ) {
					var hql = "select fi from cbFeedItem fi join fi.activeContent ac where fi.parent = :parent and ( ";
					var params = { parent=item };
					var count = 1;
					for ( var keyword IN matchAllFilter ) {
						hql &= "( fi.title not like :keyword#count# and ac.content not like :keyword#count# )";
						params["keyword#count#"] = "%#trim(keyword)#%";
						if ( arrayLen( matchAllFilter ) GT count ) hql &= " or ";
						count++;
					}
					hql &= " )";
					var feedItems = feedItemService.executeQuery( query=hql, params=params, asQuery=false );
					for ( var feedItem IN feedItems ) {
						var uniqueId = feedItem.getUniqueId();
						feedItemService.deleteContent( feedItem );
						if ( log.canInfo() ) {
							log.info("Feed item ('#uniqueId#') filtered out using match all filter '#arrayToList(matchAllFilter)#' for feed '#item.getTitle()#'");
						}
					}
				}

				if ( len( matchNoneFilter ) ) {
					var hql = "select fi from cbFeedItem fi join fi.activeContent ac where fi.parent = :parent and ( ";
					var params = { parent=item };
					var count = 1;
					for ( var keyword IN matchNoneFilter ) {
						hql &= "( fi.title like :keyword#count# or ac.content like :keyword#count# )";
						params["keyword#count#"] = "%#trim(keyword)#%";
						if ( arrayLen( matchNoneFilter ) GT count ) hql &= " or ";
						count++;
					}
					hql &= " )";
					var feedItems = feedItemService.executeQuery( query=hql, params=params, asQuery=false );
					for ( var feedItem IN feedItems ) {
						var uniqueId = feedItem.getUniqueId();
						feedItemService.deleteContent( feedItem );
						if ( log.canInfo() ) {
							log.info("Feed item ('#uniqueId#') filtered out using match none filter '#arrayToList(matchNoneFilter)#' for feed '#item.getTitle()#'");
						}
					}
				}

			}

		}

	}

	private function doAgeCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var item IN feeds ) {

			// Max age
			var maxAge = val( item.getMaxAge() ) ? val( item.getMaxAge() ) : val( settings.ag_general_max_age );
			var maxAgeUnit = val( item.getMaxAge() ) ? item.getMaxAgeUnit() : settings.ag_general_max_age_unit;
			if ( maxAge ) {
				var maxDate = now();
				switch( maxAgeUnit ) {
					case "weeks": {
						maxDate = dateAdd( "ww", -maxAge, maxDate );
						break;
					}
					case "months": {
						maxDate = dateAdd( "m", -maxAge, maxDate );
						break;
					}
					case "years": {
						maxDate = dateAdd( "yyyy", -maxAge, maxDate );
						break;
					}
					default: {
						maxDate = dateAdd( "d", -maxAge, maxDate );
					}
				}
				var c = feedItemService.newCriteria()
					.eq( "parent.contentID", item.getContentID() )
					.isLT( "datePublished", maxDate );
				var feedItems = c.list( asQuery=false );
				for ( var feedItem IN feedItems ) {
					var uniqueId = feedItem.getUniqueId();
					feedItemService.deleteContent( feedItem );
					if ( log.canInfo() ) {
						log.info("Feed item ('#uniqueId#') filtered out by age limit for feed '#item.getTitle()#'");
					}
				}

			}

		}

	}

	private function doMaxItemCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var item IN feeds ) {

			// Max items
			var maxItems = val( item.getMaxItems() ) ? val( item.getMaxItems() ) : val( settings.ag_general_max_items );
			if ( maxItems && ( item.getNumberOfFeedItems() GT maxItems ) ) {
				var feedItems = item.getFeedItems(); //TODO: This list needs to be sorted by datePublished DESC in Feed or FeedService?
				var itemsToDelete = arraySlice( feedItems, maxItems + 1 );
				for ( var feedItem IN itemsToDelete ) {
					var uniqueId = feedItem.getUniqueId();
					feedItemService.deleteContent( feedItem );
					if ( log.canInfo() ) {
						log.info("Feed item ('#uniqueId#') filtered out by item limit for feed '#item.getTitle()#'");
					}
				}
			}

		}

	}

}