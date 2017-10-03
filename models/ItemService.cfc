component extends="BaseService" singleton{

	ItemService function init() {

		super.init( entityName="cbFeedItem", useQueryCaching=true );

		return this;

	}

}