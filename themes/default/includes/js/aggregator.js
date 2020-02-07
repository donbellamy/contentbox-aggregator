$( document )
	.ready( function () {
		$( ".video-player" )
			.each( function () {
				var $this = $( this );
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

		$( ".direct-link,.video-player,.audio-player" )
			.on( "click play", function ( e ) {
				var $this = $( this );
				var slug = $this.attr( "data-slug" );
				$.ajax( {
					url: feedItemsHitUrl + "/" + slug,
					type: "GET",
					success: function ( data ) {
						console.log( data );
					}
				} );
			} );
	} );