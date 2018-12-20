<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript">
var cont = [];

var
// Config 정의
mCfg = {
	formId : '#formTaxiiPull',
	urlTaxiiPull : gCONTEXT_PATH + "tist/taxii_pull_service.json",
	urlSTIXGen : gCONTEXT_PATH + "tist/taxii_pull_stix_gen.do",
},

// JQuery 객체 변수
m$ = {
	form : $(mCfg.formId),
	serverId : $(mCfg.formId + ' [name=server_id]')
},

mState = {
	isNew : m$.serverId.val() == "" ? true : false,
	mode : m$.serverId.val() == "" ? mCfg.add : mCfg.update
},

init = function() {
	
	drawSelectList();
	
	// 이벤트 Binding
	bindEvent();
	// DOM 설정 Start
	if (mState.isNew) {
		m$.form.find(".btn-delete").hide();
	} else {
		m$.serverId.addClass("form-text").prop("readonly", true);
	}

	btnColorCtrl($("#taxii_pull_btn"));
	
},

bindEvent = function() {
	m$.form.find('.btn-taxii_pull').on('click', pullTaxiiService);
},

pullTaxiiService=function(){
	var selectedServerId = $("#selectedServer").val();
	var selectedServerIP = $("#selectedServerIP").val();
	var selectedServerPort = $("#selectedServerPort").val();
	var username = $("[name=server_user_nm]").val();
	var password = $("[name=server_user_pw]").val();
	var collection = $("[name=server_collection]").val();
	var service = $("#selectedServerService").val();
	
	if(selectedServerId == ""){
		_alert("Taxii Server를 선택하세요.", {onAgree : function() {}});
		return;
	}
	
	if (!_SL.validate(m$.form))return;
	
	loading.show();
	
	
	$.ajax({
		type : "POST",
		url : "/tist/taxii_pull_service.json",
		contentType : "application/json",
		data : JSON.stringify({server_id:selectedServerId, server_ip:selectedServerIP, 
			server_port:selectedServerPort, username:username, 
			password:password, collection:collection, server_service:service}),
		dataType : "json",
		success : function(rsJson) {
			loading.hide();
			if(rsJson.data == null){
				$("#noDataTxt").show();
				$(".tr_cls").remove();
				_alert("결과 값이 없습니다.\nCollection 이름을 확인하세요.", {onAgree : function() {}});
			}else{
				var chkConn = rsJson.data[0];
				rsJson.data.splice(0,1);
				var data = rsJson.data;
				var name = [];
				cont = [];
				
				for(var w=0; w<data.length; w++){
					if(w % 2 ==0){
						name.push(data[w]);	
					}else{
						cont.push(data[w])
					}
				}
				
				if((chkConn != null) && (chkConn == 0)){
					$("#noDataTxt").hide();	
					$(".tr_cls").remove();
					
					for(var i=0; i<name.length; i++){
						$("#taxii_pull_list").append("<tr class='tr_cls'><td>" + (i+1) + "</td><td class='t_select_btn' onclick='viewCont(" + i + ")'>" + name[i] + "</td><td class='t_stix_gen_btn' onclick='genSTIX(" + i + ",\"" + name[i] + "\")'>저장</td></tr>");
					}
					
				}else if(chkConn){
					_alert(rsJson.data[0], {onAgree : function() {}});
				}
			}
		},
		error: function() {
		    	loading.hide();
		    	_alert("Taxii Server 통신 중 오류가 발생하였습니다.\n서버 상태 및 IP를 확인하세요.", {onAgree : function() {}});
		}
	});
},

genSTIX = function(index, name){
	setCont(index);
	$("#stixSaveName").val(name);
	
	loading.show();
 	$('body').requestData(mCfg.urlSTIXGen,
			_SL.serializeMap(m$.form), {
				callback : function(rsData, rsCd, rsMsg) {
					loading.hide();
					if(rsData){
						_alert("STIX 저장이 완료되었습니다.", {onAgree : function() {}});	
					}else{
						_alert("STIX 저장 중 오류가 발생하였습니다.\n다시 시도하세요.", {onAgree : function() {}});
					}
						
				}
	});
},

onClose = function(afterClose) {
	if (afterClose) {
		m$.form.find("[data-layer-close=true]").click();
	}
};

init();

function viewCont(index){
	setCont(index);
	viewDetailPull(gCONTEXT_PATH + "tist/taxii_pull_cont_view.html")
	return;
}

function viewDetailPull(url){
	var modal = new ModalPopup(url, {
		width:850, height:210,		//모달 사이즈 옵션으로 조절 가능
		//draggable : true,				// draggable 선택 가능(기본 값 : false)
		onClose : function(){
			refresh();
		}
	});
}

function setCont(index){
	$.ajax({
		type : "POST",
		url : "/tist/taxii_pull_set_cont.do",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({cont:cont[index]}),
		dataType : "json",
		success : function(rsJson) {}
	});
}

function btnColorCtrl($btn){
	var $closeBtn = $("#expandAside").find(".btn-close");
	$closeBtn.on("click", function(){
		initBtnColor();
		if($btn.hasClass("open")){
			$btn.css("background-color", "#2c726d");			
		}else{
			$btn.css("background-color", "#274543");
		}
	});
}

function drawSelectList(){
	$.ajax({
		type : "POST",
		url : "/tist/taxii_server_list.json",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({s_id:""}),
		dataType : "json",
		success : function(rsJson) {
			var data = rsJson.data;
			var listSize = rsJson.data.length;
			
			if(listSize == 0){
				$("#server_info_show").hide();
				$(".table-bottom").hide();
				$("#server_select_list").css("width", "100%");
				$("#server_select_list").append("<div style='color:#92AAB0;font-size:24px;padding-top:130px;padding-left:100px;'>서버를 먼저 등록하세요.</div>");
			}else{
				for(var i=0; i<listSize; i++){
					var id = data[i]["server_id"];
					$("#server_select_table").append("<tr style='cursor:pointer' onclick='showServerInfo(\"" + id + "\")'><td>" + data[i]["server_ip"] + "</td></tr>");
				}	
			}
		}
	});
}

function showServerInfo(id){
	$("#server_info_show").empty();
	$.ajax({
		type : "POST",
		url : "/tist/taxii_server_list.json",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({s_id:id}),
		dataType : "json",
		success : function(rsJson) {
			var data = rsJson.data[0];
			$("#selectedServer").val(data["server_id"]);
			$("#selectedServerIP").val(data["server_ip"]);
			$("#selectedServerPort").val(data["server_port"]);
			$("#selectedServerService").val(data["server_service"]);
			
			$("#server_info_show").append("<table class='table-group' id='server_info_table'></table>");
			//$("#server_info_table").append("<tr style='text-align:center'><td colspan='2'><img sty src='" + iconSrc + "' height=50 width=50></td></tr>");
			$("#server_info_table").append("<tr style='text-align:center'><td colspan='2'><span id='pull_info_txt'>TAXII PULL Service Info</span></td></tr>");
			$("#server_info_table").append("<tr><td class='tdth'>서버 ID</td><td>" + data["server_id"] + "</td></tr>");
			$("#server_info_table").append("<tr><td class='tdth'>서버 이름</td><td>" + data["server_nm"] + "</td></tr>");
			
			if((data["server_port"] == null) || (data["server_port"] == "")){
				$("#server_info_table").append("<tr><td class='tdth'>서버 IP</td><td><span style='font-family:돋움;font-size:9pt;'>" + data["server_ip"] + "</span></td></tr>");
			}else{
				$("#server_info_table").append("<tr><td class='tdth'>서버 IP</td><td><span style='font-family:돋움;font-size:9pt;'>" + data["server_ip"] + " : " + data["server_port"] + "</span></td></tr>");
			}
			$("#server_info_table").append("<tr><td class='tdth'>서버 서비스</td><td>" + data["server_service"] + "</td></tr>");
			$("#server_info_table").append("<tr><td class='tdth'>설명</th><td><div style='width:100%;overflow:auto;height:50px;'>" + data["server_desc"] + "</div></td></tr>");
			
			$("#server_info_table").append("<tr><th scope='row'><span class='mark-required'>유저이름</span></th><td><input type='text' name='server_user_nm' class='form-input' data-valid='유저이름,required'></td></tr>");
			$("#server_info_table").append("<tr><th scope='row'><span class='mark-required'>패스워드</span></th><td><input type='password' name='server_user_pw' class='form-input' maxlength='30' data-valid='패스워드,required'></td></tr>");
			$("#server_info_table").append("<tr><th scope='row'><span class='mark-required'>Conllection</span></th><td><input type='text' name='server_collection' class='form-input' maxlength='30' data-valid='Collection,required'></td></tr>");
			
			$("#server_info_table").hide().fadeIn();
		}
	});
}
</script>
<style>
#server_select_list{
	width:35%;
	height:340px;
	overflow:auto;
	float:left;
}
    
#server_select_table td:hover{
	background-color:rgb(23,183,183);
}

#server_info_show{
	width:62%;
	height:340px;
	float:left;
	padding-left:11px;
}

#server_info_table{
	font-size:8.1pt;
	font-family:맑은고딕;
	border-top:none;
	margin-top:10px;
}

#server_info_table td{
	height:20px;
}

#server_info_table .tdth{
	background-color:#eee;
	font-weight:bold;
	width:70px;
}

#server_select_txt{
    color:#92AAB0;
    font-size:24px;
    padding-top:130px;
    padding-left:100px;
}

#pull_info_txt{
	color:#55737b;
    font-size:18px;
}

.t_select_btn{
	cursor:pointer;
}

.t_select_btn:hover{
	text-decoration:underline;
	color:#18738b;
}

.t_stix_gen_btn{
	cursor:pointer;
}

.t_stix_gen_btn:hover{
	text-decoration:underline;
	color:#18738b;
}
</style>
<div class="section-content" style="margin-left:0px;">
	<form name="formTaxiiPull" id="formTaxiiPull">
		<input type="hidden" name="slKey" value="${_slKey}">
		<input type="hidden" name="selectedServer" id="selectedServer" value="">
		<input type="hidden" name="selectedServerIP" id="selectedServerIP" value="">
		<input type="hidden" name="selectedServerPort" id="selectedServerPort" value="">
		<input type="hidden" name="selectedServerService" id="selectedServerService" value="">
		<input type="hidden" name="stixSaveName" id="stixSaveName" value="">
		<div>
			<div style="float:left;width:40%;margin-left:25px;">
				<div>
					<div id="server_select_list">
						<table class="table-group" id="server_select_table"></table>
					</div>
					<div id="server_info_show"><div id="server_select_txt">Select Server</div></div>
				</div>
				<div class="table-bottom">
					<button type="button" class="btn-basic btn-taxii_pull" data-after-close="true">PULL</button>
				</div>
			</div>
			<div style="float:left;width:5%;"> 
				<table class="table-group" style="visibility: hidden" >
					<tr>
						<th scope="row"><span class="mark-required"></span></th>
						<td></td>
					</tr>
				</table>
			</div>
		<div id="taxii_pull_list_form" style="float:left;width:50%;overflow-y:auto;height:340px;">
			<table class="tbl_type" id="taxii_pull_list" style="border-right:solid 1.5px gray;border-left:solid 1.5px gray;">
			<colgroup>        
		        <col style="width:15%" />
		        <col style="" />
		        <col style="width:20%;" />        
        	</colgroup>
			<tr>
				<th>No</th>
				<th>이름</th>
				<th>파일저장</th>
			</tr>
			<tr class="bg" id="noDataTxt">	          
	          <td colspan="3">There is no Data</td>
	        </tr>
	        
	        
				<!-- <tr><th scope="row"><span>Pull Result</span></th></tr>
				<tr>
					<td><textarea style="height:288px;width:100%;" name="stix_print" id="stix_print" class="form-input"></textarea></td>
				</tr> -->
			</table>
		</div>
	</div>
	</form>
</div>

