$(document).ready(function () {
	$(".ui.form").form({
		email : {
			identifier : "email",
			rules : [
				{
					type : "email",
					prompt : "请输入合法的E-mail地址。"
				}
			]
		},
		pass : {
			identifier : "pass",
			rules : [
				{
					type : "empty",
					prompt : "密码不能为空"
				}
			]
		},
		repass : {
			identifier : "repass",
			rules : [
				{
					type : "match[pass]",
					prompt : "两次输入的密码需匹配。"
				}
			]
		}
	}, {
		onSuccess : function () {
			var user = $("#email").val(),
				pass = $("#pass").val();
			$.post('/signup', {
				user : user,
				pass : pass
			},function (data) {
				console.log(data);
				if (data.err === 0) {
					window.location.href = "/my";
				}
				else {
					$(".ui.form").form('add errors', [data.msg]);
				}
			});
		}
	})
})