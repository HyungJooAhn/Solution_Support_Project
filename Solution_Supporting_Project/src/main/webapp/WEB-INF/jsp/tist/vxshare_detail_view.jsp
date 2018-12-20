<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
  
<script type="text/javascript">
${pagingScript}
var pageCnt = 0;

function pageBtnCtrl(){
	if($("#currPageViewer").val() == 1){
		$("#btnPrevViewer").hide();	
	}else{
		$("#btnPrevViewer").show();
	}

	if($("#currPageViewer").val() == $("#totalPageViewer").text()){
		$("#btnNextViewer").hide();	
	}else{
		$("#btnNextViewer").show();
	}
	
	if(Number($("#currPageViewer").val()) > Number($("#totalPageViewer").text())){
		$("#currPageViewer").text(1);
		$("#currPageViewer").val(1);
		genVXShareTable();
	}
}

function goPrevViewer(){
	if(Number($("#currPageViewer").val())-1 < 1){
		$("#currPageViewer").text(1);
		$("#currPageViewer").val(1);
	}else{
		$("#currPageViewer").text(Number($("#currPageViewer").val())-1);
		$("#currPageViewer").val(Number($("#currPageViewer").val())-1);	
	}
	genVXShareTable();
}


function goNextViewer(){
	$("#currPageViewer").text(Number($("#currPageViewer").val())+1);
	$("#currPageViewer").val(Number($("#currPageViewer").val())+1);
	genVXShareTable();
}

function goPageViewer() {
	if(event.keyCode == 13){
		if($("#currPageViewer").val() == ""){
			$("#currPageViewer").text(1);
			$("#currPageViewer").val(1);
		}
		genVXShareTable();
	}
}

function genVXShareTable(){
	$("#vxshare_detail_table").empty();
	pageBtnCtrl();
	var list;

	var currPage = $("[name=currPageViewer]").val();
	var vxsFileName = $("[name=vxs_file_nm]").val();
	var searchMD5 = $("[name=s_vxs_md5]").val();
	var searchSHA256 = $("[name=s_vxs_sha256]").val();
	
	$.ajax({
		type : "POST",
		url : "/tist/vxshare_detail_view.json",
		contentType : "application/json",
		async: false,
		data : JSON.stringify({currPageViewer:currPage, vxs_file_nm:vxsFileName, s_vxs_md5:searchMD5, s_vxs_sha256:searchSHA256}),
		dataType : "json",
		success : function(rsJson) {
			list = rsJson.data;
			
			if(list != null){
				if(list.length != 0){
					pageCnt = list.length;
					var startNo = (Number(currPage)-1) * 15;
					for(var i=0; i<list.length; i++){
						
						var tableStr = "";
						tableStr += "<tr><td>" + (startNo + i + 1) + "</td>";
						tableStr += "<td>" + list[i]["CRC32"] + "</td>";
						tableStr += "<td>" + list[i]["adler_32"] + "</td>";
						tableStr += "<td>" + list[i]["MD5"] + "</td>";
						tableStr += "<td>" + list[i]["ripemd_160"] + "</td>";
						tableStr += "<td>" + list[i]["whirlpool"] + "</td>";
						tableStr += "<td>" + list[i]["sha_1"] + "</td>";
						tableStr += "<td>" + list[i]["sha_256"] + "</td>";
						tableStr += "<td>" + list[i]["sha_512"] + "</td>";
						tableStr += "<td>" + list[i]["ssdeep"] + "</td></tr>";
						$("#vxshare_detail_table").append(tableStr);	
					}
				}
			}
			
		}
	});
}
genVXShareTable();
</script>
<style>
	#vxshare_data_table_div{
		overflow-x:auto;
		margin-top:35px;
		height:510px;
	} 	
</style>
<div class="section-content" style="margin-left:0px;">
	<form name="formVXShareView" id="formVXShareView" action="<c:url value="/tist/vxshare_detail_view_form.html" />">
	<input type="hidden" name="vxs_file_nm" value="${vxs_file_nm}">
	    ${pagingTop}
	    <div id="vxshare_data_table_div">
			<table class="tbl_type">
				<thead>
			        <tr>
				      <th>No</th>          
			          <th>CRC32</th>
			          <th>Adler_32</th>
			          <th>MD5</th>          
			          <th>RIPEMD-160</th>          
			          <th>Whirlpool</th>          
			          <th>SHA-1</th>          
			          <th>SHA-256</th>          
			          <th>SHA-512</th>          
			          <th>ssdeep</th>          
			        </tr>
		        </thead>
		        <tbody id="vxshare_detail_table">
		        </tbody>
			</table>
		</div>
	</form>
	${pagingBottom}
</div>

