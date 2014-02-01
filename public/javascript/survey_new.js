$('.ui.dropdown')
  .dropdown()
;

function submitForm() {
	var title = $('#survey_title').val();
	var data = {
		'title' : title,
	};
	// console.log(data);
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
	}
}, {
	onSuccess : submitForm
});


