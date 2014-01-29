express = require('express')
http = require('http')
path = require('path')
swig = require('swig')
mongoose = require 'mongoose'
app = express()

app.engine('html', swig.renderFile)

app.configure ->
	app.set "port", 3000
	app.set "views", __dirname + "/views"
	app.set "view engine", 'html'
	app.use express.favicon()
	app.use express.logger("dev")
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use express.cookieParser()
	app.use app.router
	app.use express.static(path.join(__dirname,'public'))

if 'development' == app.get('env')
	app.use express.errorHandler()

mongoose.connect("mongodb://localhost/survey")

survey = require './controllers/survey_controller'

require './models/Survey'
require './models/Response'
response = require './controllers/response_controller'
question = require './controllers/question_controller'
answer = require './controllers/answer_controller'

	
app.get '/',
	(req, res) ->
		res.render 'index'

app.get 	'/new', survey.new 
app.get		'/survey/:id/edit', survey.edit
app.get		'/survey/:id/',	survey.get
app.get		'/survey/',	survey.get
app.post	'/survey/', survey.create
app.put		'/survey/:id/', survey.modify
app.post	'/question/', question.create
app.delete	'/question/', question.delete
app.post	'/response', response.create

app.get		'/getanswer',  answer.getAnswers
		
app.listen 3000
console.log "server running at port 3000."