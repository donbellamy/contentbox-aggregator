component extends="aggregator.models.BaseWidget" singleton {

	Portal function init() {
		setName( "Portal" );
		setVersion( "1.0" );
		setDescription( "A widget that displays the portal index." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "newspaper-o" );
		setCategory( "Aggregator" );
		return this;
	}

	string function renderIt() {
		return "";
	}

}