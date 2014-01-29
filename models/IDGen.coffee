mongoose = require 'mongoose'
Schema = mongoose.Schema

IdGen = new Schema
	model : String
	currentid : {
		type : Number,
		default : 1 
	}

idg = mongoose.model('IDGen', IdGen)
idg.getNewID = (model, callback) ->
	@findOne {model : model}, (err, doc) ->
		if doc
			doc.currentid += 1
		else
			doc = new idg()
			doc.model = model
		doc.save (err) ->
			if err
				console.log(err)
				throw err('ID generate error')
			else
				console.log('IDGen : ' + doc.currentid.toString() )
				callback parseInt(doc.currentid.toString())

module.exports = idg