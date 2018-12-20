<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript">

var datePickerOptions = {
		dateFormat : "yy-mm-dd",
		changeMonth : true,
		changeYear : true,
		showAnim : "fadeIn"
};
var dateChk = false;
$(".annual_date_input").datepicker(datePickerOptions);	

function init(){
	if($("[name=annual_id]").val() == ""){
		$("#btn-delete").hide();
		$("#btn-update").hide();
	}else{
		$("#btn-save").hide();
		selectAnnual();
	}
	
	$("#annual_date_start").change(startDateChangeEvent);
	$("#annual_date_end").change(endDateChangeEvent);
	$("#annual_type").change(annualTypeChangeEvent);
	//$("#annual_date_diff").text(calDateDiff($("[name=annual_date_start]").val(), $("[name=annual_date_end]").val()) + " 일");
	$("#btn-save").on("click", saveAnnual);
	$("#btn-update").on("click", updateAnnual);
	$("#btn-delete").on("click", deleteAnnual);
}

function selectAnnual(){
	var selectID = $("[name=annual_id]").val();
	$.ajax({
		type:"POST",
		url:"/annual/annual_select.json",
		contentType : "application/json",
		data : JSON.stringify({select_id:selectID}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			_SL.setDataToForm(rsJson.data[0], $("#formAnnual"), {});
			var selectedAnnualType = $("#annual_type");
			var selectedAnnualValue = selectedAnnualType[0].options[selectedAnnualType[0].selectedIndex].value;
			
			if(selectedAnnualValue == 1 || selectedAnnualValue == 2){
				$("[name=annual_day_cnt]").val("0.5");
				$("[name=annual_day_cnt]").addClass("form-text")
				$("[name=annual_day_cnt]").prop("readonly", true);
				$("[name=end_date]").val($("[name=start_date]").val());
			}
		}
	});
}

function saveAnnual(){
	if (!_SL.validate($("#formAnnual")))return;
	var inputDateDiff = calDateDiff($("[name=start_date]").val(), $("[name=end_date]").val());
	var dateDiff = Number($("[name=annual_day_cnt]").val());

	if(inputDateDiff < dateDiff){
		_alert("휴가 기간 보다 사용일수가 더 클 수 없습니다.")
	}else{
		$('body').requestData(gCONTEXT_PATH + "annual/annual_insert.do",
				_SL.serializeMap($("#formAnnual")), {
					callback : function(rsData, rsCd, rsMsg) {
						_alert(rsMsg, {
							onAgree : function() {
								parent.refresh();
							}
						});
					}
				}
		);
	}
}

function updateAnnual(){
	if (!_SL.validate($("#formAnnual")))return;
	var inputDateDiff = calDateDiff($("[name=start_date]").val(), $("[name=end_date]").val());
	var dateDiff = Number($("[name=annual_day_cnt]").val());

	if(inputDateDiff < dateDiff){
		_alert("휴가 기간 보다 사용일수가 더 클 수 없습니다.")
	}else{
		$('body').requestData(gCONTEXT_PATH + "annual/annual_update.do",
				_SL.serializeMap($("#formAnnual")), {
					callback : function(rsData, rsCd, rsMsg) {
						_alert(rsMsg, {
							onAgree : function() {
								parent.refresh();
							}
						});
					}
				}
		);
	}
}

function deleteAnnual(){
	$('body').requestData(gCONTEXT_PATH + "annual/annual_delete.do",
			_SL.serializeMap($("#formAnnual")), {
				callback : function(rsData, rsCd, rsMsg) {
					_alert(rsMsg, {
						onAgree : function() {
							parent.refresh();
						}
					});
				}
			}
	);
}

function setDateString(datenum){
	if(datenum < 10){
		datenum = "0" + datenum;
	}
	return datenum
}

function getTomorrow(date){
	var calendarMap = {0:31, 1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31};
	var year = Number(date.split("-")[0]);
	var mon = Number(date.split("-")[1]);
	var date = Number(date.split("-")[2]);
	
	var leapYear = year % 4 == 0 ? true : false;
	date += 1;
	if(calendarMap[mon] < date){
		if(mon == 2 && leapYear){
			if(date == 30){
				date = 1;
				mon += 1;
			}
		}else{
			date = 1;
			mon += 1;		
			if(mon == 13){
				mon = 1;
				year += 1;
			}
		}
	}	
	return year + "-" + setDateString(mon) + "-" + setDateString(date);
}

function calDateDiff(start, end){
	var startDate = new Date(start);
	var endDate = new Date(end);
	
	var dateDiff = (endDate.getTime() - startDate.getTime())/1000/60/60/24;
	
	return dateDiff + 1;
}

function annualTypeChangeEvent(){
	var selectedAnnualType = $("#annual_type");
	var selectedAnnualValue = selectedAnnualType[0].options[selectedAnnualType[0].selectedIndex].value;
	
	if(selectedAnnualValue == 1 || selectedAnnualValue == 2){
		$("[name=annual_day_cnt]").val("0.5");
		$("[name=annual_day_cnt]").addClass("form-text")
		$("[name=annual_day_cnt]").prop("readonly", true);
		$("[name=end_date]").val($("[name=start_date]").val());
	}else{
		$("[name=annual_day_cnt]").val("");
		$("[name=annual_day_cnt]").removeClass("form-text")
		$("[name=annual_day_cnt]").prop("readonly", false);
	}
}

function startDateChangeEvent(){
	var startDate = $("[name=start_date]").val().split("-");
	
	var today = new Date();
	var todayYear = today.getFullYear();
	var todayMon = today.getMonth() + 1;
	var todayDate = today.getDate();
	
	var dateValid = true;
	
	if(todayYear > Number(startDate[0])){
		dateValid = false;
	}else if(todayYear == Number(startDate[0]) && todayMon > Number(startDate[1])){
		dateValid = false;
	}else if(todayYear == Number(startDate[0]) && todayMon == Number(startDate[1]) && todayDate >  Number(startDate[2])){
		dateValid = false;
	}
	
	/* if(!dateValid){
		_alert("오늘 이전 날짜는 선택할 수 없습니다.")
		$("[name=start_date]").val(todayYear + "-" + setDateString(todayMon) + "-" + setDateString(todayDate));
	}else{
		$("[name=end_date]").val($("[name=start_date]").val());
	} */
	$("[name=end_date]").val($("[name=start_date]").val());
}

function endDateChangeEvent(){
	var startDate = $("[name=start_date]").val().split("-");
	var endDate = $("[name=end_date]").val().split("-");
	
	var selectedAnnualType = $("#annual_type");
	var selectedAnnualValue = selectedAnnualType[0].options[selectedAnnualType[0].selectedIndex].value;
	
	var dateValid = true;
	
	if((Number(startDate[0]) != Number(endDate[0]) || Number(startDate[1]) != Number(endDate[1]) || Number(startDate[2]) !=  Number(endDate[2])) && (selectedAnnualValue == 1 || selectedAnnualValue == 2)){
		_alert("반차는 같은 날짜만 선택할 수 있습니다.")
		$("[name=end_date]").val($("[name=start_date]").val());
		return;
	}else if(Number(startDate[0]) > Number(endDate[0])){
		dateValid = false;
	}else if(Number(startDate[0]) == Number(endDate[0]) && Number(startDate[1]) > Number(endDate[1])){
		dateValid = false;
	}else if(Number(startDate[0]) == Number(endDate[0]) && Number(startDate[1]) == Number(endDate[1]) && Number(startDate[2]) >  Number(endDate[2])){
		dateValid = false;
	}
	
	if(!dateValid){
		_alert("시작 날짜 이전은 선택할 수 없습니다.")
		$("[name=end_date]").val(getTomorrow($("[name=start_date]").val()));
	}
}

$().ready(function() {
	$(".modal-head").find("button").css("background","url(<c:url value='/resources/themes/smoothness/images/common/btn_pop_close.png'/>) no-repeat")
	$(".modal-head").find("button").css("background-position", "center")
	init();
});

</script>
<style>
input{
	font-size: 8pt;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
}
.annual_date_input{
	width:100px;
	height: 27px;
    text-align: center;
	background-color: #fff;
    border: 1px solid #bbb;
}

.table-group th{
	font-size: 9pt;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

.table-group td{
	font-size: 9pt;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

select{
	height:23px;
	width:81px;
	font-size: 8pt;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

select option{
	height:30px;
	font-size: 8pt;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

</style>
<div class="section-content no-search-cols">
	<form name="formAnnual" id="formAnnual">
		<input type="hidden" name="slKey" value="${_slKey}">
		<input type="hidden" name="annual_id" id="annual_id" value="${annual_id}">
		<table class="table-group">
			<tr>
				<th scope="row"><span class="mark-required">기간</span></th>
				<td>
					<input class="annual_date_input" data-datepicker="true" type="text" name='start_date' id='annual_date_start' value="${today }" name="annual_date_start" data-valid="시작날짜,required"> 부터 
					<input class="annual_date_input" data-datepicker="true" type="text" name='end_date' id='annual_date_end' value="${today }" name="annual_date_end" data-valid="종료날짜,required"> 까지 
				</td>
			</tr>
			<tr>
				<th scope="row"><span class="mark-required">일수</span></th>
				<td><input type="text" name="annual_day_cnt" id='annual_day_cnt' class="form-input" maxlength="3" style="width:40px;"data-valid="일수,number,required"> 일</td>
			</tr>
			<tr>
				<th scope="row"><span class="mark-required">종류</span></th>
				<td>
					<select name="annual_type" id="annual_type">
								<option value="0">연차</option>
								<option value="1">오전 반차</option>
								<option value="2">오후 반차</option>
								<option value="3">기타</option>
					</select>
				<!-- <input style='width:30%' type="text" name="reservation_applicant_position" id='reservation_applicant_position' class="form-input" maxlength="30" data-valid="직책,required"> -->		
				</td>
			</tr>
			<tr>
				<th scope="row"><span class="mark-required">직책</span></th>
				<td>
					<select name="annual_applicant_position" id="annual_applicant_position">
								<option value="인턴">인턴</option>
								<option value="사원">사원</option>
								<option value="대리">대리</option>
								<option value="과장">과장</option>
								<option value="차장">차장</option>
								<option value="부장">부장</option>
								<option value="이사">이사</option>
					</select>
				</td>
			</tr>
			<tr>
				<th scope="row"><span class="mark-required">사용자</span></th>
				<td><input type="text" name="annual_applicant" id='annual_applicant' class="form-input" maxlength="30" data-valid="사용자,required"></td>

			</tr>
			<tr>
				<th scope="row"><span class="mark-required">내용</span></th>
				<td><textarea style="height: 80px;" name="annual_cont" id='annual_cont' class="form-area" maxlength="300" data-valid="내용,required"></textarea></td>
			</tr>
		</table>

		<div class="table-bottom">
			<button type="button" class="btn-basic btn-save" id='btn-save' data-after-close="true">등록</button>
			<button type="button" class="btn-basic btn-update" id='btn-update' data-after-close="true">수정</button>
			<button type="button" class="btn-basic btn-delete" id='btn-delete' data-after-close="true">삭제</button>
			<button type="button" class="btn-basic btn-cancel" data-layer-close="true">닫기</button>
		</div>
	</form>
</div>

