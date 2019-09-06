/**
 * ContentBox RSS Aggregator
 * DB Search Adapter to include feeds and feed items in results
 * @author Don Bellamy <don@perfectcode.com>
 */
component accessors="true" implements="contentbox.models.search.ISearchAdapter" singleton {

	// Dependencies
	property name="contentService" inject="contentService@cb";
	property name="wirebox" inject="wirebox";
	property name="controller" inject="coldbox";
	property name="cb" inject="cbHelper@cb";

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
	contentbox.models.search.SearchResults function search(
		required string searchTerm,
		numeric max=0,
		numeric offset=0
	) {

		// Set vars
		var searchResults = wirebox.getInstance("searchResults@cb");
		var sTime = getTickCount();

		try {

			var results = contentService.searchContent(
				offset = arguments.offset,
				max	= arguments.max,
				searchTerm = arguments.searchTerm,
				showInSearch = true,
				contentTypes = "Page,Entry,Feed,FeedItem"
			);

			var args = {
				results	= results.content,
				total = results.count,
				searchTime = getTickCount() - sTime,
				searchTerm = arguments.searchTerm,
				error = false
			};

			searchResults.populate( args );

		} catch ( any e ) {

			searchResults.setError( true );
			searchResults.setErrorMessages( [ "Error executing content search: #e.detail# #e.message#" ] );

		}

		return searchResults;

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
	any function renderSearch( required string searchTerm, numeric max=0, numeric offset=0 ) {
		var searchResults = search( argumentCollection=arguments );
		return renderSearchWithResults( searchResults );
	}

	/**
	 * Render the search results according the passed in search results object
	 * @searchResults The search results object
	 */
	any function renderSearchWithResults( required contentbox.models.search.SearchResults searchResults ) {

		// Set args
		var args = {
			time = arguments.searchResults.getSearchTime(),
			items = arguments.searchResults.getResults(),
			total = arguments.searchResults.getTotal(),
			searchTerm = arguments.searchResults.getSearchTerm()
		};

		// Render results
		var results = controller.getRenderer().renderView(
			view = "#cb.themeName()#/templates/aggregator/search",
			module = cb.themeRecord().module,
			args = args
		);

		return results;

	}

}