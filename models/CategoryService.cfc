component extends="contentbox.models.content.CategoryService" singleton {

	CategoryService function init() {
		super.init();
		return this;
	}

	array function getFeedCategories() {
		return [];
	}

	array function getFeedItemCategories() {
		return [];
	}

}