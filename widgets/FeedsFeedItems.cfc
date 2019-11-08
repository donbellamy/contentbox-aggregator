/**
 * ContentBox Aggregator
 * Feeds and FeedItems Widget
 * @author Don Bellamy <don@perfectcode.com>
 */
component extends="aggregator.models.BaseWidget" singleton {

	/**
	 * Constructor, sets widget properties
	 * @return Feeds
	 */
	FeedsFeedItems function init() {
		setName( "Feeds and Feed items" );
		setVersion( "1.0" );
		setDescription( "A widget that displays a list of feeds with the latest feed items for each." );
		setAuthor( "Perfect Code, LLC" );
		setAuthorURL( "https://perfectcode.com" );
		setIcon( "indent" );
		setCategory( "Aggregator" );
		return this;
	}

	/**
	 *
	 *
	 */
	string function renderIt() {

		return "";

	}

}