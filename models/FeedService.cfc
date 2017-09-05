component extends="contentbox.models.content.ContentService" singleton{

	FeedService function init() {

		super.init( entityName="cbFeed", useQueryCaching=true );

		return this;
		
	}	

	FeedService function saveFeed( required any feed ) {

		save( argumentCollection=arguments );

		return this;

	}

	struct function search(
		string search="",
		string isPublished="any"
	) {

		var results = {};
		var c = newCriteria();

		if ( len( arguments.search ) ) {
			if( arguments.searchActiveContent ) {
				c.or( c.restrictions.like( "title", "%#arguments.search#%" ),
					  c.restrictions.like( "ac.content", "%#arguments.search#%" ) );
			} else {
				c.like( "title", "%#arguments.search#%" );
			}
		}

		if ( arguments.isPublished NEQ "any" ) {
			c.eq( "isPublished", javaCast( "boolean", arguments.isPublished ) );
		}

	}

}