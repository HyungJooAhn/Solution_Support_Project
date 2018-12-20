<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<link rel="stylesheet" type="text/css" href="<c:url value="/resources/js/jq_plugin/chosen/chosen.css" />" />
<script type="text/javascript" src="<c:url value="/resources/js/jq_plugin/chosen/chosen.jquery.js" />"></script>
<script type="text/javascript">

function drawCustomerCodeTable(id){
	//$("#customer_info_area").empty();
	
	$("#select_cust_message").remove();
	$("#div_line").remove();
	$("#customer_info_table_area").remove();
	$("#selected_customer_name").remove();
	
	$("#customer_info_area").prepend("<div id='customer_info_table_area' class='customer_info_area'></div>"
			+ "<div id='div_line'></div>");
	
	$.ajax({
		type : "POST",
		url : "/customer/customer_code_list.json",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({cust_id:id}),
		dataType : "json",
		success : function(rsJson) {
			var data = rsJson.data;
			var size = data.length;
			
			$("[name=customer_type]").val(data[0]["flag2"]);
			$("[name=customer_name]").val(data[0]["code_name"]);
			$("#customer_info_area").prepend("<div id='selected_customer_name'><span>" + data[0]["code_name"] + "</span></div>")
			
			if(!('cust_cd' in data[0])){
				$("#customer_info_table_area").append("<div class='info_message'><span>생성된 코드가 없습니다.</span></div>")
			}else{
				$("#customer_info_table_area").append("<table id='customer_code_table' class='tbl_type'><tr><th>No.</th><th>코드</th><th>사용가능</th></tr>")
				for(var i=0; i<size; i++){
					$("#customer_code_table").append("<tr><td>" + (i+1) + "</td><td>" + data[i]["cust_cd"] + "</td><td>" + data[i]["cust_used"] + "</td></tr>");
				}
				$("#customer_info_table_area").append("</table>");
			}
		}
	});	
}

function initCustomer() {
	var paramInfo = {};

	$.ajax({
		type : "POST",
		url : "<c:url value="/issue/select_customer_all.json" />",
		contentType : "application/json",
		data : JSON.stringify(paramInfo),
		dataType : "json",
		success : function(rsJson, textStatus, jqXHR){
			var customerInfo = rsJson.customerInfo;
			for(var i in customerInfo) {
				var id = customerInfo[i].code_id;
				var val = customerInfo[i].code_name;
				
				$('#customer_cd_info').append($('<option>', { value: id, text : val }));
				if(custCode == id) $("[name=customer_cd_info]").val(id).trigger("chosen:updated");
			}
			
			$('#customer_cd_info').trigger("chosen:updated");
		}
	})
	.fail(function(jqXHR, textStatus) {
		alert("적용중 에러가 발생했습니다.(" + textStatus + ")\n다시 시도해 보세요.");
	});
}
function upCustomerCnt(){
	$("#customer_cnt_val").show();
	$("#customer_cnt_val").removeClass("direct")
	$("#customer_cnt_val_input").remove();
	
	var nowCnt = $("[name=customer_cnt_value").val();
	$("[name=customer_cnt_value").val(Number(nowCnt) + 1)
	
	$("#customer_cnt_val").text($("[name=customer_cnt_value").val());
}

function downCustomerCnt(){
	$("#customer_cnt_val").show();
	$("#customer_cnt_val").removeClass("direct")
	$("#customer_cnt_val_input").remove();
	
	var nowCnt = $("[name=customer_cnt_value").val();
	if(Number(nowCnt) > 0){
		$("[name=customer_cnt_value").val(Number(nowCnt) - 1)	
	} 
	$("#customer_cnt_val").text($("[name=customer_cnt_value").val());
	
}

function inputPop(){
	$("#customer_cnt_val").hide();
	$("#customer_cnt_val").addClass("direct")
	$("#customer_cnt_val_input").remove();
	$("#customer_cnt_val_area").append("<input id='customer_cnt_val_input' onKeyDown='checkKeysInt(event,\"\");' onKeyUp='checkKeysInt(event,\"\");' type='text' class='form-input' maxlength='3'>")
	
}

function generateCustCode(){
	var cnt;
	if($("#customer_cnt_val").hasClass("direct")){
		if($("#customer_cnt_val_input").val() == ""){
			_alert("개수를 입력하세요.");
			return;
		}else{
			cnt = Number($("#customer_cnt_val_input").val());	
		}
	}else{
		cnt = Number($("#customer_cnt_val").text());
	}
	
	var customerId = $("#customer_cd_info").val();
	var customerName = $("[name=customer_name]").val();
	var customerType = $("[name=customer_type]").val();
	
	if(cnt != 0){
		$.ajax({
			type : "POST",
			url : "/customer/customer_ran_code_insert_permission.do",
			contentType : "application/json",
			async: false,
			data : JSON.stringify({}),
			dataType : "json",
			success : function(rsJson) {
				var permission = rsJson.data;
				if(permission){
					_confirm("생성 하시겠습니까?",{ 
						onAgree : function(){
							$.ajax({
								type : "POST",
								url : "/customer/customer_ran_code_insert.do",
								contentType : "application/json",
								async: false,
								data : JSON.stringify({cust_id:customerId, cust_name:customerName, cust_cd_cnt:cnt, cust_type:customerType}),
								dataType : "json",
								success : function(rsJson) {
									var result = rsJson.data;
									if(result != -1){
										$("[name=customer_cnt_value]").val(0);
										$("#customer_cnt_val").text("0");
										drawCustomerCodeTable(customerId);
									}
								}
							});	
						}
					});
				}else{
					_alert("권한이 없습니다.");
				}
			}
		});	
	}
}

function checkKeysInt(e,event) {
	if(event.keyCode) {
		var code = event.keyCode;
		if ((code >= 48 && code <= 57) || (code >= 96 && code <= 105) || (code==8) || (code==9) || (code==46)) {
			return;
		} else {
			e.returnValue = false;
		}
	} else if (e.which) {
		var code = e.which;
		if ((code >= 48 && code <= 57) || (code >= 96 && code <= 105) || (code==8) || (code==9) || (code==46)) {
			return;
		} else {
			e.preventDefault();
		}
	}
}


$().ready(function() {
	initCustomer();
	$("#customer_code_generation_area").hide();
	$("#customer_cd_info").chosen({
		search_contains : true,
		width : "170px"
	});
	
	$("#contents").css("min-height", "610px");
	
	$("#customer_cd_info").on("change", function(){
		$("[name=customer_cnt_value]").val(0);
		$("#customer_cnt_val").text("0")
		$("#customer_code_generation_area").show();
		drawCustomerCodeTable($(this).val());
	})
})

</script>
<style>

.info_message{
	text-align:center;
	font-size:20pt;
	font-weight:bold;
    font-family:NanumGothic, sans-serif;
    color:gray;
    width:100%;
    margin-top:215px;
}

.customer_info_area{
	float:left;
	overflow: auto;
    height: 464px;
    margin-top:23px;
}

#customer_code_table{
    width: 92%;
    margin-left: 33px;
}

#customer_info_table_area{
	width:68%;
}

#customer_code_generation_area{
	width:31%;
}

#div_line{
	float:left;
	width:2px;
	height: 457px;
    margin-top: 25px;
    margin-left:10px;
    background: #b3b1b1;
	
}

#customer_code_generation_title{
	font-weight: bold;
    text-align: center;
    margin-top: 11px;
    color: #6d6b6b;
    font-size: 16pt;
    font-family:NanumGothic, sans-serif;
}

.customer_cnt_icon{
	width:31px;
	cursor:pointer;
}

#customer_cnt_icon_plus{
	height:30px;
	background-image:url(<c:url value="/resources/images/customer_cnt_plus_icon.png"/>);
	background-size: 31px;
}

#customer_cnt_icon_minus{
	height:31px;
	margin-top:-8px;
	background-image:url(<c:url value="/resources/images/customer_cnt_minus_icon.png"/>);
	background-size: 31px;
}

#customer_cnt_icon_plus:hover{
	background-image:url(<c:url value="/resources/images/customer_cnt_plus_icon_hover.png"/>);
}

#customer_cnt_icon_minus:hover{
	background-image:url(<c:url value="/resources/images/customer_cnt_minus_icon_hover.png"/>);
}

#customer_cnt_icon_submit{
	height:30px;
	background-image:url(<c:url value="/resources/images/customer_cnt_submit_icon.png"/>);
	background-size: 31px;
}
#customer_cnt_icon_submit:hover{
	background-image:url(<c:url value="/resources/images/customer_cnt_submit_icon_hover.png"/>);
}
#customer_cnt_val_area{
	float:left;
	text-align:center;
	font-weight: bold;
	margin-left: 141px;
    margin-top: 61px;
    font-size: 28pt;
    width:116px;
}

#customer_cnt_icon_area{
	float:left;
	margin-left: 4px;
    margin-top: 36px;
}

#customer_cnt_input_area{
	width:21%;
	float:left;
	font-family:NanumGothic, sans-serif;
	font-weight: bold;
	margin-left: 153px;
    margin-top: 15px;
    cursor:pointer;
}

#customer_cnt_input_area:hover{
	color:#888888;	
}

#customer_cnt_submit_area{
    float: left;
    width: 8%;
    margin-left: 262px;
    margin-top: 20px;
    font-family:NanumGothic, sans-serif;
	font-weight: bold;
}

#customer_cnt_generate_info{
	float:left;
	font-family:NanumGothic, sans-serif;
	font-weight: bold;
	margin-top:36px;
	margin-left:93px;
}

#customer_cnt_val_input{
    width: 111px;
    height: 50px;
    margin-top: -14px;
    margin-left:-8px;
}

#selected_customer_name{
	margin-top: 20px;
    font-size: 15pt;
    text-align: center;
    width: 68%;
    font-family:NanumGothic, sans-serif;
	font-weight: bold;
}
</style>
<form name="searchForm" id="customerCodeForm" action="<c:url value="/issue/customer_code_management.do" />">
	<input type="hidden" name="popup" value="${param.popup}">
	<input type="hidden" name="s_log_psr_id" value="${param.s_log_psr_id}"/>
	<input type="hidden" name="customer_cnt_value" value="0"/>
	<input type="hidden" name="customer_type" value=""/>
	<input type="hidden" name="customer_name" value=""/>
	<div class="sub_search" style="border:0px; margin-left:-15px;">
		<div class="sub_title03">고객사 코드</div>
	</div>
	<br>
	<div>
		<table class="table-group">
				<tr>
					<th scope="row"><span>고객사</span></th>
					<td>
						<select name="customer_cd_info" class="chosen-choices" id="customer_cd_info" >
						<option value="">[선택하세요]</option>
						</select>
					</td>
				</tr>
		</table>
	</div>
	<div id="customer_info_area">
		<div class="info_message" id="select_cust_message"><span>고객사를 선택하세요.</span></div>
		
		<div id='customer_code_generation_area' class='customer_info_area'>
			<div id="customer_code_generation_title"><span>코드 생성</span></div>
			<div>
				<div id="customer_cnt_val_area"><span id="customer_cnt_val">0</span></div>
				<div id="customer_cnt_icon_area">
					<div class="customer_cnt_icon" id="customer_cnt_icon_plus" onclick="javascript:upCustomerCnt()"></div>
					<br>
					<div class="customer_cnt_icon" id="customer_cnt_icon_minus" onclick="javascript:downCustomerCnt()"></div>
				</div>
				<div id="customer_cnt_input_area" onclick="javascript:inputPop()"><img style="margin-right:10px;width:19px;margin-bottom:1px;" src="<c:url value="/resources/images/customer_cnt_input_icon.png"/>"/>직접입력</div>
				<div id="customer_cnt_submit_area">
					<div class="customer_cnt_icon" id="customer_cnt_icon_submit" onclick="javascript:generateCustCode()"></div>
					<div style="margin-top:8px;margin-left:3px;">생성</div>
				</div>
				<div id="customer_cnt_generate_info">
					-&nbsp;&nbsp;필요한 코드 개수를 선택<br><br>
					-&nbsp;&nbsp;수량이 많은 경우 ‘ 직접입력 ’ 버튼을 사용<br><br>
					-&nbsp;&nbsp;선택한 고객사가 맞는지 확인<br><br>
					-&nbsp;&nbsp;생성 버튼 클릭(기존 코드 존재 시 추가됨)<br><br>
					-&nbsp;&nbsp;좌측 테이블에서 확인 가능<br><br>
					<span style="color:#48929a">※&nbsp;&nbsp;사용가능이 ‘ Y ’인 코드만 사용할 수 있음</span>
				</div>
			</div>
		</div>
	</div>
</form>
