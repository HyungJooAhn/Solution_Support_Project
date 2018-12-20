<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script>
$(function(){
	$('.btn-save').on('click', customerAddOper);	
})

function isDuplicateChk(idx, valArray){
	
	var isDuplicateResult = true;
	
	var data = {
			checkCaseIdx : idx,
			valArray : valArray
		}
	
	$.ajax({
		type : "POST",
		url : "check_duplicate.json",
		contentType : "application/json",
		data : JSON.stringify(data),
		dataType : "json",
		async: false,
		success : function(rsJson){
			if(rsJson.RESULT_CODE) {
				if(rsJson.RESULT_CODE == "0000") {
					if(rsJson.isDuplicate){
						alert("값이 중복되었습니다. 다른 값을 넣어주세요");
						isDuplicateResult = true;							
						return ;
					}else{
						isDuplicateResult = false;
						 
					}
				}else{
					alert("요청이 잘못됐습니다. 확인 후 다시 시도해주세요.");
					return;
				}
			}
		}
	});
	
	return isDuplicateResult;
		
}

function customerAddOper(){
	
	if (!_SL.validate($("#customer_input_dlg_form")))return;
	
	
	var param1 = $("#cust_main_code_name").val();
	var param2 = $("#cust_main_code_cont").val();
	var param3 = $('input[name=cust_main_code_type]:checked').val();
	var valArray = [param1];	
	
	//if(isDuplicateChk(2, valArray)){ return; }
	
	_confirm("등록 하시겠습니까?",{ 
		onAgree : function(){
			var sendData = {
					code_name : param1,
					code_cont : param2,
					code_type : param3,
				}
					
				$.ajax({
					type : "POST",
					url : "customer_code_insert.do",
					contentType : "application/json",
					data : JSON.stringify(sendData),
					dataType : "json",
					async: false,
					success : function(rsJson){
							if(rsJson.RESULT) {
								parent.refresh();
							}else{
								_alert("중복된 고객사 입니다.")
							}
					}
				});
		}
	});
}
</script>
<style>
	.cust_main_code_type{
		width:14px;
		float:left;
	}
	.cust_main_code_type_txt{
		float:left;
		margin-left:10px;
		margin-top:4px;
	}
</style>
<div class="section-content" style="margin-left:0px;">
	<form id="customer_input_dlg_form" style="overflow:hidden;">
		<table class="table-group">
			<tr>
				<th scope="row"><span class="mark-required">고객사명</span></th>
				<td><input class="form-input" type="text" id ="cust_main_code_name" name ="cust_main_code_name" style="margin-bottom:3px"  maxlength="255" data-valid="고객사명,required"/></td>
			</tr>
			<tr>
				<th scope="row"><span class="mark-required">고객사 구분</span></th>
				<td>
					<input type="radio" class="cust_main_code_type" name="cust_main_code_type" value="C" checked="checked"><span class="cust_main_code_type_txt">고객사</span>
					<input type="radio" class="cust_main_code_type" name="cust_main_code_type" style="margin-left:20px;" value="P"><span class="cust_main_code_type_txt">협력사</span>
				</td>
			</tr>
			<tr>
				<th scope="row"><span class="mark-required">상세내용</span></th>
				<td>
					<textarea class="form-area" id="cust_main_code_cont" name="cust_main_code_cont"  class="i_text" style="resize:none;width:100%;height:125px;margin-bottom:5px;" maxlength="900" data-valid="상세내용,required"></textarea>
				</td>
			</tr>
		</table>		
		<div class="table-bottom">
				<button type="button" class="btn-basic btn-save" data-after-close="true">등록</button>
				<button type="button" class="btn-basic btn-cancel" data-layer-close="true">취소</button>
		</div>
	</form>
</div>

