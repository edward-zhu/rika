mongoose = require 'mongoose'

userSchema = new mongoose.Schema 
	username : String
	level : Number

module.exports = mongoose.model('User', userSchema)