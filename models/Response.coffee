mongoose = require 'mongoose'

responseSchema = new mongoose.Schema 
	survey : {
		type: Number,
		ref: 'Survey'
	}
	taker_token : String 
	answers : [{
		answer_id	: mongoose.Schema.Types.ObjectId,
		answer		: String
	}]

module.exports = mongoose.model('Response', responseSchema)
