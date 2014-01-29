mongoose = require 'mongoose'

exports.create = (req, res) ->
	Response = mongoose.model('Response')
	response = new Response({
		survey 		: req.body.survey_id,
		taker_token	: req.body.taker_token,
		answers		: req.body.answers
	})
	response.save (err, resp) ->
		if err
			res.send({
				err : 1,
				msg	: err.msg
			})
		else
			res.send({
				err 	: 0,
				resp 	: resp
			})