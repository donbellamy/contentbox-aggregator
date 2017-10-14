component extends="BaseService" singleton{

	FeedItemService function init() {

		super.init( entityName="cbFeedItem", useQueryCaching=true );

		return this;

	}

	struct function search( 
		string search="",
		string feed="all",
		string category="all",
		string status="any",
		numeric max=0,
		numeric offset=0,
		string sortOrder=""
	) {

		var results = {};
		var c = newCriteria();

		if ( len( trim( arguments.search ) ) || findNoCase( "modifiedDate", arguments.sortOrder ) ) {
			c.createAlias( "activeContent", "ac" );
		}

		if ( len( trim( arguments.search ) ) ) {
			c.or( c.restrictions.like( "title", "%#arguments.search#%" ), c.restrictions.like( "ac.content", "%#arguments.search#%" ) );
		}

		if ( arguments.feed NEQ "all" ) {
			c.eq( "parent.contentID", javaCast( "int", arguments.feed ) );
		}

		if ( arguments.category NEQ "all" ) {
			if( arguments.category EQ "none" ) {
				c.isEmpty( "categories" );
			} else{
				c.createAlias( "categories", "cats" ).isIn( "cats.categoryID", javaCast( "java.lang.Integer[]", [ arguments.category ] ) );
			}
		}

		if ( arguments.status NEQ "any" ) {
			c.eq( "isPublished", javaCast( "boolean", arguments.status ) );
		}

		if ( arguments.state NEQ "any" ) {
			c.eq( "isActive", javaCast( "boolean", arguments.state ) );
		}

		if ( !len( arguments.sortOrder ) ) {
			arguments.sortOrder = "title ASC";
		}

		results.count = c.count( "contentID" );
		results.feeds = c.resultTransformer( c.DISTINCT_ROOT_ENTITY ).list( 
			offset=arguments.offset, 
			max=arguments.max, 
			sortOrder=arguments.sortOrder, 
			asQuery=false 
		);

		return results;

	}

}