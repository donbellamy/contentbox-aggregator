component extends="aggregator.models.BaseWidget" singleton {

	Archives function init() {
		setName( "Archives" );
		setVersion( "1.0" );
		setDescription( "A widget that displays feed item archives." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "calendar" );
		setCategory( "Aggregator" );
		return this;
	}

	string function renderIt() {
		return "";
	}

}