/*$(document).ready(function () {
	$('#submit_button').click(function () {
		var title = $('#survey_title').toString(),
			email = $('#survey_email').toString(),
			pass = $('#survey_pass').toString();
		var data = {
			'title' : title,
			'email'	: email,
			'pass'	: pass
		};
		$.post('/survey', data, function(data) {
			$('#survey_form').removeClass('loading');
			if (data.) {
				
			}
		});
		$('#survey_form').addClass('loading');
		
	})
}*/

$('.ui.dropdown')
  .dropdown()
;

function submitForm() {
	var title = $('#survey_title').val(),
		email = $('#survey_email').val(),
		pass = $('#survey_pass').val();
	var data = {
		'title' : title,
		'email'	: email,
		'pass'	: pass
	};
	console.log(data);
	$.post('/survey/', data, function(resData) {
		$('#survey_form').removeClass('loading');
		if (resData.err === 0) {
			var survey_id = resData.id.toString();
			window.location.href= "/survey/" + survey_id + '/edit';
		}
	});
	$('#survey_form').addClass('loading');

	return true;
}

$('.ui.form').form({
	title: {
		identifier	: 'survey_title',
		rules: [
			{
				type	: 'empty',
				prompt	: '问卷名不能为空。'
			}
		]
	},
	email: {
		identifier	: 'survey_email',
		rules: [
			{
				type	: 'empty',
				prompt	: 'Email不能为空。'
			}
		]
	},
	password: {
		identifier	: 'survey_pass',
		rules: [
			{
				type	: 'empty',
				prompt	: '密码不能为空。'
			}
		]
	}
}, {
	onSuccess : submitForm
});




// $('.item').find("#test_button")

/*$('#add_question').click(function () {
	var form;
	$.get('/partials/question_form.html', {}, function(doc) {
		$("#question_list").append(doc);
		
		$('.item').find("#test_button").click(function () {
			$(this).parent().remove();
		})
		$('.ui.dropdown')
		  .dropdown()
		;
	})
	
	
	
})*/

