<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript">

var permission = false;
function viewDetail(url){
	var modal = new ModalPopup(url, {
		width:450, height:210,		//모달 사이즈 옵션으로 조절 가능
		//draggable : true,				// draggable 선택 가능(기본 값 : false)
		onClose : function(){
			refresh();
		}
	});
}

function goDetailViewOri() {
	viewDetail(gCONTEXT_PATH + "annual/annual_management_form.html");
}

function goDetailView(id) {
	viewDetail(gCONTEXT_PATH + "annual/annual_management_form.html?select_id=" + id);
}

function refresh(){
	location.reload();
}

function init(){
	checkPermission();
	
	drawCalendar(0);
	drawCalendarDashBoard();
	setInterval(drawCalendarDashBoard, 10000);
	
	$("#annual_calendar_btn_pre").on("click", function(){
		drawCalendar(-1);
		aniIdx = 0;
		drawCalendarDashBoard()
	});
	
	$("#annual_calendar_btn_next").on("click", function(){
		drawCalendar(1);
		aniIdx = 0;
		drawCalendarDashBoard()
	});
	
	$("#annual_calendar_btn_today").on("click", function(){
		drawCalendar(0);
		aniIdx = 0;
		drawCalendarDashBoard()
	});
	
	$("#annual_calendar_btn_add").on("click", function(){
		goDetailViewOri();
	});
	
	if(!permission){
		$("#annual_calendar_btn_add").css("display", "none");
	}
}

function checkPermission(){
	$.ajax({
		type:"POST",
		url:"/annual/annual_permission_chk.do",
		contentType : "application/json",
		data : JSON.stringify({all:true}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			permission = rsJson.data;
		}, 
		error : function(error){
			permission = false;
		} 
	})
}

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


var monList = ["January", "Febuary", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
var dayList = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
var calendarMap = {0:31, 1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31};
function drawCalendar(idx){
	$("#contents").css("min-height", "730px");
	$("#annual_calendar").empty();
	var date;
	var d_Year;
	var d_Mon;
	
	if(idx == 0){
		date = new Date();
		d_Year = date.getFullYear();
		d_Mon = date.getMonth() + 1;
	}else if(idx == 1){
		d_Year = Number($("[name=page_year]").val());
		d_Mon = Number($("[name=page_mon]").val()) + 1;
		if(d_Mon == 13){
			d_Year ++;
			d_Mon = 1;
		}
	}else{
		d_Year = Number($("[name=page_year]").val());
		d_Mon = Number($("[name=page_mon]").val()) - 1;
		if(d_Mon == 0){
			d_Year --;
			d_Mon = 12;
		}
	}
	
	var leapYear = d_Year % 4 == 0 ? true : false;
	
	$("#annual_calendar_title").text(monList[d_Mon - 1] + " " + d_Year);
	$("[name=page_year]").val(d_Year);
	$("[name=page_mon]").val(d_Mon);
	
	var stdDate = new Date(d_Year + "-" + d_Mon + "-01");
	var calendarID = "calendar_table";
	
	$("#annual_calendar").append("<table id='" + calendarID + "'></table>")

	var nextMonDateNum = 1;
	var preMonDateNum = calendarMap[d_Mon - 1] - stdDate.getDay() + 1;
	if(d_Mon - 1 == 2 && leapYear){
		preMonDateNum = 29 - stdDate.getDay() + 1;
	}
	var preMonStartDate = d_Year + "-" + setDateString(d_Mon - 1) + "-" + setDateString(preMonDateNum);
	var preMonEndDate = d_Year + "-" + setDateString(d_Mon - 1) + "-" + setDateString(calendarMap[d_Mon - 1]);
	if(d_Mon - 1 == 0){
		preMonStartDate = (d_Year - 1) + "-12-" + setDateString(preMonDateNum);
		preMonEndDate = (d_Year - 1) + "-12-" + setDateString(calendarMap[d_Mon - 1]);
	}
	if(d_Mon - 1 == 2 && leapYear){
		preMonEndDate = d_Year + "-02-29";
	}
	
	for(var i=0; i<49; i++){
		if(i < 7){
			if(i % 7 == 0){
				$("#" + calendarID).append("<tr id='calendar_table_head'></tr>")
			}
			$("#calendar_table_head").append("<th>" + dayList[i] + "</th>")
		}else{
			var lineNum = parseInt(i / 7);
			var tdIdx = i % 7;
			if(i % 7 == 0){
				$("#" + calendarID).append("<tr id='calendar_table_line_" + lineNum + "'></tr>")
			}
			var dateNum = i - 6 - stdDate.getDay();
			if(dateNum < 1){
				var d_Mon_data = d_Mon
				d_Mon_data --;
				
				var d_Year_data = d_Year;
				
				if(d_Mon_data == 0){
					d_Mon_data = 12;
					d_Year_data --;
				}
				$("#calendar_table_line_" + lineNum).append("<td id='" + lineNum + "_" + tdIdx + "' data-date='" + d_Year_data + "-" + setDateString(d_Mon_data) + "-" + setDateString(preMonDateNum) + "'><div class='o_mon_date'>" + preMonDateNum + "</div></td>")
				preMonDateNum ++;
			}else if(calendarMap[d_Mon] < dateNum){
				if(d_Mon == 2 && leapYear && dateNum == 29){
					$("#calendar_table_line_" + lineNum).append("<td id='" + lineNum + "_" + tdIdx + "' data-date='" + d_Year + "-" + setDateString(d_Mon) + "-29'><div class='n_mon_date'><div style='padding-top:3px;'>29</div></div></td>")
				}else{
					var d_Mon_data = d_Mon
					d_Mon_data ++;
					if(d_Mon_data == 13){
						d_Mon_data = 1;
					}
					
					$("#calendar_table_line_" + lineNum).append("<td id='" + lineNum + "_" + tdIdx + "' data-date='" + d_Year + "-" + setDateString(d_Mon_data) + "-" + setDateString(nextMonDateNum) + "'><div class='o_mon_date'>" + nextMonDateNum + "</div></td>")
					nextMonDateNum ++;					
				}
			}else{
				$("#calendar_table_line_" + lineNum).append("<td id='" + lineNum + "_" + tdIdx + "' data-date='" + d_Year + "-" + setDateString(d_Mon) + "-" + setDateString(dateNum) + "'><div class='n_mon_date'><div style='padding-top:3px;'>" + dateNum + "</div></div></td>")				
			}
		}
	}
	var tdList = $("#calendar_table").find("td");
	for(var i=0; i<tdList.length; i++){
		var todayDate = new Date();
		var todayYear = todayDate.getFullYear();
		var todayMon = todayDate.getMonth() + 1;
		var todayDate = todayDate.getDate();
		
		if(todayYear + "-" + setDateString(todayMon) + "-" + setDateString(todayDate) == $(tdList[i]).attr("data-date")) {
			$($(tdList[i]).find(".n_mon_date")[0]).css("border-color", "#ad1515");
			$($(tdList[i]).find(".n_mon_date")[0]).css("background-color", "#ad1515");
		}
	}
	drawMonAnnualElements(tdList, d_Year, d_Mon, preMonStartDate, preMonEndDate);
}

function drawMonAnnualElements(tdList, year, mon, preMonStartDate, preMonEndDate){
	var annualList;
	
	var lastMon = mon - 1;
	var overYear = year;
	if(lastMon == 0){
		lastMon = 12;
		overYear = year - 1;
	}
	
	$.ajax({
		type:"POST",
		url:"/annual/annual_list.json",
		contentType : "application/json",
		data : JSON.stringify({year:year, mon:setDateString(mon), over_year:overYear, last_mon:setDateString(lastMon), pre_start_date:preMonStartDate, pre_end_date:preMonEndDate}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			annualList = rsJson.data;
		}
	});

	if(annualList != null && annualList.length != 0){
		for(var k=0; k<annualList.length; k ++){
			var s_Date = annualList[k]["start_date"];
			var dayDiffChk = calDateDiff(preMonStartDate, annualList[k]["start_date"]);
			var dayDiffChkMinus = false;
			var moreCnt = 0;
			if(dayDiffChk < 0){
				s_Date = preMonStartDate;
				dayDiffChkMinus = true;
				moreCnt = calDateDiff(annualList[k]["start_date"], preMonStartDate) - 1;
			}
			for(var i=0; i<tdList.length; i++){
				if(s_Date == $(tdList[i]).attr("data-date")) {
					var conTd = $($(tdList[i]));
					var eleID = annualList[k]["id"];
					var line = Number($($(tdList[i])).attr("id").split("_")[0]);
					var idx = Number($($(tdList[i])).attr("id").split("_")[1]);
					var dayDiff = calDateDiff(annualList[k]["start_date"], annualList[k]["end_date"]) - moreCnt;
					var elementLen = (130 * dayDiff) + (dayDiff);
					
					switch(annualList[k]["annual_type"]){
					case "0":
						if(idx + (dayDiff - 1) > 6){
							elementLen = (130 * (7 - idx)) + (7 - idx);
							if(permission){
								$(conTd).append("<div onclick='javascript:goDetailView(\"" + annualList[k]["id"] + "\")' id='annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx + "' class='annual_element_0 ele more_ori' style='width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
								$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("cursor", "pointer");
							}else{
								$(conTd).append("<div id='annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx + "' class='annual_element_0 ele more_ori' style='width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
							}
							
							if(dayDiffChkMinus){
								$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("border-top-left-radius", "0px");
								$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("border-bottom-left-radius", "0px");
							}
							
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("border-top-right-radius", "0px");
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("border-bottom-right-radius", "0px");
							
							var leftLen = idx + (dayDiff - 1) - 6;
							for(var z=0; z<=leftLen; z++){
								if(z % 7 == 0){
									var lineIdx = parseInt(z / 7) + 1;
									var fullBarChk = parseInt(z / 7) < parseInt(leftLen / 7) ? true : false;
									var moreLeftLen;
									if(fullBarChk){
										moreLeftLen = 7;
										elementLen = (130 * moreLeftLen) + moreLeftLen;
										moreLeftLen = 7 + "" + z
									}else{
										moreLeftLen = leftLen - (parseInt(z / 7) * 7);
										elementLen = (130 * moreLeftLen) + moreLeftLen;
									}
									
									if(permission){
										$("#" + (line + lineIdx) + "_0").append("<div onclick='javascript:goDetailView(\"" + annualList[k]["id"] + "\")' id='Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0' class='annual_element_0 ele more' style='width:" + elementLen + "px;'></div>")
										$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").css("cursor", "pointer");
									}else{
										$("#" + (line + lineIdx) + "_0").append("<div id='Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0' class='annual_element_0 ele more' style='width:" + elementLen + "px;'></div>")
									}
									
									if(fullBarChk){
										$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").css("border-radius", "0px");
									}else{
										$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").css("border-top-left-radius", "0px");
										$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").css("border-bottom-left-radius", "0px");
									}
									
									$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").mouseenter(function(e) {
										var selectID = $(this).attr("id").split("_")[2];
										longElementHover(selectID, "0");
										toolTipMaker(selectID, e);
									});
									$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").mousemove(function(e){
										$("#annual_info_tooltip").css("top", (e.pageY - 40) + "px");
										$("#annual_info_tooltip").css("left",(e.pageX) + "px");
									});
									$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").mouseleave(function() {
										var selectID = $(this).attr("id").split("_")[2];
										longElementLeave(selectID);
										$("#annual_info_tooltip").css("display", "none");
									});
									
								}
							}
							
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseenter(function(e) {
								var selectID = $(this).attr("id").split("_")[2];
								longElementHover(selectID, "0");
								toolTipMaker(selectID, e);
							});
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mousemove(function(e){
								$("#annual_info_tooltip").css("top", (e.pageY - 40) + "px");
								$("#annual_info_tooltip").css("left",(e.pageX) + "px");
							});
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseleave(function() {
								var selectID = $(this).attr("id").split("_")[2];
								longElementLeave(selectID);
								$("#annual_info_tooltip").css("display", "none");
							});
						}else{
							if(permission){
								$(conTd).append("<div onclick='javascript:goDetailView(\"" + annualList[k]["id"] + "\")' id='annual_element_" + annualList[k]["id"] + "_" + dayDiff +  "_" + idx + "' class='annual_element_0 ele' style='width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
								$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("cursor", "pointer");
							}else{
								$(conTd).append("<div id='annual_element_" + annualList[k]["id"] + "_" + dayDiff +  "_" + idx + "' class='annual_element_0 ele' style='width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
							}
							
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseenter(function(e) {
								var selectID = $(this).attr("id").split("_")[2];
								toolTipMaker(selectID, e);
							});
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mousemove(function(e){
								$("#annual_info_tooltip").css("top", (e.pageY - 40) + "px");
								$("#annual_info_tooltip").css("left",(e.pageX) + "px");
							});
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseleave(function() {
								$("#annual_info_tooltip").css("display", "none");
							});
						}
						break;
					case "1":
						elementLen = parseInt(elementLen / 2);
						if(permission){
							$(conTd).append("<div onclick='javascript:goDetailView(\"" + annualList[k]["id"] + "\")' id='annual_element_" + annualList[k]["id"] + "_" + dayDiff +  "_" + idx + "' class='annual_element_1 ele' style='width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff +  "_" + idx).css("cursor", "pointer");
						}else{
							$(conTd).append("<div id='annual_element_" + annualList[k]["id"] + "_" + dayDiff +  "_" + idx + "' class='annual_element_1 ele' style='width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
						}
						
						$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseenter(function(e) {
							var selectID = $(this).attr("id").split("_")[2];
							$("#annual_info_tooltip").css("width", "350px");
							toolTipMaker(selectID, e);
						});
						$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mousemove(function(e){
							$("#annual_info_tooltip").css("top", (e.pageY - 40) + "px");
							$("#annual_info_tooltip").css("left",(e.pageX) + "px");
						});
						$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseleave(function() {
							$("#annual_info_tooltip").css("display", "none");
							$("#annual_info_tooltip").css("width", "330px");
						});
						
						break;
					case "2":
						elementLen = parseInt(elementLen / 2);
						if(permission){
							$(conTd).append("<div onclick='javascript:goDetailView(\"" + annualList[k]["id"] + "\")' id='annual_element_" + annualList[k]["id"] + "_" + dayDiff +  "_" + idx + "' class='annual_element_2 ele' style='margin-left:65px;width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff +  "_" + idx).css("cursor", "pointer");
						}else{
							$(conTd).append("<div id='annual_element_" + annualList[k]["id"] + "_" + dayDiff +  "_" + idx + "' class='annual_element_2 ele' style='margin-left:65px;width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
						}
						
						$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseenter(function(e) {
							var selectID = $(this).attr("id").split("_")[2];
							$("#annual_info_tooltip").css("width", "350px");
							toolTipMaker(selectID, e);
						});
						$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mousemove(function(e){
							$("#annual_info_tooltip").css("top", (e.pageY - 40) + "px");
							$("#annual_info_tooltip").css("left",(e.pageX) + "px");
						});
						$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseleave(function() {
							$("#annual_info_tooltip").css("display", "none");
							$("#annual_info_tooltip").css("width", "330px");
						});
						
						break;
					case "3":
						if(idx + (dayDiff - 1) > 6){
							elementLen = (130 * (7 - idx)) + (7 - idx);
							if(permission){
								$(conTd).append("<div onclick='javascript:goDetailView(\"" + annualList[k]["id"] + "\")' id='annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx + "' class='annual_element_3 ele more_ori' style='width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
								$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("cursor", "pointer");
							}else{
								$(conTd).append("<div id='annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx + "' class='annual_element_3 ele more_ori' style='width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
							}
							
							if(dayDiffChkMinus){
								$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("border-top-left-radius", "0px");
								$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("border-bottom-left-radius", "0px");
							}
							
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("border-top-right-radius", "0px");
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("border-bottom-right-radius", "0px");
							
							var leftLen = idx + (dayDiff - 1) - 6;
							for(var z=0; z<=leftLen; z++){
								if(z % 7 == 0){
									var lineIdx = parseInt(z / 7) + 1;
									var fullBarChk = parseInt(z / 7) < parseInt(leftLen / 7) ? true : false;
									var moreLeftLen;
									if(fullBarChk){
										moreLeftLen = 7;
										elementLen = (130 * moreLeftLen) + moreLeftLen;
										moreLeftLen = 7 + "" + z
									}else{
										moreLeftLen = leftLen - (parseInt(z / 7) * 7);
										elementLen = (130 * moreLeftLen) + moreLeftLen;
									}
									
									if(permission){
										$("#" + (line + lineIdx) + "_0").append("<div onclick='javascript:goDetailView(\"" + annualList[k]["id"] + "\")' id='Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0' class='annual_element_3 ele more' style='width:" + elementLen + "px;'></div>")
										$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").css("cursor", "pointer");
									}else{
										$("#" + (line + lineIdx) + "_0").append("<div id='Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0' class='annual_element_3 ele more' style='width:" + elementLen + "px;'></div>")
									}
									
									if(fullBarChk){
										$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").css("border-radius", "0px");
									}else{
										$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").css("border-top-left-radius", "0px");
										$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").css("border-bottom-left-radius", "0px");
									}
									
									$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").mouseenter(function(e) {
										var selectID = $(this).attr("id").split("_")[2];
										longElementHover(selectID, "3");
										toolTipMaker(selectID, e);
									});
									$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").mousemove(function(e){
										$("#annual_info_tooltip").css("top", (e.pageY - 40) + "px");
										$("#annual_info_tooltip").css("left",(e.pageX) + "px");
									});
									$("#Mannual_element_" + annualList[k]["id"] + "_" + moreLeftLen + "_0").mouseleave(function() {
										var selectID = $(this).attr("id").split("_")[2];
										longElementLeave(selectID);
										$("#annual_info_tooltip").css("display", "none");
									});
									
								}
							}
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseenter(function(e) {
								var selectID = $(this).attr("id").split("_")[2];
								longElementHover(selectID, "3");
								toolTipMaker(selectID, e);
							});
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mousemove(function(e){
								$("#annual_info_tooltip").css("top", (e.pageY - 40) + "px");
								$("#annual_info_tooltip").css("left",(e.pageX) + "px");
							});
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseleave(function() {
								var selectID = $(this).attr("id").split("_")[2];
								longElementLeave(selectID);
								$("#annual_info_tooltip").css("display", "none");
							});
						}else{
							if(permission){
								$(conTd).append("<div onclick='javascript:goDetailView(\"" + annualList[k]["id"] + "\")' id='annual_element_" + annualList[k]["id"] + "_" + dayDiff +  "_" + idx + "' class='annual_element_3 ele' style='width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
								$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).css("cursor", "pointer");
							}else{
								$(conTd).append("<div id='annual_element_" + annualList[k]["id"] + "_" + dayDiff +  "_" + idx + "' class='annual_element_3 ele' style='width:" + elementLen + "px;'><div class='annual_element_label'>" + annualList[k]["annual_applicant_position"] + " " + annualList[k]["annual_applicant"] + "</div></div>")
							}
							
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseenter(function(e) {
								var selectID = $(this).attr("id").split("_")[2];
								toolTipMaker(selectID, e);
							});
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mousemove(function(e){
								$("#annual_info_tooltip").css("top", (e.pageY - 40) + "px");
								$("#annual_info_tooltip").css("left",(e.pageX) + "px");
							});
							$("#annual_element_" + annualList[k]["id"] + "_" + dayDiff + "_" + idx).mouseleave(function() {
								$("#annual_info_tooltip").css("display", "none");
							});
						}
						break;
					}
				}
			}				
		}
	}
	sortAnnualElements();
//	$("#annual_calednar_background").css("height", (Number($("#calendar_table").css("height").replace("px", "")) + 49) + "px");
}

function sortAnnualElements(){
	
	for(var i=1; i<7; i++){
		var sortedList = [];
		var tmpSortedList = [];
		var tdList = $("#calendar_table_line_" + i).find("td");
		for(var t=0; t<tdList.length; t++){
			var eleList = $(tdList[t]).find(".ele");
			var eleListLen = eleList.length;
			
			if(eleList.length != 0){
				for(var k=0; k<eleListLen - 1; k++){
					for(var p=0; p<eleListLen - 1; p++){
						var eleLen = Number($(eleList[p]).attr("id").split("_")[3]);	
						var nextEleLen = Number($(eleList[p + 1]).attr("id").split("_")[3]);	
						
						if(eleLen < nextEleLen){
							var tmp = eleList[p];
							eleList[p] = eleList[p + 1];
							eleList[p + 1] = tmp;
						}
					}
				}
				
				for(var k=0; k<eleListLen; k++){
					tmpSortedList.push(eleList[k]);
				}
			}
		}
		
		for(var t=0; t<tmpSortedList.length; t++){
			if($(tmpSortedList[t]).hasClass("more")){
				
				sortedList.push(tmpSortedList[t]);
			}
		}
		for(var t=0; t<tmpSortedList.length; t++){
			if(!$(tmpSortedList[t]).hasClass("more")){
				sortedList.push(tmpSortedList[t]);
			}
		}
		
		for(var t=0; t<7; t++){
			if(sortedList.length != 0){
				var eleCnt = 0;
				var rowIdx = 0;
				var stdIdx = Number($(sortedList[0]).attr("id").split("_")[4]);
				for(var k=0; k<sortedList.length; k++){
					var eleIdx = Number($(sortedList[k]).attr("id").split("_")[4]);	
					var eleLen = Number($(sortedList[k]).attr("id").split("_")[3]);	
					var eleLine = Number($($(sortedList[k]).parent()[0]).attr("id").split("_")[0]);
					if(t == eleIdx){
						var tdb_eleList = $("#" + eleLine + "_" + t).find(".b_ele");
						if(stdIdx != eleIdx){
							stdIdx = eleIdx;
							rowIdx = 0;
						}
						
						if(tdb_eleList.length != 0){
							if(tdb_eleList.length == 1){
								if(rowIdx == Number($(tdb_eleList[0]).attr("value"))){
									rowIdx ++;
								}
							}else{
								for(var s=0; s<tdb_eleList.length - 1; s++){
									for(var n=0; n<tdb_eleList.length - 1; n++){
										var b_eleRowIdx = Number($(tdb_eleList[n]).attr("value"));
										var nextb_eleRowIdx = Number($(tdb_eleList[n + 1]).attr("value"));
										if(b_eleRowIdx > nextb_eleRowIdx){
											var tmp = tdb_eleList[n];
											tdb_eleList[n] = tdb_eleList[n + 1];
											tdb_eleList[n + 1] = tmp;
										}
									}
								}
								
								for(var w=0; w<tdb_eleList.length - 1; w++){
									var b_eleRowIdx = Number($(tdb_eleList[w]).attr("value"));
									var nextb_eleRowIdx = Number($(tdb_eleList[w + 1]).attr("value"));
									if(rowIdx == b_eleRowIdx){
										rowIdx ++;
										if(nextb_eleRowIdx - b_eleRowIdx == 1){
											if(w == tdb_eleList.length - 2){
												rowIdx ++;
											}
											continue;
										}else{
											break;
										}
									}else if(rowIdx < b_eleRowIdx){
										break;
									}
								}
							}
						}
						
						if($(sortedList[k]).hasClass("more_ori")){
							eleLen = 7 - eleIdx;
						}
						for(var p=1; p<=eleLen-1; p++){
							$("#" + eleLine + "_" + (eleIdx+p)).append("<div class='b_ele' value='" + rowIdx + "'></div>");
						}
						if(rowIdx == 0){
							$(sortedList[k]).css("margin-top", "4px")
						}else{
							$(sortedList[k]).css("margin-top", (4 + (rowIdx * 19) + rowIdx) + "px");
						}
						rowIdx ++;
					}
				}				
			}
		}
		
		var maxEleCnt = 0;
		for(var t=0; t<tdList.length; t++){
			var eleCnt = $(tdList[t]).find(".ele").length;
			var eleMoreCnt = $(tdList[t]).find(".b_ele").length;
			
			if(maxEleCnt < (eleMoreCnt + eleCnt)){
				maxEleCnt = (eleMoreCnt + eleCnt);
			}
		}

		$(tdList[0]).css("height", Number($(tdList[0]).css("height").replace("px", "")) + (21 * (maxEleCnt - 3)) + "px");
		
		if(maxEleCnt - 3 > 0){
			for(var t=0; t<maxEleCnt - 3; t++){
				$("#contents").css("min-height", (Number($("#contents").css("min-height").replace("px", "")) + 21) + "px");
			}
		}
	}
}

function toolTipMaker(id, e){
	var paramInfoMap;
	$.ajax({
		type:"POST",
		url:"/annual/annual_select.json",
		contentType : "application/json",
		data : JSON.stringify({select_id:id}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			paramInfoMap = rsJson.data[0];
		}
	});
	
	$("#annual_info_tooltip").hide();
	$("#annual_info_tooltip").fadeIn();
	$("#annual_info_tooltip").css("top", (e.pageY - 30) + "px");
	$("#annual_info_tooltip").css("left",(e.pageX + 10) + "px");
	$("#annual_info_tooltip").css("display", "inline");
	
	var annualType = "";
	var annualDayCnt = calDateDiff(paramInfoMap["start_date"], paramInfoMap["end_date"]);
	switch(paramInfoMap["annual_type"]){
	case "0":
		annualType = "연차";
		$("#annual_info_tooltip").css("background-color", "#f4d5ff");
		$("#annual_info_tooltip_tra").css("border-color", "#f4d5ff transparent transparent transparent");
		break;
	case "1":
		annualType = "오전반차";
		annualDayCnt = "0.5";
		$("#annual_info_tooltip").css("background-color", "#ffa442");
		$("#annual_info_tooltip_tra").css("border-color", "#ffa442 transparent transparent transparent");
		break;
	case "2":
		annualType = "오후반차";
		annualDayCnt = "0.5";
		$("#annual_info_tooltip").css("background-color", "#ffa442");
		$("#annual_info_tooltip_tra").css("border-color", "#ffa442 transparent transparent transparent");
		break;
	case "3":
		annualType = "기타";
		$("#annual_info_tooltip").css("background-color", "#c5ff96");
		$("#annual_info_tooltip_tra").css("border-color", "#c5ff96 transparent transparent transparent");
		break;
	}
	$("#annual_info_tooltip_text").text("[" + annualType + "] " + paramInfoMap["annual_applicant_position"] + " " + paramInfoMap["annual_applicant"] + " - " + paramInfoMap["start_date"] + " ~ " + paramInfoMap["end_date"] + " (" + annualDayCnt + "일간)");
}

function longElementHover(id, type){
	var moreOriList = $("#annual_calendar").find(".more_ori");
	var moreList = $("#annual_calendar").find(".more");
	
	for(var i=0; i<moreList.length; i++){
		moreOriList.push(moreList[i]);
	}
	
	for(var q=0; q<moreOriList.length; q++){
		if(id == $(moreOriList[q]).attr("id").split("_")[2]){
			switch(type){
			case "0":
				$(moreOriList[q]).css("box-shadow", "0px 0px 15px #f238ff");
				break;
			case "3":
				$(moreOriList[q]).css("box-shadow", "0px 0px 15px #29ff5b");
				break;
			}
		}
	}
}

function longElementLeave(id){
	var moreOriList = $("#annual_calendar").find(".more_ori");
	var moreList = $("#annual_calendar").find(".more");
	
	for(var i=0; i<moreList.length; i++){
		moreOriList.push(moreList[i]);
	}
	
	for(var q=0; q<moreOriList.length; q++){
		if(id == $(moreOriList[q]).attr("id").split("_")[2]){
			$(moreOriList[q]).css("box-shadow", "")
		}
	}
}

function getCalendarDashBoardData(){
	var annualList = null;
	var date = new Date();
	var d_Year = date.getFullYear();
	var d_Mon = date.getMonth() + 1;
	var d_Date = date.getDate();
	var d_Day = date.getDay();
	
	var leapYear = d_Year % 4 == 0 ? true : false;
	
	var startDate;
	var s_Year = d_Year;
	var s_Mon = d_Mon;
	var s_Date = d_Date;
	var s_Day = d_Day;
	if(s_Date - s_Day < 0){
		s_Mon --;
		
		if(s_Mon == 0){
			s_Year --;
			s_Mon = 12;
		}
		
		if(leapYear){
			if(s_Mon == 2){
				s_Date = 29 - s_Day + 1;
			}else{
				s_Date = calendarMap[s_Mon] - s_Day + 1;
			}
		}else{
			s_Date = calendarMap[s_Mon] - s_Day + 1;
		}
	}else{
		s_Date = s_Date - s_Day;
	}
	startDate = s_Year + "-" + setDateString(s_Mon) + "-" + setDateString(s_Date);
	
	var endDate;
	var e_Year = d_Year;
	var e_Mon = d_Mon;
	var e_Date = d_Date;
	var e_Day = d_Day;
	if(leapYear){
		if(e_Mon == 2){
			if(e_Date + (7 - e_Day) - 1 > 29){
				e_Date = (e_Date + (7 - e_Day) - 1) - 29;
				e_Mon ++;
			}else{
				e_Date = e_Date + (7 - e_Day) - 1;
			}
		}else{
			if(e_Date + (7 - e_Day) - 1 > calendarMap[e_Mon]){
				e_Date = (e_Date + (7 - e_Day) - 1) - calendarMap[e_Mon];
				
				e_Mon ++;
				if(e_Mon == 13){
					e_Year ++;
					e_Mon = 1;
				}
			}else{
				e_Date = e_Date + (7 - e_Day) - 1;
			}
		}
	}else{
		if(e_Date + (7 - e_Day) - 1 > calendarMap[e_Mon]){
			e_Date = (e_Date + (7 - e_Day) - 1) - calendarMap[e_Mon];
			
			e_Mon ++;
			if(e_Mon == 13){
				e_Year ++;
				e_Mon = 1;
			}
		}else{
			e_Date = e_Date + (7 - e_Day) - 1;
		}
	}
	endDate = e_Year + "-" + setDateString(e_Mon) + "-" + setDateString(e_Date);
	
	$.ajax({
		type:"POST",
		url:"/annual/annual_list_weekly.json",
		contentType : "application/json",
		data : JSON.stringify({start_date:startDate, end_date:endDate}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			annualList = rsJson.data;
		}
	});
	
	return annualList;
}
var annualList;
var annualListSize;
var aniIdx = 0;
var lastChkNum = 0;
function drawCalendarDashBoard(){
	$("#annual_dashboard_list_all").empty();
	$("#annual_dashboard").css("height", "585px");
	$("#no_data_dashboard").remove();
	if(aniIdx == 0){
		annualList = getCalendarDashBoardData();	
	}
	if(annualList != null && annualList.length > 0){
		annualListSize = annualList.length;
		$("#annual_dashboard_list_all").css("width", (annualListSize * 277) + "px");
		
		var contentHeight = Number($("#contents").css("min-height").replace("px", ""));
		var pageUnit = 11;
		if(contentHeight > 730){
			var newChkNum = parseInt((contentHeight - 730) / 50)
			if(newChkNum > 0){
				pageUnit += newChkNum;
				$("#annual_dashboard").css("height", Number($("#annual_dashboard").css("height").replace("px", "")) + (newChkNum * 50) + "px");
			}
		}
		var pageNum = parseInt(annualListSize / pageUnit);
		if(annualListSize % pageUnit != 0){
			pageNum ++;
		}
		
		for(var i=0; i<pageNum; i++){
			$("#annual_dashboard_list_all").append("<div class='annual_dashboard_list_area' id='d_area_" + i + "'></div>");
		}
		
		for(var i=0; i<annualListSize; i++){
			var page = parseInt(i / pageUnit);
			var color;
			var annualType;
			var annualTypeEng;
			switch(annualList[i]["annual_type"]){
			case "0":
				annualType = "연차";
				annualTypeEng = "Day Off";
				color = "#660b6b";
				break;
			case "1":case "2":
				annualType = "반차";
				annualTypeEng = "Half-Day Off";
				color = "#ce6a00";
				break;
			case "3":
				annualType = "기타";
				annualTypeEng = "";
				color = "#558624";
				break;
			}
			
			var _startDate = new Date(annualList[i]["start_date"]);
			var _endDate = new Date(annualList[i]["end_date"]);
			
			if(calDateDiff(annualList[i]["start_date"], annualList[i]["end_date"]) == 1){
				$("#d_area_" + page).append("<div class='annual_dashboard_element'>"
						+ "<div class='d_title_type' style='background-color:" + color + "'><div style='padding-top:2px;'>" + annualType + "</div></div>"
						/* + "<div class='d_title'><div class='d_title_title' style='color:" + color + "'>" + annualType + " " + annualTypeEng + "</div></div>" */
						+ "<div class='d_term'><div style='float:left;color:#014a8a'>" + setDateString(_startDate.getMonth() + 1) + "." + setDateString(_startDate.getDate()) + "</div>&nbsp;&nbsp;&nbsp;" 
						+ annualList[i]["annual_applicant_position"] + " " + annualList[i]["annual_applicant"] + "</div>");
			}else{
				$("#d_area_" + page).append("<div class='annual_dashboard_element'>"
						+ "<div class='d_title_type' style='background-color:" + color + "'><div style='padding-top:2px;'>" + annualType + "</div></div>"
						/* + "<div class='d_title'><div class='d_title_title' style='color:" + color + "'>" + annualType + " " + annualTypeEng + "</div></div>" */
						+ "<div class='d_term'><div style='float:left;color:#014a8a'>" + setDateString(_startDate.getMonth() + 1) + "." + setDateString(_startDate.getDate()) + " ~ " + setDateString(_endDate.getMonth() + 1) + "." + setDateString(_endDate.getDate()) + "</div>&nbsp;&nbsp;&nbsp;" 
						+ annualList[i]["annual_applicant_position"] + " " + annualList[i]["annual_applicant"] + "</div>");				
			}
		}
		
		$("#annual_dashboad_list_all").hide();
		$("#annual_dashboad_list_all").fadeIn();
	}else{
		$("#annual_dashboard_list").append("<div id='no_data_dashboard'>이번 주 휴가자가 없습니다.</div>");
	}
	
	var moveLen = aniIdx * -277;
	$("#annual_dashboard_list_all").animate({
		"margin-left" : moveLen + "px"
	});
	
	var pageChk = annualListSize % pageUnit == 0 ? true : false;
	var pageNum;
	if(pageChk){
		pageNum = parseInt(annualListSize / pageUnit) -1;
	}else{
		pageNum = parseInt(annualListSize / pageUnit);
	}
	
	if(aniIdx == pageNum){
		aniIdx = 0;
	}else{
		aniIdx ++;	
	}
}

$().ready(function() {
	init();
});

</script>
<style>

#calendar_table th{
    width: 130px;
    height: 28px;
    background-color: #212121;
    color: white;
    border: 1px solid;
    border-color: black;
    font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

#calendar_table td{
    width: 130px;
    height: 92px;
    background-color: #171717;
    color: white;
    vertical-align: top;
    border: 1px solid;
    border-color: #2f2f2f;
    font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

#annual_calendar{
	float:left;
	position: relative;
    z-index: 200;
    margin-top: 25px;
    width:933px;
}

#annual_calendar_top{
	width: 919px;
}
#annual_calendar_title{
	margin-bottom:15px;
	font-size: 29pt;
	font-weight:bold;
	font-family:auto;
	text-shadow: 0px 1px, 1px 0px, 1px 1px;
}

#annual_calendar_btn{
	height:35px;
	margin-bottom:-30px;
}

#annual_calendar_btn_pre{
	float:right;
	height:26px;
	width:25px;
	margin-right:6px;
	background-image:url(<c:url value="/resources/images/calendar/pre_btn.png"/>);
	background-size: 25px;
	cursor:pointer;
}

#annual_calendar_btn_pre:hover{
	background-image:url(<c:url value="/resources/images/calendar/pre_btn_over.png"/>);
}

#annual_calendar_btn_next{
	float:right;
	height:26px;
	width:25px;
	margin-left:6px;
	background-image:url(<c:url value="/resources/images/calendar/next_btn.png"/>);
	background-size: 25px;
	cursor:pointer;
}

#annual_calendar_btn_next:hover{
	background-image:url(<c:url value="/resources/images/calendar/next_btn_over.png"/>);
}

#annual_calendar_btn_today{
	float:right;
	height:25px;
	width:55px;
	color:white;
	background-image:linear-gradient(#563b77,#847892);
	border-radius:12px;
	box-shadow:0.5px 0.5px 2px;
	font-size: 8pt;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
	text-align:center;
	cursor:pointer;
}

#annual_calendar_btn_today:hover{
	background-image:linear-gradient(#3b2852,#494252);
}

#annual_calendar_btn_add{
	float:right;
	height:24.5px;
	width:25px;
	margin-right:6px;
	background-image:url(<c:url value="/resources/images/calendar/add_btn.png"/>);
	background-size: 25px;
	margin-top:1px;
	cursor:pointer;
}

#annual_calendar_btn_add:hover{
	background-image:url(<c:url value="/resources/images/calendar/add_btn_over.png"/>);
}

.n_mon_date{
	text-align:center;
	width: 22px;
	height: 22px;
    font-size: 8pt;
    margin-top:5px;
    margin-left: 102px;
    border-radius: 16px;
}

.o_mon_date{
	text-align:right;
	color:#505050;
	margin-top:11px;
	margin-right:15px;
}

#annual_calednar_background{
	width:620px;
	height:620px;
	position: absolute;
    z-index: 100;
}

.annual_element_label{
	margin-top:1px;
	margin-left:5px;
}

.annual_element_0{
	height: 18px;
    position: absolute;
    background: #660b6b;
    border-radius: 5px;
    font-size: 8pt;
    font-weight: 200;
	font-family:NanumGothic, sans-serif;
}

.annual_element_0:hover{
	box-shadow: 0px 0px 15px #f238ff;
}

.annual_element_1{
	height: 18px;
    position: absolute;
    background: #ce6a00;
    border-radius: 5px;
    font-size: 8pt;
    font-weight: 200;
	font-family:NanumGothic, sans-serif;
}

.annual_element_1:hover{
	box-shadow: 0px 0px 15px #ff8400;
}

.annual_element_2{
	height: 18px;
    position: absolute;
    background: #ce6a00;
    border-radius: 5px;
    font-size: 8pt;
    font-weight: 200;
	font-family:NanumGothic, sans-serif;
}

.annual_element_2:hover{
	box-shadow: 0px 0px 15px #ff8400;
}

.annual_element_3{
	height: 18px;
    position: absolute;
    background: #177700;
    border-radius: 5px;
    font-size: 8pt;
    font-weight: 200;
	font-family:NanumGothic, sans-serif;
}

.annual_element_3:hover{
	box-shadow: 0px 0px 15px #29ff5b;
}

#annual_info_tooltip{
	position: absolute;	
	width: 320px;
    height: 28px;
    top:300px;
    left:300px;
    border-radius: 5px;
    z-index: 300;
    background-color: #f4d5ff;
    display:none;
}

#annual_info_tooltip_tra {
	content: '';
    position: absolute;
    width: -30px;
    height: -29px;
    border-style: solid;
    border: 8px solid;
    border-color: #f4d5ff transparent transparent transparent;
    bottom: -15px;
    left: 8px;
}

#annual_info_tooltip_text{
	font-size: 9pt;
	font-weight: bold;
	font-family:NanumGothic, sans-serif;
	padding-top: 5.1px;
    margin-left: 6px;
    color:#313131;
}

#annual_dashboard{
	float: left;
	width: 277px;
    height: 585px;
    margin-top: 28px;
}

#annual_dashboard_list{
	height: 100%;
    width: 277px;
    overflow:hidden;
}

.annual_dashboard_element{
	width: 270px;
    height: 20px;
    margin-top: 30px;
    margin-left: 8px;
}

.d_title{
	font-weight: bold;
    font-family: Verdana, sans-serif;
    padding-top:26px;
    width:100%;
    height:30px;
}

.d_title_title{
	float:left;
	font-weight:bold;
	font-size: 15pt;
	width:243px;
	color: #444444;
}

.d_term{
	font-size: 11pt;
	padding-top:4px;
	margin-left: 54px;
    font-family: Verdana, sans-serif;
    text-shadow: 0px 1px, 1px 0px, 1px 1px;
    color: #444444;
}

.d_name{
	font-size: 13pt;
	font-weight: bold;
    font-family: Verdana, sans-serif;
    margin-top: 29px;
    text-align: right;
    text-shadow: 0px 1px, 1px 0px, 1px 1px;
    margin-right: 20px;
    color: #444444;
}

.d_title_type{
	float:left;
	width: 32px;
    height: 20px;
    padding: 2px 5px;
    text-align: center;
    border-radius: 12px;
	font-weight: bold;
    font-family: Verdana, sans-serif;
    color:white;
}

.annual_dashboard_list_area{
	height:100%;
	width:277px;
	float:left;
}

#annual_dashboard_title{
	font-size: 19pt;
    font-family: Verdana, sans-serif;
    text-align:center;
    text-shadow: 0px 1px, 1px 0px, 1px 0.5px;
}

#no_data_dashboard{
	font-size: 13pt;
	font-weight: bold;
    font-family: NanumGothic, sans-serif;
    text-align:center;
    margin-top:300px;
}

</style>
<form name="calendarForm">
	<input type="hidden" name="page_year" value="">
	<input type="hidden" name="page_mon" value="">
	<br>
	<div style="margin-left:32px;margin-top:10px;">
		<div id="annual_calendar_top">
			<div id="annual_calendar_title"></div>
			<div id="annual_calendar_btn">
				<div id="annual_calendar_btn_next"></div>
				<div id="annual_calendar_btn_today"><div style="padding-top:4px;">Today</div></div>
				<div id="annual_calendar_btn_pre"></div>
				<div id="annual_calendar_btn_add"></div>
			</div>
		</div>
		<%-- <img id="annual_calednar_background" src='<c:url value="/resources/images/calendar/calendar_background.png" />'/> --%>
		<div id="annual_info_tooltip">
			<div id="annual_info_tooltip_text"></div>
			<div id="annual_info_tooltip_tra"></div>
		</div>
		<div id="annual_calendar"></div>
		<div id="annual_dashboard">
			<div id="annual_dashboard_title">This week's vacation</div>
			<div id="annual_dashboard_list">
				<div id="annual_dashboard_list_all"></div>
			</div>
		</div>
	</div>
</form>
<img src='<c:url value="/resources/images/common/loading-circle.gif" />'
	alt="loading now..."
	style="display: none; position: absolute; left: 50%; top: 50%;"
	id="loading_img" />