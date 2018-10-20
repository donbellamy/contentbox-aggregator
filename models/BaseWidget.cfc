/**
 * ContentBox RSS Aggregator
 * BaseWidget Model
 * @author Don Bellamy <don@perfectcode.com>
 */
component accessors="true" extends="contentbox.models.ui.BaseWidget" {

	// Dependencies
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="ag" inject="helper@aggregator";

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
	 * Grabs the categories
	 * @return An array of all category names
	 */
	array function getAllCategories() cbIgnore {
		return categoryService.getAllNames();
	}

}