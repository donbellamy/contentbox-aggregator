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

	// TODO: Add number imported

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

	FeedImport function init() {
		importedDate = now();
		return this;
	}

}