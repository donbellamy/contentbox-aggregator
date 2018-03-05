component accessors="true" extends="contentbox.models.ui.BaseWidget" {

	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="ag" inject="helper@aggregator";

}