mongoose = require 'mongoose'
crypto = require 'crypto'
states = "unused used finished".split(' ')

tokenSchema = new mongoose.Schema
	token	: {
		type	: String,
		unique 	: true
	}
	state	: {
		type 	: String,
		enum	: states
	}
	date	: {
		type	: Date,
		default	: Date.now
	}
	survey	: {
		type	: Number,
		ref		: 'Survey'
	}

tokenSchema.index({token : 1, survey : 1})

module.exports = mongoose.model('Token', tokenSchema)
