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
												 <span class="movie-name">{{movieName}}</span>
												 <span class="rating">{{rating}}</span>
												 <span class="edit">edit</span>
												 <span class="delete">x</span>
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
		$b.append "<div class='existing-movies-block'><h4>Movies</h4><p>Note: Films with too few ratings will not appear below.</p></div>"
		for movie of ratings
			do (movie) ->
				ratingsService.getMovieRating movie, (rating) ->
					$('.existing-movies-block').append ratedMovieSection { movieName: movie, rating: rating.toFixed(2) }

	# submit call
	$(document).on 'submit', "#submit-film", (e) ->
		e.preventDefault()
		name = $("#form-name").val()
		rating = $("#form-rating").val()
		# console.log "params " + name + " " + rating
		# add validations here
		name = name.replace("'","\'")
		# submit
		$.ajax
			type: 'post'
			url: "/api/movieratings/" + name
			data:
				rating : parseInt(rating)
			success: (res) ->
				console.log res
				$("#submit-film").append("<span class='done'>Done!</span>").find(".done").fadeOut(2000)
				htmlName = name
				if $("[id='"+name+"']").length
					ratingsService.getMovieRating name, (ratingAve) ->
						$("[id='"+name+"']").find(".rating").html(ratingAve.toFixed(2))
				else
					$(".existing-movies-block").append ratedMovieSection { movieName: name, rating: Math.round(rating * 100) / 100 }

	# delete call
	$(document).on 'click', ".delete", (e) ->
		movieDiv = $(e.target).parent()
		movieId = movieDiv.attr("id")
		if confirm("Delete '"+movieId+"' from database?")
			$.ajax
				type: 'delete'
				url: "/api/movieratings/" + movieId
				success: (res) ->
					movieDiv.remove()

	# edit call
	$(document).on 'click', ".edit", (e) ->
		movieDiv = $(e.target).parent()
		movieId = movieDiv.attr("id")
		newRating = prompt("Please enter the new rating for '"+movieId+"'.","eg: 2,3,4,5")
		newRating = newRating.split(',')
		parseInt(number) for number in newRating
		console.log newRating
		$.ajax
			type: 'put'
			url: "/api/movieratings/" + movieId
			data: 
				ratings: newRating
			success: (res) ->
				console.log res
				ratingsService.getMovieRating movieId, (rating) ->
					movieDiv.find(".rating").html(rating.toFixed(2))
