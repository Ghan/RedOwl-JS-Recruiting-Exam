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
                       <div class="rated-movie" id="{{movieName}}">
                         <span class="movie-name">{{movieName}}</span><span class="rating">{{rating}}</span>
                       </div>
                       """

  movieRatingsSection = Handlebars.compile movieRatingsTemplate
  ratedMovieSection = Handlebars.compile ratedMovieTemplate
  $b = $('body')

  ratingsService.getAllMovieRatings (ratings) ->
    console.log JSON.stringify ratings
    $b.append movieRatingsSection { movieRatings: JSON.stringify ratings }
    $b.append "<form id='submit-film'>
      <h3>Add new film ratings here:</h3>
      <input type='text' id='form-name' name='name' placeholder='Film Name' autofocus required>
      <input type='text' id='form-rating' name='rating' placeholder='Rating' required>
      <input type='submit' value='Add'>
    </form>"
    $b.append "<div class='existing-movies-block'><h4>Movies</h4><p>Note: Showing films with more than 2 ratings</p></div>"
    for movie of ratings
      do (movie) ->
        ratingsService.getMovieRating movie, (rating) ->
          $('.existing-movies-block').append ratedMovieSection { movieName: movie, rating: rating }

  # submit function
  $(document).on 'submit', "#submit-film", (e) ->
    e.preventDefault()
    name = $("#form-name").val()
    rating = $("#form-rating").val()
    # console.log "params " + name + " " + rating
    # add validations here
    # submit
    $.ajax
      type: 'post'
      url: "/api/movieratings/" + name
      data:
        rating : parseInt(rating)
      success: (res) ->
        $("#submit-film").append("<span class='done'>Done!</span>").find(".done").fadeOut(2000)
        htmlName = name
        if $("[id='"+name+"']").length
          ratingsService.getMovieRating name, (rating) ->
            $("[id='"+name+"']").find(".rating").html(rating)
        else
          $(".existing-movies-block").append ratedMovieSection { movieName: name, rating: rating }
        