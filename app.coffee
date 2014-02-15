express = require('express')
http = require('http')
path = require('path')
swig = require('swig')
MongoStore = require('connect-mongo')(express)
mongoose = require 'mongoose'
flash = require 'connect-flash'
settings = require './settings'

app = express()

app.engine('html', swig.renderFile)

mongoose.connect("mongodb://edward:mtmtmt@troup.mongohq.com:10018/survey")
#mongoose.connect("mongodb://localhost/survey")

app.configure ->
	app.set "port", 3000
	app.set "views", __dirname + "/views"
	app.set "view engine", 'html'
	app.use express.favicon()
	app.use express.logger("dev")
	app.use express.json()
	app.use express.urlencoded()
	app.use express.methodOverride()
	app.use express.cookieParser()
	app.use express.session(
		secret	: settings.secret,
		cookie	: {maxAge: 1000 * 60 * 60 *24 * 30},
		store	: new MongoStore(
			db: mongoose.connections[0].db
		)
	)
	app.use flash()
	app.use app.router
	app.use(express.compress());
	app.use express.static(path.join(__dirname,'public'))

if 'development' == app.get('env')
	app.use express.errorHandler()

require './models/User'
require './models/Survey'
require './models/Response'
require './models/Token'

survey = require './controllers/survey_controller'
response = require './controllers/response_controller'
question = require './controllers/question_controller'
answer = require './controllers/answer_controller'
login = require './controllers/login_controller'
user = require './controllers/user_controller'
token = require './controllers/token_controller'
print = require './controllers/print_controller'

	
app.get '/',
	(req, res) ->
		res.render 'index'

app.get 	'/new'					,	survey.new 

app.get		'/survey/:id/edit'		,	survey.edit
app.get		'/survey/:id/'			,	survey.get
app.put		'/survey/:id/'			,	survey.modify
app.get		'/survey/:id/stats'		,	survey.getStats
app.get		'/survey/:id/takers'	,	token.get
app.get		'/survey/:id/print'		,	print.print
app.get		'/survey/:id/analyze'	,	survey.analyze

app.get		'/survey/'				,	survey.get
app.post	'/survey/'				,	survey.create
app.post	'/question/'			,	question.create
app.delete	'/question/'			,	question.delete
app.post	'/response'				,	response.create
app.get		'/getanswer'			,	answer.getAnswers
app.get		'/gettextans'			,	answer.getTextAnswers
app.post	'/login'				,	login.login
app.get		'/login'				,	login.get
app.get		'/my'					,	survey.getUserSurveys
app.get		'/signup'				,	user.new
app.post	'/signup'				,	user.create
app.post	'/token'				,	token.upsert
app.post	'/trim'					,	response.trimResp
app.post	'/getrelans'			,	answer.getRelativeAnswers

		
app.listen process.env.PORT || 3000
console.log "server running at port 3000."