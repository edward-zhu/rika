mongoose = require 'mongoose'
crypto = require 'crypto'
states = "unused used".split(' ')

tokenSchema = new mongoose.Schema
	token	: String
	state	: {
		type 	: String,
		enum	: states
	}
	survey	: {
		type	: Number,
		ref		: 'Survey'
	}

module.exports = mongoose.model('Token', tokenSchema)
