mongoose = require 'mongoose'
User = mongoose.model('User')
error = require '../helpers/err'

exports.get = (req, res) ->
	res.render('login', {message : req.flash('info')})
	
exports.login = (req, res) ->
	email = req.param("email")
	pass = req.param("pass")
	console.log("loging in...")
	token = User.getToken(email, pass)
	User.findOne {user : email}, (err, user) ->
		if err?
			res.send({
				err : 1,
				msg	: err.msg
			})
		else if not user?
			res.send({
				err : 1,
				msg : "不存在的用户名。"
			})
		else
			if user.token != token
				res.send({
					err : 1,
					msg : "用户名或密码错误"
				})
			else
				req.session.user = user.user
				res.send({
					err : 0,
					msg : "登录成功！"
				})
				
exports.logout = (req, res) ->
	req.session.user = null
				
	