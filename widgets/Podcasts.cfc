/**
 * ContentBox Aggregator
 * Podcasts Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return Podcasts
	 */
	Podcasts function init() {
		setName( "Podcasts" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a list of podcast feed items." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "podcast" );
		setCategory( "Aggregator" );
		return this;
	}

	string function renderIt() {

		// Grab the event
		var event = getRequestContext();
		var prc = event.getCollection(private=true);

		// Fixes bug in widget preview - take out when fixed
		prc.cbTheme = prc.cbSettings.cb_site_theme;
		prc.cbThemeRecord = themeService.getThemeRecord( prc.cbTheme );

		// Set args
		var args = {};

		// Render the podcasts template
		return renderView(
			view = "#cb.themeName()#/templates/aggregator/podcasts",
			module = cb.themeRecord().module,
			args = args
		);

	}

}