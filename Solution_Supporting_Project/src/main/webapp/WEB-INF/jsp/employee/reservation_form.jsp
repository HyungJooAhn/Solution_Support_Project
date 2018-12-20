<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript">
$().ready(function() {
	$(".modal-head").find("button").css("background","url(<c:url value='/resources/themes/smoothness/images/common/btn_pop_close.png'/>) no-repeat")
	$(".modal-head").find("button").css("background-position", "center")
});

var datePickerOptions = {
		dateFormat : "yy-mm-dd",
		changeMonth : true,
		changeYear : true,
		showAnim : "fadeIn"
};
var dateChk = false;

var
// Config 정의
mCfg = {
	formId : '#formReservation',
	urlSelect : gCONTEXT_PATH + "reservation/reservation.json",
	urlExist : gCONTEXT_PATH + "reservation/reservation_check.json",
	urlDelete : gCONTEXT_PATH + "reservation/reservation_delete.do",
	urlSendMail : gCONTEXT_PATH + "reservation/reservation_mail_send.do",
	add : {
		action : gCONTEXT_PATH + "reservation/reservation_insert.do",
		message : "등록 하시겠습니까?"
	},
	update : {
		action : gCONTEXT_PATH + "reservation/reservation_update.do",
		message : "수정 하시겠습니까?"
	}
},

// JQuery 객체 변수
m$ = {
	form : $(mCfg.formId),
	reservationId : $(mCfg.formId + ' [name=reservation_id]')
},

mState = {
	isNew : m$.reservationId.val() == "" ? true : false,
	mode : m$.reservationId.val() == "" ? mCfg.add : mCfg.update
},

init = function() {
	$(".ph_width").css("height", "27px")
	$(".pm_width").css("height", "27px")
	
	if($("[name=selected_yn]").val() == "false"){
		$("#reservation_date").datepicker(datePickerOptions);		
	}
	$("input:radio[name=reservation_room]:radio[value='1']").prop("checked", "true");
	
	var now = new Date();

	var nowYear = now.getFullYear();
	var nowMon = now.getMonth() + 1;
	var nowDate = now.getDate();
	
	var selectedDate = $("#reservation_date").val().split('-');
	var selectedYear = Number(selectedDate[0]);
	var selectedMon = Number(selectedDate[1]);
	var selectedDate = Number(selectedDate[2]);
	
	if(!((nowYear > selectedYear) || ((nowYear == selectedYear) && (nowMon > selectedMon)) || ((nowYear == selectedYear) && (nowMon == selectedMon) && (nowDate >= selectedDate)))){
		dateChk = true;
	}
	// 이벤트 Binding
	bindEvent();

	// DOM 설정 Start
	if (mState.isNew) {
		m$.form.find(".btn-delete").hide();
	}else {
		m$.form.find(".btn-save").text("수정")
	}
	// DOM 설정 End

	// 데이타 조회
	if (!mState.isNew){
		select();
	}else{
		$("#mail_check").css("display", "inline");
	}
},

bindEvent = function() {
	
	m$.form.find('#reservation_date').change(function(){
		var validChk = true;
		var now = new Date();

		var nowYear = now.getFullYear();
		var nowMon = now.getMonth() + 1;
		var nowDate = now.getDate();
		
		var selectedDate = $("#reservation_date").val().split('-');
		var selectedYear = Number(selectedDate[0]);
		var selectedMon = Number(selectedDate[1]);
		var selectedDate = Number(selectedDate[2]);
		
		if((nowYear > selectedYear)){
			validChk = false;
		}else if((nowYear == selectedYear) && (nowMon > selectedMon)){
			validChk = false;
		}else if((nowYear == selectedYear) && (nowMon == selectedMon) && (nowDate > selectedDate)){
			validChk = false;
		}else{
			dateChk = true;
		}
		
		if(!validChk){
			_alert("오늘 이전 날짜는 선택할 수 없습니다.", {onAgree : function() {
				if(nowMon < 10)nowMon = "0" + nowMon;
				if(nowDate < 10)nowDate = "0" + nowDate;
				$("#reservation_date").val(nowYear + "-" + nowMon + "-" + nowDate)
			}
			});
		}
	});

	
	m$.form.find('#startHour').change(function(){
		if(!dateChk){
			var now = new Date();
			var nowYear = now.getFullYear();
			var nowMon = now.getMonth() + 1;
			var nowDate = now.getDate();
			
			var selectedDate = $("#reservation_date").val();
			
			
			var nowHour = now.getHours();
			var nowMin = now.getMinutes();
			var selectedStartHour = Number($("#startHour").val());
			
			if(nowHour > selectedStartHour){
				_alert("현재시간 이전 시간은 선택할 수 없습니다.", {onAgree : function() {
					if(nowMin >= 30){
						nowHour ++;
					}
					if(nowHour < 10)nowHour = "0" + nowHour;
					$("#startHour").val(nowHour)
				}});
			}
		}
	});
	
	m$.form.find('#startMin').change(function(){
		if(!dateChk){
			var now = new Date();
			var nowHour = now.getHours();
			var nowMin = now.getMinutes();
			var selectedStartHour = Number($("#startHour").val());
			var selectedStartMin = Number($("#startMin").val());
			
			if(nowMin > selectedStartMin){
				if(nowHour >= selectedStartHour){
					_alert("현재시간 이전 시간은 선택할 수 없습니다.", {onAgree : function() {
						if(nowMin >= 30){
							if(nowHour+1 < 10){
								nowHour = "0" + (nowHour+1);
							}else{
								nowHour ++;
							}
							$("#startHour").val(nowHour);
							$("#startMin").val("00");
						}else{
							$("#startHour").val(nowHour);
							$("#startMin").val("30");
						}
					
					}});
				}
			}
		}
	});
	
	m$.form.find('#endHour').change(function(){
		
		var selectedStartHour = Number($("#startHour").val());
		var selectedStartMin = Number($("#startMin").val());
		var selectedEndHour = Number($("#endHour").val());
		
		if((selectedStartHour > selectedEndHour) || ((selectedStartMin == 30) && (selectedStartHour == selectedEndHour))){
			_alert("시작시간 이전 시간은 선택할 수 없습니다.", {onAgree : function() {
				
				if(selectedStartMin == 30){
					selectedStartHour ++;
					if(selectedStartHour < 10)selectedStartHour = "0" + selectedStartHour;
				}
				$("#endHour").val(selectedStartHour)
			}});
		}
	});
	
	m$.form.find('#endMin').change(function(){
		var selectedStartHour = Number($("#startHour").val());
		var selectedStartMin = Number($("#startMin").val());
		var selectedEndHour = Number($("#endHour").val());
		var selectedEndMin = Number($("#endMin").val());
			
		if((selectedStartHour == selectedEndHour) && (selectedStartMin == selectedEndMin)){
			_alert("시작시간과 같을 수  없습니다.", {onAgree : function() {
				if(selectedStartMin == 30){
					if(selectedStartHour < 10)selectedStartHour = "0" + (selectedStartHour+1);
					else selectedStartHour ++;
				}
				$("#endHour").val(selectedStartHour)
				
				if(selectedEndMin == 30){
					$("#endMin").val("00")
				}else{
					$("#endMin").val("30")	
				}
			}});
		}else if((selectedStartHour == selectedEndHour) && (selectedStartMin > selectedEndMin)){
			_alert("종료시간은 시작시간 보다 이후여야 합니다.", {onAgree : function() {
				if(selectedStartMin == 30){
					if(selectedStartHour < 10)selectedStartHour = "0" + (selectedStartHour+1);
					else selectedStartHour ++;
				}
				$("#endHour").val(selectedStartHour)
				$("#endMin").val("00")
			}});
			
		}
	});
	
	// SAVE
	m$.form.find('.btn-save').on('click', onSave);

	// DELETE
	m$.form.find('.btn-delete').on("click", onDelete);
},

select = function() {
	
	var now = new Date();
	var nowDate = now.getFullYear() + "-" + setDateString(now.getMonth() + 1) + "-" + setDateString(now.getDate());
	
	var id = m$.reservationId.val(), rqData = {
		'reservation_id' : id
	},
	
	callback = function(data) {
		var selectedDay = data.reservation_date;
		_SL.setDataToForm(data, m$.form, {});
		if((data.proc_id != $("[name=session_id]").val()) || (calDateDiff(nowDate, selectedDay) < 0)){
			$("#reservation_date").remove();
			$("#rtime_td").empty();
			$("#rroom_td").empty();
			$("#reservation_applicant_position").remove();
			
			$("#rdate_td").append("<input id='reservation_date' style='width:30%' type='text' value='" + data.reservation_date + "' class='form-input form-text'>")
			
			$("#rtime_td").append("<input id='reservation_time' style='width:35%' type='text' value='" + data.start_time + " ~ " + data.end_time + "' class='form-input form-text'>")
			
			$("#rroom_td").append("<input id='reservation_room' style='width:35%' type='text' value='" + data.reservation_room + "호실' class='form-input form-text'>")
			
			$("#rposition_td").append("<input id='reservation_applicant_position' style='width:30%' type='text' value='" + data.reservation_applicant_position + "' class='form-input form-text'>")
			
			$("#reservation_date").addClass("form-text").prop("readonly", true);
			$("#reservation_time").addClass("form-text").prop("readonly", true);
			$("#reservation_room").addClass("form-text").prop("readonly", true);
			$("#reservation_applicant_position").addClass("form-text").prop("readonly", true);
			$("#reservation_applicant").addClass("form-text").prop("readonly", true);
			$("#reservation_nm").addClass("form-text").prop("readonly", true);
			$("#reservation_cont").addClass("form-text").prop("readonly", true);
			
			$("#btn-save").remove();
			$("#btn-delete").remove();
		}else{
			$("#mail_check").css("display", "inline");
		}
	};

	$('body').requestData(mCfg.urlSelect, rqData, {
		callback : callback
	});
},

onSave = function() {
	var timeChk = true;
	var selectedStartHour = Number($("#startHour").val());
	var selectedStartMin = Number($("#startMin").val());
	var selectedEndHour = Number($("#endHour").val());
	var selectedEndMin = Number($("#endMin").val());
	
	if((selectedStartHour == -1) || (selectedStartMin == -1) || (selectedEndHour == -1) || (selectedEndMin == -1)){
		timeChk = false
		_alert("시간을 입력하세요.", {onAgree : function() {}});
	}else if((selectedStartHour > selectedEndHour) || ((selectedEndHour == selectedStartHour) && (selectedStartMin > selectedEndMin))){
		timeChk = false
		_alert("시작시간은 종료시간 이전으로 선택해야 합니다.", {onAgree : function() {}});
	}else if((selectedStartHour == selectedEndHour) && (selectedStartMin == selectedEndMin)){
		timeChk = false
		_alert("시작시간은 종료시간 같을 수 없습니다.", {onAgree : function() {}});
	}
	
	if (!_SL.validate(m$.form))return;

	var afterClose = $(this).data('after-close') == true ? true : false;
	
	var submit = function() {
		$('body').requestData(mState.mode.action,
				_SL.serializeMap(m$.form), {
					callback : function(rsData, rsCd, rsMsg) {
						_alert(rsMsg, {
							onAgree : function() {
								parent.refresh();
								//parent.calendarDraw();
							}
						});
					}
				});
	}
	
	$('body').requestData(mCfg.urlExist,
		_SL.serializeMap(m$.form), {
			callback : function(rsData, rsCd, rsMsg) {
				if(!rsData){
					if(timeChk){
						submit();
						if($("#mail_send_check")[0].checked == true){
							$('body').requestData(mCfg.urlSendMail,
								_SL.serializeMap(m$.form), {
									callback : function(rsData, rsCd, rsMsg) {}
							});
						}
					}
				}else{
					_alert("이미 예약된 시간 입니다.", {onAgree : function() {}});
				}
		}
	});
},

onDelete = function() {
	var serverId = m$.reservationId.val();
	var afterClose = $(this).data('after-close') == true ? true : false;
	var delReservation = function() {
		_confirm("삭제하시겠습니까?", {
			onAgree : function() {
				$('body').requestData(mCfg.urlDelete,
						_SL.serializeMap(m$.form), {
							callback : function(rsData, rsCd, rsMsg) {
								_alert(rsMsg, {
									onAgree : function() {
										parent.refresh();
									}
								});
							}
						});
			}
		});
	};
	delReservation();
},

onClose = function(afterClose) {
	if (afterClose) {
		m$.form.find("[data-layer-close=true]").click();
	}
};

function calDateDiff(start, end){
	var startDate = new Date(start);
	var endDate = new Date(end);
	
	var dateDiff = (endDate.getTime() - startDate.getTime())/1000/60/60/24;
	return dateDiff + 1;
}

function setDateString(datenum){
	if(datenum < 10){
		datenum = "0" + datenum;
	}
	return datenum
}

init();

</script>
<div class="section-content no-search-cols">
	<form name="formReservation" id="formReservation">
		<input type="hidden" name="slKey" value="${_slKey}">
		<input type="hidden" name="reservation_id" value="${param.reservation_id}">
		<input type="hidden" name="session_id" value="${proc_id}">
		<input type="hidden" name="selected_yn" value="${selected}">
		<div id="mail_check" style="display:none">
			<input style="float:right; margin-top:-5px;margin-left:10px" type="checkbox" id="mail_send_check" name="mail_send_check" value="Y" checked>
			<span style="font-family:맑은고딕;font-weight:bold;float:right;margin-top:-7px;padding-bottom:8px;">메일발송 여부</span>
		</div>
		<table class="table-group">
			<tr>
				<th scope="row"><span class="mark-required">날짜</span></th>
				<td id='rdate_td'>
					<c:choose>
						<c:when test="${selected eq true}">
							<input style='width:30%' type="text" id='reservation_date' value="${selected_date}" name="reservation_date" class="form-input form-text" readonly>
						</c:when>
						<c:otherwise>
							<input style='width:30%' data-datepicker="true" type="text" id='reservation_date' value="${today}" name="reservation_date" class="form-input" data-valid="날짜,required">
						</c:otherwise>
					</c:choose>
				</td>
			</tr>
			<tr>
				<th scope="row"><span class="mark-required">시간</span></th>
				
				<td id='rtime_td' colspan="3">
						<select name="startHour" id="startHour" class="ph_width">
						<option value="-1">--</option>
							<c:forEach var="hour" begin="0" end="23">
								<fmt:formatNumber value="${hour}" pattern="00" var="shour" />
												<option value="${shour}" <c:if test="${(shour == startHour)}"> selected </c:if>>${shour}</option>
							</c:forEach>
						</select>
						시
						<select name="startMin" id="startMin" class="pm_width">
							<option value="-1">--</option>
							<option value="00">00</option>
							<option value="30">30</option>
						</select>
						분 ~
						<select name="endHour" id="endHour" class="ph_width">
							<option value="-1">--</option>
							<c:forEach var="hour" begin="0" end="23">
								<fmt:formatNumber value="${hour}" pattern="00" var="ehour" />
												<option value="${ehour}" <c:if test="${(ehour == endHour)}"> selected </c:if>>${ehour}</option>
							</c:forEach>
						</select>
						시
						<select name="endMin" id="endMin" class="pm_width">
							<option value="-1">--</option>
							<option value="00">00</option>
							<option value="30">30</option>
						</select>
						분
					</td>
					
			</tr>
			<tr>
				<th scope="row"><span class="mark-required">회의실</span></th>
				<td id='rroom_td'>
					<input style="float:left;" type="radio" name="reservation_room" value="1" data-valid="호실,required" selected><span style="float:left;margin-top:3px;margin-left:5px;">1호실 </span>&nbsp;
					<input style="float:left;margin-left:10px;" type="radio" name="reservation_room" value="2" data-valid="호실,required"><span style="float:left;margin-top:3px;margin-left:5px;">2호실</span>
					<input style="float:left;margin-left:10px;" type="radio" name="reservation_room" value="전체" data-valid="호실,required"><span style="float:left;margin-top:3px;margin-left:5px;">전체 호실</span>
				</td>
			</tr>
			<tr>
				<th scope="row"><span class="mark-required">직책</span></th>
				<td id='rposition_td'>
					<select name="reservation_applicant_position" id="reservation_applicant_position" style="height:30px;">
								<option value="인턴">인턴</option>
								<option value="사원">사원</option>
								<option value="대리">대리</option>
								<option value="과장">과장</option>
								<option value="차장">차장</option>
								<option value="부장">부장</option>
								<option value="이사">이사</option>
					</select>
				<!-- <input style='width:30%' type="text" name="reservation_applicant_position" id='reservation_applicant_position' class="form-input" maxlength="30" data-valid="직책,required"> -->		
				</td>
			</tr>
			<tr>

				<th scope="row"><span class="mark-required">신청자</span></th>
				<td><input type="text" name="reservation_applicant" id='reservation_applicant' class="form-input" maxlength="30" data-valid="신청인,required"></td>

			</tr>
			<tr>

				<th scope="row"><span class="mark-required">예약명</span></th>
				<td><input type="text" name="reservation_nm" id='reservation_nm' class="form-input" maxlength="30" data-valid="예약명,required"></td>

			</tr>
			<tr>
				<th scope="row"><span class="mark-required">내용</span></th>
				<td><textarea style="height: 80px;" name="reservation_cont" id='reservation_cont' class="form-area" maxlength="300" data-valid="내용,required"></textarea></td>
			</tr>
		</table>

		<div class="table-bottom">
			<button type="button" class="btn-basic btn-save" id='btn-save' data-after-close="true">예약</button>
			<button type="button" class="btn-basic btn-delete" id='btn-delete' data-after-close="true">삭제</button>
			<button type="button" class="btn-basic btn-cancel" data-layer-close="true">닫기</button>
		</div>

	</form>

</div>

