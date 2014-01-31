$(document).ready(function () {
	$(".ui.form").form({
		email : {
			identifier : "email",
			rules : [
				{
					type	: "email",
					prompt	: "请输入有效地E-mail地址"
				},
				{
					type 	: "empty",
					prompt	: "请输入邮箱地址"
				}
			]
		},
		pass : {
			identifier : "pass",
			rules : [
				{
					type	: "empty",
					prompt	: "请输入密码。"
				}
			]
		}
	}, {
		onSuccess : function () {
			$(".ui.form").addClass("loading");
			$.post('/login', {
				email	: $("#email").val(),
				pass	: $("#pass").val()
			}, function (data) {
				$(".ui.form").removeClass("loading");
				if (data.err === 1) {
					$("#msg").show();
					$("#msg").html(data.msg);
				}
				else {
					window.location.href = '/my'
				}
			});
		}
	});
});