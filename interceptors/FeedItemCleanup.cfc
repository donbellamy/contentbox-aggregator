component extends="coldbox.system.Interceptor" {

	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="settingService" inject="settingService@cb";

	function aggregator_preFeedItemRemove( event, interceptData ) {
		// TODO: Change to check if any other content is using this, a related entry could be using the image
		var feedItem = arguments.interceptData.feedItem;
		var directoryPath = expandPath( settingService.getSetting( "cb_media_directoryRoot" ) ) & "\aggregator\feeditems\" & dateformat( feedItem.getPublishedDate(), "yyyy\mm\" );
		var images = directoryList( path=directoryPath, filter="#feedItem.getSlug()#_*" );
		for ( var image IN images ) {
			if ( fileExists( image ) ) {
				try { fileDelete( image ); } catch( any e ) {}
			}
		}
		var files = directoryList( directoryPath );
		if ( !arrayLen( files ) ) {
			try { directoryDelete( directoryPath ); } catch( any e ) {}
		}
	}

	function aggregator_postFeedImport( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		doKeywordCleanup( feed );
		doAgeCleanup( feed );
		doMaxItemCleanup( feed );
	}

	function aggregator_postFeedSave( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		doKeywordCleanup( feed );
		doAgeCleanup( feed );
		doMaxItemCleanup( feed );
	}

	function aggregator_postSettingsSave( event, interceptData ) {
		doKeywordCleanup();
		doAgeCleanup();
		doMaxItemCleanup();
	}

	/************************************** PRIVATE *********************************************/

	private function doKeywordCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var feed IN feeds ) {

			// Keyword filters
			var matchAnyFilter = listToArray( len( trim( feed.getMatchAnyFilter() ) ) ? feed.getMatchAnyFilter() : trim( settings.ag_importing_match_any_filter ) );
			var matchAllFilter = listToArray( len( trim( feed.getMatchAllFilter() ) ) ? feed.getMatchAllFilter() : trim( settings.ag_importing_match_all_filter ) );
			var matchNoneFilter = listToArray( len( trim( feed.getMatchNoneFilter() ) ) ? feed.getMatchNoneFilter() : trim( settings.ag_importing_match_none_filter ) );

			// Filter out if any filters exist
			if ( len( matchAnyFilter ) || len( matchAllFilter ) || len( matchNoneFilter ) ) {

				if ( len( matchAnyFilter ) ) {
					var hql = "select fi from cbFeedItem fi join fi.activeContent ac where fi.parent = :parent and ( ";
					var params = { parent=feed };
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
							log.info("Feed item ('#uniqueId#') filtered out using match any filter '#arrayToList(matchAnyFilter)#' for feed '#feed.getTitle()#'");
						}
					}
				}

				if ( len( matchAllFilter ) ) {
					var hql = "select fi from cbFeedItem fi join fi.activeContent ac where fi.parent = :parent and ( ";
					var params = { parent=feed };
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
							log.info("Feed item ('#uniqueId#') filtered out using match all filter '#arrayToList(matchAllFilter)#' for feed '#feed.getTitle()#'");
						}
					}
				}

				if ( len( matchNoneFilter ) ) {
					var hql = "select fi from cbFeedItem fi join fi.activeContent ac where fi.parent = :parent and ( ";
					var params = { parent=feed };
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
							log.info("Feed item ('#uniqueId#') filtered out using match none filter '#arrayToList(matchNoneFilter)#' for feed '#feed.getTitle()#'");
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
		for ( var feed IN feeds ) {

			// Max age
			var maxAge = val( feed.getMaxAge() ) ? val( feed.getMaxAge() ) : val( settings.ag_importing_max_age );
			var maxAgeUnit = val( feed.getMaxAge() ) ? feed.getMaxAgeUnit() : settings.ag_importing_max_age_unit;
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
					.eq( "parent.contentID", feed.getContentID() )
					.isLT( "publishedDate", maxDate );
				var feedItems = c.list( asQuery=false );
				for ( var feedItem IN feedItems ) {
					var uniqueId = feedItem.getUniqueId();
					feedItemService.deleteContent( feedItem );
					if ( log.canInfo() ) {
						log.info("Feed item ('#uniqueId#') filtered out by age limit for feed '#feed.getTitle()#'");
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
		for ( var feed IN feeds ) {

			// Max items
			var maxItems = val( feed.getMaxItems() ) ? val( feed.getMaxItems() ) : val( settings.ag_importing_max_items );
			if ( maxItems && ( arrayLen( feed.getFeedItems() ) GT maxItems ) ) {
				var feedItems = feed.getFeedItems();
				var itemsToDelete = arraySlice( feedItems, maxItems + 1 );
				for ( var feedItem IN itemsToDelete ) {
					var uniqueId = feedItem.getUniqueId();
					feedItemService.deleteContent( feedItem );
					if ( log.canInfo() ) {
						log.info("Feed item ('#uniqueId#') filtered out by item limit for feed '#feed.getTitle()#'");
					}
				}
			}

		}

	}

}