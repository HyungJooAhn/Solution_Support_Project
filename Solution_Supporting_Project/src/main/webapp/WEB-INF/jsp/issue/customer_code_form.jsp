<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<link rel="stylesheet" type="text/css" href="<c:url value="/resources/js/jq_plugin/chosen/chosen.css" />" />
<script type="text/javascript" src="<c:url value="/resources/js/jq_plugin/chosen/chosen.jquery.js" />"></script>

<script type="text/javascript">
$().ready(function() {
	$(".modal-head").find("button").css("background","url(<c:url value='/resources/themes/smoothness/images/common/btn_pop_close.png'/>) no-repeat")
	$(".modal-head").find("button").css("background-position", "center")

	$('#customer_cd_info').off().on('change',function() {
		$("#customer_cd_td").remove();
		
		var selected = $("[name=customer_cd_info]").val();
		if(selected != ''){
		 	$.ajax({
				type : "POST",
				url : "<c:url value="/issue/select_customer_cd.json" />",
				contentType : "application/json",
				data : JSON.stringify({code_id:selected}),
				dataType : "json",
				success : function(rsJson, textStatus, jqXHR){
					var customerInfo = rsJson.customerInfo;
					var customerCode = customerInfo.customer_cd;
					$(".table-group").append("<tr id='customer_cd_td'><td id='customer_cd_td' scope='row' colspan='2''><span id='code_span'>" + customerCode + "</span></td></tr>");
					$("#customer_cd_td").css("height", "120px").css("text-align", "center");
					$("#code_span").css("font-family","맑은고딕").css("font-size", "20pt");
				}
			}) 
		}
	});
	
	$("#customer_cd_info").chosen({
		search_contains : true,
		width : "170px"
	});
	
	initCustomer();
});

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

</script>
<div class="section-content no-search-cols">
	<form name="formCustomerCd" id="formCustomerCd">
		<input type="hidden" name="slKey" value="${_slKey}">

		<table class="table-group">
			<tr>
				<th scope="row"><span class="mark-required">고객사명</span></th>
				<td>
					<select name="customer_cd_info" class="chosen-choices" id="customer_cd_info" >
					<option value="">[선택하세요]</option>
					</select>
				</td>
			</tr>

		</table>

		<div class="table-bottom">
			<button type="button" class="btn-basic btn-cancel" data-layer-close="true">닫기</button>
		</div>

	</form>

</div>

