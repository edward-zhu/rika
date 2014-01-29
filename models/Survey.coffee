mongoose = require 'mongoose'
types = "single multiple text".split(' ')

surveySchema = new mongoose.Schema
	_id		: {
		type	 : Number
		required : true
	}
	title	: {
		type		: String
		required 	: true
	}
	date	: {
		type : Date,
		default : Date.now
	}
	owner_token : String
	questions	: [ {
		id			: Number,
		question 	: String,
		type 		: {
			type : String,
			enum : types
		}
		answers	 : [ {
			answer	: String,
			next	: Number 
		} ]
	} ]

surveySchema.index({_id : 1, "questions.id" : 1})

surveySchema.methods.genOwnerToken = (email, pass)->
	crypto = require 'crypto'
	sha1 = crypto.createHash('sha1')
	sha1.update(email + 'rika' + pass)
	@owner_token = sha1.digest('hex')

module.exports = mongoose.model('Survey', surveySchema)
