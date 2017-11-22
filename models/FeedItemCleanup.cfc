component extends="coldbox.system.Interceptor" {

	property name="settingService" inject="settingService@cb";
	property name="feedService" inject="feedService@aggregator";
	property name="feedImportService" inject="feedImportService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";

	function agadmin_postFeedImport( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		doFeedItemCleanup( feed );
	}

	function agadmin_postFeedSave( event, interceptData ) {
		var feed = arguments.interceptData.feed;
		doFeedItemCleanUp( feed );
	}

	function agadmin_postSettingsSave( event, interceptData ) {
		doFeedItemCleanUp();
	}

	private function doFeedItemCleanup( any feed ) {

		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			var feeds = [ arguments.feed ];
		} else {
			var feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var feed IN feeds ) {

			// Keyword filters
			var matchAnyFilter = listToArray( len( trim( feed.getMatchAnyFilter() ) ) ? feed.getMatchAnyFilter() : trim( settings.ag_general_match_any_filter ) );
			var matchAllFilter = listToArray( len( trim( feed.getMatchAllFilter() ) ) ? feed.getMatchAllFilter() : trim( settings.ag_general_match_all_filter ) );
			var matchNoneFilter = listToArray( len( trim( feed.getMatchNoneFilter() ) ) ? feed.getMatchNoneFilter() : trim( settings.ag_general_match_none_filter ) );

			// Filter out if any filters exist
			if ( len( matchAnyFilter ) || len( matchAllFilter ) || len( matchNoneFilter ) ) {

				/*
					// Grab items that match any keyword
					SELECT * 
					FROM content 
					WHERE parent = :parent
					AND ( 
						( title LIKE :keyword or content LIKE :keyword )
						OR ( title LIKE :keyword1 or content LIKE :keyword1 ) 
					)
					// Grab items that dont match any keyword
					SELECT * 
					FROM content 
					WHERE parent = :parent
					AND ( title NOT LIKE :keyword and content NOT LIKE :keyword )
					AND ( title NOT LIKE :keyword1 and content NOT LIKE :keyword1 )
				*/

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
					for ( feedItem IN feedItems ) {
						feedItemService.deleteContent( feedItem );
						// TODO: log this?
					}
				}

				/*
					// Grab items that match all keywords
					SELECT * 
					FROM content 
					WHERE parent = :parent
					AND ( title LIKE :keyword or content LIKE :keyword )
					AND ( title LIKE :keyword1 or content LIKE :keyword1 )
					AND ( title LIKE :keyword2 or content LIKE :keyword2 )
					// Grab items that dont match all keywords
					SELECT * 
					FROM content 
					WHERE parent = :parent
					AND ( 
						( title NOT LIKE :keyword and content NOT LIKE :keyword )
						OR ( title NOT LIKE :keyword1 and content NOT LIKE :keyword1 )
						OR ( title NOT LIKE :keyword2 and content NOT LIKE :keyword2 )
					)
				*/

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
					for ( feedItem IN feedItems ) {
						feedItemService.deleteContent( feedItem );
						// TODO: log this?
					}
				}

				/*
					// Grab items that match none of the keywords 
					SELECT * 
					FROM content 
					WHERE parent = :parent
					AND ( title NOT LIKE :keyword and content NOT LIKE :keyword )
					AND ( title NOT LIKE :keyword1 and content NOT LIKE :keyword1 )
					AND ( title NOT LIKE :keyword2 and content NOT LIKE :keyword2 )

					// Grab items that dont match all keywords
					SELECT * 
					FROM content 
					WHERE parent = :parent
					AND ( 
						( title LIKE :keyword or content LIKE :keyword )
						OR ( title LIKE :keyword1 or content LIKE :keyword1 )
						OR ( title LIKE :keyword2 or content LIKE :keyword2 )
					)
				*/

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
					for ( feedItem IN feedItems ) {
						feedItemService.deleteContent( feedItem );
						// TODO: log this?
					}
				}

			}

			// Max age

			// Max items
			var maxItems = val( feed.getMaxItems() ) ? val( feed.getMaxItems() ) : val( settings.ag_general_max_items );
			if ( feed.getNumberOfFeedItems() GT maxItems ) {

			}


		}

	}

}