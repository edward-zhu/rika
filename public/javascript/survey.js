var data;
var questions = [];
var taker_token;
var html_sing, html_multi, html_text;

var rules = 
	{
		checkbox : {
			identifier : 'answer',
			rules : [
				{
					type: "checked_check",
					prompt : "请至少选择一个答案。"
				}
			]
		}
	};

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

function getPos(id, answers) {
	for (var i = 0; i < answers.length; i++) {
		if (answers[i]._id == id) {
			return i;
		}
	}
	return -1;
}

function loadSingleQuestion(question, total, callback) {
	var data = question;
	data.total = total;
	$("#question_form").html(Mustache.render(html_sing, data));
	callback();
	$(".ui.checkbox").checkbox();
	$(".ui.form").form(rules,{
		onSuccess: function () {
			$("#question_form").addClass("loading");
			var answer_id = $("input:checked").val();
			var answers = [
				{
					answer_id : answer_id
				}
			]
			var pos = getPos(answer_id, question.answers);
			var next = question.id + 1;
			if (question.next) {
				next = question.next;
			}
			if (question.answers[pos].next) {
				next = question.answers[pos].next;
			}
			$.ajax('/response',{
				data : {
					taker_token	: taker_token,
					survey_id 	: $("#survey_id").val(),
					answers		: answers,
					question_id	: question._id
				},
				type : 'POST'
			}).done(function (data) {
				console.log(next);
				
				loadQuestion(next);
			});
		},
		rules : {
			checked_check : function () {
				return $("input:checked").length > 0;
			}
		}
	});
}

function loadMultipleQuestion(question, total, callback) {
	var data = question;
	data.total = total;
	$("#question_form").html(Mustache.render(html_multi, data));
	callback();
	$(".ui.checkbox").checkbox();
	$(".ui.form").form(rules ,{
		onSuccess: function () {
			$("#question_form").addClass("loading");
			var answers = [];
			$("input:checked").each(function (i, answer) {
				answers[i] = {
					answer_id : $(answer).val()
				}
			});
			console.log(answers);
			var next = question.id + 1;
			if (question.next) {
				next = question.next;
			}
			$.ajax('/response',{
				data : {
					taker_token	: taker_token,
					survey_id 	: $("#survey_id").val(),
					answers		: answers,
					question_id	: question._id
				},
				type : 'POST'
			}).done(function (data) {
				loadQuestion(next);
			});
		},
		rules : {
			checked_check : function () {
				return $("input:checked").length > 0;
			}
		}
	});
}

function loadTextQuestion(question, total, callback) {
	var data = question;
	data.total = total;
	
	$("#question_form").html(Mustache.render(html_text, data));
	callback();
	$(".ui.form").form({},{
		onSuccess: function () {
			$("#question_form").addClass("loading");
			var answers = [{
				answer_id	: question._id,
				answer		: $("#answer").val()
			}];
			console.log(answers);
			var next = question.id + 1;
			if (question.next) {
				next = question.next;
			}
			$.ajax('/response',{
				data : {
					taker_token	: taker_token,
					survey_id 	: $("#survey_id").val(),
					answers		: answers,
					question_id	: question._id
				},
				type : 'POST'
			}).done(function (data) {
				loadQuestion(next);
			});
		}
	});
}

function finish() {
	$("#question_form").load('/partials/question_finish.html');
	$("#question_form").removeClass("loading");
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

function loadUI(callback) {
	$.get('/partials/question_single.html', function (html) {
		html_sing = html;
		$.get('/partials/question_multiple.html', function (html) {
			html_multi = html;
			$.get('/partials/question_text.html', function (html) {
				html_text = html;
				callback();
			});
		});
	});
}

$(document).ready(function () {
	$("#go").addClass("disabled");
	$("#go").html("<i class='ui play icon'></i>加载UI..");
	loadUI(function () {
		$("#go").html("<i class='ui play icon'></i>加载调查内容..");
		loadQuestions(function (data) {
			questions = data;
			$("#go").removeClass("disabled");
			$("#go").html("<i class='ui play icon'></i>开始");
		});
		taker_token = CryptoJS.SHA1(Date() + $("#survey_id").val() + Math.random().toString()).toString();
	});
	
});


$("#go").click(function () {
	$("#question_form").addClass("loading");
	loadQuestion(1);	
})