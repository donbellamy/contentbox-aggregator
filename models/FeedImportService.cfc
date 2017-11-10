component extends="cborm.models.VirtualEntityService" singleton {

	property name="feedReader" inject="feedReader@cbfeeds";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";

	FeedImportService function init( entityName="cbFeedImport" ) {

		super.init( entityName=arguments.entityName, useQueryCaching=true );

		return this;
	}

}