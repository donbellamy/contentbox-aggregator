component extends="BaseService" singleton{

	FeedService function init() {

		super.init( entityName="cbFeed", useQueryCaching=true );

		return this;

	}

}