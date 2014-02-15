mongoose = require 'mongoose'
async = require 'async'

Survey = mongoose.model('Survey')
Response = mongoose.model('Response')
Token = mongoose.model('Token')

exports.genStats = (survey_id, questions, callback) ->
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