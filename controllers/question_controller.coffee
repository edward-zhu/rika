mongoose = require 'mongoose'

genAnswers = (ansStr) ->
	idgen = require('../models/IDGen')
	ans = ansStr.split(" ")
	console.log(ans)
	answers = []
	for answer, i in ans
		ansStr = ans[i]
		re = RegExp("\\[\\d+\\]$")
		if ansStr.match(re)?
			result = ansStr.match(re)
			index = result.index
			result = result[0]
			answers[i] = {
				answer	: ansStr.substr(0, index),
				next	: parseInt(result.substr(1, result.length - 2))
			}
		else
			answers[i] = {
				answer	: ans[i]
			}
	console.log(answers)
	answers
	
exports.delete = (req, res) ->
	if not req.param("survey_id")?
		res.send({
			err : 1,
			msg : "缺少survey_id."
		})
	Survey = mongoose.model('Survey')
	survey_id = req.param('survey_id')
	Survey.findOneAndUpdate(
		{ _id : survey_id },
		{
			'$pull': {
				questions: {
					_id : req.param('question_id')
				}
			}
		},
		{},
		(err, survey) ->
			if err
				res.send({
					err : 1,
					msg : err.msg
				})
			else
				res.send({
					err : 0,
					msg : "操作成功。"
				})
	)

exports.create = (req, res) ->
	Survey = mongoose.model('Survey')
	survey_id = req.param('survey_id')
	
	Survey.findById survey_id, (err, survey) ->
		count = survey.questions.length
		if err
			res.send({
				err : 1,
				msg : err.msg
			})
		question = {
			id			: count + 1,
			question	: req.param('question_name'),
			type		: req.param('question_type')
			
		}
		if question.type != 'text'
			question.answers  = genAnswers(req.param('question_answers')) 
		Survey.findOneAndUpdate(
			{ _id : survey_id },
			{
				'$push': {
					questions : question
				}
			},{}, (err, survey) ->
				if err
					console.log(err)
					res.send({
						err : err.msg
					})
				else
					res.send({
						err : 0,
						survey : survey
					})
		)

