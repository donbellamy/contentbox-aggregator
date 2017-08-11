component {

	function index( event, rc, prc ) {
		event.setView( "news/index" );
	}

	function item( event, rc, prc ) {
		event.setView( "news/item" );
	}

	function feeds( event, rc, prc ) {
		event.setView( "news/feeds" );
	}

	function feed( event, rc, prc ) {
		event.setView( "news/feed" );
	}

}