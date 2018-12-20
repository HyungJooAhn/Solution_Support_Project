<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">

<c:import url="/WEB-INF/jsp/mon/earthmap_graph.jsp" />

<script type="text/javascript">

$(function() {
	var browserHeight = window.innerHeight;
	$("body").css("overflow", "hidden");
	$(".container").css("height", (browserHeight * 1.05) + "px");
	$("#component_license_text").css("top", (browserHeight * 0.885) + "px");
	$("#dashboard_main_area").hide();
	$("#dashboard_main_area").fadeIn();
	$(".top_logo").css("padding-top", "20px");
	
});

$(window).on('resize', function () {
    location.reload();
});
</script>
<style>

body{
	background:#1f3d63;
}
#dashboard_title{
	font-family:Modem;
	font-size:17pt;
	font-weight:bold;
	color:#ececec;
	margin-top:16px;
	margin-left:-20px;
}
#dashboard_main_area{
	width:103%;
	margin-left:-45px;
}

.component_L{
	width:100%;
	height:100%;
	box-shadow:0.5px 0.5px 3px;
	float:left;
	overflow:hidden;
}

#chartdiv{
	height:100%;
}

#component_license_text{
	position:absolute;
	float:left;
	font-size:5pt;
	font-weight:bold;
	margin-left: 3px;
    margin-top: 3px;
	color:#cccccc;
	font-family:NanumGothic, sans-serif;
}

</style>
<div style="margin-left:3%">
	<div id="dashboard_title">Dashboard<img style="width:40px;height:40px;margin-bottom:3px;" src="<c:url value="/resources/images/dashboard/dashboard_title.gif" />"/></div>
	
	<div id="dashboard_main_area">
		<div id="chartdiv" style="margin-top:-48px;margin-left:3px;"></div>
		<!-- <span id="component_license_text">JS map by amCharts</span> -->
	</div>
	<br>
</div>
