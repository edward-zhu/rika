mongoose = require 'mongoose'
User = mongoose.model('User')

exports.new = (req, res) ->
	res.render('signup');

exports.create = (req, res) ->
	username = req.body.user
	pass = req.body.pass
	user = new User({
		user : username
	})
	user.genToken(username, pass)
	user.save((err, u) ->
		if err?
			res.send({
				err : 1,
				msg : err.msg
			})
		else
			console.log(u)
			req.session.user = username
			res.send({
				err : 0,
				msg : "注册成功."
			})
	)
	
	