var data;
var questions = [];
var taker_token;
var html;

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
	}).done(function (data, textStatus) {
		// console.log(data);
		console.log(textStatus);
		if (data.questions && data.questions.length > 0)
		{
			callback(data.questions.sort(sortBy));
		}
		else {
			alert("问题载入失败，或问卷未准备好，请刷新");
			location.reload();
		}
	}).fail(function () {
		alert("问题载入失败，或问卷未准备好，请刷新");
		location.reload();
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

function loadOneQuestion(question, total, callback) {
	var data = question;
	data.total = total;
	if (question.type === "single") {
		data.single = true;
	} else if (question.type === "multiple") {
		data.multiple = true;
	} else {
		data.text = true;
	}
	$("#question_form").html(Mustache.render(html, data));
	callback();
	$(".ui.checkbox").checkbox();
	$(".ui.form").form(rules,{
		onSuccess: function () {
			var next = question.id + 1;
			if (question.next) {
				next = question.next;
			}
			$("#question_form").addClass("loading");
			if(question.type === "single") {
				var answer_id = $("input:checked").val();
				var answers = [
					{
						answer_id : answer_id
					}
				]
				var pos = getPos(answer_id, question.answers);
				if (question.answers[pos].next) {
					next = question.answers[pos].next;
				}
			} else if (question.type === "multiple") {
				var answers = [];
				$("input:checked").each(function (i, answer) {
					answers[i] = {
						answer_id : $(answer).val()
					}
				});
			} else {
				var answers = [{
					answer_id	: question._id,
					answer		: $("#answer").val()
				}];
			}
			
			$.ajax('/response',{
				data : {
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
				return $("input:checked").length > 0 || question.type === "text";
			}
		}
	});
}

function finish() {
	window.onbeforeunload = function () {};
	$.post('/token',{
		survey_id : $("#survey_id").val(),
		state : "finished"
	},function(data) {
		console.log(data)
		$("#question_form").load('/partials/question_finish.html', function () {
			$("#question_form").removeClass("loading");
		});
	})
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
	
	loadOneQuestion(question, total, callback);
}

function loadUI(callback) {
	$.get('/partials/question_single.html', function (html_data) {
		html = html_data;
		callback();
	});
}

$("#go").addClass("disabled");
$("#go").html("<i class='ui play icon'></i>加载UI..");
loadUI(function () {
	$("#go").html("<i class='ui play icon'></i>加载调查内容..");
	loadQuestions(function (data) {
		questions = data;
		$("#go").removeClass("disabled");
		$("#go").html("<i class='ui play icon'></i>开始");
		window.onbeforeunload = function()
		{
		    return "您还没有填完问卷，如果您现在离开您的选择都将不被保存，真的要离开吗？";
		}
	});
	taker_token = CryptoJS.SHA1(Date() + $("#survey_id").val() + Math.random().toString()).toString();
});


$("#go").click(function () {
	$("#question_form").addClass("loading");
	loadQuestion(1);	
})