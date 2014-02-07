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
	
exports.getRelativeAnswers = (req, res) ->
	survey_id = parseInt(req.body.survey_id)
	baseId = parseInt(req.body.base_id) # 基础问题
	refId = parseInt(req.body.ref_id)	# 参考问题（根据该问题分类）
	console.log(survey_id)
	console.log(baseId)
	console.log(refId)
	data = {}
	takers_list = []
	baseAnswers = []
	refAnswers = []
	search_results = []
	async.series([
		# 1、根据参考问题_id获取答案
		(callback) ->
			#console.log("Phase 1")
			#console.log("refId : " + refId)
			Survey
				.aggregate(
					[
						{ $match : {_id : survey_id}},
						{ $project : {questions : 1}},
						{ $unwind : "$questions" },
						{ $match : {"questions.id" : refId}},
						{ $group : {_id : "$questions.question", answers : {$push : "$questions.answers"}}},
						{ $unwind : "$answers"},
						{ $project : {"answers._id" : 1, "answers.answer" : 1}},
						{ $unwind : "$answers"},
						{ $group : {_id : "$_id", answers : {$push : "$answers"}}}
					],
					(err, result) ->
						if err? or not result? or result.length == 0
							callback(err) if err?
							res.send({
								err : 1,
								msg : "该问题不存在"
							})
						else
							#console.log(result)
							for ans in result[0].answers
								refAnswers.push(ans)
							data['ref_question'] = result[0]._id
							#console.log("Phase 1 - results")
							#console.log(refAnswers)
							callback(null)
				)
		,
		# 2、根据参考问题的答案把takers分类
		(callback) ->
			#console.log("Phase 2")
			async.eachLimit(refAnswers, 3, (answer, callback) ->
				
				Response
					.find({"answers.answer_id" : answer._id})
					.select("taker_token")
					.exec((err, responses) ->
						if err? or not responses?
							callback(err)
						else
							#console.log(responses)
							takers = []
							for	resp in responses
								takers.push(resp.taker_token)
							takers_list.push({
								answer_id : answer._id,
								answer : answer.answer,
								takers : takers
							})
							callback(null)
					)
			,
			(err) ->
				if err?
					callback(err)
				else
					#console.log("Phase 2 - results")
					#console.log(takers_list)
					callback(null)
			)
			# 得到 takers[ {answer1, answer1_takers}, {answer2, answer2_takers}, ...]
		,
		# 3、根据base问题，得到所有答案
		(callback) ->
			console.log("Phase 3")
			console.log("baseId : " + baseId)
			Survey
				.aggregate(
					[
						{ $match : {_id : survey_id}},
						{ $project : {questions : 1}},
						{ $unwind : "$questions" },
						{ $match : {"questions.id" : baseId}},
						{ $group : {_id : "$questions.question", answers : {$push : "$questions.answers"}}},
						{ $unwind : "$answers"},
						{ $project : {"answers._id" : 1, "answers.answer" : 1}},
						{ $unwind : "$answers"},
						{ $group : {_id : "$_id", answers : {$push : "$answers"}}}
					],
					(err, result) ->
						if err? or not result? or result.length == 0
							callback(err) if err?
							res.send({
								err : 1,
								msg : "该问题不存在"
							})
						else
							for ans in result[0].answers
								baseAnswers.push(ans)
							data['base_question'] = result[0]._id
							#console.log("Phase 3 - results")
							#console.log(baseAnswers)
							callback(null)
				)
		,
		# 4、根据takers分类检索出base问题基于ref问题的数据
		(callback) ->
			console.log("Phase 4")
			async.eachLimit(baseAnswers, 3, (answer, callback) ->
				answer_id = answer._id
				search_result = {
					answer : answer.answer,
					answer_id : answer._id
				}
				search_result.ref_counts = []
				async.eachLimit(takers_list, 3, (takers, callback) ->
					ref_count = {
						answer : takers.answer,
						answer_id : takers.answer_id
					}
					ref_count.count = 0
					async.eachLimit(takers.takers, 3, (taker, callback) ->
						
						Response
							.count({"answers.answer_id" : search_result.answer_id, taker_token : taker})
							.exec((err, count) ->
								if err?
									callback(err)
								else
									ref_count.count += count
									callback(null)
							)
					,
					(err) ->
						if err?
							callback(err)
						else
							#console.log("add ref_count : ")
							#console.log(ref_count)
							search_result.ref_counts.push(ref_count)
							callback(null)		
					)
				,
				(err) ->
					if err?
						callback(err)
					else
						search_results.push(search_result)
						callback(null)
				)
			,
			(err) ->
				if err?
					callback(err)
				else
					data.search_results = search_results
					callback(null)
			)
			
	]
	,
	(err) ->
		if err?
			res.send({
				err 	: 1,
				detail	: err
			})
		else
			res.send({
				err	 : 0,
				data : data 
			})
	)
	
	
			