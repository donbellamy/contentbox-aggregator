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

	property name="numberImported"
		notnull="true"
		ormtype="long";

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

	FeedImport function init() {
		importedDate = now();
		numberImported = 0;
		return this;
	}

}