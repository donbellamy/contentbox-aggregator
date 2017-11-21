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

		var feeds = [];
		var settings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		if ( structKeyExists( arguments, "feed" ) ) {
			arrayAppend( feeds, arguments.feed );
		} else {
			feeds = feedService.list( asQuery=false );
		}

		// Loop over feeds
		for ( var feed IN feeds ) {

			// Keyword filters
			var matchAnyFilter = listToArray( len( trim( feed.getMatchAnyFilter() ) ) ? feed.getMatchAnyFilter() : trim( settings.ag_general_match_any_filter ) );
			var matchAllFilter = listToArray( len( trim( feed.getMatchAllFilter() ) ) ? feed.getMatchAllFilter() : trim( settings.ag_general_match_all_filter ) );
			var matchNoneFilter = listToArray( len( trim( feed.getMatchNoneFilter() ) ) ? feed.getMatchNoneFilter() : trim( settings.ag_general_match_none_filter ) );

			// Filter out if any filters exist
			if ( len( matchAnyFilter ) || len( matchAllFilter ) || len( matchNoneFilter ) ) {

				// Query items that do not match any keywords
				// to match any - any title/content LIKE keywords
				// to not match any - any title/content !LIKE keywords
				if ( len( matchAnyFilter ) ) {
					var hql = "select fi from cbFeedItem fi inner join fi.activeContent ac where fi.parent = :parent and ( ";
					var params = { parent=feed };
					var count = 1;
					for ( var keyword IN matchAnyFilter ) {
						hql &= "( fi.title not like :keyword#count# and ac.content not like :keyword#count# )";
						params["keyword#count#"] = "%#trim(keyword)#%";
						if ( arrayLen( matchAnyFilter ) GT count ) hql &= " and ";
						count++;
					}
					hql &= " )";
					var results = feedItemService.executeQuery( query=hql, params=params );
					writedump(params);
					writedump(hql);
					writedump(results);
					abort;
				}
		

				// Query items that do not match all keywords
				// to match all - 
				/*
				if ( len( matchAllFilter ) ) {
					var hql = "select fi from cbFeedItem fi inner join fi.activeContent ac where fi.parent = :parent and ( ";
					var params = { parent=feed };
					var count = 1;
					for ( var keyword IN matchAnyFilter ) {
					for ( var keyword IN matchAnyFilter ) {
						hql &= "( fi.title not like :keyword#count# and ac.content not like :keyword#count# )";
						params["keyword#count#"] = "%#trim(keyword)#%";
						if ( arrayLen( matchAnyFilter ) GT count ) hql &= " and ";
						count++;
					}
					}
					hql &= " )";
					var results = feedItemService.executeQuery( query=hql, params=params );
					writedump(results);
					abort;
				}
				*/

				// Query items that match none of the keywords
				if ( len( matchNoneFilter ) ) {}

				// Loop over results and delete matching feed items

					// Log removed feed item

			}

			// Max age

			// Max items

		}

	}

}