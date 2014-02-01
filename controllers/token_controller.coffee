mongoose = require 'mongoose'
Token = mongoose.model('Token')

exports.upsert = (req, res) ->
	console.log(req.param("survey_id"))
	if req.session.token? and req.session.survey_id == req.param("survey_id")
		token = req.session.token
		survey_id = req.session.survey_id
		state = req.body.state
		console.log(token + " finished")
		Token
			.update({token : token}, {$set : {state : req.body.state, survey : survey_id}},{upsert : true})
			.exec()
		res.send({
			err : 0
		})
	else
		res.send({
			err : 1,
			msg : "这样做不可以侬。"
		})
	