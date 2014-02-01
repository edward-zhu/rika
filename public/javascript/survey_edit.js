

function sortBy(a, b) {
	return a.id - b.id;
}

function modifyOrder() {
	var questions = $("tbody").find("tr").find("#q_name");
	var ids = [];
	if (questions.length === 0) return;
	for (var i = questions.length - 1; i >= 0; i--) {
		ids[i] = $(questions[i]).data("value");
	}
	var post_data = {
		modify_type	: 'order',
		questions : ids
	}
	$.ajax('/survey/' + $("#survey_id").val() + '/', {
		type	: 'PUT',
		data	: post_data
	}).done(function (data) {
		//console.log(data);
	});
}

function getQuestions() {
	var survey_id = $("#survey_id").val();
	var alphabet = "ABCDEFGHIJ"
	$.get('/partials/question_table.html', {}, function (html) {
		$.ajax('/survey/' + survey_id + '/', {
			dataType : 'json'
		}).done(function (data) {
			for (var i = 0; i < data.questions.length; i++) {
				var question = data.questions[i];
				if (question["type"] !== "text") {
					for (var j = 0; j < question.answers.length; j++) {
						console.log(question.answers[j].answer);
						question.answers[j].answer = alphabet[j] + "." + question.answers[j].answer;
					}
				}
				question["type"] = getTypeName(question["type"]);
				data.questions.sort(sortBy);
			}
			$("#question_table").html(Mustache.render(html, data));
			$('.sortable').sortable({
				items: 'tr'
			});
			$("#question_table tr").find("#delete").click(function () {
				question_id = $(this).data("value");
				survey_id = $("#survey_id").val();
				row = $(this).parents("tr");
				$.ajax('/question/', {
					type : 'DELETE',
					data : {
						question_id : question_id,
						survey_id	: survey_id
					}
				}).done(function (data){
					// console.log(data);
					row.remove();
					modifyOrder();
				})
			});
		});
	});
}

$(document).ready(function () {
	getQuestions();
	$("#copy").zclip({
		path: '/javascript/ZeroClipboard.swf',
		copy: $("#survey-url").val()
	});
})


$('.ui.dropdown').dropdown({
	onChange : function(value, text) {
		var input = $("#question_answer").parent()
		if (value === 'text') {
			input.hide();
		}
		else {
			input.show();
		}
	}
});

$('.ui.form').form({
	question_name: {
		identifier: 'question_name',
		rules: [
			{
				type	: 'empty',
				prompt	: '问题名不能为空。'
			}
		]
	},
	question_answers: {
		identifier: 'question_answer',
		rules: [
			{
				type	: 'type_check',
				prompt	: '非文本问题的答案列表不能为空。'
			},
			{
				type	: 'array_check',
				prompt	: '至少需要两个选项，且不能多于10个选项。'
			}
		]
	}
}, {
	rules : {
		type_check : function (value) {
			return !($(":input[name='question_type']").val() !== 'text' && (value === undefined || value === ''));
		},
		array_check : function (value) {
			return (
				value !== undefined && 
				value !== '' 
				&& value.split(' ').length >= 2
				&& value.split(' ').length <= 10
			) || 
			$(":input[name='question_type']").val() === 'text';
		}
	},
	onSuccess: function () {
		var type = $(":input[name='question_type']").val();
		if (type === undefined || type === '') {
			type = "single";
		}
		var post_data = {
			survey_id			: $("#survey_id").val(),
			question_name		: $("#question_name").val(),
			question_type		: type,
			question_answers	: $("#question_answer").val()
		}
		$.post('/question/', post_data, function (data) {
			$(".ui.form").removeClass("loading");
			getQuestions();
		})
		$(".ui.form").addClass("loading");
		return true;
	}
	
});



$("#changeOrder").click(function () {
	modifyOrder();
	getQuestions();
});

