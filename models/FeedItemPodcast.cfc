/**
 * ContentBox Aggregator
 * FeedItemPodcast Model
 * @author Don Bellamy <don@perfectcode.com>
 */
component persistent="true"
	entityname="cbFeedItemPodcast"
	table="cb_feeditempodcast"
	batchsize="25"
	cachename="cbFeedItemPodcast"
	cacheuse="read-write"
	extends="contentbox.models.BaseEntity" {

	/* *********************************************************************
	**                            PROPERTIES
	********************************************************************* */

	property name="feedItemPodcastID"
		fieldtype="id"
		generator="native"
		setter="false"
		params="{ allocationSize=1, sequence='feedItemPodcastID_seq' }";

	property name="podcastUrl"
		notnull="false"
		length="510";

	property name="mimeType"
		notnull="false";

	/* *********************************************************************
	**                            RELATIONSHIPS
	********************************************************************* */

	// M20 -> FeedItem
	property name="feedItem"
		notnull="true"
		cfc="FeedItem"
		fieldtype="many-to-one"
		fkcolumn="FK_feedItemID"
		lazy="true";

	/* *********************************************************************
	**                            CONSTRAINTS
	********************************************************************* */

	this.pk = "feedItemPodcastID";

	/**
	 * Constructor
	 * @return FeedItemPodcast
	 */
	FeedItemPodcast function init() {
		super.init();
		createdDate = now();
		return this;
	}

}