<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript">

function updateServerStatus(){
	$("#server_status_val").fadeOut()
	$("#service_status_val").fadeOut()
	$.ajax({
		type : "POST",
		url : "/tist/hub_spoke_taxii_server_status.json",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({all:true}),
		dataType : "json",
		success : function(rsJson) {
			var statusMap = rsJson.data;
			if(statusMap != null){
				if(statusMap["server_status"] == "1"){
                	$("#server_status_val").text("On");
                    $("#server_status_val").css("color", "#80ff00");
	            }else{
	                $("#server_status_val").text("Off");
	                $("#server_status_val").css("color", "#a90000");
	            }
	
	            if(statusMap["service_status"] == "1"){
	                $("#service_status_val").text("On");
	                $("#service_status_val").css("color", "#80ff00");
	            }else{
	                $("#service_status_val").text("Off");
	                $("#service_status_val").css("color", "#a90000");
	            }
	            
			}else{
				$("#server_status_val").text("Unable to check");
				$("#service_status_val").text("Unable to check");
			}
			 $("#server_status_val").fadeIn()
             $("#service_status_val").fadeIn()
		}
	});
}

function initServerInfo(){
	$.ajax({
		type : "POST",
		url : "/tist/hub_spoke_taxii_server_info.json",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({}),
		dataType : "json",
		success : function(rsJson) {
			var serverInfo = rsJson.data;
			
			$("#server_component_info").append("<span>Name : " + serverInfo["name"] + "</span><br><br>")
			$("#server_component_info").append("<span>Addr : " + serverInfo["url"] + " : " + serverInfo["port"] + "</span><br><br>")
			if(serverInfo["ssl"] == "Y"){
				$("#server_component_info").append("<span>SSL : On </span><br><br>")	
			}else{
				$("#server_component_info").append("<span>SSL : Off </span><br><br>")
			}
			
			$("#server_component_info").append("<span>Server Status : </span><span id='server_status_val'></span><br><br>")
			$("#server_component_info").append("<span>Service Status : </span><span id='service_status_val'></span><br><br>")
			$("#server_status_val").css("color", "#000000");
			$("#service_status_val").css("color", "#000000");
		}
	});
}

var threatServerIdList = [];
var pageTotal = 0;
function drawThreatServerInfo(page){
	$("#threat_sharing_component_list").empty();
	
	var pageUnit = 3;
	var pageNum = $("[name=threat_sharing_list_page]").val();
	if(pageNum == 1){
		$("#threat_sharing_list_up_icon").css("visibility", "hidden");
	}
	$.ajax({
		type : "POST",
		url : "/tist/hub_spoke_taxii_threat_server_info.json",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({}),
		dataType : "json",
		success : function(rsJson) {
			var threatServerList = rsJson.data;
			var threatServerListLen = threatServerList.length;
			$("#threat_sharing_list_total").text(threatServerList.length);
			$("[name=threat_sharing_list_cnt]").val(threatServerList.length);
			
			var startIdx = (page - 1) * pageUnit;
			for(var i=startIdx; i<(startIdx+3); i++){
				if(i < threatServerListLen){
					threatServerIdList.push(threatServerList[i]["id"]);
					$("#threat_sharing_component_list").append("<div class='threat_sharing_component' id='threat_sharing_component_" + threatServerList[i]["id"] + "'>"
					+ "<div class='threat_sharing_server_component_detail' id='threat_sharing_server_component_detail_" + threatServerList[i]["id"] + "' onclick='javascript:showThreatServerSetting(" + threatServerList[i]["id"] + ")'>"
					+ "<img id='threat_sharing_setting_icon_" + threatServerList[i]["id"] + "' style='margin-top:42px;margin-left:9px;width:30px' src='<c:url value='/resources/images/threat/hstaxii/threat_setting_icon.png'/>'/></div>"
					+ "<div class=threat_sharing_server_component_info>"
					+ "<div class='threat_sharing_server_name'>" + threatServerList[i]["name"] + "</div>"
					+ "<div class='threat_sharing_server_info'>"
					+ "<span>URL : " + threatServerList[i]["url"] + "</span><br>"
					+ "<div style='height:10px;'></div>"
					+ "<span>Collection : " + threatServerList[i]["collection"] + "</span></div></div>"
					+ "<div class='div_line'></div>"
					+ "<img class='threat_server_icon' src='<c:url value='/resources/images/threat/hstaxii/threat_sharing_icon.png'/>'/></div>"
					+ "<div class='threat_sharing_server_component_setting' id='threat_sharing_server_component_setting_" + threatServerList[i]["id"] + "'></div>"
					);
				}
			}
			
			if(threatServerListLen % pageUnit == 0){
				pageTotal = threatServerListLen / pageUnit;
			}else{
				pageTotal = parseInt(threatServerListLen / pageUnit) + 1;
			}
			
			if(pageNum == pageTotal){
				$("#threat_sharing_list_down_icon").css("visibility", "hidden");
			}
		}
	});
}

var threatServerSetting = true;
function setThreatServerSettingView(id){
	if(threatServerSetting){
		$("#threat_sharing_server_component_setting_" + id).empty();
		$.ajax({
			type : "POST",
			url : "/tist/hub_spoke_taxii_threat_server_info.json",
			contentType : "application/json",
			async: false,
			data : JSON.stringify({server_id:id}),
			dataType : "json",
			success : function(rsJson) {
				var threatServerInfo = rsJson.data[0];
				if(threatServerInfo["port"] == null){
					threatServerInfo["port"] = "";
				}

				var tableStr = "<table class='threat_sharing_server_table' id='threat_sharing_server_table_" + id + "'>"
				+ "<tr><th>Name</th><td>" + threatServerInfo["name"] + "</td></tr>"
				+ "<tr><th>URL</th><td>" + threatServerInfo["url"] + "</td></tr>"
				+ "<tr><th>Port</th><td>" + threatServerInfo["port"] + "</td></tr>"
				+ "<tr><th>Service Path</th><td>" + threatServerInfo["service_path"] + "</td></tr>"
				+ "<tr><th>User</th><td>"
				
				if(threatServerInfo["user_name"].length > 21){
					tableStr += threatServerInfo["user_name"].substring(0,21) + "...";
				}else{
					tableStr += threatServerInfo["user_name"];
				}
				tableStr += "</td></tr>"
				+ "<tr><th>Collection</th><td>" + threatServerInfo["collection"] + "</td></tr>"
				+ "<tr><th>SSL</th><td>";
				
				if(threatServerInfo["ssl"] == "Y"){
					tableStr += "Y"
				}else{
					tableStr += "N"
				}
				tableStr += "</td></tr></table>";
				
				$("#threat_sharing_server_component_setting_" + id).append("<div id='threat_sharing_server_setting_line_" + id + "' style='width:4px;height:90px;position:absolute;background:#255f6f;margin-left:14px;margin-top:20px;'></div>"
				+ "<div><img onclick='javascript:deleteThreatSharingServerSetting(" + id + ")' class='detail_setting_icon' id='detail_setting_icon_del_" + id + "' style='width:15px;margin-top:4px;margin-left:214px;' src='<c:url value='/resources/images/threat/hstaxii/detail_delete_icon.png'/>'/></div>"
				+ "<div><img onclick='javascript:setThreatServerSetting(" + id + ")' class='detail_setting_icon' id='detail_setting_icon_set_" + id + "' style='width:15px;margin-top:4px;' src='<c:url value='/resources/images/threat/hstaxii/detail_setting_icon.png'/>'/></div>"
				+ tableStr)
			}
		});
		threatServerSetting = false;
	}
}

function setThreatServerSetting(id){
	$("#threat_sharing_server_component_setting_" + id).empty();
	$.ajax({
		type : "POST",
		url : "/tist/hub_spoke_taxii_threat_server_info.json",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({server_id:id}),
		dataType : "json",
		success : function(rsJson) {
			var threatServerInfo = rsJson.data[0];
			if(threatServerInfo["port"] == null){
				threatServerInfo["port"] = "";
			}
			$("#threat_sharing_server_component_setting_" + id).append("<div id='threat_sharing_server_setting_line_" + id + "' style='width:4px;height:159px;position:absolute;background:#255f6f;margin-left:14px;margin-top:20px;'></div>"
			+ "<div><img onclick='javascript:saveThreatServerSetting(" + id + ")' style='margin-top:160px;' class='detail_setting_icon' id='detail_setting_icon_save_" + id + "' src='<c:url value='/resources/images/threat/hstaxii/detail_save_icon.png'/>'/></div>"
			+ "<div><img onclick='javascript:cancelThreatServerSetting(" + id + ")' style='margin-top:160px;margin-left:214px;' class='detail_setting_icon' id='detail_setting_icon_cancel_" + id + "' src='<c:url value='/resources/images/threat/hstaxii/detail_cancel_icon.png'/>'/></div>"
			+ "<table class='threat_sharing_server_table' id='threat_sharing_server_table_" + id + "'>"
			+ "<tr><th>Name</th><td><input name='threat_server_name' maxlength='20' data-valid='Name,required,namenum' value='" + threatServerInfo["name"] + "'></td></tr>"
			+ "<tr><th>URL</th><td><input name='threat_server_url' maxlength='200' data-valid='URL,required' value='" + threatServerInfo["url"] + "'></td></tr>"
			+ "<tr><th>Port</th><td><input name='threat_server_port' maxlength='5' data-valid='Port,port' value='" + threatServerInfo["port"] + "'></td></tr>"
			+ "<tr><th>Service Path</th><td><input name='threat_server_service' maxlength='50' data-valid='Service Path,required' value='" + threatServerInfo["service_path"] + "'></td></tr>"
			+ "<tr><th>User</th><td><input name='threat_server_user_name' maxlength='200' data-valid='User,required,namenum' value='" + threatServerInfo["user_name"] + "'></td></tr>"
			+ "<tr><th>Collection</th><td><input name='threat_server_collection' maxlength='50' data-valid='Collection,required,namenum' value='" + threatServerInfo["collection"] + "'></td></tr>"
			+ "<tr><th>SSL</th><td><input value='Y' name='threat_ssl' id='threat_ssl_Y_" + id + "' type='radio' style='width:12px;float:left;' selected><span style='float:left;margin-left:7px;font-weight:bold;'>Y</span>"
			+ "<input value='N' name='threat_ssl' id='threat_ssl_N_" + id + "' type='radio' style='width:12px;margin-left:10px;float:left;'><span style='float:left;margin-left:7px;font-weight:bold;'>N</span></td></tr>"
			+ "</table>")
			
			if(threatServerInfo["ssl"] == "Y"){
				$("#threat_ssl_Y_" + id).attr('checked', true);
			}else{
				$("#threat_ssl_N_" + id).attr('checked', true);
			}
		}
	});
}

function saveThreatServerSetting(id){
	if (!_SL.validate($("#HSTaxiiForm")))return;
	
	var threatServerName = $("[name=threat_server_name]").val();
	var threatServerURL = $("[name=threat_server_url]").val();
	var threatServerPort = $("[name=threat_server_port]").val();
	var threatServerService = $("[name=threat_server_service]").val();
	var threatServerUserName = $("[name=threat_server_user_name]").val();
	var threatServerCollection = $("[name=threat_server_collection]").val();
	var threatServerSSL = $('input[name=threat_ssl]:checked').val();
	
	var pageNum = $("[name=threat_sharing_list_page]").val();
	
	$.ajax({
		type : "POST",
		url : "/tist/hub_spoke_taxii_threat_server_info_update.do",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({server_id:id, server_name:threatServerName, server_url:threatServerURL, 
			server_port:threatServerPort, server_service:threatServerService, server_user_name:threatServerUserName,
			server_collection:threatServerCollection, server_ssl:threatServerSSL}),
		dataType : "json",
		success : function(rsJson) {
			var success = rsJson.data;
			if(success != -1){
				threatServerSetting = true;
				drawThreatServerInfo(pageNum);
			}else{
				_alert("업데이트 중 오류가 발생하였습니다.");
			}
		}
	});
}

function deleteThreatSharingServerSetting(id){
	var serverCnt = $("[name=threat_sharing_list_cnt]").val();
	_confirm("삭제 하시겠습니까?",{ 
		onAgree : function(){
			var pageNum = $("[name=threat_sharing_list_page]").val();
			$.ajax({
				type : "POST",
				url : "/tist/hub_spoke_taxii_threat_server_info_delete.do",
				contentType : "application/json",
				async: false,
				data : JSON.stringify({server_id:id}),
				dataType : "json",
				success : function(rsJson) {
					var success = rsJson.data;
					if(success != -1){
						threatServerSetting = true;
						
						if(serverCnt % 3 == 1){
							$("[name=threat_sharing_list_page]").val(Number($("[name=threat_sharing_list_page]").val())-1)
							drawThreatServerInfo(pageNum - 1);
						}else{
							drawThreatServerInfo(pageNum);	
						}
					}else{
						_alert("삭제 중 오류가 발생하였습니다.");
					}
				}
			});	
		}
	});
}

function cancelThreatServerSetting(id){
	threatServerSetting = true;
	setThreatServerSettingView(id)
	$("#detail_setting_icon_set_" + id).css("margin-top", "159px")
	$("#detail_setting_icon_del_" + id).css("margin-top", "159px")
	$("#threat_sharing_server_setting_line_" + id).css("height", "159px");
}
var threatServerIdx = -1;
function showThreatServerSetting(id){

	if($("#threat_sharing_server_component_detail_" + id).hasClass("open")){
		
		$("#threat_sharing_server_component_detail_" + id).removeClass("open");
		$("#threat_sharing_server_component_detail_" + id).css("background", "#31859c");
		
		$("#threat_sharing_server_component_setting_" + id).animate({
			'margin-top':'-109px',
			'height':'112px'
		},{duration:300, step: function(now,fx){
			$("#threat_sharing_setting_icon_" + id).css("transform", "rotate(0deg)");
		}, complete: function _completeCallback() {
			$("#threat_sharing_server_component_setting_" + id).empty();
			
			$("#threat_sharing_server_table_" + id).remove();
			$("#threat_sharing_component_" + id).css("z-index", "150")
			$("#threat_sharing_server_component_setting_" + id).css("z-index", "100");
			threatServerSetting = true;
		}});	
	}else{
		if($(".threat_sharing_server_component_detail").hasClass("open")){
			threatServerSetting = true;
			for(var i=0; i<threatServerIdList.length; i++){
				if($("#threat_sharing_server_component_detail_" + threatServerIdList[i]).hasClass("open")){
					threatServerIdx = i;
					$("#threat_sharing_server_component_detail_" + threatServerIdList[i]).removeClass("open");
					$("#threat_sharing_server_component_detail_" + threatServerIdList[i]).css("background", "#31859c");
					
					$("#threat_sharing_server_component_setting_" + threatServerIdList[i]).animate({
						'margin-top':'-109px',
						'height':'112px'
					},{duration:300, step: function(now,fx){
						$("#threat_sharing_setting_icon_" + threatServerIdList[threatServerIdx]).css("transform", "rotate(0deg)");
					}, complete: function _completeCallback() {
						$("#threat_sharing_server_component_setting_" + threatServerIdList[threatServerIdx]).empty();

						$("#threat_sharing_component_" + threatServerIdList[threatServerIdx]).css("z-index", "150")
						$("#threat_sharing_server_component_setting_" + threatServerIdList[threatServerIdx]).css("z-index", "100");
						
						$("#threat_sharing_server_component_detail_" + id).addClass("open");
						$("#threat_sharing_server_component_detail_" + id).css("background", "#255f6f");
						
						$("#threat_sharing_component_" + id).css("z-index", Number($("#threat_sharing_component_" + (threatServerIdx+1)).css("z-index")) + 100)
						$("#threat_sharing_server_component_setting_" + id).css("z-index", Number($("#threat_sharing_component_" + (threatServerIdx+1)).css("z-index")) + 50);
						
						$("#threat_sharing_server_component_setting_" + id).animate({
							'margin-top':'-18px',
							'height':'180px'
						},{duration:500, step: function(now,fx){
							$("#threat_sharing_setting_icon_" + id).css("transform", "rotate(45deg)");
							$("#detail_setting_icon_set_" + id).css("margin-top", "159px")
							$("#detail_setting_icon_del_" + id).css("margin-top", "159px")
							
							$("#threat_sharing_server_setting_line_" + id).css("height", "159px");
							setThreatServerSettingView(id);
						},complete: function _completeCallback() {
							$("#threat_sharing_component_" + id).css("z-index", "250")
							$("#threat_sharing_server_component_setting_" + id).css("z-index", "200");
						}});
					}});	
				}
			}
		}else{
			$("#threat_sharing_server_component_detail_" + id).addClass("open");
			$("#threat_sharing_server_component_detail_" + id).css("background", "#255f6f");
			
			$("#threat_sharing_component_" + id).css("z-index", "250")
			$("#threat_sharing_server_component_setting_" + id).css("z-index", "200");
			
			$("#threat_sharing_server_component_setting_" + id).animate({
				'margin-top':'-18px',
				'height':'180px'
			},{duration:500, step: function(now,fx){
				$("#threat_sharing_setting_icon_" + id).css("transform", "rotate(30deg)");
				$("#detail_setting_icon_set_" + id).css("margin-top", "159px")
				$("#detail_setting_icon_del_" + id).css("margin-top", "159px")
				$("#threat_sharing_server_setting_line_" + id).css("height", "159px");
				setThreatServerSettingView(id);
			},complete: function _completeCallback() {
				$("#threat_sharing_component_" + id).css("z-index", "250")
				$("#threat_sharing_server_component_setting_" + id).css("z-index", "200");
			}});
		}
	}
}

function upThreatSharingList(){
	var nowMarginTop = Number($("#threat_sharing_component_list").css("margin-top").replace("px", "")) + 0;

	$("#threat_sharing_list_down_icon").css("visibility", "inherit");
	$("[name=threat_sharing_list_page]").val(Number($("[name=threat_sharing_list_page]").val()) - 1);
	
	var pageNum = $("[name=threat_sharing_list_page]").val();
	drawThreatServerInfo(pageNum);
	if(pageNum == 1){
		$("#threat_sharing_list_up_icon").css("visibility", "hidden");
	}
}

function downThreatSharingList(){
	var nowMarginTop = Number($("#threat_sharing_component_list").css("margin-top").replace("px", ""));
	
	$("#threat_sharing_list_up_icon").css("visibility", "inherit");
	$("[name=threat_sharing_list_page]").val(Number($("[name=threat_sharing_list_page]").val()) + 1);
	
	var pageNum = $("[name=threat_sharing_list_page]").val();
	drawThreatServerInfo(pageNum);
	if(pageNum == pageTotal){
		$("#threat_sharing_list_down_icon").css("visibility", "hidden");
	}
}

function threatSharingServerAddFormUp(){
	$(".threat_sharing_server_component_add_form").animate({
		"margin-top":"-288px"
	})
}

function threatSharingServerAddFormDown(){
	$(".threat_sharing_server_component_add_form").animate({
		"margin-top":"23px"
	})
	$("[name=threat_sharing_server_add_name]").val("");
	$("[name=threat_sharing_server_add_url]").val("");
	$("[name=threat_sharing_server_add_port]").val("");
	$("[name=threat_sharing_server_add_service]").val("");
	$("[name=threat_sharing_server_add_user]").val("");
	$("[name=threat_sharing_server_add_collection]").val("");
	$("#threat_sharing_server_add_ssl_Y").attr("checked", true);
}

function threatSharingServerAddFormSave(){
	if (!_SL.validate($("#HSTaxiiForm")))return;
	
	var threatSharingServerAddName = $("[name=threat_sharing_server_add_name]").val();
	var threatSharingServerAddURL = $("[name=threat_sharing_server_add_url]").val();
	var threatSharingServerAddPort = $("[name=threat_sharing_server_add_port]").val();
	var threatSharingServerAddServicePath = $("[name=threat_sharing_server_add_service]").val();
	var threatSharingServerAddUser = $("[name=threat_sharing_server_add_user]").val();
	var threatSharingServerAddCollection = $("[name=threat_sharing_server_add_collection]").val();
	var threatSharingServerAddSSL = $("input[name=threat_sharing_server_add_ssl]:checked").val();
	
	var serverCnt = $("[name=threat_sharing_list_cnt]").val();
	
	_confirm("추가 하시겠습니까?",{ 
		onAgree : function(){
			var pageNum = $("[name=threat_sharing_list_page]").val();
			$.ajax({
				type : "POST",
				url : "/tist/hub_spoke_taxii_threat_server_insert.do",
				contentType : "application/json",
				async: false,
				data : JSON.stringify({server_name:threatSharingServerAddName, server_url:threatSharingServerAddURL, server_port:threatSharingServerAddPort,
					server_service_path:threatSharingServerAddServicePath, server_user:threatSharingServerAddUser, server_collection:threatSharingServerAddCollection,
					server_ssl : threatSharingServerAddSSL}),
				dataType : "json",
				success : function(rsJson) {
					var success = rsJson.data;
					if(success != -1){
						if(serverCnt % 3 == 0){
							$("#threat_sharing_list_down_icon").css("visibility", "inherit");
						}
						drawThreatServerInfo(pageNum);
						$(".threat_sharing_server_component_add_form").css("margin-top", "23px");
						
						$("[name=threat_sharing_server_add_name]").val("");
						$("[name=threat_sharing_server_add_url]").val("");
						$("[name=threat_sharing_server_add_port]").val("");
						$("[name=threat_sharing_server_add_service]").val("");
						$("[name=threat_sharing_server_add_user]").val("");
						$("[name=threat_sharing_server_add_collection]").val("");
						$("#threat_sharing_server_add_ssl_Y").attr("checked", true);
					}else{
						_alert("추가 중 오류가 발생하였습니다.");
					}
				}
			});	
		}
	});
}

$().ready(function() {
	$("#version_tab").hide();
	$("#contents").css("min-height", "610px");
	initServerInfo();
	updateServerStatus();
	//setInterval(updateServerStatus, 10000);
	drawThreatServerInfo(1);
})

</script>
<style>
#threat_sharing_site_div{
	float:left;
	width:30%;
	height:556px;
	overflow:hidden;
	margin-left:7px;
}
#taxii_server_div{
	float:left;
	width:30%;
	height:581px;
	text-align:center;
}
#taxii_client_div{
	float:left;
	width:39%;
	height:581px;
}

.threat_sharing_component{
	padding-top:5px;
	margin-top:20px;
	height:110px;
	position:relative;
	z-index:150;
}

.threat_sharing_server_component_setting{
	width:267px;
	height:112px;
	border-radius:14px;
	background:#ffde7b;
	position:absolute;
	margin-top: -109px;
	z-index:100;
}

.threat_sharing_server_component_info{
	width:241px;
	height:112px;
	border-radius:14px;
	margin-left:-24px;
	background:#c4bd97;
	float:left;
	z-index:100;
	position:relative;
}

.threat_sharing_server_component_add_form{
	width:271px;
	height:320px;
	border-radius:14px;
	background:#215968;
	position: relative;
    z-index: 300;
    margin-top: 23px;
    margin-left: -11px;
}

#threat_sharing_server_component_add_form_down{
	width:100%;
	height:20px;
	border-top-left-radius:14px;
	border-top-right-radius:14px;
	border-bottom-left-radius: 0px;
    border-bottom-right-radius: 0px;
	background:#ffc000;
	position: relative;
	cursor:pointer;
}

#threat_sharing_server_component_add_form_down:hover{
	background:#cea52a;
}

.threat_sharing_server_component_detail{
	width:50px;
	height:112px;
	border-radius:13px;
	background:#31859c;
	float:left;
	z-index:200;
	position:relative;
}

.threat_sharing_server_component_detail:hover{
	cursor:pointer;
	background:#255f6f;
}

.server_component{
	width:241px;
	height:250px;
	box-shadow:0.5px 0.5px 3px;
	border-radius:33px;
	margin-top:-63px;
	margin-left:66px;
	background:linear-gradient(to bottom left, #a09e9e, #6d6464);
}

.server_component_setting_black{
	width:242px;
	height:34px;
	box-shadow:0.5px 0.5px 3px;
	border-radius:10px;
	margin-top:-33px;
	margin-left:66px;
	background:#4e4e4e;
}

.server_component_setting_yellow{
	width:242px;
	height:10px;
	box-shadow:0.5px 0.5px 1px;
	margin-top:-35px;
	margin-left:66px;
	background:#ffc000;
}

#server_component_info{
	padding-top: 52px;
    text-align: left;
    margin-left:27px;
    color:white;
    font-weight:bold;
    font-family:NanumGothic, sans-serif;
}

#threat_sharing_component_list_parent{
	height:395px;
	margin-top:-16px;
}

#threat_sharing_component_list{
	margin-top:0px;
}

.div_line{
	height: 7px;
	width: 267px;
    background: #ffc000;
    z-index: 150;
    margin-top: 88px;
    position: relative;
}
.threat_server_icon{
	margin-top:-24px;
	margin-left:-43px;
	z-index:250;
	position:relative;
	width:38px;
}

.threat_sharing_server_name{
	color: white;
    font-weight: bold;
    font-family: NanumGothic, sans-serif;
    font-size: 12pt;
    text-align: center;
    margin-top: 9px;
}

.threat_sharing_server_info{
	color: white;
    font-weight: bold;
    font-family: NanumGothic, sans-serif;
    font-size: 10pt;
    margin-left:33px;
    margin-top:9px;
}

.threat_sharing_server_table{
	margin-left:37px;
	margin-top:24px;
	color: #0d2227;
    font-size:7pt;
}

.threat_sharing_server_table tr{
	height:19px;
}

.threat_sharing_server_table th{
	font-weight: bold;
    font-family: NanumGothic, sans-serif;
	width:96px;
	text-align:left;
	color:#296271;
}

.threat_sharing_server_table td{
	font-weight: bold;
    font-family: NanumGothic, sans-serif;
	width:96px;
	text-align:left;
}

.threat_sharing_server_table input{
	font-weight: bold;
    font-family: NanumGothic, sans-serif;
	width:116px;
	height:15px;
	background: rgba(0,0,0,0);
    border: 1px solid;
}
.detail_setting_icon{
	position: absolute;
    width: 14px;
    margin-top: 4px;
    margin-left: 236px;
    cursor:pointer;
}

.detail_delet_icon{
	position: absolute;
    width: 14px;
    margin-top: 4px;
    margin-left: 236px;
    cursor:pointer;
}

#threat_sharing_list_up_icon{
    width: 22px;
    margin-left: 124px;
    margin-top: 12px;
    margin-bottom:1px;
    cursor:pointer;
}

#threat_sharing_list_down_icon{
    width: 22px;
    margin-left: 124px;
    margin-top: 11px;
    margin-bottom: 8px;
    cursor:pointer;
}

#threat_sharing_list_total{
	font-size:13pt;
    color:#2a858a;
    margin-top:6px;
    margin-bottom:6px;
}

#threat_sharing_list_add_icon{
	height:30px;
	background-image:url(<c:url value='/resources/images/threat/hstaxii/threat_sharing_server_add.png'/>);
	background-size: 37px;
	width:37px;
	height:37px;
	margin-left:190px;
	margin-top:-50px;
	cursor:pointer;
}

#threat_sharing_list_add_icon:hover{
	background-image:url(<c:url value='/resources/images/threat/hstaxii/threat_sharing_server_add_hover.png'/>);
}

#threat_sharing_server_component_add_table{
	font-weight: bold;
    font-family: NanumGothic, sans-serif;
    font-size:9pt;
    color:#f9f9f9;
    margin-left:31px;
}

#threat_sharing_server_component_add_table th{
	font-weight: bold;
    font-family: NanumGothic, sans-serif;
	width:96px;
	text-align:left;
}

#threat_sharing_server_component_add_table tr{
	height:31px;
}

#threat_sharing_server_component_add_table td{
	font-weight: bold;
    font-family: NanumGothic, sans-serif;
	width:96px;
	text-align:left;
}

#threat_sharing_server_component_add_table input{
	font-weight: bold;
    font-family: NanumGothic, sans-serif;
	width:116px;
	height:22px;
	background: rgba(0,0,0,0);
    border: 1px solid;
    border-color:#b7b7b7;
}

#threat_sharing_server_component_add_title{
	text-align:center;
	font-weight: bold;
    font-family: NanumGothic, sans-serif;
    color:#f9f9f9;
    margin-top: 10px;
    margin-bottom: 14px;
}

#threat_sharing_server_componet_add_down_icon{
    width: 22px;
    margin-left: 124px;
    margin-top:4px;
    margin-bottom: 8px;
}

#threat_sharing_server_componet_add_save_icon{
    width: 18px;
    margin-left: 239px;
    margin-top:4px;
    margin-bottom: 8px;
    cursor:pointer;
}

</style>
<form name="searchForm" id="HSTaxiiForm" action="<c:url value="/tist/hub_spoke_taxii.do" />">
	<input type="hidden" name="threat_sharing_list_page" value=1>
	<input type="hidden" name="threat_sharing_list_cnt" value=0>
	<input type="hidden" name="popup" value="${param.popup}">
	<input type="hidden" name="s_log_psr_id" value="${param.s_log_psr_id}"/>
	<div class="sub_search" style="border:0px; margin-left:-15px;">
		<div class="sub_title03">Hub and Spoke TAXII</div>
	</div>
	<br>
	<div id="threat_sharing_site_div">
		<img onclick="javascript:upThreatSharingList()" id="threat_sharing_list_up_icon" src="<c:url value='/resources/images/threat/hstaxii/threat_sharing_up_icon.png'/>"/>
		<div id="threat_sharing_component_list_parent"><div id="threat_sharing_component_list"></div></div>
		<img onclick="javascript:downThreatSharingList()" id="threat_sharing_list_down_icon" src="<c:url value='/resources/images/threat/hstaxii/threat_sharing_down_icon.png'/>"/>
		<div style="margin-top:33px;margin-left:10px;font-size:12pt;font-weight:bold;font-family: NanumGothic, sans-serif;">
			<div style="width:130px;text-align:center;">
				<div>Total</div>
				<div id="threat_sharing_list_total"></div>
				<div>Sharing Servers</div>
			</div>
			<div id="threat_sharing_list_add_icon" onclick="javascript:threatSharingServerAddFormUp()"></div>
			<div class="threat_sharing_server_component_add_form">
				<div id="threat_sharing_server_component_add_form_down" onclick="javascript:threatSharingServerAddFormDown()">
					<img id="threat_sharing_server_componet_add_down_icon" src="<c:url value='/resources/images/threat/hstaxii/threat_sharing_add_form_down_icon.png'/>"/>
				</div>
				<div id="threat_sharing_server_component_add_title">Registration</div>
				<table id="threat_sharing_server_component_add_table">
					<tr>
						<th>Name</th>
						<td><input name="threat_sharing_server_add_name" data-valid='Name,required,namenum' maxlength='20'></td>
					</tr>
					<tr>
						<th>URL</th>
						<td><input name="threat_sharing_server_add_url" data-valid='URL,required' maxlength='200'></td>
					</tr>
					<tr>
						<th>Port</th>
						<td><input name="threat_sharing_server_add_port" data-valid='Port,port' maxlength='5'></td>
					</tr>
					<tr>
						<th>Service Path</th>
						<td><input name="threat_sharing_server_add_service" data-valid='Service Path,required' maxlength='50'></td>
					</tr>
					<tr>
						<th>User</th>
						<td><input name="threat_sharing_server_add_user" data-valid='User,required,namenum' maxlength='200'></td>
					</tr>
					<tr>
						<th>Collection</th>
						<td><input name="threat_sharing_server_add_collection" data-valid='Collection,required,namenum' maxlength='50'></td>
					</tr>
					<tr>
						<th>SSL</th>
						<td>
							<input value='Y' name='threat_sharing_server_add_ssl' id='threat_sharing_server_add_ssl_Y' type='radio' style='width:12px;float:left;' checked><span style='float:left;margin-left:7px;color:#f9f9f9;'>Y</span>
							<input value='N' name='threat_sharing_server_add_ssl' id='threat_sharing_server_add_ssl_N' type='radio' style='width:12px;margin-left:10px;float:left;'><span style='float:left;margin-left:7px;color:#f9f9f9;'>N</span>
						</td>
					</tr>
				</table>
				<img onclick="javascript:threatSharingServerAddFormSave()" id="threat_sharing_server_componet_add_save_icon" src="<c:url value='/resources/images/threat/hstaxii/threat_sharing_add_form_save_icon.png'/>"/>
			</div>
		</div>
	</div>
	<div id="taxii_server_div">
		<div id="taxii_server_info_board">
			<img style="width:205px;" src="<c:url value='/resources/images/threat/hstaxii/taxii_server.png'/>"/>
			<div class="server_component">
				<div id="server_component_info">
				</div>
			</div>
			<div class="server_component_setting">
				<div class="server_component_setting_black">
					<div style="padding-top:14px;font-size:10pt;color:white;font-family:NanumGothic, sans-serif;font-weight:bold;">
						<span>Setting&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;>></span>
					</div>
				</div>
				<div class="server_component_setting_yellow"></div>
			</div>
		</div>
	</div>
	<div id="taxii_client_div">
		
	</div>
</form>
