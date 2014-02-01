mongoose = require 'mongoose'
async = require 'async'

Response = mongoose.model('Response')
Token = mongoose.model('Token')

exports.create = (req, res) ->
	Response
		.count({question_id : req.body.question_id, taker_token : req.session.token}, (err, count) ->
			if err?
				res.send({
					err : 1,
					msg	: err.msg
				})
			else if count == 0
				response = new Response({
					survey 		: req.body.survey_id,
					taker_token	: req.session.token,
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
		
exports.trimResp = (req, res) ->
	data = []
	tokens =[]
	survey_id = req.param("survey_id")
	async.series [
		(callback) ->
			Token.find({state : /used/, survey : survey_id}, (err, result) ->
				if err?
					callback(err)
				else
					tokens = result
					callback(null)
			)
		,
		(callback) ->
			async.eachLimit tokens, 3, (token, callback) ->
				Response
					.remove({
						survey	: survey_id,
						taker_token	: token.token
					},(err) ->
						if err?
							callback(err)
						else
							callback(null)
					)
			, (err) ->
				if err
					callback(err)
				else
					callback(null)
	], (err) ->
		if err
			res.send({
				err : 1,
				msg : err
			})
		else
			# Return Result
			res.send({
				err : 0,
				msg : "操作成功完成!"
			})
	
	