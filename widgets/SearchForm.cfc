component extends="aggregator.models.BaseWidget" singleton {

	SearchForm function init() {
		setName( "Search Form" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a feed item search form." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "search" );
		setCategory( "Aggregator" );
		return this;
	}

	string function renderIt() {
		return "";
	}

}