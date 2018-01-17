component extends="coldbox.system.EventHandler" {

	property name="settingService" inject="settingService@aggregator";
	property name="messagebox" inject="messagebox@cbmessagebox";

	function preHandler( event, rc, prc, action, eventArguments ) {}

}