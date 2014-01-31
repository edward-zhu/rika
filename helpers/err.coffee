err = (res, msg) ->
	res.format 
		'text/html' : ->
			res.render('error', {error : msg})
		'application/json' : ->
			res.send({
				err : 1,
				msg : msg
			})

module.exports = err