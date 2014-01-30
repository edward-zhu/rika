var data;
var questions = [];
var taker_token;

function sortBy(a, b) {
	return a.id - b.id;
}


function loadQuestions(callback) {
	var survey_id = $("#survey_id").val();
	$.ajax('/survey/' + survey_id + '/', {
		dataType : 'json'
	}).done(function (data) {
		// console.log(data);
		callback(data.questions.sort(sortBy));
	});
}

function loadSingleQuestion(question, total, callback) {
	var data = question;
	data.total = total;
	$.get('/partials/question_single.html',{}, function (html) {
		$("#question_form").html(Mustache.render(html, data));
		$(".ui.checkbox").checkbox();
		$(".ui.form").form({
			checkbox : {
				identifier : 'answer',
				rules : [
					{
						type: "checked_check",
						prompt : "请至少选择一个答案。"
					}
				]
			}
		},{
			onSuccess: function () {
				var answer_id = $("input:checked").val();
				var answers = [
					{
						answer_id : answer_id
					}
				]
				$.ajax('/response',{
					data : {
						taker_token	: taker_token,
						survey_id 	: $("#survey_id").val(),
						answers		: answers,
						question_id	: question._id
					},
					type : 'POST'
				}).done(function (data) {
					console.log(question.id + 1);
					loadQuestion(question.id + 1);
				});
			},
			rules : {
				checked_check : function () {
					return $("input:checked").length > 0;
				}
			}
		});
		callback();
	});
}

function loadMultipleQuestion(question, total, callback) {
	var data = question;
	data.total = total;
	$.get('/partials/question_multiple.html',{}, function (html) {
		$("#question_form").html(Mustache.render(html, data));
		$(".ui.checkbox").checkbox();
		$(".ui.form").form({
			checkbox : {
				identifier : 'answer',
				rules : [
					{
						type: "checked_check",
						prompt : "请至少选择一个答案。"
					}
				]
			}
		},{
			onSuccess: function () {
				var answers = [];
				$("input:checked").each(function (i, answer) {
					answers[i] = {
						answer_id : $(answer).val()
					}
				});
				console.log(answers);
				$.ajax('/response',{
					data : {
						taker_token	: taker_token,
						survey_id 	: $("#survey_id").val(),
						answers		: answers,
						question_id	: question._id
					},
					type : 'POST'
				}).done(function (data) {
					// console.log(data);
					loadQuestion(question.id + 1);
				});
			},
			rules : {
				checked_check : function () {
					return $("input:checked").length > 0;
				}
			}
		});
		callback();
	});
}

function loadTextQuestion(question, total, callback)
{
	var data = question;
	data.total = total;
	$.get('/partials/question_text.html',{}, function (html) {
		$("#question_form").html(Mustache.render(html, data));
		$(".ui.form").form({

		},{
			onSuccess: function () {
				var answers = [{
					answer_id	: question._id,
					answer		: $("#answer").val()
				}];
				console.log(answers);
				$.ajax('/response',{
					data : {
						taker_token	: taker_token,
						survey_id 	: $("#survey_id").val(),
						answers		: answers,
						question_id	: question._id
					},
					type : 'POST'
				}).done(function (data) {
					// console.log(data);
					loadQuestion(question.id + 1);
				});
			}
		});
		callback();
	});
}

function finish() {
	$("#question_form").load('/partials/question_finish.html');
}


function loadQuestion(id) {
	var question = questions[id - 1];
	var total = questions.length;
	if (id > total) {
		finish();
		return;
	}
	var callback = function () {
		$("#question_form").removeClass("loading");
	}
	$("#question_form").addClass("loading");
	if (question.type === 'single') {
		loadSingleQuestion(question, total, callback);
	} 
	else if (question.type === 'multiple') {
		loadMultipleQuestion(question, total, callback);
	}
	else if (question.type === 'text') {
		loadTextQuestion(question, total, callback);
	}
}


$(document).ready(function () {
	$("#go").addClass("disabled");
	loadQuestions(function (data) {
		questions = data;
		// console.log(questions);
		$("#go").removeClass("disabled");
	});
	taker_token = CryptoJS.SHA1(Date() + $("#survey_id").val() + Math.random().toString()).toString();
});


$("#go").click(function () {
	loadQuestion(1);	
})