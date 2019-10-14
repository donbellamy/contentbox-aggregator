/**
 * ContentBox Aggregator
 * BaseWidget Model
 * @author Don Bellamy <don@perfectcode.com>
 */
component accessors="true" extends="contentbox.models.ui.BaseWidget" {

	// Dependencies
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="ag" inject="helper@aggregator";
	property name="themeService" inject="themeService@cb";

	/**
	 * Grabs the feed slugs
	 * @return An array of all feed slugs
	 */
	array function getFeedSlugs() cbIgnore {
		var slugs = feedService.getAllFlatSlugs();
		arrayPrepend( slugs, "" );
		return slugs;
	}

	/**
	 * Grabs the category slugs
	 * @return An array of all category slugs
	 */
	array function getCategorySlugs() cbIgnore {
		var c = categoryService.newCriteria();
		var slugs =  c.withProjections( property="slug" )
			.list( sortOrder="slug asc" );
		arrayPrepend( slugs, "" );
		return slugs;
	}

	/**
	 * Grabs the feed item types
	 * @return An array of feed item types
	 */
	array function getTypes() cbIgnore {
		return [
			"",
			"article",
			"podcast",
			"video"
		];
	}

}