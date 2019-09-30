/**
 * ContentBox Aggregator
 * Videos Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return Videos
	 */
	Videos function init() {
		setName( "Videos" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a list of video feed items." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "video-camera" );
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
			view = "#cb.themeName()#/templates/aggregator/videos",
			module = cb.themeRecord().module,
			args = args
		);

	}

}