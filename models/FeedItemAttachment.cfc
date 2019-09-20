/**
 * ContentBox Aggregator
 * FeedItemAttachment Model
 * @author Don Bellamy <don@perfectcode.com>
 */
component persistent="true"
	entityname="cbFeedItemAttachment"
	table="cb_feeditemattachment"
	batchsize="25"
	cachename="cbFeedItemAttachment"
	cacheuse="read-write"
	extends="contentbox.models.BaseEntity" {

	/* *********************************************************************
	**                            PROPERTIES
	********************************************************************* */

	property name="feedItemAttachmentID"
		fieldtype="id"
		generator="native"
		setter="false"
		params="{ allocationSize=1, sequence='feedItemAttachmentID_seq' }";

	property name="attachmentUrl"
		notnull="true"
		length="510";

	property name="type"
		notnull="false"
		length="255";

	property name="medium"
		notnull="false"
		length="255";

	property name="mimeType"
		notnull="false"
		length="255";

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

	this.pk = "feedItemAttachmentID";

	/**
	 * Constructor
	 * @return FeedItemAttachment
	 */
	FeedItemAttachment function init() {
		super.init();
		createdDate = now();
		return this;
	}

}