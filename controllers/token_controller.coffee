mongoose = require 'mongoose'
Token = mongoose.model('Token')
Survey = mongoose.model('Survey')

exports.upsert = (req, res) ->
	if req.session.token? and req.session.survey_id == req.param("survey_id")
		token = req.session.token
		survey_id = req.session.survey_id
		state = req.body.state
		console.log(token + " finished")
		Token
			.update({token : token}, {$set : {state : req.body.state, survey : survey_id, date: Date.now()}},{upsert : true})
			.exec()
		res.send({
			err : 0
		})
	else
		res.send({
			err : 1,
			msg : "这样做不可以侬。"
		})
		

exports.get = (req, res) ->
	Survey.findById(req.param("id"), 'title' ,(err, survey) ->
		if not survey?
			res.send({
				err : 1,
				msg : "该问卷不存在"
			})
		else
			Token
				.find({survey : survey._id})
				.sort('-date')
				.exec((err, tokens) ->
					if err?
						res.send({
							err : 1,
							msg : err.msg
						})
					else
						finished = 0
						for token in tokens
							if token.state == "finished"
								finished++
						res.render('survey_takers', {
							survey_id	: survey._id,
							title		: survey.title,
							finished	: finished,
							total 		: tokens.length,
							tokens 		: tokens
						})
				)
	)
	