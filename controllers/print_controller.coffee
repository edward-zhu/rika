mongoose = require 'mongoose'
Survey = mongoose.model('Survey')

statsGen = require '../helpers/stats_generator'

exports.print = (req, res) ->
	id = req.params.id
	# console.log(id)
	Survey.findById(id , 
		(err, survey) ->
			if err
				res.send({
					err : 1,
					msg : err.msg
				})
			else
				statsGen.genStats id, survey.questions, (err, data) ->
					if err
						res.send({
							err : 1,
							msg : err
						})
					else
						questions = []
						for	question in data
							q = {}
							answers = []
							if question.type != 'text'	
								for answer in question.answers
									count = answer.value
									total = question.answer_count
									ans = {
										answer : answer.answer,
										count : count
										total : total
										percent : ((count / total) * 100).toFixed(2)
									}
									answers.push(ans)
								q.answers = answers
								q.question = question.question
								questions.push(q)
						res.render('print_stats', {survey_title : survey.title, questions : questions})
	)