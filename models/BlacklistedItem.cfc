/**
 * ContentBox Aggregator
 * BlacklistedItem Model
 * @author Don Bellamy <don@perfectcode.com>
 */
component persistent="true"
	entityname="cbBlacklistedItem"
	table="cb_blacklisteditem"
	batchsize="25"
	cachename="cbBlacklistedItem"
	cacheuse="read-write"
	extends="contentbox.models.BaseEntity" {

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
		length="510"
		index="idx_itemUrl";

	/* *********************************************************************
	**                            RELATIONSHIPS
	********************************************************************* */

	// M20 -> Feed
	property name="feed"
		notnull="true"
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

	this.pk = "blacklistedItemID";

	this.constraints = {
		"title" = { required=true, size="1..255" },
		"itemUrl" = { required=true, type="url", size="1..255" }
	};

	/**
	 * Constructor
	 * @return BlacklistedItem
	 */
	BlacklistedItem function init() {
		return this;
	}

	/**
	 * Gets the formatted created date
	 * @dateFormat The dateformat to use
	 * @timeFormat The timeformat to use
	 * @return The formatted created date
	 */
	string function getDisplayCreatedDate( string dateFormat="dd mmm yyyy", string timeFormat="hh:mm tt" ) {
		var createdDate = getCreatedDate();
		return dateFormat( createdDate, arguments.dateFormat ) & " " & timeFormat( createdDate, arguments.timeFormat );
	}

	/**
	 * Validates the blacklisted item
	 * @return An array of errors or an empty array if no error is found
	 */
	array function validate() {

		var errors = [];

		variables.title = trim( left( variables.title, 255 ) );
		variables.itemUrl = trim( left( variables.feedUrl, 255 ) );

		if ( !len( variables.title ) ) { arrayAppend( errors, "Title is required" ); }
		if ( !len( variables.itemUrl ) ) { arrayAppend( errors, "Item URL is required" ); }

		return errors;

	}

}