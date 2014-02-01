var html, html_for_textans;

function sortBy(a, b) {
	return a.id - b.id;
}

function genTextAns(question, page, first_time) {
	$.ajax('/gettextans',{
		type : 'GET',
		data : {
			id		: question._id,
			page	: page
		}
	}).done(function (data) {
		// console.log(page);
		// console.log(data);
		data._id = question._id;
		data.id = question.id;
		data.question = question.question;
		if (data.page === 1 || data.total === 0) {
			data.first_page = true;
		}
		if (data.page === data.total || data.total === 0) {
			data.last_page = true;
		}
		var h = $.parseHTML(Mustache.render(html_for_textans, data));
		if(first_time) {
			$("#stats_list").append(h);
		}
		else {
			$("#" + question._id).html(h);
		}
		var node = $("#" + question._id);
		node.find("#next").click(function () {
			genTextAns(question, page + 1, false);
		});
		node.find("#prev").click(function () {
			genTextAns(question, page - 1, false);
		});
		
	})
}

function getStats(callback) {
	$("#stats_list").html("");
	$("#loader").addClass("active");
	$.ajax('/getanswer', {
		type : 'GET',
		data : {
			id	: $("#survey_id").val()
		}
	}).done(function (data){
		$("#loader").removeClass("active");
		if(data.err) {
			alert("加载失败");
			return;
		}
		else {
			var questions = data.data;
			questions.sort(sortBy);
			for (var i = 0; i < questions.length; i++) {
				var question = questions[i];
				if(question.type !== 'text') {
					for (var j = 0; j < question.answers.length; j++) {
						question.answers[j].percent = (question.answers[j].value / question.answer_count * 100).toFixed(2).toString();
					}
					var h = $.parseHTML(Mustache.render(html, question));
					for (var j = 0; j < question.answers.length; j++) {
						$(h).find("#" + question.answers[j].id +".bar").css("width", (question.answers[j].percent*0.75).toString() + '%');
					}
					$("#stats_list").append(h);
				}
				else {
					genTextAns(question, 1, true);
					
				}
			}
		}
	});
}

$(document).ready(function () {
	$.get('/partials/question_stat.html', function (h) {
		html = h;
		$.get('/partials/question_tans.html', function (h) {
			html_for_textans = h;
			getStats();
		})
	});
	$("#trim_action").click(function () {
		$.post('/trim', {
			survey_id : $("#survey_id").val()
		}, function (data) {
			if (data.err === 0) {
				alert(data.msg);
				getStats();
			}
			else {
				alert("执行失败");
				// console.log(data.msg);
			}
		});
	});
});