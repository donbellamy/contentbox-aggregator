component extends="contentbox.models.content.ContentService" singleton{

	FeedService function init() {

		super.init( entityName="cbFeed", useQueryCaching=true );

		return this;
		
	}	

}