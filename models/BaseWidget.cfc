/**
 * The base widget class for aggregator widgets
 * @author Don Bellamy <don@perfectcode.com>
 */
component accessors="true" extends="contentbox.models.ui.BaseWidget" {

	// Dependencies
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="ag" inject="helper@aggregator";

}