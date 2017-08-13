component extends="coldbox.system.EventHandler" {

	property name="settingService" inject="settingService@cb";
	property name="cbMessagebox" inject="messagebox@cbmessagebox";
	property name="cbHelper" inject="CBHelper@cb";

	function preHandler( event, rc, prc, action, eventArguments ) {

		prc.cb = CBHelper;

		prc.aggregatorSettings = deserializeJSON( settingService.getSetting( "aggregator" ) );

		prc.aggregatorEntryPoint = "#prc.cbAdminEntryPoint#.module.#getModuleConfig('contentbox-aggregator').entryPoint#";

		prc.xehAggregatorSettings = "#prc.aggregatorEntryPoint#.settings";
		prc.xehAggregatorSaveSettings = "#prc.aggregatorEntryPoint#.settings.save";

		//writedump(prc.aggregatorSettings);
		//abort;

	}

}