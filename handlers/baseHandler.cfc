component extends="coldbox.system.EventHandler" {

	property name="settingService" inject="settingService@cb";
	property name="cbMessagebox" inject="messagebox@cbmessagebox";
	property name="cbHelper" inject="CBHelper@cb";

	function preHandler( event, rc, prc, action, eventArguments ) {

		prc.cb = CBHelper;

		prc.agSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );
		prc.agAdminEntryPoint = "#prc.cbAdminEntryPoint#.module.#getModuleConfig('contentbox-aggregator').entryPoint#";

		prc.xehAgSettings = "#prc.agAdminEntryPoint#.settings";
		prc.xehAgSaveSettings = "#prc.agAdminEntryPoint#.settings.save";

	}

}