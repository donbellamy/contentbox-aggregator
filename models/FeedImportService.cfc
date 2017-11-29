component extends="cborm.models.VirtualEntityService" singleton {

	property name="feedReader" inject="feedReader@cbfeeds";
	property name="feedService" inject="feedService@aggregator";
	property name="feedItemService" inject="feedItemService@aggregator";
	property name="settingService" inject="settingService@cb";
	property name="htmlHelper" inject="HTMLHelper@coldbox";
	property name="log" inject="logbox:logger:aggregator";

	FeedImportService function init( entityName="cbFeedImport" ) {

		super.init( entityName=arguments.entityName, useQueryCaching=true );

		return this;

	}

	FeedImportService function import( required Feed feed, required Author author ) {

		try {

			//var threadName = "retrieve_feed_#hash( arguments.feed.getContentID() & now() )#";
			//thread action="run" name="#threadName#" url="#arguments.feed.getUrl()#" {
				variables.feed = feedReader.retrieveFeed( arguments.feed.getUrl() );
			//}

			// Check for items in feed
			if ( arrayLen( variables.feed.items ) ) {

				// Set an item counter
				var itemCount = 0;

				// Loop over items
				for ( var item IN variables.feed.items ) {

					// Create a unique id to track this item
					var uniqueId = item.id;
					if ( !len( uniqueId ) ) {
						uniqueId = item.url;
					}

					// Validate url, title and body
					if ( len( item.url ) && len( item.title ) && len( item.body ) ) {

						// Check if item already exists
						var itemExists = feedItemService.newCriteria().isEq( "uniqueId", uniqueId ).count();

						// Doesn't exist, so try and import
						if ( !itemExists ) {

							try {

								// Create feed item
								var feedItem = feedItemService.new();

								// FeedItem properties
								feedItem.setUrl( item.url );
								feedItem.setUniqueId( uniqueId );
								if ( len( trim( item.author ) ) ) {
									feedItem.setAuthor( item.author );
								}
								var now = now();
								if ( isDate( item.datePublished ) ) {
									feedItem.setDatePublished( item.datePublished );
								} else {
									feedItem.setDatePublished( now );
								}
								if ( isDate( item.dateUpdated ) ) {
									feedItem.setDateUpdated( item.dateUpdated );
								} else {
									feedItem.setDateUpdated( now );
								}
								feedItem.setMetaInfo( serializeJSON( item ) );
								feedItem.setParent( arguments.feed );

								// BaseContent properties
								feedItem.setTitle( item.title );
								feedItem.setSlug( htmlHelper.slugify( item.title ) );
								feedItem.setCreator( arguments.author );
								// TODO: Rip out image
								// TODO: Clean html
								// TODO: Validate feedItem, so add contentversion as last step after validating the body
								feedItem.addNewContentVersion( 
									content=left( item.body, 8000 ), //TODO: Move this to validate()
									changelog="Item imported.",
									author=arguments.author
								);
								if ( feedItem.getDatePublished() GT now ) {
									feedItem.setpublishedDate( feedItem.getDatePublished() );
								} else {
									feedItem.setpublishedDate( now );
								}
								if ( arguments.feed.autoPublishItems() ) {
									feedItem.setisPublished( true );
								} else {
									feedItem.setisPublished( false );
								}

								// Save item
								feedItemService.save( feedItem );

								// Increase item count
								itemCount++;

							} catch( any e ) {

								// Log error
								if ( log.canError() ) {
									log.error( "Error saving item ('#uniqueId#') for feed '#arguments.feed.getTitle()#'.", e );
								}

							}
							
							// Log item saved
							if ( log.canInfo() ) {
								log.info("Item ('#uniqueId#') saved for feed '#arguments.feed.getTitle()#'.");
							}

						} else {

							// Log item exists
							if ( log.canInfo() ) {
								log.info("Item ('#uniqueId#') already exists for feed '#arguments.feed.getTitle()#'.");
							}

						}

					} else {
						
						// Log invalid item in feed
						if ( log.canWarn() ) {
							log.warn("Invalid item ('#uniqueId#') found for feed '#arguments.feed.getTitle()#'.");
						}

					}
				}

				// Log import
				if ( log.canInfo() ) {
					log.info("There were #itemCount# item(s) imported for feed '#arguments.feed.getTitle()#'.");
				}

			} else {
				
				// Log empty feed
				if ( log.canInfo() ) {
					log.info("There were no items found for feed '#arguments.feed.getTitle()#'.");
				}

			}

			// Create feed import and save
			var feedImport = new();
			feedImport.setFeed( arguments.feed );
			feedImport.setMetaInfo( serializeJSON( variables.feed ) );
			save( feedImport );

		} catch ( any e ) {

			if ( log.canError() ) { 
				log.error( "Error importing feed '#arguments.feed.getTitle()#'.", e );
			}

		}

		return this;

	}

}