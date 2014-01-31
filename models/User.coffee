mongoose = require 'mongoose'

userSchema = new mongoose.Schema 
	user 	: {
		type	: String,
		unique	: true
	}
	token	: String
	
genToken = (email, pass) ->
	crypto = require 'crypto'
	sha1 = crypto.createHash('sha1')
	sha1.update(email + 'rika' + pass)
	sha1.digest('hex')
	
userSchema.methods.genToken = (email, pass)->
	@token = genToken(email, pass)

User = mongoose.model('User', userSchema)

User.getToken = genToken

module.exports = User
