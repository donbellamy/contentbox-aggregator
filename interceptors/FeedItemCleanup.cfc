/**
 * ContentBox Aggregator
 * Feed item cleanup interceptor
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="coldbox.system.Interceptor" {

	// Dependencies
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="settingService" inject="settingService@cb";

	/**
	 * Fired before feed item delete
	 */
	function aggregator_preFeedItemRemove( event, interceptData ) {
		var feedItem = arguments.interceptData.feedItem;
		var directoryPath = expandPath( settingService.getSetting( "cb_media_directoryRoot" ) ) & "\aggregator\feeditems\" & dateformat( feedItem.getPublishedDate(), "yyyy\mm\" );
		var images = directoryList( path = directoryPath, filter = "#feedItem.getSlug()#_*" );
		for ( var imagePath IN images ) {
			if ( fileExists( imagePath ) && !feedService.isImageInUse( imagePath ) ) {
				try { fileDelete( imagePath ); } catch( any e ) {}
			}
		}
		var files = directoryList( directoryPath );
		if ( !arrayLen( files ) ) {
			try { directoryDelete( directoryPath ); } catch( any e ) {}
		}
	}

	/**
	 * Fired after feed import
	 */
	function aggregator_postFeedImport( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		doMaxItemCleanup( feed );
	}

	/**
	 * Fired after feed save
	 */
	function aggregator_postFeedSave( event, interceptData ) {
		/*
		TODO: fix
		var feed = arguments.interceptData.feed;
		var oldFeed = arguments.interceptData.oldFeed;
		if (
			feed.getMatchAnyFilter() != oldFeed.matchAnyFilter ||
			feed.getMatchAllFilter() != oldFeed.matchAllFilter ||
			feed.getMatchNoneFilter() != oldFeed.matchNoneFilter
		) {
			doKeywordCleanup( feed );
		}
		if (
			val( feed.getMaxAge() ) != val( oldFeed.maxAge ) ||
			feed.getMaxAgeUnit() != oldFeed.maxAgeUnit
		) {
			doAgeCleanup( feed );
		}
		if ( val( feed.getMaxItems() ) != val( oldFeed.maxItems ) ) {
			doMaxItemCleanup( feed );
		}
		*/
	}

	/**
	 * Fired after settings save
	 */
	function aggregator_postSettingsSave( event, interceptData ) {
		var settings = arguments.interceptData.settings;
		var oldSettings = arguments.interceptData.oldSettings;
		if (
			settings.importing_match_any_filter != oldSettings.importing_match_any_filter ||
			settings.importing_match_all_filter != oldSettings.importing_match_all_filter ||
			settings.importing_match_none_filter != oldSettings.importing_match_none_filter
		) {
			doKeywordCleanup();
		}
		if (
			val( settings.importing_max_feed_item_age ) != val( oldSettings.importing_max_feed_item_age ) ||
			settings.importing_max_feed_item_age_unit != oldSettings.importing_max_feed_item_age_unit
		 ) {
			doAgeCleanup();
		}
		if ( val( settings.importing_max_feed_items ) != val( oldSettings.importing_max_feed_items ) ) {
			doMaxItemCleanup();
		}
	}

	/************************************** PRIVATE *********************************************/

	/**
	 * Removes feed items using feed or global keyword filters
	 * @feed The feed to clean up
	 */
	private function doKeywordCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var feed IN feeds ) {

			// Counter
			var numberDeleted = 0;

			// Keyword filters
			var matchAnyFilter = listToArray( len( trim( feed.getSetting( "importing_match_any_filter", "" ) ) ) ? feed.getSetting( "importing_match_any_filter", "" ) : settings.importing_match_any_filter );
			var matchAllFilter = listToArray( len( trim( feed.getSetting( "importing_match_all_filter", "" ) ) ) ? feed.getSetting( "importing_match_all_filter", "" ) : settings.importing_match_all_filter );
			var matchNoneFilter = listToArray( len( trim( feed.getSetting( "importing_match_none_filter", "" ) ) ) ? feed.getSetting( "importing_match_none_filter", "" ) : settings.importing_match_none_filter );

			// Filter out if any filters exist
			if ( arrayLen( matchAnyFilter ) || arrayLen( matchAllFilter ) || arrayLen( matchNoneFilter ) ) {

				if ( arrayLen( matchAnyFilter ) ) {
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
					var feedItems = feedItemService.executeQuery(
						query = hql,
						params = params,
						asQuery = false
					);
					for ( var feedItem IN feedItems ) {
						var uniqueId = feedItem.getUniqueId();
						feedItemService.deleteContent( feedItem );
						if ( log.canInfo() ) {
							log.info("Feed item ('#uniqueId#') filtered out using match any filter '#arrayToList(matchAnyFilter)#' for feed '#feed.getTitle()#'");
						}
						numberDeleted++;
					}
				}

				if ( arrayLen( matchAllFilter ) ) {
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
					var feedItems = feedItemService.executeQuery(
						query = hql,
						params = params,
						asQuery = false
					);
					for ( var feedItem IN feedItems ) {
						var uniqueId = feedItem.getUniqueId();
						feedItemService.deleteContent( feedItem );
						if ( log.canInfo() ) {
							log.info("Feed item ('#uniqueId#') filtered out using match all filter '#arrayToList(matchAllFilter)#' for feed '#feed.getTitle()#'");
						}
						numberDeleted++;
					}
				}

				if ( arrayLen( matchNoneFilter ) ) {
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
					var feedItems = feedItemService.executeQuery(
						query = hql,
						params = params,
						asQuery = false
					);
					for ( var feedItem IN feedItems ) {
						var uniqueId = feedItem.getUniqueId();
						feedItemService.deleteContent( feedItem );
						if ( log.canInfo() ) {
							log.info("Feed item ('#uniqueId#') filtered out using match none filter '#arrayToList(matchNoneFilter)#' for feed '#feed.getTitle()#'");
						}
						numberDeleted++;
					}
				}

			}

			if ( log.canInfo() ) {
				log.info("There were #numberDeleted# feed item(s) filtered out by keywords for feed '#feed.getTitle()#'");
			}

		}

	}

	/**
	 * Removes feed items using feed or global max age settings
	 * @feed The feed to clean up
	 */
	private function doAgeCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var feed IN feeds ) {

			// Counter
			var numberDeleted = 0;

			// Max age
			var maxAge = val( feed.getSetting( "importing_max_feed_item_age", "" ) ) ? val( feed.getSetting( "importing_max_feed_item_age", "" ) ) : val( settings.importing_max_feed_item_age );
			var maxAgeUnit = len( feed.getSetting( "importing_max_feed_item_age_unit", "" ) ) ? feed.getSetting( "importing_max_feed_item_age_unit", "" ) : settings.importing_max_feed_item_age_unit;
			if ( maxAge && len( maxAgeUnit ) ) {
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
					numberDeleted++;
				}

			}

			if ( log.canInfo() ) {
				log.info("There were #numberDeleted# feed item(s) filtered out by age limit for feed '#feed.getTitle()#'");
			}

		}

	}

	/**
	 * Removes feed items using feed or global max item settings
	 * @feed The feed to clean up
	 */
	private function doMaxItemCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var feed IN feeds ) {

			// Counter
			var numberDeleted = 0;

			// Max items
			var maxItems = val( feed.getSetting( "importing_max_feed_items", "" ) ) ?
				val( feed.getSetting( "importing_max_feed_items", "" ) ) :
				val( settings.importing_max_feed_items );
			if ( maxItems && ( arrayLen( feed.getFeedItems() ) GT maxItems ) ) {
				var feedItems = feed.getFeedItems();
				var itemsToDelete = arraySlice( feedItems, maxItems + 1 );
				for ( var feedItem IN itemsToDelete ) {
					var uniqueId = feedItem.getUniqueId();
					feedItemService.deleteContent( feedItem );
					if ( log.canInfo() ) {
						log.info("Feed item ('#uniqueId#') filtered out by item limit for feed '#feed.getTitle()#'");
					}
					numberDeleted++;
				}
			}

			if ( log.canInfo() ) {
				log.info("There were #numberDeleted# feed item(s) filtered out by item limit for feed '#feed.getTitle()#'");
			}

		}

	}

}