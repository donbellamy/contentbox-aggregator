/**
 * ContentBox Aggregator
 * FeedItemVideo Model
 * @author Don Bellamy <don@perfectcode.com>
 */
component persistent="true"
	entityname="cbFeedItemVideo"
	table="cb_feeditemvideo"
	batchsize="25"
	cachename="cbFeedItemVideo"
	cacheuse="read-write"
	extends="contentbox.models.BaseEntity" {

	/* *********************************************************************
	**                            PROPERTIES
	********************************************************************* */

	property name="feedItemVideoID"
		fieldtype="id"
		generator="native"
		setter="false"
		params="{ allocationSize=1, sequence='feedItemVideoID_seq' }";

	property name="videoUrl"
		notnull="false"
		length="510";

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

	this.pk = "feedItemVideoID";

	/**
	 * Constructor
	 * @return FeedItemVideo
	 */
	FeedItemVideo function init() {
		super.init();
		createdDate = now();
		return this;
	}

}