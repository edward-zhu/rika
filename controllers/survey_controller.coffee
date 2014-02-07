mongoose = require 'mongoose'
Survey = mongoose.model('Survey')
Token = mongoose.model('Token')

error = require '../helpers/err'

exports.get = (req, res) ->
	if req.params.id?
		res.format 
			'text/html' : ->
				Survey
					.findById(req.params.id)
					.select("_id title")
					.exec((err, survey) ->
						if err? or not survey?
							error(res, "找不到该问卷")
						else
							if not req.session.token? or req.session.survey_id != req.params.id
								crypto = require 'crypto'
								sha1 = crypto.createHash('sha1')
								sha1.update(Date() + req.params.id + Math.random().toString())
								req.session.survey_id = req.params.id
								token = sha1.digest('hex')
								req.session.token = token
								Token
									.update({token : token}, {$set : {state : "used", survey: req.params.id, date: Date.now()}},{upsert : true})
									.exec()
							else
								token = req.session.token
							res.render('survey', {survey : survey})
					)
			'application/json' : ->
				Survey
					.findById(req.params.id)
					.exec((err, survey) ->
						if err? or not survey?
							error(res, "找不到该问卷")
						else
							res.send(survey)
					)
	else
		error(res, "找不到网页")
		
exports.new = (req, res) ->
	if req.session.user?
		res.render('survey_new')
	else
		req.flash('info','请登录后进行操作。')
		res.redirect '/login'
	
exports.create = (req, res) ->
	console.log('Creating...')
	if req.param('title')?
		survey = new Survey({
			title : req.param('title'),
			user  : req.session.user
		})
		idgen = require('../models/IDGen')
		idgen.getNewID 'Survey', (id) ->
			# console.log('get ID : ' + id.toString())
			survey._id = id;
			# console.log(survey)
			survey.save (err) ->
				if err
					console.log(err)
					res.send({'err' : 1, 'msg' : err.msg})
				else
					res.send({'err' : 0, 'msg' : 'Success!', 'id' : survey._id})
	else
		error(res, "调查名为空。")
		
exports.edit = (req, res) ->
	if not req.params.id?
		error(res, '未提供id')
	else
		Survey.findById req.params.id, 'title user', (err, survey) ->
			if err? or not survey? or survey.user != req.session.user
				req.flash('info',"您没有编辑的权限，请以该问卷管理者身份登录以进行操作")
				res.redirect '/login'
			else
				res.render('survey_edit', survey)
	
exports.modify = (req, res) ->
	if req.body.modify_type == 'order'
		for question, i in req.body.questions
			# console.log(req.params.id)
			# console.log(question + ' ' + i.toString())
			Survey.findOneAndUpdate(
				{
					_id : req.params.id,
					"questions._id" : mongoose.Types.ObjectId(question)
				},
				{
					"$set" : {
						"questions.$.id" : i + 1
					}
				},
				{},
				(err, survey) ->
					if (err)
						res.send({
							err : 1,
							msg : err.msg
						})
					else
						console.log(survey)
			)
		res.send({
			err : 0,
			msg : "操作成功！"
		})
	error(res, "找不到网页")
	
exports.getStats = (req, res) ->
	Survey.findById req.params.id, 'title', (err, survey) ->
		if err? or not survey?
			error(res, err.msg) if err?
			error(res, "找不到该调查。") if not survey?
		else
			res.render('survey_stats', { survey : survey })
			
exports.getUserSurveys = (req, res) ->
	if not req.session.user?
		req.flash('info', '请先登录')
		res.redirect '/login'
	else
		user = req.session.user
		Survey
			.find({user : user})
			.select('title date')
			.sort('-date')
			.exec((err, surveys) ->
				if err?
					error(res, err.msg)
				else
					for survey in surveys
						# console.log(survey.date)
						survey.date_str = survey.date.toString()
					res.render('survey_my', {
						surveys : surveys
					})
			)
			
sortBy = (a, b) ->
	a.id - b.id
			
exports.analyze = (req, res) ->
	res.format
		'text/html' : ->
			Survey.findById req.params.id, 'title', (err, survey) ->
				if err? or not survey?
					error(res, err.msg) if err?
					error(res, "找不到该调查。") if not survey?
				else
					res.render('survey_analysis', { survey : survey })
		'application/json' : ->
			Survey.findById req.params.id, 'title questions.question questions.id questions.type', (err, survey) ->
				if err? or not survey?
					error(res, err.msg) if err?
					error(res, "找不到该调查。") if not survey?
				else
					survey.questions.sort(sortBy)
					res.send(survey)