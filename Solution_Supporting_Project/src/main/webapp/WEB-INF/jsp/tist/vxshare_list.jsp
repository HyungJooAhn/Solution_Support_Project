<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<style>
#table_area_1{
	position:relative;
	z-index:5;
	width:48%;
	float:left;
}

#table_area_2{
	position:relative;
	z-index:5;
	width:48%;
	float:left;
}

#table_over_view_1 {
	position:absolute;
	float:left;
	z-index:10;
}

#table_over_view_2 {
	position:absolute;
	float:left;
	z-index:10;
}

.viewVXSText{
	cursor:pointer;
	color:#1f9797;
	font-weight:600;
}
.viewVXSText:hover{
	color:#2c726d;
}

</style>
<script type="text/javascript">
${pagingScript}

function viewDetail(url){
	var modal = new ModalPopup(url, {
		width:1450, height:610,		
		onClose : function(){
			refresh();
		}
	});
}


function goSearch() {
	var form = document.searchForm;
	form.action = "<c:url value="/tist/vxshare_list.do" />";
	form.submit();
}

function viewVXShare(fileName){
	viewDetail(gCONTEXT_PATH + "tist/vxshare_detail_view_form.html?vxs_file_nm=" + fileName);
}

function extendTable(idx){
	var list;
	var currPage = $("[name=currPage]").val();
	var searchName = $("[name=s_vxs_file_nm]").val();
	var searchDate = $("[name=s_vxs_date]").val();
	
	$.ajax({
		type : "POST",
		url : "/tist/vxshare_list.json",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({currPage:currPage, s_vxs_file_nm:searchName, s_vxs_date:searchDate, idx:idx}),
		dataType : "json",
		success : function(rsJson) {
			list = rsJson.data;
		}
	});

	if(list != null){
		if(list.length != 0){
			var srcStr = "<table class='tbl_type'><colgroup><col style='width:8%'/><col style=''/><col style=''/><col style='width:15%'/><col style='width:15%'/><col style='width:15%'/></colgroup>";
			srcStr += "<tr><th>No</th><th>파일명</th><th>해쉬값</th><th>데이터수</th><th>날짜</th><th>상세보기</th></tr>";
			
			for(var i=0; i<list.length; i++){
				srcStr += "<tr><td>" + list[i]["seq"] + "</td>";
				srcStr += "<td>" + list[i]["file_nm"] + "</td>";
				srcStr += "<td>" + list[i]["hashes"] + "</td>";
				srcStr += "<td>" + list[i]["rows"] + "</td>";
				srcStr += "<td>" + list[i]["date"] + "</td>";
				srcStr += "<td><span onclick='javascript:viewVXShare(\"" + list[i]["file_nm"] + "\")' class='viewVXSText'>보기</span><img onclick='javascript:viewVXShare(\"" + list[i]["file_nm"] + "\")' src='<c:url value='/resources/images/threat/viewIcon.png' />' style='cursor:pointer;width:17px;height:17px;'/></td></tr>";
			}
			
			srcStr += "</tr></table>";
			$("#table_over_view_" + idx).append(srcStr);
			var tableWidth = Number($("#table_area_1").css("width").replace("px", "")) + Number($("#middle_area").css("width").replace("px", "")) + Number($("#table_area_2").css("width").replace("px", ""));
			$("#table_over_view_" + idx).css("width", tableWidth + "px");
			$("#table_over_view_" + idx).find(".tbl_type").find("tr").css("background-color", "white");
			$("#table_over_view_" + idx).hide();
			$("#table_over_view_" + idx).fadeIn();
			
			$("#table_area_1").fadeOut();
			$("#table_area_2").fadeOut();
		}
	}
}

function initExtendTable(idx){
	$("#table_over_view_" + idx).fadeOut(300, function(){
		$("#table_over_view_" + idx).empty();	
	});
}


function mouseOnEvent(){
	$("#table_area_1").mouseenter(function(){
		extendTable(1);
	});
	$("#table_area_1").mousemove(function(){});
	$("#table_area_1").click(function(){});
	$("#table_area_1").dblclick(function(){});
	
	$("#table_area_2").mouseenter(function(){
		extendTable(2);
	});
	$("#table_area_2").mousemove(function(){});
	$("#table_area_2").click(function(){});
	$("#table_area_2").dblclick(function(){});
}

function mouseOutEvent(){
	$("#table_over_view_1").mouseleave(function(){
		initExtendTable(1)
		$("#table_area_1").fadeIn();
		$("#table_area_2").fadeIn();
	});
	$("#table_over_view_2").mouseleave(function(){
		initExtendTable(2)
		$("#table_area_1").fadeIn();
		$("#table_area_2").fadeIn();
	});	
}

$().ready(function() {
	$("#version_tab").hide();
	mouseOnEvent();
	mouseOutEvent();
	$("#contents").css("min-height", "610px");
	$("input[type=text]:not(#currPage)").keydown( function(event) { if(event.which=='13'){ goSearch(); } } );
})

</script>
<!-- contents -->
<form name="searchForm" id="VXShareForm" action="<c:url value="/tist/vxshare_list.do" />">
<input type="hidden" name="psr_id">
<input type="hidden" name="popup" value="${param.popup}">
<input type="hidden" name="s_log_psr_id" value="${param.s_log_psr_id}"/>
	<div id="sub_container" style="padding-bottom: 0px"> 
	  <div class="sub_search" style="border:0px; margin-left:-15px;">
		  <div class="sub_title03">VXShare</div>
	  </div>
	  <!-- search -->
      <div class="sub_search">
      	<table>
	        <tr>
	          <th>파일명</th>
	          <td>
	            <input type="text" class="i_text i_width01" name="s_vxs_file_nm" value="<c:out value="${param.s_vxs_file_nm}" />"/>
	          </td>
	          <th>날짜</th>
	          <td>
	         	<input type="text" class="i_text i_width01" name="s_vxs_date" value="<c:out value="${param.s_vxs_date}" />"/>
	          </td>	          
	          <td class="bt_area"><img src="<c:url value="/resources/themes/smoothness/images/common/btn_search.gif" />" alt="검색" onclick="goSearch();" style="cursor:pointer"/></td>
	        </tr>
	     </table>
      </div>
    <div>
		${pagingTop}
	</div>
	<div id="table_area" style="margin-top:10px;">
		<div id="table_area_1">
			<table class="tbl_type">
		        <colgroup>        
		        <col style="width:20%" />
		        <col style="" />
		        <col style="width:30%" />
		        </colgroup>
		        <tr id="table_1_th">          
		          <th>No</th>
		          <th>파일명</th>
		          <th>날짜</th>
		        </tr>
	        	<c:choose>
					<c:when test="${empty list_1}">
						<tr class="bg">	          
				          <td colspan="3">There is no Search Result</td>
				        </tr>
					</c:when>
					<c:otherwise>
						<c:forEach var="map" items="${list_1}" varStatus="calCount">
							
							<tr id="table_1_tr">		          
					          <td>${map.seq}</td>
					          <td>${map.file_nm}</td>
					          <td>${map.date}</td>
					        </tr>
					        
						</c:forEach>
					</c:otherwise>
				</c:choose>
	  	    </table>
		</div>
		<div id="middle_area" style="width:4%;float:left;">
			<table class="table-group" style="visibility: hidden" >
					<tr>
						<th><span class="mark-required"></span></th>
						<td></td>
					</tr>
			</table>
		</div>
		<div id="table_area_2">
		<table class="tbl_type" summary="">
		        <colgroup>        
		        <col style="width:20%" />
		        <col style="" />
		        <col style="width:30%" />
		        </colgroup>
		        <tr>          
		          <th>No</th>
		          <th>파일명</th>
		          <th>날짜</th>
		        </tr>
	        	<c:choose>
					<c:when test="${empty list_2}">
						<tr class="bg">	          
				          <td colspan="3">There is no Search Result</td>
				        </tr>
					</c:when>
					<c:otherwise>
						<c:forEach var="map" items="${list_2}" varStatus="calCount">
							
							<tr ${calCount.count % 2 == 0 ? "class='bg'" : "" }>		          
					          <td>${map.seq}</td>
					          <td>${map.file_nm}</td>
					          <td>${map.date}</td>
					        </tr>
					        
						</c:forEach>
					</c:otherwise>
				</c:choose>
	  	    </table>
		</div>
		<div id='table_over_view_1'></div>
		<div id='table_over_view_2'></div>
	</div>
      
      <!-- list --> 
      	<!-- paging -->
		${pagingBottom}
    	<!-- paging -->      
    </div>
</form>
<!-- contents -->
