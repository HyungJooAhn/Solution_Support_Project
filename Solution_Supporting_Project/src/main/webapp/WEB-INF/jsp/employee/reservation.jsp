<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript">

function viewDetail(url){
	var modal = new ModalPopup(url, {
		width:450, height:210,		//모달 사이즈 옵션으로 조절 가능
		//draggable : true,				// draggable 선택 가능(기본 값 : false)
		onClose : function(){
			refresh();
		}
	});
}

function goAddForm() {
	viewDetail(gCONTEXT_PATH + "reservation/reservation_form.html");
}

function goAddFormSelect(date) {
	viewDetail(gCONTEXT_PATH + "reservation/reservation_form.html?selected_date=" + date);
}

function goDetailView(id) {
	viewDetail(gCONTEXT_PATH + "reservation/reservation_form.html?reservation_id=" + id);
}

function reservationPop(){
	
}

function refresh(){
	location.reload();
}

function calendarDraw(){
	
	$("#calendar").empty();
	$('#calendar').fullCalendar({
		lang: 'ko',
		header: {
					left: "" ,//month,basicWeek, basicDay",
					right: "today, prev, next",
					center:"title"
				},
		titleFormat: {
					month: "YYYY MMMM"
				},
		views: {
			//month: { buttonText: '월간일정' },
			//basicWeek: { buttonText: '주간일정' },
			//basicDay: { buttonText: '일일일정' }
		},
		navLinks: true, 
		defaultView: 'month',

		dayNamesShort: ["일","월","화","수","목","금","토"],
		monthNames: ["1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월"],
		editable: true,
		eventLimit: true, 
		events: [

			<c:forEach var="row" items="${calendar_data}" varStatus="loop">
			   {	start: '${row.reservation_date}'//'${row.evt_dd}'
				    ,className: '<c:choose><c:when test="${row.reservation_room eq '1'}">calendar_contents_1</c:when><c:when test="${row.reservation_room eq '2'}">calendar_contents_2</c:when><c:otherwise>calendar_contents_3</c:otherwise></c:choose>'
					,title: '${row.start_time} ~ ${row.end_time} ${row.reservation_applicant_position} ${row.reservation_applicant}'
					,url:'javascript:goDetailView("${row.id}")'
				}
				${!loop.last ? ',' : ''}
				</c:forEach>,
		],
	});
	
	$("#calendar").css("margin-left", "2.3%");
	$("#calendar").css("width", "95%");
	$(".fc-center").css("font-size", "18pt").css("font-family", "맑은고딕").css("font-weight", "bold").css("margin-right", "80px");
	$(".fc-left").append("<button class='btn-basic btn-add' type=button>예약</button>")
	$(".fc-left").append("<svg height='30' width='30'> <circle cx='15' cy='13' r='9' fill='#4caf50' /><span id='room_info_1'>1호실</span></svg>")
	$(".fc-left").append("&nbsp;<svg height='30' width='30'> <circle cx='15' cy='13' r='9' fill='#FFCC33' /><span id='room_info_2'>2호실</span></svg>")
	$(".fc-left").append("&nbsp;<svg height='30' width='30'> <circle cx='15' cy='13' r='9' fill='#981515' /><span id='room_info_2'>전체 호실</span></svg>")
	$(".btn-add").on("click", goAddForm);
	
	mappingAddForm();
	addButtonCtrl();
	
}

function mappingAddForm(){
	var now = new Date();
	var nowYear = now.getFullYear();
	var nowMon = now.getMonth() + 1;
	var nowDate = now.getDate();
	
	var weekList = $(".fc-row");
	for(var i=0; i<weekList.length; i++){
		var dayList = $(weekList[i]).find(".fc-day");
		dayList.css("vertical-align", "bottom");
		
		for(var k=0; k<dayList.length; k++){
			var thisDate = $(dayList[k]).attr("data-date");
			
			var thisYear = Number(thisDate.split("-")[0]);
			var thisMon = Number(thisDate.split("-")[1]);
			var thisDay = Number(thisDate.split("-")[2]);
			
			if((nowYear > thisYear) || ((nowYear == thisYear) && (nowMon > thisMon)) || ((nowYear == thisYear) && (nowMon == thisMon) && (nowDate > thisDay))){
				$(dayList[k]).css("background-color", "#f5f5f5");
			}else{
				if(!$(dayList[k]).hasClass("fc-other-month")){
					$(dayList[k]).append("<div onclick='javascript:goAddFormSelect(\"" + thisDate + "\")' class='reservation_add' style=''>예약</div>");
				}
			}
		}
	}
}
function addButtonCtrl(){
	$(".reservation_add").mouseover(function(){
		$(this).css("background-color", "#ffe8a0")
	});
	
	$(".reservation_add").mouseout(function(){
		$(this).css("background-color", "white")
	});
	
	$(".reservation_add").mousedown(function(){
		$(this).css("background-color", "#ffd34f")
	});
	
	$(".reservation_add").mouseup(function(){
		$(this).css("background-color", "white")
	});
}
$().ready(function() {
	calendarDraw();
	
	$(".fc-today-button").on("click", function(){
		mappingAddForm();
		addButtonCtrl();
	});
	$(".fc-prev-button").on("click", function(){
		mappingAddForm();
		addButtonCtrl();
	});
	$(".fc-next-button").on("click", function(){
		mappingAddForm();
		addButtonCtrl();
	});
});

</script>
<style>
#room_info_1{
	margin-left:0;
	padding-top:5px;
	font-family:맑은고딕;
	font-size:10pt;
	font-weight:bold;
}

#room_info_2{
	margin-left:0;
	padding-top:5px;
	font-family:맑은고딕;
	font-size:10pt;
	font-weight:bold;
}

#calendar .calendar_contents_1 {
	width:164px;

}
.calendar_contents_1 .fc-content {	
	padding:4px 8px;
	color:#fff;
	border: 1px solid #4caf50;
    background-color: #4caf50;
	border-radius: 10px;
}

#calendar .calendar_contents_2 {
	width:164px;

}
.calendar_contents_2 .fc-content {	
	padding:4px 8px;
	color:black;
	border: 1px solid #FFCC33;
    background-color: #FFCC33;
	border-radius: 10px;
}

#calendar .calendar_contents_3 {
	width:164px;

}
.calendar_contents_3 .fc-content {	
	padding:4px 8px;
	color:white;
	border: 1px solid #981515;
    background-color: #981515;
	border-radius: 10px;
}

.reservation_add{
	text-align:center;
	width:100%;
	cursor:pointer;
	background:white;
}
</style>
<form name="searchForm">
	<input type="hidden" name="menu_idx" value="${param.menu_idx}">
	<input type="hidden" name="s_type_cd" value="${param.s_type_cd}">
	<input type="hidden" name="page_identify" value="stix_taxii">
	<input type="hidden" name="listCount" value="${listCount}"> <input
		type="hidden" name="sttIndex" value="${sttIndex}"> <input
		type="hidden" name="pageRow" value="15">
	<div class="sub_search" style="border: 0px; margin-left: -15px;">
		<div class="sub_title03">회의실 예약</div>
	</div>
	<br>
	<div id='calendar'></div>
</form>
<img src='<c:url value="/resources/images/common/loading-circle.gif" />'
	alt="loading now..."
	style="display: none; position: absolute; left: 50%; top: 50%;"
	id="loading_img" />