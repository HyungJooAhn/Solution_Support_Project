<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript">
${pagingScript}

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

var iconSrc = "<c:url value='/resources/images/threat/server.png' />";
var drawServerList = function(){
	
	var totalCount = 0;
	var s_id = $("#s_id").val();
	var s_ip = $("#s_ip").val();
	
	$.ajax({
		type : "POST",
		url : "/tist/taxii_server_list.json",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({s_id:s_id, s_ip:s_ip}),
		dataType : "json",
		success : function(rsJson) {
			totalCount = rsJson.data.length;
		}
	});
	
	var currPage;
	if($("#currPage")[0] == null){
		currPage = 1;		
	}else{
		currPage = Number($("#currPage")[0].value);	
	}
	var pageRows = Number($("[name=pageRow]")[1].value);
	var totalPage = parseInt(totalCount/(pageRows+1)) + 1
	
	$("#totalPage").text(totalPage);
	$("#totalServers").text(totalCount);
			
	if(currPage == 1){
		$("#btnPrev").remove();
	}else{
		$("#btnPrev").remove();
		$(".t_info3").prepend("<img id='btnPrev' src='/resources/themes/smoothness/images/common/bt07_front.gif' width='15' height='15' style='cursor: pointer;' onclick='javascript:goPrev(" + (currPage -1) + ");'/>");
	}
	
	$("#server_list").empty();
	$.ajax({
		type : "POST",
		url : "/tist/taxii_server_list.json",
		contentType : "application/json",
		data : JSON.stringify({s_id:s_id, s_ip:s_ip, currPage:currPage, pageRows:pageRows}),
		dataType : "json",
		success : function(rsJson) {
			
			if(rsJson.data.length == 0 ){
				$("#server_list").append("<br><text style='font-size:9pt;font-weight:bold'>There is no data result.</text><br>");
				$("#server_list").css("text-align", "center");
				
			}else{
				var listCount = rsJson.data.length;
				var list = rsJson.data;
				var listLine = parseInt(listCount / 5) + 1;
				var index = 0;
				
				if(currPage == totalPage || totalPage == 1){
					$("#btnNext").remove();
				}else{
					$("#btnNext").remove();
					$(".t_info3").append("<img id='btnNext' src='/resources/themes/smoothness/images/common/bt07_next.gif' width='15' height='15' style='cursor: pointer;' onclick='javascript:goNext(" + (currPage + 1) + ");'/>");
				}
				
				for(var i=0; i < listLine; i++){
					var colNum = 0;
					index = i * 5;
					$("#server_list").append("<div id='server_line_" + i + "'></div><br>");
					$("#server_line_" + i).append("<table style='width:100%' id='server_table_" + i + "'/>")
						
					for(var j = index; j < index + 5; j++){
						if(j == listCount){
							break;
						}
						$("#server_table_" + i).append("<td style='width:20%;font-size:10pt;font-weight:bold;text-align:center'><img style='cursor:pointer' onclick=goDetailView('" + list[j].server_id + "') src='" + iconSrc + "' height=100 width=100></img><br><br>" + list[j].server_id + "<br>" + list[j].server_ip + "</td>");
						colNum ++;
					}
					for(var k = 0; k < 5-colNum; k++){
						$("#server_table_" + (listLine-1)).append("<td></td>");
					}
				}
			}
		}
	})
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

$(function() {
	$(".page-menu li").css("padding-top", "0px")
	$("#gen_stix_li").show();
	$("#parsing_stix_li").show();
	$("#taxii_pull_li").show();
	
	$("#gen_stix_btn").togglePage(gCONTEXT_PATH + "tist/stix_generator_form.html");
	$("#parsing_stix_btn").togglePage(gCONTEXT_PATH + "tist/stix_parsing_form.html");
	$("#taxii_pull_btn").togglePage(gCONTEXT_PATH + "tist/taxii_pull_form.html");
	
	btnColorCtrl($("#gen_stix_btn"));
	btnColorCtrl($("#parsing_stix_btn"));
	btnColorCtrl($("#taxii_pull_btn"));
	
	$("#s_id_header").css("width", "50px");
	$("#s_ip_header").css("width", "50px");
	$(".tbl_info .i_box4").css("font-size", "11px");
	
	drawServerList();
});

</script>
<style>
#expandcontent{
	margin-left:3%;
}
</style>
<form name="searchForm"	style="margin-left:3%" action="<c:url value="/tist/taxii_server_list.do" />">
	<input type="hidden" name="menu_idx" value="${param.menu_idx}">
	<input type="hidden" name="s_type_cd" value="${param.s_type_cd}">
	<input type="hidden" name="page_identify" value="stix_taxii">
	<input type="hidden" name="listCount" value="${listCount}"> <input
		type="hidden" name="sttIndex" value="${sttIndex}"> <input
		type="hidden" name="pageRow" id="pageRow" value="15">
	<div class="sub_search" style="border: 0px; margin-left:-17px;margin-top:10px">
		<div class="sub_title03">TAXII 서버 관리</div>
	</div>
	<div class="sub_search">
		<table border="0" align="center" cellpadding="0" cellspacing="0">
			<tr>
				<th id="s_id_header">ID</th>
				<td><input maxlength="5" type="text" id="s_id" name="s_id"
					class="i_text" style="width: 150px;" value="${param.s_id}"></td>
				<th id="s_ip_header">IP</th>
				<td><input type="text" id="s_ip" name="s_ip" class="i_text"
					style="width: 150px;" value="${param.s_ip}"></td>
				<td>&nbsp;&nbsp;<img
					src="<c:url value="/resources/themes/smoothness/images/common/btn_search.gif"/>"
					alt="검색" onclick="drawServerList()" style="cursor: pointer" />
				</td>
			</tr>
		</table>
	</div>
	${pagingTop} <br>
	<br>
	<div id="server_list" style="padding-left: 3px;"></div>
</form>
${pagingBottom}
<img src='<c:url value="/resources/images/common/loading-circle.gif" />'
	alt="loading now..."
	style="display: none; position: absolute; left: 50%; top: 50%;"
	id="loading_img" />

<div class="tbl_bt02">
	<div id="server_add_btn" class="btn_both">
		<div class="fr">
			<a id="sever_add_btn" class="btn_big" href="javascript:goAddForm();"><span>추가</span></a>
		</div>
	</div>
</div>
