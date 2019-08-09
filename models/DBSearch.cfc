/**
 * ContentBox RSS Aggregator
 * DB Search Adapter to include feeds and feed items in results
 * @author Don Bellamy <don@perfectcode.com>
 */
component accessors="true" implements="contentbox.models.search.ISearchAdapter" singleton {

	// Dependencies
	property name="contentService" inject="contentService@aggregator";
	property name="ag" inject="helper@aggregator";
	property name="wirebox" inject="wirebox";

	/**
	 * Constructor
	 * @return DBSearch
	 */
	DBSearch function init() {
		return this;
	}

	/**
	 * Search content and return an standardized ContentBox Results object.
	 * @searchTerm The search term to search on
	 * @max The max results to return if paging
	 * @offset The offset to use in the search results if paging
	 */
	contentbox.models.search.SearchResults function search( required string searchTerm, numeric max=0, numeric offset=0 ) {

	}

	/**
	 * If chosen to be implemented, it should refresh search indexes and collections
	 */
	contentbox.models.search.ISearchAdapter function refresh() {}

	/**
	 * Render the search results according to the adapter and return HTML
	 * @searchTerm The search term to search on
	 * @max The max results to return if paging
	 * @offset The offset to use in the search results if paging
	 */
	any function renderSearch(required string searchTerm, numeric max=0, numeric offset=0) {

	}

	/**
	 * Render the search results according the passed in search results object
	 * @searchResults The search results object
	 */
	any function renderSearchWithResults(required contentbox.models.search.SearchResults searchResults) {

	}

}