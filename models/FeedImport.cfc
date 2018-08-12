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

	property name="importFailed"
		notnull="true"
		ormtype="boolean"
		default="false"
		index="idx_importFailed";

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
		setMetaInfo({});
		return this;
	}

	FeedImport function setMetaInfo( required any metaInfo ) {
		if ( isStruct( arguments.metaInfo ) ) {
			arguments.metaInfo = serializeJSON( arguments.metaInfo );
		}
		variables.metaInfo = arguments.metaInfo;
		return this;
	}

	struct function getMetaInfo() {
		return ( !isNull( metaInfo ) && isJSON( metaInfo ) ) ? deserializeJSON( metaInfo ) : {};
	}

	numeric function getItemCount() {
		var import = getMetaInfo();
		if ( isStruct( import ) && structKeyExists( import, "items" ) ) {
			return arrayLen( import.items );
		} else {
			return 0;
		}
	}

	boolean function failed() {
		return getImportFailed();
	}

	string function getDisplayImportedDate( string dateFormat="dd mmm yyyy", string timeFormat="hh:mm tt" ) {
		var importedDate = getImportedDate();
		return dateFormat( importedDate, arguments.dateFormat ) & " " & timeFormat( importedDate, arguments.timeFormat );
	}

}