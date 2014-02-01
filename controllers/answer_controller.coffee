mongoose = require 'mongoose'
async = require 'async'

Survey = mongoose.model('Survey')
Response = mongoose.model('Response')
Token = mongoose.model('Token')

genStats = (survey_id, questions, callback) ->
	data = []
	tokens =[]

	async.eachLimit questions, 3, (question, callback) ->
		q = {
			id		: question.id,
			_id		: question._id,
			question : question.question,
			type	: question.type
		}
		q.answers = []
		tokens = []
		async.series([
			(callback) ->
				async.eachLimit question.answers, 3, (answer, callback) ->
					a = {
						id		: answer._id,
						answer	: answer.answer
					}
					Response.count(
						{
							"answers.answer_id" : answer._id
						}, 
						(err, count) ->
							if err
								callback(err)
							else
								a.value = count
								q.answers.push(a)
								callback(null)
					)
				, (err) ->
					if err
						callback(err)
					else
						# All answers for the question have been processed
				
						callback(null)
			,
			(callback) ->
				Response.count(
					{
						"question_id" : question._id
					},
					(err, count) ->
						if err
							callback(err)
						else
							q.answer_count = count
							callback(null)
				)

		], (err) ->
			data.push(q)
			callback(null)
		)
	

	, (err) ->
		if err
			callback(err)
		else
			# All questions have been processed
			callback(null, data)

exports.getAnswers = (req, res) ->
	id = req.param('id')
	# console.log(id)
	Survey.findById(id , 
		(err, survey) ->
			if err
				res.send({
					err : 1,
					msg : err.msg
				})
			else
				genStats id, survey.questions, (err, data) ->
					if err
						res.send({
							err : 1,
							msg : err
						})
					else
						res.send({
							err 	: 0,
							data 	: data
						})
	)
			
exports.getTextAnswers = (req, res) ->
	question_id = req.param('id')
	page = if req.param("page")? then parseInt(req.param("page")) else 1
	console.log(page)
	Response
		.count({"answers.answer_id" : question_id}, (err, count) ->
			if err
				res.send({
					err : 1,
					msg : err.msg
				})
			Response
				.find({"answers.answer_id" : question_id})
				.select("answers.answer")
				.skip((page - 1) * 5)
				.limit(5)
				.exec((err, responses) ->
					if err
						res.send({
							err : 1,
							msg : err.msg
						})
					console.log(responses)
					ans = []
					for	response in responses
						ans.push({answer : response.answers[0].answer})	
					res.send({
						err		: 0,
						page	: page,
						total	: Math.ceil(count / 5),
						answers	: ans
					})
				)	
	)
	
			
			