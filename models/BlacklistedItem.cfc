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
		length="510"
		index="idx_itemUrl";

	property name="createdDate"
		type="date"
		ormtype="timestamp"
		notnull="true"
		update="false"
		index="idx_createdDate";

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
		"itemUrl" = { required=true, type="url", size="1..255" },
		"createdDate" = { required=true, type="date" },
	};

	/**
	 * Constructor
	 * @return BlacklistedItem
	 */
	BlacklistedItem function init() {
		createdDate = now();
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

		title = trim( left( title, 255 ) );
		itemUrl = trim( left( feedUrl, 255 ) );

		if ( !len( title ) ) { arrayAppend( errors, "Title is required" ); }
		if ( !len( itemUrl ) ) { arrayAppend( errors, "Item URL is required" ); }

		return errors;

	}

}