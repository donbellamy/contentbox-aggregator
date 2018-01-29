component accessors="true" singleton threadSafe {

	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="settingService" inject="settingService@aggregator";

	function init() {
		return this;
	}

	function test() {
		writeoutput("This is working!!!");
	}

}