$( document )
	.ready( function () {
		$( ".video-player" )
			.each( function () {
				var $this = $( this );
				var videoId = $this.attr( "data-id" );
				var videoUrl = $this.attr( "data-url" );
				var imageUrl = $this.attr( "data-image" );
				if ( imageUrl ) {
					$this.html( '<img src="' + imageUrl + '"><div class="play"></div>' );
					$this.on( "click", function () {
						$this.html( '<iframe src="' + videoUrl + '?autoplay=1" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>' );
					} );
				} else {
					$this.html( '<iframe src="' + videoUrl + '" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>' );
				}
			} );
		// TODO: Add in clicks to hits for direct links
	} );