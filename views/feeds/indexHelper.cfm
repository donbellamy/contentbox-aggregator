<cfoutput>
<!---#renderView(view="_tags/contentListViewer", prePostExempt=true)#--->
<script>

function setupFeedView( settings ) {

	$tableContainer = settings.tableContainer;
	$tableURL = settings.tableURL;
	$searchField = settings.searchField;
	$searchName = settings.searchName;
	$contentForm = settings.contentForm;
	$bulkStatusURL = settings.bulkStatusURL;

	$searchField.keyup( 
		_.debounce( 
			function() {
				var $this = $( this );
				// ? var clearIt = ( $this.val().length > 0 ? false : true );
				// ajax search
				contentLoad( { search : $this.val() } );
			}, 
			300 
		) 
	);

}

function contentLoad( criteria ) {

	// default checks
	if( criteria == undefined ){ criteria = {}; }
	// default criteria matches
	if( !( "search" in criteria) ){ criteria.search = ""; }
	if( !( "page" in criteria) ){ criteria.page = 1; }
	//if( !( "parent" in criteria) ){ criteria.parent = ""; }
	//if( !( "fAuthors" in criteria) ){ criteria.fAuthors = "all"; }
	if( !( "fCreators" in criteria) ){ criteria.fCreators = "all"; }
	if( !( "fCategories" in criteria) ){ criteria.fCategories = "all"; }
	if( !( "fStatus" in criteria) ){ criteria.fStatus = "any"; }
	if( !( "fState" in criteria) ){ criteria.fState = "any"; }
	if( !( "showAll" in criteria) ){ criteria.showAll = false; }
	
	// loading effect
	$tableContainer.css( 'opacity', .60 );

	var args = {  
		page : criteria.page, 
		//parent : criteria.parent,
		//fAuthors : criteria.fAuthors,
		fCreators : criteria.fCreators,
		fCategories : criteria.fCategories,
		fStatus : criteria.fStatus,
		fState : criteria.fState,
		showAll : criteria.showAll
	};

	// Add dynamic search key name
	args[ $searchName ] = criteria.search;

	// load content
	$tableContainer.load( $tableURL, args, function() {
		$tableContainer.css( 'opacity', 1 );
		$( this ).fadeIn( 'fast' );
	});

}

$(document).ready(function() {

	setupFeedView({ 
		tableContainer : $("##feedsTableContainer"), 
		tableURL : "#event.buildLink( prc.xehFeedTable )#",
		searchField : $("##feedSearch"),
		searchName : "searchFeeds",
		contentForm : $("##feedForm"),
		bulkStatusURL : "#event.buildlink( prc.xehFeedBulkStatus )#"
	});
	
	// load content on startup, using default parents if passed.
	contentLoad();
	
});

</script>

</cfoutput>