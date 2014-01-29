mongoose = require 'mongoose'

exports.get = (req, res) ->
	Survey = mongoose.model('Survey')
	
	if req.params.id?
		Survey.findById req.params.id, (err, survey) ->
			res.send(500, {error: err}) if err?
			res.format 
				'text/html' : ->
					console.log(survey.questions)
					res.render('survey', {survey : survey})
				'application/json' : ->
					res.send(survey)
	else
		res.send({'err', '0'})
		
exports.new = (req, res) ->
	res.render('survey_new')
	
exports.create = (req, res) ->
	Survey = mongoose.model('Survey')
	if req.param('title')?
		survey = new Survey({
			title: req.param('title')
		})
		idgen = require('../models/IDGen')
		idgen.getNewID 'Survey', (id) ->
			console.log('get ID : ' + id.toString())
			survey._id = id;
			survey.genOwnerToken req.param('email'), req.param('pass')
			console.log(survey)
			survey.save (err) ->
				if err
					console.log(err)
					res.send({'err' : 1, 'msg' : err.msg})
				else
					res.send({'err' : 0, 'msg' : 'Success!', 'id' : survey._id})
	else
		res.send({'err' : 1, 'msg' : "Empty Title"})
		
exports.edit = (req, res) ->
	res.render('survey_edit', {id : req.params.id})
	
exports.modify = (req, res) ->
	Survey = mongoose.model('Survey')
	if req.body.modify_type == 'order'
		for question, i in req.body.questions
			console.log(req.params.id)
			console.log(question + ' ' + i.toString())
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
	res.send({
		err : 1,
		msg : "404"
	})