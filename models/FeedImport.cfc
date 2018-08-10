component persistent="true"
	entityname="cbFeedImport"
	table="cb_feedimport"
	batchsize="25"
	cachename="cbFeedImport"
	cacheuse="read-write" {

	/* *********************************************************************
	**							PROPERTIES
	********************************************************************* */

	property name="feedImportID"
		fieldtype="id"
		generator="native"
		setter="false"
		params="{ allocationSize=1, sequence='feedImportID_seq' }";

	property name="importedDate"
		type="date"
		ormtype="timestamp"
		notnull="true"
		update="false"
		index="idx_importedDate";

	property name="importedCount"
		notnull="true"
		ormtype="long";

	// TODO: create get/set functions
	property name="metaInfo"
		notnull="true"
		ormtype="text";

	/* *********************************************************************
	**							RELATIONSHIPS
	********************************************************************* */

	// M20 -> Feed
	property name="feed"
		cfc="Feed"
		fieldtype="many-to-one"
		fkcolumn="FK_feedID"
		lazy="true";

	// M20 -> Importer
	property name="importer"
		notnull="true"
		cfc="contentbox.models.security.Author"
		fieldtype="many-to-one"
		fkcolumn="FK_authorID"
		lazy="true"
		fetch="join";

	/* *********************************************************************
	**                            CONSTRAINTS
	********************************************************************* */
	// TODO: constraints

	FeedImport function init() {
		importedDate = now();
		importedCount = 0;
		return this;
	}

	numeric function getItemCount() {
		var import = deserializeJSON( getMetaInfo() );
		return arrayLen( import.items );
	}

	string function getDisplayImportedDate( string dateFormat="dd mmm yyyy", string timeFormat="hh:mm tt" ) {
		var importedDate = getImportedDate();
		return dateFormat( importedDate, arguments.dateFormat ) & " " & timeFormat( importedDate, arguments.timeFormat );
	}

}