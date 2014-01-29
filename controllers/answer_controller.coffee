mongoose = require 'mongoose'
async = require 'async'

Survey = mongoose.model('Survey')
Response = mongoose.model('Response')

	
# genQuestions = 

genStats = (questions, callback) ->
	data = []
	async.eachLimit questions, 3, (question, callback) ->
			q = {
				q_id	: question._id
				id		: question.id
			}
			q.answers = []
			async.eachLimit question.answers, 3, (answer, callback) ->
				a = {
					id	: answer._id
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
					data.push(q)
					callback(null)

	, (err) ->
		if err
			callback(err)
		else
			# All questions have been processed
			callback(null, data)
	
	

exports.getAnswers = (req, res) ->
	id = req.param('id')
	console.log(id)
	Survey.findById(id , 'questions.id questions._id questions questions.answers', 
		(err, survey) ->
			if err
				res.send({
					err : 1,
					msg : err.msg
				})
			else
				genStats survey.questions, (err, data) ->
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
					