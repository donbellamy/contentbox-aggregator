component extends="BaseService" singleton{

	FeedItemService function init() {

		super.init( entityName="cbFeedItem", useQueryCaching=true );

		return this;

	}

}