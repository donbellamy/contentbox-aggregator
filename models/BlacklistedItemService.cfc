/**
 * ContentBox RSS Aggregator
 * BlacklistedItem Service
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="cborm.models.VirtualEntityService" singleton {

	/**
	 * Constructor
	 * @return BlacklistedItemService
	 */
	BlacklistedItemService function init() {

		super.init( entityName="cbBlacklistedItem", useQueryCaching=true );

		return this;

	}

}