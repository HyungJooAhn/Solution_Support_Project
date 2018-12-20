<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<c:set var="reqLocLang" value="${empty pageContext.request.locale.language ? 'en' : pageContext.request.locale.language}" /> 
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Intelligence Center</title>
<link rel="shortcut icon" type="image/x-icon" href="<c:url value="/resources/images/favicon-32.ico" />" sizes="32x32">
<link rel="stylesheet" type="text/css" href="<c:url value="/resources/themes/smoothness/jquery-ui/jquery-ui.css" />" />


<link rel="stylesheet" type="text/css" href="<c:url value="/resources/themes/smoothness/style.css" />" />

<script type="text/javascript" src = "<c:url value="/resources/js/jquery-1.10.2.js" />"></script>
<script type="text/javascript" src = "<c:url value="/resources/js/jq_plugin/jquery.cookie.js" />"></script>
<script type="text/javascript" src = "<c:url value="/resources/js/ui/jquery-ui.min.js" />"></script>
<script type="text/javascript" src = "<c:url value="/resources/js/sl.global.js" />"></script>
<script type="text/javascript" src = "<c:url value="/resources/js/i18n/sl.messages-${reqLocLang}.js" />"></script>
<script type="text/javascript" src = "<c:url value="/resources/js/i18n/sl.resources-${reqLocLang}.js" />"></script>
<script type="text/javascript" src = "<c:url value="/resources/js/sl.util.js" />"></script>
<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript" src = "<c:url value="/resources/js/jquery.nanoscroller.min.js" />"></script>
<script type="text/javascript" src = "<c:url value="/resources/js/sl.ui.js" />"></script>
<script type="text/javascript" src = "<c:url value="/resources/js/common.ui.js" />"></script>

<style type="text/css">

body {
	font-family: "돋움", dotum, AppleGothic , "나눔고딕" ;
	font-size: 12px;
	color:#333333;
	line-height:18px;
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
	overflow:hidden;
}

A:link {color:#333333;text-decoration:none;}
A:visited {color:#333333;text-decoration:none;}
A:active {color:#333333;text-decoration:none;}
A:hover {color:#333333;text-decoration:underline;}

img,fieldset{border:0}  
#login_bg {
	background-image:url(<c:url value="/resources/images/login/IC_LOGIN_BG_DN.png" />);
	background-repeat:no-repeat;
	background-size:cover;
}

.login_box {
	position:absolute;
	top:10%;
	left:37%;
	height:435px;
	text-align:center;
	background-color: rgba(1,1,1,0.8);
	border: 2px solid #191919;
	width: 480px;
}

#login_title {
	width: 348px;
	height:88px;
	margin-left:19%;
	margin-top:12%;
	background-image:url(<c:url value="/resources/images/login/IC_LOGO_DN.png" /> );
	background-repeat:no-repeat;
	background-size:75%;
}

#login_tab_area {
	height:45px;
}
#login_tab{
	font-family:Noto Sans CJK KR;
	font-size:17px;
	font-weight:300;
	margin-left:19%;
}

#login_sel{
	font-weight:bold;
	color:#c8c8c8;
	float:left;
	cursor:pointer;
	font-weight:bold
}

#register_sel{
	color:#8c8787;
	font-weight:normal;
	float:left;
	margin-left:18px;
	cursor:pointer
}

.col_label{
	font-family:Noto Sans CJK KR;
	font-size:11px;
	height:30px;
	color:#c8c8c8;
	text-align:left;
	margin-left:20%;
	padding-top:1%;
}

.input_area{
	height:35px;
	width:240px;
}

.input_form_log{
	height:80%;
	width:100%;
	margin-left:32%;
	border:1px solid #665d5d;
	background-color:rgba(1,1,1,0);
	color:#c8c8c8;
	font-family:Noto Sans CJK KR;
	font-size:11px;
}

.login_save{
	font-family:Noto Sans CJK KR;
	font-size:11px;
	height:45px;
	color:#c8c8c8;
	text-align:left;
	margin-left:19%;
	padding-top:2%;
}

.login_btn{
	width:322px;
	height:30px;
	background-color:#2C726D;
	font-family:Noto Sans CJK KR;
	font-weight:bold;
	color:#E1E1E1;
	margin-left:18%;
}

.login_btn:hover{
	background-color:#1d3735;
}

.L_table{
	font-family:Noto Sans CJK KR;
	font-size:13px;
	color:#c8c8c8;
	text-align:left;
	margin-left:19%;
}

.L_table tr{
	height:50px;
}

.L_table th{
	width:100px;
}

.L_table td{
	
}

.register_table_input{
	height:30px;
	width:200px;
	margin-left:10%;
	border:1px solid #665d5d;
	background-color:rgba(1,1,1,0);
	color:#c8c8c8;
	font-family:Noto Sans CJK KR;
	font-size:14px;
}

.register_btn{
	width:322px;
	height:30px;
	background-color:#2C726D;
	font-family:Noto Sans CJK KR;
	font-weight:bold;
	color:#E1E1E1;
	margin-top:3.5%;
	margin-left:18%;
}

.register_table_select{
	height:28px;
	width:200px;
	margin-top:3%;
	margin-left:10%;
	border:1px solid #665d5d;
	background-color:rgba(1,1,1,0);
	color:#8a8181;
	font-family:Noto Sans CJK KR;
	font-size:11px;
}

.warning_text{
	margin-left:10%;
	width:201px;
	font-family:Noto Sans CJK KR;
	color:red;
	font-size:7pt
}

.ok_text{
	margin-left:10%;
	width:201px;
	font-family:Noto Sans CJK KR;
	color:blue;
	font-size:7pt
}


input[id="check_save"] {
	position: relative;
	top: 2px;
}

</style>
<script language="javascript">
var  regForm; 

$().ready(function(){
	$("#login_bg").css("height", window.innerHeight + "px");
	$("#login_bg").css("width", window.innerWidth + "px");	
	
	//$("#register-btn-save").on("click", onSaveID);
	
	buttonInit();
});


window.onresize = function(event) {
	$("#login_bg").css("height", window.innerHeight + "px");
	$("#login_bg").css("width", window.innerWidth + "px");
};

function viewDetail(url){
	var modal = new ModalPopup(url, {
		width:400, height:210,		//모달 사이즈 옵션으로 조절 가능
		//draggable : true,				// draggable 선택 가능(기본 값 : false)
		onClose : function(){
			refresh();
		}
	});
}

function goSignUpPage(){
	location = "<c:url value='/interface/sign-up_page.html' />"
}
	
function checkForm() {
	if (!_SL.validate("#login_form")) return;
	
	if($("#check_save:checked").size()) {
		$.cookie('saveUserId', $("#login_form").find("#userId").val(), {expires:30});
	}
	else {
		$.cookie('saveUserId', "");
	}

	doLogin(false);
}

function doLogin(bForceLogin) {
	$.ajax({
		type : "POST",
		url : "<c:url value="/login.do" />",
		use_alert : true,
		data : $("form").serialize() + "&forceLogin=" + (bForceLogin?"Y":"N"),
		dataType : "json"
	})
	.done(function(rsJson) {
		var strUrl;
		
		if(!!rsJson.RESULT_CODE) {
			switch(rsJson.RESULT_CODE) {
			case "INF.MSG.LOG0001" :
				/////////로그인시 첫화면 경로설정rsJson.loginOpt
				strUrl = $.cookie("saveUserId")
				if(rsJson.loginOpt != null && rsJson.loginOpt != "" && rsJson.loginOpt != undefined){
					strUrl = "<c:url value='"+rsJson.loginUrl+"' />?filter_type=" + rsJson.loginOpt;  //로그검색-loginOpt:기본0||상세1||전문2						
				}else if(rsJson.loginUrl != null && rsJson.loginUrl != "" && rsJson.loginUrl != undefined){
					strUrl = "<c:url value='"+rsJson.loginUrl+"' />";  //로그인시 첫화면 설정
				}else {
					strUrl = "<c:url value="/" />";
				}
				
				//공지사항 여부 설정
				if(rsJson.popupNotice) {
					strUrl += (strUrl.indexOf("?") == -1 ? "?" : "&") + "popupNotice=Y";
				}
				location.href = strUrl;
				break;
				////////
			case "INF.MSG.LOG0010" :
				if(confirm(rsJson.RESULT_MSG)) {
					doLogin(true);
				}
				break;
			default :
				alert(rsJson.RESULT_MSG);
				break;
			}
		}
	})
}



var secuCode = "";

function onSaveID() {
	var dept_cd = $("#dept_nm").val();
	
	if (!_SL.validate($("#register_form")))return;

	var submit = function() {
		$('body').requestData("<c:url value='/interface/sign-up_insert.do' />",
				_SL.serializeMap($("#register_form")), {
					callback : function(rsData, rsCd, rsMsg) {
						_alert(rsMsg, {
							onAgree : function() {
								location = "<c:url value='/login.do' />"
							}
						});
					}
				});
	}
	if(secuCode == $("[name=sign_auth_cd]").val()){
		if(dept_cd != "none"){
			submit();	
		}else{
			_alert("부서를 선택하세요.", {onAgree : function() {}});
		}
	}else{
		submit();
	}
	
}

var errImgSrc = "<c:url value='/resources/images/IC_S_ERR.png' />";
var oriImgSrc = "<c:url value='/resources/images/IC_S_OK_Normal.png' />";
var overImgNorSrc = "this.src='<c:url value='/resources/images/IC_S_OK_Over.png' />'";
var outImgNorSrc = "this.src='<c:url value='/resources/images/IC_S_OK_Normal.png' />'";
	
function buttonInit(){
	$("#register-btn-save").css("background-color", "#2C726D")
	$("#bt_IC_S_OK").attr("onmouseover", overImgNorSrc);
	$("#bt_IC_S_OK").attr("onmouseout", outImgNorSrc);
	document.getElementById("register-btn-save").disabled = false;
}

function buttonErr(){
	$("#register-btn-save").css("background-color", "#7b7d7d")
	document.getElementById("register-btn-save").disabled = true;
}

function InitIDForm(){
	buttonInit();
	$("#id_warning_text").remove();
}

function IDCheckEvent(){
	var sign_id = $("[name=sign_id]");
	var chk_01 = false;
	var chk_02 = false;
	
	function minLenChk(elem, val) {
		if($(elem).val().length < val) {
			buttonErr();
			$("#sign_id_td").append("<div id='id_warning_text' class='warning_text'>아이디의 길이는 최소 3글자 이상이여야 합니다.</div>")
		}else{
			chk_01 = true;
		}
	}
	minLenChk(sign_id, 3);
	
	function alphanumChk(elem) {
		if (/\W/.test($(elem).val())) {
			buttonErr();
			$("#sign_id_td").append("<div id='id_warning_text' class='warning_text'>아이디는 영문자, 숫자, 밑줄만 입력할 수 있습니다.</div>")
		}else{
			chk_02=true;
		}
	}
	if(chk_01){
		alphanumChk(sign_id);
	}
	
	if(chk_02){
		$.ajax({
			type : "POST",
			url : "/interface/sign-up_id_check.json",
			contentType : "application/json",
			data : JSON.stringify({sign_id:sign_id.val()}),
			dataType : "json",
			success : function(rsJson) {
				var chk = rsJson.data;
				if(!chk){
					buttonErr();
					$("#sign_id_td").append("<div id='id_warning_text' class='warning_text'>아이디가 중복 됩니다.</div>")
				}else{
					if($("[name=sign_pw]").val().length != 0){
						PWCheckEvent();
					}
				}
			}
		});
	}
}

function InitNameForm(){
	buttonInit();
	$("#name_warning_text").remove();
}

function NameCheckEvent(){
	var sign_nm = $("[name=sign_nm]");
	
	function nameValidChk(elem){
		if(elem.val().length == 0){
			buttonErr();
			$("#sign_nm_td").append("<div id='name_warning_text' class='warning_text'>이름을 입력하세요.</div>")
		}else if (!/^[ㄱ-ㅎ|가-힣|a-z|A-Z|_|\*]+$/.test(elem.val())) {
			buttonErr();
			$("#sign_nm_td").append("<div id='name_warning_text' class='warning_text'>한글,영문자 또는 밑줄만 입력하세요.</div>")
		}	
	}
	
	nameValidChk(sign_nm);
}

var pwMessageLength = 0;

function InitPWForm(){
	buttonInit();
	$("#pw_warning_text").remove();
}
function PWCheckEvent(){
	InitPWForm()
	pwMessageLength = 0;
	var sign_pw = $("[name=sign_pw]")
	function pwChk (elem) {
		if (elem.val() == "") return;
		var userId = "";
		this.message = ""
		
		if($("[name=sign_id]").val() == ""){
			InitIDForm();
			pwMessageLength = -1;
			buttonErr();
			$("#sign_id_td").append("<div id='id_warning_text' class='warning_text'>아이디를 먼저 입력하세요.</div>")
		}else{
			userId = $("[name=sign_id]").val();
			var passwd = elem.val();
			var typeCnt = 0;
			
			if (/[가-힣]/.test(passwd)) {
				this.message = "비밀번호는 한글을 입력할 수 없습니다.";
			} else if (passwd.length < 9 || passwd.length > 15) {
				this.message = "비밀번호는 9자 ~ 15자 이내로 입력하세요.";
			} else if (passwd == userId) {
				this.message = "아이디와 비밀번호는 같을 수 없습니다.";
			} else {
				if(/[A-Z]/.test(passwd)) typeCnt++;
				if(/[a-z]/.test(passwd)) typeCnt++;
				if(/[\d]/.test(passwd)) typeCnt++;
				if(/[^A-Za-z0-9]/.test(passwd)) typeCnt++;

				if(typeCnt < 3) {
					this.message = "영문 대문자/영문 소문자/숫자/특수문자 중 3가지 이상의 문자 조합으로 입력하세요.";
				}
			}
			
			if(this.message.length != 0){
				pwMessageLength = this.message.length;
				buttonErr();
				$("#sign_pw_td").append("<div id='pw_warning_text' class='warning_text'>" + this.message + "</div>")	
			}
		}
	}
	pwChk(sign_pw)
}


function InitPWReForm(){
	if(pwMessageLength == 0){
		buttonInit();
		$("#pw_chk_warning_text").remove();
	}
}
function PWReCheckEvent(){
	var sign_pw = $("[name=sign_pw]").val();
	var sign_pw_chk = $("[name=sign_pw_chk]").val();
	if(pwMessageLength == 0){
		if(sign_pw != sign_pw_chk){
			buttonErr();
			$("#sign_pw_chk_td").append("<div id='pw_chk_warning_text' class='warning_text'>비밀번호가 일치하지 않습니다.</div>")
		}
	}
}

var authChk = true;

function InitAuthForm(){
	buttonInit();
	$("#auth_warning_text").remove();
}

function FinishAuthForm(){
	
	if(authChk){
		buttonInit();
		$("#auth_warning_text").remove();	
	}else{
		buttonErr();
	}
}

function AuthCheckEvent(){
	InitAuthForm();
	
	var sign_auth_cd = $("[name=sign_auth_cd]");
	var chk_01 = false;
	var chk_02 = false;

	
	function minLenChk(elem, val) {
		if($(elem).val().length < val) {
			buttonErr();
			$("#sign_auth_cd_td").append("<div id='auth_warning_text' class='warning_text'>인증코드를 입력하세요.</div>")
		}else{
			chk_01 = true;
		}
	}
	minLenChk(sign_auth_cd, 1);
	
	function alphanumChk(elem) {
		if (/\W/.test($(elem).val())) {
			buttonErr();
			$("#sign_auth_cd_td").append("<div id='auth_warning_text' class='warning_text'>아이디는 영문자, 숫자, 밑줄만 입력할 수 있습니다.</div>")
		}else{
			chk_02 = true;
		}
	}
	if(chk_01){
		alphanumChk(sign_auth_cd);
	}
	
	if(chk_02){
		$.ajax({
			type : "POST",
			url : "/interface/sign-up_auth_check.json",
			contentType : "application/json",
			data : JSON.stringify({sign_auth_cd:sign_auth_cd.val()}),
			dataType : "json",
			async : false,
			success : function(rsJson) {
				var chk = rsJson.data;
				if(!chk){
					buttonErr();
					$("#sign_auth_cd_td").append("<div id='auth_warning_text' class='warning_text'>인증코드가 일치하지 않습니다.</div>")
					authChk = false;
					$("#dept_tr").css("display", "none");
				}else{
					$("#sign_auth_cd_td").append("<div id='auth_warning_text' class='ok_text'>인증코드가 일치합니다.</div>")
					authChk = true;
					
					$.ajax({
						type : "POST",
						url : "/interface/get_secu_code.json",
						contentType : "application/json",
						data : JSON.stringify({ALL:true}),
						dataType : "json",
						async : false,
						success : function(rsJson) {
							secuCode = rsJson.data;
							
							if(sign_auth_cd.val() == secuCode){
								//$("#dept_tr").css("display", "contents");
								$("#dept_tr").removeAttr("style");
							}else{
								$("#dept_tr").css("display", "none");
							}
						}
					});
				}
			}
		});
	}
}

function goLoginForm(){
	$("#login_t").show();
	$("#register_t").hide();
	
	$("#login_sel").css("font-weight", "bold");
	$("#register_sel").css("font-weight", "normal");
	
	$("#login_sel").css("color", "#c8c8c8");
	$("#register_sel").css("color", "#8c8787");
	
	$(".login_box").css("height", "435px");
	
}

function goRegisterForm(){
	$("#login_t").hide();
	$("#register_t").show();
	
	$("#login_sel").css("font-weight", "normal");
	$("#register_sel").css("font-weight", "bold");
	
	$("#login_sel").css("color", "#8c8787");
	$("#register_sel").css("color", "#c8c8c8");
	
	$(".login_box").css("height", "650px");
}
$(function(){
	if(!($.cookie('saveUserId') == "")){
		$("#userId").val($.cookie('saveUserId'));
		$("#userPswd").val("");
	}else{
		$("#userId").val("");
		$("#userPswd").val("");
	}
});
</script>
</head>

<body>
<div id="login_bg">
	<div class="login_box">
		<div id="login_title"></div>
	
		<div id="login_tab_area">
			<ul id="login_tab">
				<li id="login_sel" onClick="goLoginForm()">Log In</li>
				<li id="register_sel" onClick="goRegisterForm()">Register</li>
			</ul>
		</div>
		<form name="formLogin" id="login_form" method="post" autocomplete="off">
			<div id="login_t">
				
				<table class="L_table">
					<tr>
						<th scope="row"><span class="mark-required">ID *</span></th>
						<td><input type="text" name="userId" id="userId" class="register_table_input" value="${param.userId != null ? fn:escapeXml(param.userId) : ''}" slValid="ID,required" onKeyDown="if(event.keyCode==13) { checkForm(); }" /></td>
					</tr>
					<tr>
						<th scope="row"><span class="mark-required">PW *</span></th>
						<td><input type="password" name="userPswd" id="userPswd" class="register_table_input" value="<c:out value="${param.userPswd}" />" slValid="Password,required" onKeyDown="if(event.keyCode==13) { checkForm(); }" maxlength="15" /></td>
					</tr>
				</table>
		        <div class="login_save"><input type="checkbox" name="check_save" id="check_save"${cookie.saveUserId.value != null ? " checked" : ""}/> Save Id</div>
		        
		        <div class="login_btn"><button style="width:100%;height:100%;" type="button" onclick="javascript:checkForm()">LOG IN</button></div>
			</div>
		</form>
		<form name="formRegister" id="register_form" method="post" autocomplete="off">
			<div id="register_t" style="display:none;">
				<table class="L_table">
					<tr>
						<th scope="row"><span class="mark-required">ID *</span></th>
						<td id="sign_id_td"><input onfocus="InitIDForm()" onblur="IDCheckEvent();"  id="sign_id_td" type="text" name="sign_id" class="register_table_input" maxlength="100"	data-valid="ID,required,minLen=3,alphanum"></td>
					</tr>
					<tr>
						<th scope="row"><span class="mark-required">NAME *</span></th>
						<td id="sign_nm_td"><input onfocus="InitNameForm()" onblur="NameCheckEvent();" type="text" name="sign_nm" class="register_table_input" maxlength="20"	data-valid="NAME,required,name"></td>
					</tr>
					<tr>
						<th scope="row"><span class="mark-required">PW *</span></th>
						<td id="sign_pw_td"><input placeholder=" 9 ~ 15자" onfocus="InitPWForm()" onblur="PWCheckEvent();" type="password" name="sign_pw" class="register_table_input" maxlength="15" data-valid="PW,required,password"></td>
					</tr>
					<tr>
						<th scope="row"><span class="mark-required">PW COMFIRM *</span></th>
						<td id="sign_pw_chk_td"><input onfocus="InitPWReForm()" onblur="PWReCheckEvent();" type="password" name="sign_pw_chk" class="register_table_input" maxlength="15" data-valid="PW CONFIRM,required,password"></td>
					</tr>
					<tr>
						<th scope="row"><span class="mark-required">E-MAIL *</span></th>
						<td><input type="text" name="sign_email" class="register_table_input" data-valid="E-MAIL,required,email"></td>
					</tr>
					<tr>
						<th scope="row"><span class="mark-required">전화번호 *</span></th>
						<td><input type="text" name="sign_call" class="register_table_input" data-valid="전화번호,required,phone"></td>
					</tr>
					<tr>
						<th scope="row"><span class="mark-required">인증코드 *</span></th>
						<td id="sign_auth_cd_td">
							<input onfocus="InitAuthForm()" onblur="FinishAuthForm()" onInput="AuthCheckEvent();" type="text" name="sign_auth_cd" class="register_table_input" maxlength="5" data-valid="인증코드,required,alphanum">
						</td>
					</tr>
					<tr id="dept_tr" style="display:none;">
						<th scope="row"><span class="mark-required">부서 *</span></th>
						<td>
							<select class="register_table_select" name="dept_cd" id="dept_nm">
								<option value="none">[선택하세요]</option>
								<option value="3">기술연구본부</option>
								<option value="4">솔루션사업본부</option>
								<option value="5">영업본부</option>
								<option value="6">경영지원본부</option>
							</select>
						</td>
					</tr>
				</table>
				<div class="register_btn"><button style="width:100%;height:100%;" id="register-btn-save" type="button" onclick="javascript:onSaveID()">REGISTER</button></div>
			</div>
		</form>
		<div style="text-align:center;margin-left:11px;margin-top:24px;color:#c7c7c7"><span>※ 본 사이트는 구글 크롬에 최적화 되어있습니다.</span></div>
	</div>
	<div id="license_dlg" class="license-dlg" title="License Warning" style="display:none">
		<div style="width:300px;padding:15px 5px 5px 10px;line-height:initial;"></div>
	</div>
</div>
</body>
</html>
