mongoose = require 'mongoose'

exports.create = (req, res) ->
	Response = mongoose.model('Response')
	Response
		.count({question_id : req.body.question_id, taker_token : req.body.taker_token})
		.exec((err, count) ->
			if err?
				res.send({
					err : 1,
					msg	: err.msg
				})
			else if count == 0 or not count?
				response = new Response({
					survey 		: req.body.survey_id,
					taker_token	: req.body.taker_token,
					question_id	: req.body.question_id,
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
							msg		: "提交成功"
						})
			else
				res.send({
					err	: 0,
					msg : "重复提交"
				})
		) 
	