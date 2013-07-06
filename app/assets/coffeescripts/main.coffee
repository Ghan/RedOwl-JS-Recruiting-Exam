requirejs.config
  baseUrl: '/javascripts'
  paths:
    vendor: './vendor'
  shim:
    'vendor/jquery':
      exports: 'jQuery'
    'vendor/underscore':
      exports: '_'
    'vendor/handlebars':
      exports: 'Handlebars'

dependencies = [
  'vendor/jquery'
  'vendor/underscore'
  'vendor/handlebars'
  'movie-ratings-service-client'
]

requirejs dependencies, ($, _, Handlebars, ratingsService) ->

  movieRatingsTemplate = """
                         <div class="movie-ratings">
                           {{movieRatings}}
                         </div>
                         """
  ratedMovieTemplate = """
                       <div class="rated-movie">
                         <span class="movie-name">{{movieName}}</span><span class="rating">{{rating}}</span>
                       </div>
                       """

  movieRatingsSection = Handlebars.compile movieRatingsTemplate
  ratedMovieSection = Handlebars.compile ratedMovieTemplate
  $b = $('body')

  ratingsService.getAllMovieRatings (ratings) ->
    $b.append movieRatingsSection { movieRatings: JSON.stringify ratings }
    movieBlock = "<div class='existing-movies-block'>Movies"
    for movie of ratings
      do (movie) ->
        ratingsService.getMovieRating movie, (rating) ->
        	movieBlock += String ratedMovieSection { movieName: movie, rating: rating }
        	console.log movieBlock
    console.log movieBlock + " Finished"
    $b.append movieBlock