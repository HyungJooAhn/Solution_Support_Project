<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">

<c:import url="/WEB-INF/jsp/mon/earthmap_graph.jsp" />

<script src="https://d3js.org/d3.v4.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/d3/4.1.1/d3.min.js"></script>   
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
	viewDetail(gCONTEXT_PATH + 'tist/taxii_server_form.html');
}

function goDetailView(id) {
	viewDetail(gCONTEXT_PATH + "tist/taxii_server_form.html?taxii_server_id=" + id);
}

var drawServerList = function(){
	
};

var refresh = function() {
	drawServerList();
};

function initBtnColor(){
	$(".btn-aside").css("background-color", "#2c726d");
}
function btnColorCtrl($btn){
	$btn.on("click", function(){
		initBtnColor();
		if($btn.hasClass("open")){
			$btn.css("background-color", "#274543");
		}else{
			$btn.css("background-color", "#2c726d");
		}
	});
}

function getContentsStatus(async){
	var data = [];
	$.ajax({
		type : "POST",
		url : "/mon/contents_status.json",
		contentType : "application/json",
		data : JSON.stringify({all:true}),
		dataType : "json",
		async : async,
		success : function(rsJson) {
			var map = rsJson.data
			data.push(map["parser"])
			data.push(map["log_parser"])
			data.push(map["event"])
			data.push(map["senario_event"])
			data.push(map["rel_event"])
			data.push(map["blacklist"])
			data.push(map["vxshare"])
		}
	})
	
	return data;
}

var contentsDataIdx = 0;
var contentsData;
var contentCol = ["Parser", "Log Parser", "Event Ruleset", "Scenario Event", "Relation Analysis", "Harmful IP", "VXSHare"];

function initContentsDashboardSummary(){
	contentsData = getContentsStatus(false);
	
	for(var i=0; i<contentsData.length; i++){
		$("#contents_slide_div").append("<span class='component_data'>" + contentsData[i] + "</span><br>")
	}
	
	$("#component_data_col_contents").text(contentCol[contentsDataIdx]);
	$("#component_data_col_contents").hide();
	$("#component_data_col_contents").fadeIn();
	
	contentsDataIdx ++;
}

function contentsDashboardSummary(){
	var moveUnit = -40;
	if(contentsDataIdx == contentsData.length){
		$("#contents_slide_div").empty();
		
		for(var i=0; i<contentsData.length; i++){
			$("#contents_slide_div").append("<span class='component_data'>" + contentsData[i] + "</span><br>")
		}
		contentsDataIdx = 0;
		contentsData = getContentsStatus(true);
	}
	
	var slidePercent = contentsDataIdx * moveUnit;
	
	$("#contents_slide_div").animate({
		'margin-top': slidePercent + "%"
	});
	
	$("#component_data_col_contents").text(contentCol[contentsDataIdx]);
	$("#component_data_col_contents").hide();
	$("#component_data_col_contents").fadeIn();
	
	contentsDataIdx ++;
}

function getTIStatus(async){
	var data = [];
	$.ajax({
		type : "POST",
		url : "/mon/ti_status.json",
		contentType : "application/json",
		data : JSON.stringify({all:true}),
		dataType : "json",
		async : async,
		success : function(rsJson) {
			var map = rsJson.data
			data.push(map["relation"])
			data.push(map["indicator"])
			data.push(map["rss"])
			data.push(map["collect"])
			data.push(map["analysis"])
		}
	})
	return data;
}

var tiDataIdx = 0;
var tiData;
var tiCol = ["Relationship", "Indicator", "RSS", "수집현황", "분석현황"];

function initTiDashboardSummary(){
	tiData = getTIStatus(false);
	
	for(var i=0; i<tiData.length; i++){
		$("#ti_slide_div").append("<span class='component_data'>" + tiData[i] + "</span><br>")
	}
	
	$("#ti_data_col_contents").text(tiCol[tiDataIdx]);
	$("#ti_data_col_contents").hide();
	$("#ti_data_col_contents").fadeIn();
	
	tiDataIdx ++;
}
function tiDashboardSummary(){
	var moveUnit = -40;
	if(tiDataIdx == tiData.length){
		$("#ti_slide_div").empty();
		
		for(var i=0; i<tiData.length; i++){
			$("#ti_slide_div").append("<span class='component_data'>" + tiData[i] + "</span><br>")
		}
		tiDataIdx = 0;
		tiData = getTIStatus(true);
	}
	var slidePercent = tiDataIdx * moveUnit;
	$("#ti_slide_div").animate({
		'margin-top': slidePercent + "%"
	});
	
	$("#ti_data_col_contents").text(tiCol[tiDataIdx]);
	$("#ti_data_col_contents").hide();
	$("#ti_data_col_contents").fadeIn();
	
	tiDataIdx ++;

}

function getDownloadStatus(async){
	var data = [];
	$.ajax({
		type : "POST",
		url : "/mon/download_status.json",
		contentType : "application/json",
		data : JSON.stringify({all:true}),
		dataType : "json",
		async : async,
		success : function(rsJson) {
			var map = rsJson.data
			data.push(map["v31_all_in_one"])
			data.push(map["v31_patch"])
			data.push(map["v30_all_in_one"])
			data.push(map["v30_patch"])
			data.push(map["v25_all_in_one"])
			data.push(map["v25_patch"])
		}
	})
	return data;
}

var downloadDataIdx = 0;
var downloadData;
var downloadCol = ["v3.1 All-in-One", "v3.1 Patch", "v3.0 All-in-One", "v3.0 Patch", "v2.5 All-in-One", "v2.5 Patch"];

function initDownloadDashboardSummary(){
	downloadData = getDownloadStatus(false);
	for(var i=0; i<downloadData.length; i++){
		$("#download_slide_div").append("<span class='component_data'>" + downloadData[i] + "</span><br>")
	}
	$("#download_data_col_contents").text(downloadCol[downloadDataIdx]);
	$("#download_data_col_contents").hide();
	$("#download_data_col_contents").fadeIn();
	
	downloadDataIdx ++;
}
function downloadDashboardSummary(){
	var moveUnit = -40;
	if(downloadDataIdx == downloadData.length){
		$("#download_slide_div").empty();
		for(var i=0; i<downloadData.length; i++){
			$("#download_slide_div").append("<span class='component_data'>" + downloadData[i] + "</span><br>")
		}
		downloadDataIdx = 0;
		downloadData = getDownloadStatus(true);
	}
	var slidePercent = downloadDataIdx * moveUnit;
	$("#download_slide_div").animate({
		'margin-top': slidePercent + "%"
	});
	
	$("#download_data_col_contents").text(downloadCol[downloadDataIdx]);
	$("#download_data_col_contents").hide();
	$("#download_data_col_contents").fadeIn();
	
	downloadDataIdx ++;
}

function getIssueStatus(async){
	var data = [];
	$.ajax({
		type : "POST",
		url : "/mon/issue_status.json",
		contentType : "application/json",
		data : JSON.stringify({all:true}),
		dataType : "json",
		async : async,
		success : function(rsJson) {
			var map = rsJson.data
			data.push(map["new"])
			data.push(map["improve"])
			data.push(map["error"])
			data.push(map["etc"])
		}
	})
	return data;
}

var issueDataIdx = 0;
var issueData;
var issueCol = ["신규", "개선", "오류", "기타"];

function initIssueDashboardSummary(){
	issueData = getIssueStatus(false);
	for(var i=0; i<issueData.length; i++){
		$("#issue_slide_div").append("<span class='component_data'>" + issueData[i] + "</span><br>")
	}
	$("#issue_data_col_contents").text(issueCol[issueDataIdx]);
	$("#issue_data_col_contents").hide();
	$("#issue_data_col_contents").fadeIn();
	
	issueDataIdx ++;
}

function issueDashboardSummary(){
	
	var moveUnit = -40;
	
	if(issueDataIdx == issueData.length){
		$("#issue_slide_div").empty();
		for(var i=0; i<issueData.length; i++){
			$("#issue_slide_div").append("<span class='component_data'>" + issueData[i] + "</span><br>")
		}
		issueDataIdx = 0;
		issueData = getIssueStatus(true);
	}
	var slidePercent = issueDataIdx * moveUnit;
	$("#issue_slide_div").animate({
		'margin-top': slidePercent + "%"
	});
	
	$("#issue_data_col_contents").text(issueCol[issueDataIdx]);
	$("#issue_data_col_contents").hide();
	$("#issue_data_col_contents").fadeIn();
	
	issueDataIdx ++;
}

function getBoardStatus(){
	var data = [];
	$.ajax({
		type : "POST",
		url : "/mon/board_status.json",
		contentType : "application/json",
		data : JSON.stringify({all:true}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			var map = rsJson.data
			data.push(map["tech"])
			data.push(map["secu"])
			data.push(map["manual"])
			data.push(map["laboratory"])
			data.push(map["sales"])
			data.push(map["business_sup"])
			data.push(map["TS"])
			data.push(map["business"])
			data.push(map["new_tech"])
			data.push(map["consulting"])
			data.push(map["service"])
		}
	})
	return data;
}

var slBoardTextIdx = 0;
var graphData;
var slBoardDataCnt = 0;

function drawPieChart(){
	
	$("#sl_board_area").empty();
	var w = 300, h = 300;
	graphData = getBoardStatus();
	
	slBoardDataCnt = d3.sum(graphData);

	if(slBoardDataCnt != 0){
		var colorData = ["#bb1717", "#ff5400", "#1f8623", "#ffc000", "#3a9fab", "#944823", "#46a09a", "#2b288c", "#4b337d", "#b1309d", "#4f9c4c"];
		var pie = d3.pie();
		var arc = d3.arc().innerRadius(65).outerRadius(120);

		var svg = d3.select("#sl_board_area")
			.append("svg")
			.attr("width", w)
			.attr("height", h)
			.attr("id", "graphWrap");

		var g = svg.selectAll(".pie")
			.data(pie(graphData))
			.enter()
			.append("g")
			.attr("class", "pie")
			.attr("transform","translate("+w/2+","+h/2+")");

		g.append("path")
			//.attr("d", arc)
			.style("fill", function(d, i) {
				return colorData[i];
			})
			.transition()
			.duration(800)
			.attrTween("d", function(d, i) { // 보간 처리
				var interpolate = d3.interpolate(
					{startAngle : d.startAngle, endAngle : d.startAngle},
					{startAngle : d.startAngle, endAngle : d.endAngle}
				);
				return function(t){
					return arc(interpolate(t));
				}
			});

		g.append("text")
			.attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; })
			.attr("dy", ".35em")
			.attr("class", "chart_label")
			.style("text-anchor", "middle")
			.style("font-weight", "bold")
			.text(function(d, i) {
				return graphData[i];
			});
		
		$(".chart_label").hide();
		$(".chart_label").fadeIn();
		
		var totalDataSrc = "<div id='d3_total_text'><span style='color:black;font-size:17pt;margin-left:11px;'>Total</span>"
						   + "<div style='height:10px;margin-top:3px;border-top:solid 1px #656464'></div>" 
						   + "<div style='text-align:center'><span style='color:black;font-size:13pt;'>" + d3.sum(graphData) + "</span></div></div>";
		$("#sl_board_area").append(totalDataSrc);
		var gList = $("#sl_board_area").find("g");
		for(var i=0; i<gList.length; i++){
			gList[i].id = "pie_" + i
		}
	}else{
		$("#sl_board_area").append("<div style='font-size:15pt;font-family:NanumGothic, sans-serif;font-weight:bold;padding-top:135px;margin-left:82px;'>No Board Data</div>");
		$("#sl_board_area").append("<div style='height:10px;margin-top:3px;width:173px;margin-left:61px;border-top:solid 1px #656464'></div>");
	}
}

var chartAniIdx = 0;

function pieChartAni(){
	//var slList = ["기술연구본부", "영업본부", "HQ본부", "기술지원팀", "사업지원개발팀", "신기술팀", "컨설팅팀", "서비스지원팀", "기술백서", "제품 매뉴얼", "보안동향보고서", "Board Status"]
	var slList = ["기술백서", "보안동향보고서", "제품 매뉴얼", "기술연구본부", "영업본부", "HQ본부", "기술지원팀", "사업지원개발팀", "신기술팀", "컨설팅팀", "서비스지원팀", "Board Status"]
	slBoardDataCnt = d3.sum(graphData);
	
	if(slBoardDataCnt != 0){
		if(chartAniIdx == 11){
			$("#sl_board_title").text(slList[chartAniIdx]);
			$("#sl_board_title").hide();
			$("#sl_board_title").fadeIn();
			$("#sl_board_title").css("color", "#33618a");
			$("#sl_board_title").css("font-size", "17pt");
			
			drawPieChart();
			chartAniIdx = -1;
		}else{
			$("#sl_board_area").find(".pie").animate({
				"opacity":'0.35'
			})										
			
			$("#pie_" + chartAniIdx).animate({
				"opacity":'1'
			});	

			$("#sl_board_title").css("color", "black");
			$("#sl_board_title").css("font-size", "16pt");
			$("#sl_board_title").text(slList[chartAniIdx]);
			$("#sl_board_title").hide();
			$("#sl_board_title").fadeIn();
		}
		chartAniIdx++;
	}else{
		chartAniIdx = 11;
		graphData = getBoardStatus();
	}
}

function getReservationList(async, today){
	var data = [];
	$.ajax({
		type : "POST",
		url : "/mon/reservation_list.json",
		contentType : "application/json",
		data : JSON.stringify({date:today}),
		dataType : "json",
		async : async,
		success : function(rsJson) {
			var list = rsJson.data
			data = makeReservationList(list)
		}
	})
	return data;
}
function changeTimeToNum(time){
	var first = time.split(":")[0];
	var second = time.split(":")[1];
	if(second == "30"){
		second = 0.5;
	}else{
		second = 0;
	}
	var result = Number(first) + second;
	return result;
}
function makeReservationList(list){
	var result = [];
	
	for(var k=0; k<list.length-1; k++){
		for(var t=0; t<list.length-1; t++){
			if(changeTimeToNum(list[t]["start_time"]) > changeTimeToNum(list[t+1]["start_time"])){
				var tmp = list[t+1];
				list[t+1] = list[t];
				list[t] = tmp;
			}
		}
	}
	
	for(var i=0; i<list.length; i++){
		var ele = "";
		ele += list[i]["room"];
		ele += list[i]["start_time"] + " ~ "; 
		ele += list[i]["end_time"] + " "; 
		ele += list[i]["subject"]; 
		result.push(ele);
	}
	
	return result;
}
var meetingRoomIdx = 0;
var reservationOrd = true
var reservationData;

function todayMeetingRoomSlide(){
	var now = new Date();
	var nowDate = now.getFullYear() + "-";
	var mon = now.getMonth()+1;
	var date = now.getDate();
	
	if(mon < 10){
		nowDate += "0" + mon;
	}else{
		nowDate += mon;
	}
	
	if(date < 10){
		nowDate += "-0" + date;
	}else{
		nowDate += "-" + date;
	}
	
	if(reservationOrd){
		reservationData = getReservationList(false, nowDate);
		reservationOrd = false;
	}
	
	$("#meeting_room_slide_area").empty();
	var slideWidth = 0;
	var slideCnt = 0;
	var slideWidthUnit = 260;

	if((reservationData != null) && (reservationData.length != 0)){
		if(reservationData.length % 4 == 0){
			slideCnt = reservationData.length / 4;
			slideWidth = slideWidthUnit * slideCnt;
		}else{
			slideCnt = (parseInt(reservationData.length / 4)) + 1;
			slideWidth = slideWidthUnit * slideCnt;
		}
	
		$("#meeting_room_slide_area").css("width", slideWidth);
		for(var i=0; i<slideCnt; i++){
			$("#meeting_room_slide_area").append("<div class='meeting_room_component_area' id='meeting_room_component_area_" + i + "'></div>")	
			for(var k=i*4; k<(i*4)+4; k++){
				if(k == reservationData.length){
					break;
				}
				var longStr = "";
				if(((reservationData[k].substring(1)).length > 20) && ((reservationData[k][0] == "1" || reservationData[k][0] == "2"))){
					for(var t=1; t<20; t++){
						longStr += reservationData[k][t];
					}
					longStr += "...";
					$("#meeting_room_component_area_" + i).append("<div class='meeting_room_component_" + reservationData[k][0] + "'><div class='meeting_room_component_text'>" + longStr + "</div></div>");
					
				}else if((reservationData[k].substring(2)).length > 20){
					for(var t=2; t<21; t++){
						longStr += reservationData[k][t];
					}
					longStr += "...";
					$("#meeting_room_component_area_" + i).append("<div class='meeting_room_component_3'><div class='meeting_room_component_text' style='color:#f9f9f9;'>" + longStr + "</div></div>");
					
				}else{
					if(reservationData[k][0] == "1" || reservationData[k][0] == "2"){
						$("#meeting_room_component_area_" + i).append("<div class='meeting_room_component_" + reservationData[k][0] + "'><div class='meeting_room_component_text'>" + reservationData[k].substring(1) + "</div></div>");
					}else{
						$("#meeting_room_component_area_" + i).append("<div class='meeting_room_component_3'><div class='meeting_room_component_text' style='color:#f9f9f9;'>" + reservationData[k].substring(2) + "</div></div>");
					}
				}
			}
		}
		
		if(meetingRoomIdx == slideCnt){
			meetingRoomIdx = 0;
			reservationData = getReservationList(false, nowDate);
		}
	
		$("#meeting_room_slide_area").animate({
			'margin-left': (meetingRoomIdx * -100) + "%"
		});
		meetingRoomIdx ++;
	}else{
		$("#meeting_room_slide_area").append("<div style='font-size:15pt;font-family:NanumGothic, sans-serif;font-weight:bold;margin-left:61px;margin-top:83px;'>No Reservation</div>")
	}
}

function todayClock(){
	var now = new Date();
	var nowDate = now.getFullYear() + "-";
	var mon = now.getMonth()+1;
	var date = now.getDate();
	var hour = now.getHours();
	var min = now.getMinutes();
	
	if(mon < 10){
		nowDate += "0" + mon;
	}else{
		nowDate += mon;
	}
	
	if(date < 10){
		nowDate += "-0" + date;
	}else{
		nowDate += "-" + date;
	}
	
	$("#today_date").text(nowDate);
	
	if(hour < 10){
		$("#tm_hour").text("0" + hour);
	}else{
		$("#tm_hour").text(hour);
	}
	
	if(min < 10){
		$("#tm_min").text("0" + min);
	}else{
		$("#tm_min").text(min);
	}
	
	$("#time_div").hide();
	$("#time_div").show(200);
}

function todayVisitor() 
{   
	$.ajax({
		type : "POST",
		url : "/mon/today_visitor.json",
		contentType : "application/json",
		data : JSON.stringify({all:true}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			var visitorData = rsJson.data;
			$("#today_visitor").text(visitorData["today"])
			$("#yesterday_visitor").text(visitorData["yesterday"])
		}
	});
} 

var indicatorNameList = [ 'CVE' , 'IP' , 'FILENAME' , 'MD5', 'SHA1' , 'SHA256' , 'URL'];
var indicatorOrd = false;

function getIndicatorData(){
	var indicatorCountList = [];
	
	$.ajax({
		type : "POST",
		url : "/networkmap/indicator_top_monitoring.json",
		contentType : "application/json",
		data : JSON.stringify({}),
		dataType : "json",
		async : false,
		success : function(rsJson, statusText, xhr, $form) {
			var list = rsJson.list;
			for(var i = 0 ; i < indicatorNameList.length; i++){
				var indicator = indicatorNameList[i];
				for(var idx = 0; idx < list.length; idx++){
					var data = list[idx];
					if(data.indicator == indicator){
						indicatorCountList.push(data.count)
						break;
					} 
				}
			}
		}
	});
	
	return indicatorCountList;
}
function generateChart(data){
	var svg = d3.select("#barchart"),
	margin = 150,
	width = svg.attr("width") - margin,
	height = svg.attr("height") - margin
	
	svg.append("text")
	.attr("transform", "translate(100,0)")
	.attr("x", 145)
	.attr("y", 50)
	.style("font-size", "17pt")
	.style("font-weight", "bold")
	.text("Indicator Top Chart");
	
	var xScale = d3.scaleBand().range([0, width]).padding(0.4),
	    yScale = d3.scaleLinear().range([height, 0]);
	
	var g = svg.append("g").attr("transform", "translate(" + 100 + "," + 80 + ")");
	
	
	xScale.domain(data.map(function(d) { return d.indicator; }));
	yScale.domain([0, d3.max(data, function(d) { return d.count; })]);
	
	g.append("g")
	.attr("transform", "translate(0," + height + ")")
	.call(d3.axisBottom(xScale))
	.append("text")
	.attr("y", 45)
	.attr("x", 275)
	.attr("text-anchor", "end")
	.attr("stroke", "black")
	.text("Indicator");
	
	g.append("g")
	.call(d3.axisLeft(yScale).tickFormat(function(d){
	    return d;
	})
	.ticks(5))
	.append("text")
	.attr("transform", "rotate(-90)")
	.attr("y", 8)
	.attr("x", -75)
	.attr("dy", "-5.1em")
	.attr("text-anchor", "end")
	.attr("stroke", "black")
	.text("Count");
	
	g.selectAll(".bar")
	.data(data)
	.enter().append("rect")
	.attr("class", "bar")
	.attr("x", function(d) { return xScale(d.indicator); })
	.attr("y", "-191")
	.attr("width", xScale.bandwidth())
	.attr("height", function(d) { return height - yScale(d.count); })
	
	
	var barList = $("#barchart").find("rect");
	for(var k=0; k<barList.length; k++){
		data[k]["x"] = $(barList[k]).attr("x");
		data[k]["height"] = $(barList[k]).attr("height");
	}
	
	svg.selectAll("text").select("div")
    .data(data)
    .enter().append("text")
	.attr("class", "text")
	.text(function(d) {return d.count})
	.attr("x", function(d, i) {
		var count = d.count;
		var ctrlNum = 0;
		if(count < 10){
			ctrlNum = 4;
		}else if(count < 100){
			ctrlNum = 0;
		}else{
			ctrlNum = -6;
		}
		return 113 + Number(d.x) + ctrlNum})
    .attr("y", function(d, i) {
    	return 300 - (Number(d.height) + 50)}
    )
    
    var barList = $("#barchart").find("rect");
    var textList = $("#barchart").find(".text");
    
	for(var i=0; i<barList.length; i++){
		$(textList[i]).hide();
		$(textList[i]).fadeIn(3000);
		
		$(barList[i]).css("transform", "rotateX(180deg)")
		$(barList[i]).css("height", "0px")
		$(barList[i]).animate({
			"height" : $(barList[i]).attr("height") + "px" 
		},4000)
	}
}

function drawIndicatorChart(){
	
	var data = [];
	var list = getIndicatorData();
	
	for(var i=0; i<list.length; i++){
		var tmp = {"indicator" : indicatorNameList[i], "count" : list[i], "x":0};
		data.push(tmp);
	}
	if(indicatorOrd){
		var removeList = $("#barchart").find("rect");
		var removeTextList = $("#barchart").find(".text");
		
		for(var k=0; k<removeList.length; k++){
			$(removeTextList[k]).fadeOut();
			
			$(removeList[k]).animate({
				"height" : "0px"
			},{duration : 2000, complete: function _completeCallback() {
					$("#barchart").empty();
					generateChart(data)
				}
			})
		}
	}else{
		generateChart(data)
		indicatorOrd = true;
	}
}

var indicatorAnalysisGroupList = [];
var indicatorAnalysisOrd = true;

function getIndicatorGroupData(){
	$.ajax({
		type : "POST",
		url : "/threat/indicator_group_list.json",
		contentType : "application/json",
		data : JSON.stringify({}),
		dataType : "json",
		async : false,
		success : function(rsJson, statusText, xhr, $form) {
			var list = rsJson.data;
			var topCnt = 2;
			
			for(var m=0; m < topCnt; m++){
				var max = -1;
				var idx = 0;
				for(var i=0; i < list.length; i++){
					if(max < list[i]["group_cnt"]){
						max = list[i]["group_cnt"];
						idx = i;
					}
				}	
				indicatorAnalysisGroupList.push(list[idx]);
				list.splice(idx, 1);
			}
		}
	});
}

function getIndicatorAnalysisData(){
	var nodeData;
	$.ajax({
		type : "POST",
		url : "/threat/indicator_all_list.json",
		contentType : "application/json",
		data : JSON.stringify({top_group : indicatorAnalysisGroupList}),
		dataType : "json",
		async : false,
		success : function(rsJson, statusText, xhr, $form) {
			var list = rsJson.data;
			nodeData = makeNodeData(list);
		}
	});
	return nodeData;
}

function randomRange(min, max) {
	return Math.floor( Math.random()  * (max - min + 1) + min );
}
	
function makeNodeData(list){
	var leafNodeGroupList = [30, 40, 50, 60, 70];
	var indicatorListByGroup = {};
	var result = [];
	for(var i=0; i<indicatorAnalysisGroupList.length; i++){
		var groupName = indicatorAnalysisGroupList[i].system_name;
		var tmpArr = [];
		for(var w=0; w<list.length; w++){
			if(groupName == list[w].system_name){
				tmpArr.push(list[w]);
			}	
		}
		indicatorListByGroup[groupName] = tmpArr;
	}
	
	for(var i=0; i<indicatorAnalysisGroupList.length; i++){
		var nodes = [];
		var links = [];
		var nData = {};
		var groupName = indicatorAnalysisGroupList[i].system_name;
		var groupCode = indicatorAnalysisGroupList[i].system_code;
		var nodeList = indicatorListByGroup[groupName];
		
		nodes.push({"name" : groupName, "group" : 1});
		nodes.push({"name" : "Property", "group" : 10});
		nodes.push({"name" : "Indicator", "group" : 20});
		
		links.push({"source" : 1 , "target" : 0})
		links.push({"source" : 2, "target" : 0})
		
		for(var w=0; w<nodeList.length; w++){
			var randomIdx = randomRange(0, 4);
			if(nodeList[w]["type_name"] == "Property"){
				nodes.push({"name" : nodeList[w]["field_nm"], "group" : leafNodeGroupList[randomIdx]});
				links.push({"source" : (w + 3), "target" : 1});
			}else{
				nodes.push({"name" : nodeList[w]["field_nm"], "group" : leafNodeGroupList[randomIdx]});
				links.push({"source" : (w + 3), "target" : 2});
			}
			if(w > 10){
				break;
			}
		}
		nData["nodes"] = nodes;
		nData["links"] = links;
		result.push(nData);
	}
	return result;
}

function generatorIndicatorAnalysisChart(nData, divId){
	var width = 336, height = 240;
	var svg = d3.select("#" + divId).append("svg")
		.attr("width", width)
 		.attr("height", height);

	var force = d3.forceSimulation()
		.force("charge", d3.forceManyBody().strength(-150).distanceMin(100).distanceMax(1000)) 
        .force("link", d3.forceLink().id(function(d) { return d.index })) 
        .force("center", d3.forceCenter(width / 2, height / 1.5))
        .force("y", d3.forceY(0.001))
        .force("x", d3.forceX(0.001))

	var color = function (group) {
		if (group == 1) {
		    return "#ffc000";
		}else if (group == 10){
			return "#3d6d3b";
		}else if(group == 20){
		    return "#2a7782";
		}else if(group == 30){
		    return "#ff8400";
		}else if(group == 40){
		    return "#d646b9";
		}else if(group == 50){
		    return "#303d67";
		}else if(group == 60){
		    return "#ff3d2e";
		}else if(group == 70){
		    return "#6ad612";
		}
	}
	
	function dragstarted(d) {
	    if (!d3.event.active) force.alphaTarget(0.5).restart();
	    d.fx = d.x;
	    d.fy = d.y;
	}
	
	function dragged(d) {
	    d.fx = d3.event.x;
	    d.fy = d3.event.y;
	}
	
	function dragended(d) {
	    if (!d3.event.active) force.alphaTarget(0.5);
	    d.fx = null;
	    d.fy = null;
	} 
	
	function radiusCal(group){
		if(group == 1){
			return 22;
		}else if(group == 10 || group == 20){
			return 15;
		}else{
			return 10;
		}
	}
	function groupNameDx(d){
		if(d.group == 1){
			return d.name.length * -3; 
		}else if(d.group == 10 || d.group == 20){
			return d.name.length * -2.5;
		}else{
			return d.name.length * -2.6;
		}
	}
	
	function groupNameDy(d){
		if(d.group == 1){
			return 5;
		}
	}
	
    force
        .nodes(nData.nodes) 
        .force("link").links(nData.links)

    var link = svg.selectAll(".link")
        .data(nData.links)
        .enter()
        .append("line")
        .attr("class", "link");

    var node = svg.selectAll(".node")
        .data(nData.nodes)
        .enter().append("g")
        .attr("class", "node")
        .call(d3.drag()
        .on("start", dragstarted)
        .on("drag", dragged)
        .on("end", dragended));  

    node.append('circle')
        .attr('r', function(d){
        	return radiusCal(d.group);
        })
        .attr('fill', function (d) {
            return color(d.group);
        });

    node.append("text")
        .attr("dx", function(d){
        	return groupNameDx(d);
        })
        .attr("dy", 5)
        .style("font-family", "NanumGothic, sans-serif")
        .style("font-size", "8pt")
        .style("cursor", "default")
        .style("font-weight", "bold")

        .text(function (d) {
            return d.name
        });

    force.on("tick", function () {
        link.attr("x1", function (d) {
                return d.source.x;
            })
            .attr("y1", function (d) {
                return d.source.y;
            })
            .attr("x2", function (d) {
                return d.target.x;
            })
            .attr("y2", function (d) {
                return d.target.y;
            });
        node.attr("transform", function (d) {
            return "translate(" + d.x + "," + d.y + ")";
        });
    });
}
function drawIndicatorAnalysisChart(){
	if(indicatorAnalysisOrd){
		getIndicatorGroupData();	
		indicatorAnalysisOrd = false;
	}
	
	$("#component_indicator_analysis_chart_id").empty();
	var nDataList = getIndicatorAnalysisData();
	
	for(var i=0; i<nDataList.length; i++){
		$("#component_indicator_analysis_chart_id").append("<div class='component_indicator_analysis_area' id='component_indicator_analysis_area_" + i + "'></div>")
		if(i == 0){
			$("#component_indicator_analysis_chart_id").append("<div style='float:left;height:230px;width:1px;background:white;margin-top:30px;'></div>")	
		}
		generatorIndicatorAnalysisChart(nDataList[i], "component_indicator_analysis_area_" + i);
	}
	$("#component_indicator_analysis_chart_id").append("<div id='component_indicator_analysis_group_name_div' style='width:672px;'><div class='component_indicator_analysis_group_name'><span>" + nDataList[0]["nodes"][0]["name"]+ "</span></div><div class='component_indicator_analysis_group_name'><span>" + nDataList[1]["nodes"][0]["name"] + "</span></div>")
	$("#component_indicator_analysis_group_name_div").hide();
	$("#component_indicator_analysis_group_name_div").fadeIn();
}

function goComponent(name){
	switch(name){
	case "contents":
		location = "<c:url value="/management/parser_list.do" />";
		break;
	case "ti":
		location = "<c:url value="/threat/relationship/relationship_list.do" />";
		break;
	case "download":
		location = "<c:url value="/download/download_menu_list.do" />";
		break;
	case "issue":
		location = "<c:url value="/issue/issue_list.do" />";
		break;
	case "harmful":
		location = "<c:url value="/event/blacklist_list.do?menu_idx=2" />";
		break;
	case "board":
		location = "<c:url value="/information/community_list.do?s_type_cd=96903840493731962" />";
		break;
	case "reservation":
		location = "<c:url value="/reservation/reservation.do" />";
		break;
	case "indicator":
		location = "<c:url value="/networkmap/monitoring.do" />";
		break;
	case "indicator_analysis":
		location = "<c:url value="/threat/indicator/indicator_list.do" />";
		break;
	}
}

function goReservation(){
	location = "<c:url value="/reservation/reservation.do" />";
}

$(function() {
	$("#dashboard_main_area").hide();
	$("#dashboard_main_area").fadeIn();
	
	$(".top_logo").css("padding-top", "20px");
	
	initContentsDashboardSummary();
	setInterval(contentsDashboardSummary, 3000);
	
	initTiDashboardSummary()
	setInterval(tiDashboardSummary, 3000);
	
	initDownloadDashboardSummary();
	setInterval(downloadDashboardSummary, 3000);
	
	initIssueDashboardSummary();
	setInterval(issueDashboardSummary, 3000);
	
	drawPieChart();
	setInterval(pieChartAni, 5000);
	
	todayClock();
	setInterval(todayClock, 1000);
	
	todayMeetingRoomSlide();
	setInterval(todayMeetingRoomSlide, 10000);
	
	todayVisitor();
	
	drawIndicatorChart();
	setInterval(drawIndicatorChart, 20000);
	
	drawIndicatorAnalysisChart();
	setInterval(drawIndicatorAnalysisChart, 60000);
	
	var browser = navigator.userAgent.toLowerCase();
	if(browser.indexOf("msie") != -1){
		$("#component_title_contents").css("margin-left", "37px");
		$("#component_title_ti").css("margin-left", "31px");
		$("#component_title_download").css("margin-left", "37px");
		$("#component_title_issue").css("margin-left", "47px");
	}
	setInterval(function(){
		location.reload();
	}, 1800000);
});

</script>
<style>

#dashboard_title{
	font-family:Modem;
	font-size:17pt;
	font-weight:bold;
	color:#669bb5;
	margin-top:16px;
	margin-left:-20px;
	float:left;
	width:200px;
}
#dashboard_visitor{
	font-family:Modem;
	font-size:13pt;
	font-weight:bold;
	margin-top:16px;
	float:right;
	width:200px;
}

#dashboard_main_area{
	width:100%;
	margin-top:10px;
	margin-left:-36px;
}

.component_M{
	width:310px;
	height:160px;
	box-shadow:0.5px 0.5px 3px;
	border-radius:18px;
	margin-top:15px;
	margin-left:55px;
	float:left;
}

.component_L{
	width:675px;
	height:340px;
	box-shadow:0.5px 0.5px 3px;
	border-radius:18px;
	margin-top:50px;
	margin-left:55px;
	float:left;
	overflow:hidden;
}

.component_LONG{
	width:310px;
	height:340px;
	box-shadow:0.5px 0.5px 3px;
	border-radius:18px;
	margin-top:50px;
	margin-left:55px;
	float:left;
	overflow:hidden;
}

.component_title_LONG{
	color:white;
	font-size:18pt;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

.component_title{
	position:absolute;
	color:white;
}

.component_exptend{
	height:23px;
	margin-top:34px;
	border-bottom-right-radius:18px;
    border-bottom-left-radius:18px;
}

.component_slide_area{
	width:150px;
	height:73px;
	margin-left:144px;
	text-align:center;
	overflow:hidden;
}
.component_data{
	font-size:30pt;
	font-weight:bold;
	position: relative;
	color:white;
}

.component_slie_div{
	height:200%;
}

.component_vertical_line{
	border-left:solid;
	border-left-width:thin;
	height:110px;
	width:10px;
	float:left;
	margin-left:135px;
	margin-top:26px;
	color:white;
}

.component_data_col{
	color:white;
	margin-left:5px;
	float:left;
	width:140px;
	text-align:center;
}

#sl_board_area{
	margin-left:4px;
	margin-top:2px;
	height:400px;
	width:400px;
}

#sl_board_title{
	margin-top:-114px;
	color:#33618a;
	text-align:center;
	font-size:17pt;
	font-family:NanumGothic, sans-serif;
	font-weight:bold;
}

#d3_total_text{
	position:absolute;
	bottom:155px;
	margin-left:111px;
	margin-bottom:383px;
	width:75px;
}

#graphWrap{
 	-webkit-filter: drop-shadow( 0px 3px 3px rgba(0,0,0,.5) );
    filter: drop-shadow( 0px 3px 3px rgba(0,0,0,.5) );
}

#meeting_room_area{
	width:260px;
	height:197px;
	box-shadow:0.5px 0.5px 3px;
	border-radius:18px;
	margin-top:9px;
	margin-left:27px;
	overflow:hidden;
	background:#ccc8c8;
}

#today_time_area{
	text-align:center;
	color:white;
	font-family:NanumGothic, sans-serif;
	font-size:15pt;
	font-weight:bold;
	margin-top:5px;
}
.today_time{
	color:#f9eabb;
}

.meeting_room_component_1{
	width:234px;
	height:35px;
	margin-left:12px;
	margin-top:11px;
	border-radius:12px;
	box-shadow:0.5px 0.5px 3px;
	background:rgb(76, 175, 80);
}

.meeting_room_component_2{
	width:234px;
	height:35px;
	margin-left:12px;
	margin-top:11px;
	border-radius:12px;
	box-shadow:0.5px 0.5px 3px;
	background:rgb(255, 204, 51);
}

.meeting_room_component_3{
	width:234px;
	height:35px;
	margin-left:12px;
	margin-top:11px;
	border-radius:12px;
	box-shadow:0.5px 0.5px 3px;
	background:rgb(152, 21, 21);
}

#meeting_room_slide_area{
	height:197px;
}

.meeting_room_component_area{
	width:260px;
	height:197px;
	float:left;
}
.meeting_room_component_text{
	color:#464646;
	font-weight:bold;
	margin-left:10px;
	padding-top:5.5px;
}
.visitor{
	margin-left:10px;
}
#component_contents_id{
	background:#bb1717;
	cursor:pointer;
}

#component_contents_id:hover{
	background:#9a1e1e;
}

#component_ti_id{
	background:#1f8623;
	cursor:pointer;
}

#component_ti_id:hover{
	background:#236325;
}

#component_download_id{
	background:#ffc000;
	cursor:pointer;
}

#component_download_id:hover{
	background:#d8ac24;
}

#component_issue_id{
	background:#3a9fab;
	cursor:pointer;
}

#component_issue_id:hover{
	background:#3c8b94;
}

#component_harmful_id{
	background:#1f3d63;
}

#component_board_id{
	background:#e4d9d9;
	cursor:pointer;
}

#component_board_id:hover{
	background:#bbafaf;
}
#component_reservation_id{
	background:#863b98;
	cursor:pointer;
}

#component_reservation_id:hover{
	background:#6b3877;
}

#component_indicator_id{
	background:#ffc000;
	cursor:pointer;
}

#component_indicator_id:hover{
	background:#d8ac24;
}

#component_indicator_analysis_id{
	background:#921212;
}

#component_harmful_detail{
	width: 675px;
    height: 20px;
    background-color: rgba(0,0,0,0.5);
    margin-top: -132px;
    z-index: 10;
    position: relative;
    text-align:right;
    cursor:pointer;
}

#component_indicator_analysis_detail{
	width: 675px;
    height: 20px;
    background-color: #fbfb99;
    margin-top: 278px;
    z-index: 10;
    position: relative;
    text-align:right;
    cursor:pointer;
}

#component_harmful_detail:hover{
	background-color: rgba(0,0,0,1);
}

#component_indicator_analysis_detail:hover{
	background-color: #dcdc77;
}

.component_detail_text{
	font-size:9pt;
	font-weight:bold;
	margin-right:13px;
	color:white;
	font-family:NanumGothic, sans-serif;
}

#component_license_text{
	float:left;
	font-size:7pt;
	font-weight:bold;
	margin-left: 14px;
    margin-top: 3px;
	color:#cccccc;
	font-family:NanumGothic, sans-serif;
}

.component_indicator_analysis_area{
	width:336;
	height:240;
	float:left;
}

.component_indicator_analysis_group_name{
	width:336;
	height:20px;
	float:left;
	text-align:center;
	color:white;
	font-family:NanumGothic, sans-serif;
	font-size:16pt;
	font-weight:bold;
	margin-top:-17px;
}

.link {
  stroke: #aaa;
}

</style>
<div style="margin-left:3%">
	<div style="width:100%;height:49px;">
		<div id="dashboard_title">Dashboard<img style="width:40px;height:40px;margin-bottom:3px;" src="<c:url value="/resources/images/dashboard/dashboard_title.gif" />"/></div>
		<div id="dashboard_visitor"><span class="visitor" style="margin-left:-55px;color:#5696e8;">Today</span><span id="today_visitor" class="visitor"></span><span class="visitor" style="color:#81c149;">Yesterday</span><span id="yesterday_visitor" class="visitor"></span></div>
	</div>
	<div id="dashboard_main_area">
		<div class="component_M" id="component_contents_id" onclick="javascript:goComponent('contents')">
			<span class="component_title" style="margin-left:-109px;margin-top:31px;" id="component_title_contents">Contents</span>
			<img style="width:70px;height:60px;margin-left:-110px;margin-top:62px;" src="<c:url value="/resources/images/dashboard/contents_icon.png"/>"/>
			<div class="component_vertical_line"></div>
			<div class="component_slide_area" style="margin-top:-88px;">
				<div class="component_slie_div" id="contents_slide_div">
				</div>
			</div>
			<div class="component_data_col"><span id="component_data_col_contents"></span></div>
		</div>
		<div class="component_M" id="component_ti_id" onclick="javascript:goComponent('ti')">
		<span class="component_title" style="margin-left:-113px;margin-top:20px;" id="component_title_ti">Threat<br>Intelligence</span>
		<img style="width:65px;height:65px;margin-left:-107px;margin-top:69px;" src="<c:url value="/resources/images/dashboard/ti_icon.png"/>"/>
		<div class="component_vertical_line"></div>
			<div class="component_slide_area" style="margin-top:-100px;">
				<div class="component_slie_div" id="ti_slide_div">
				</div>
			</div>
			<div class="component_data_col"><span id="ti_data_col_contents"></span></div>
		</div>
		<div class="component_M" id="component_download_id" onclick="javascript:goComponent('download')">
			<span class="component_title" style="margin-left:-111px;margin-top:31px;" id="component_title_download">Download</span>
			<img style="width:90px;height:90px;margin-left:-117px;margin-top:48px;" src="<c:url value="/resources/images/dashboard/download_icon.png"/>"/>
			<div class="component_vertical_line"></div>
			<div class="component_slide_area" style="margin-top:-103px;">
				<div class="component_slie_div" id="download_slide_div">
				</div>
			</div>
			<div class="component_data_col"><span id="download_data_col_contents"></span></div>
		</div>
		<div class="component_M" id="component_issue_id" onclick="javascript:goComponent('issue')">
			<span class="component_title" style="margin-left:-96px;margin-top:31px;" id="component_title_issue">Issue</span>
			<img style="width:70px;height:65px;margin-left:-110px;margin-top:61px;" src="<c:url value="/resources/images/dashboard/issue_icon.png"/>"/>
			<div class="component_vertical_line"></div>
			<div class="component_slide_area" style="margin-top:-90px;">
				<div class="component_slie_div" id="issue_slide_div">
				</div>
			</div>
			<div class="component_data_col"><span id="issue_data_col_contents"></span></div>
		</div>
		
		<div class="component_L" id="component_harmful_id">
			<span class="component_title" style="margin-left:572px;margin-top:22px;">Harmful IP</span>
			<div id="chartdiv" style="margin-top:-48px;position:relative;z-index:5;"></div>
			<div id="component_harmful_detail" onclick="javascript:goComponent('harmful')"><!-- <span id="component_license_text">JS map by amCharts</span> --><span class="component_detail_text">Detail >></span></div>
		</div>
		<div class="component_LONG" id="component_board_id" onclick="javascript:goComponent('board')">
			<div id="sl_board_area"></div>
			<div id="sl_board_title">Board Status</div>
		</div>
		<div class="component_LONG" id="component_reservation_id" onclick="javascript:goComponent('reservation')">
			<div style="margin-top:15px;">
				<span class="component_title_LONG" style="margin-left:30px;">Today's</span><br>
				<span class="component_title_LONG" style="margin-left:73px;">Meeting Room</span>
				<div id="meeting_room_area" onclick="javascript:goReservation()">
					<div id="meeting_room_slide_area"></div>
				</div>
				<div id="today_time_area"><span id="today_date"></span> <span class="today_time" id="tm_hour"></span><span class="today_time" id="time_div">:</span><span class="today_time" id="tm_min"></span></div>
			</div>
		</div>
		<div class="component_L" id="component_indicator_id" onclick="javascript:goComponent('indicator')">
			<svg width="675" height="340" id="barchart"></svg>
		</div>
		<div class="component_L" id="component_indicator_analysis_id">
			<div style="text-align:center;height:30px;margin-top:15px;">
				<span style="color:white;font-family:NanumGothic, sans-serif;font-size:16pt;font-weight:bold">Indicator Top Node Analysis</span>
			</div>
			<div id="component_indicator_analysis_chart_id"></div>
			<div id="component_indicator_analysis_detail" onclick="javascript:goComponent('indicator_analysis')"><span class="component_detail_text" style="color:black">Detail >></span></div>
		</div>
	</div>
	<br>
</div>
