var html = "";
var perPage = 12;
var questions = [];
var chart = {};

function createChartData(data) {
	chart = {
		ref_question : data.ref_question,
		base_question : data.base_question
	}
	chart.base = []
	chart.ref = []
	chart.data = []
	for (var i = 0; i < data.search_results.length; i++) {
		a = data.search_results[i];
		base_answer = a.answer;
		chart.base.push(base_answer);
		for (var j = 0; j < a.ref_counts.length; j++) {
			ref = a.ref_counts[j];
			if (i == 0) {
				chart.ref.push({
					label: ref.answer
				});
				chart.data[j] = [];	
			}
			chart.data[j].push(ref.count);
		}
	}
	return chart;
}

function getSurvey(callback) {
	$.ajax('/survey/' + $("#survey_id").val() + '/', {
		dataType : 'json',
		type : 'GET'
	}).done(function(data) {
		questions = data.questions;
		for (var i = 0; i < questions.length; i++) {
			if(questions[i] === 'text') {
				questions[i].text = true;
 			}
		}
		callback();
	});
}

function showPage(page) {
	var start = perPage * (page - 1);
	var length  = questions.length;
	var total = Math.ceil(length / perPage)
	var data = {};
	data.questions = [];
	console.log(questions);
	console.log(data);
	for (var i = start; i < start + perPage && i < length; i++) {
		data.questions.push(questions[i]);
	}
	if (page === 1) {
		data.first_page = true;
	}
	if (page === total) {
		data.last_page = true;
	}
	data.page = page;
	data.total = total;
	console.log(data);
	var h = $.parseHTML(Mustache.render(html, data));
	$('#q_list').html(h);
	$('#next').click(function () {
		showPage(page + 1);
	});
	$('#prev').click(function () {
		showPage(page - 1);
	});
	$('#q_list').find('a#set_base').click(function () {
		$("#base_id").val($(this).data("value"));
	});
	$('#q_list').find('a#set_ref').click(function () {
		$("#ref_id").val($(this).data("value"));
	});
}

$(document).ready(function() {
	$.get('/partials/survey_analyze_list.html', function (h) {
		html = h;
		
		getSurvey(function () {
			showPage(1);
		})
	});
	$('#chart').bind('jqplotDataClick', 
		function (ev, seriesIndex, pointIndex, data) {
			var num = chart.data[seriesIndex][pointIndex];
			var total = 0;
			for (var i = 0; i < chart.data.length; i++) {
				total += chart.data[i][pointIndex];
			}
	    	$('#result').html('value: '+num.toString() + ', percent: ' + (num / total * 100).toFixed(2));
		}
	); 
	$('#swap_button').click(function() {
		var temp = $('#base_id').val();
		$('#base_id').val($('#ref_id').val());
		$('#ref_id').val(temp);
	})
})



$('.ui.form').form({
	base_id : {
		identifier : 'base_id',
		rules : [
			{
				type	: "empty",
				prompt	: "基础问题不能为空。"
			},
			{
				type	: "range_check",
				prompt	: "非法的问题编号。"
			}
		]
	},
	ref_id : {
		identifier : "ref_id",
		rules : [
			{
				type	: "empty",
				prompt	: "基础问题不能为空。"
			},
			{
				type	: "range_check",
				prompt	: "非法的问题编号。"
			}
		]
	}
}, {
	rules : {
		range_check : function (value) {
			console.log(value);
			return value > 0 && value <= questions.length;
		}
	},
	onSuccess : function () {
		$.ajax('/getrelans', {
			type : 'POST',
			dataType : 'json',
			data : {
				survey_id : $("#survey_id").val(),
				base_id : $("#base_id").val(),
				ref_id : $("#ref_id").val()
			}
		}).done(function (data) {
			$("#chart").html("");
			chart = createChartData(data.data)
			plot3 = $.jqplot('chart', chart.data, {
				stackSeries: true,
				series : chart.ref,
				seriesDefaults:{
			    	renderer:$.jqplot.BarRenderer,
					rendererOptions: {
						barMargin: 30
					},
					pointLabels: {show: true}
				},
			    axes: {
					xaxis: {
						ticks : chart.base, 
						renderer: $.jqplot.CategoryAxisRenderer
					},
			      	yaxis: {
						min : 0,
			        	padMin: 0
			      	}
			    },
			    legend: {
			    	show: true,
			      	location: 'e',
			      	placement: 'outside'
			    }      
			});
		})
		
	}
})