/**
 * ContentBox RSS Aggregator
 * BlacklistedItem Model
 * @author Don Bellamy <don@perfectcode.com>
 */
component persistent="true"
	entityname="cbBlacklistedItem"
	table="cb_blacklisteditem"
	batchsize="25"
	cachename="cbBlacklistedItem"
	cacheuse="read-write" {

	/* *********************************************************************
	**                            PROPERTIES
	********************************************************************* */

	property name="blacklistedItemID"
		fieldtype="id"
		generator="native"
		setter="false"
		params="{ allocationSize=1, sequence='blacklistedItemID_seq' }";

	property name="title"
		notnull="true"
		length="255";

	property name="itemUrl"
		notnull="true"
		length="255"
		index="idx_itemUrl";

	/* *********************************************************************
	**                            RELATIONSHIPS
	********************************************************************* */

	// M20 -> Feed
	property name="feed"
		cfc="Feed"
		fieldtype="many-to-one"
		fkcolumn="FK_feedID"
		lazy="true";

	// M20 -> Creator
	property name="creator"
		notnull="true"
		cfc="contentbox.models.security.Author"
		fieldtype="many-to-one"
		fkcolumn="FK_authorID"
		lazy="true"
		fetch="join";

	/* *********************************************************************
	**                            CONSTRAINTS
	********************************************************************* */

	this.constraints = {
		"title" = { required = true, size = "1..255" },
		"itemUrl" = { required = true, size = "1..255" }
	};

	/**
	 * Constructor
	 * @return BlacklistedItem
	 */
	BlacklistedItem function init() {
		return this;
	}

}