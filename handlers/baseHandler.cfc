/**
 * ContentBox Aggregator
 * Base handler
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="contentbox.modules.contentbox-admin.handlers.baseHandler" {

	/**
	 * Pre handler
	 */
	function preHandler( event, rc, prc, action, eventArguments ) {
		// Make sure call is coming from admin
		if ( reFindNoCase( "^contentbox-aggregator", event.getCurrentEvent() ) ) {
			setNextEvent(
				event = "cbadmin/module/aggregator/#event.getCurrentHandler()#",
				ssl = getRequestContext().isSSL()
			);
		}
	}

}
