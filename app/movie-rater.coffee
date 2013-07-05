module.exports = (ratings, other_arg) ->
	if ratings instanceof Array and not other_arg?
		if ratings.length > 3
			# sort array
			ratings.sort (a, b) ->
				a - b
			# remove all min ratings
			min = ratings[0]
			ratings.splice(0,1) while ratings[0] is min
			# remove all the max values
			max = ratings[ratings.length-1]
			ratings.splice(ratings.length-1, 1) while ratings[ratings.length-1] is max
			if ratings.length > 0
				i = 0
				sum = 0
				while i < ratings.length
					sum += parseInt(ratings[i])
					i++
				avg = sum/ratings.length
				return avg
			else
				throw Error "Not enough ratings"
		else
			throw Error "Not enough ratings"
	else
		throw Error "Invalid arguments"