<%@ page contentType="text/html; charset=utf-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<link rel="stylesheet" type="text/css" href="<c:url value="/resources/js/jq_plugin/chosen/chosen.css" />" />
<script type="text/javascript" src="<c:url value="/resources/js/jq_plugin/chosen/chosen.jquery.js" />"></script>
<script type="text/javascript">

${pagingScript}

function viewDetail(url){
	var modal = new ModalPopup(url, {
		width:700, height:500,		//모달 사이즈 옵션으로 조절 가능
		//draggable : true,				// draggable 선택 가능(기본 값 : false)
		onClose : function(){
			refresh();
		}
	});
}

function refresh(){
	location.reload();
}

function goGenerateForm() {
	viewDetail(gCONTEXT_PATH + "download/patch_file_form.html");
}

function patchFileDownload(fildId){
	$("#file_id").val(fildId);
	$("#downloadForm").submit();
}

function patchFileDelete(){
	var checkBoxList = $("#patch_file_table").find("input");
	_confirm("삭제하시겠습니까?", {
		onAgree : function() {
			for(var i=1; i<checkBoxList.length; i++){
				if($(checkBoxList[i]).is(":checked") == true){
					var fileId = $(checkBoxList[i]).val()
					$.ajax({
						type: 'POST',
					    url: "/download/patch_file_delete.do",
					    contentType : "application/json",
					    data: JSON.stringify({file_id:fileId}),
						dataType: 'json',
						async:false,
						success: function(rsJson) {
							var result = rsJson.data;
							if(result){
								refresh();
							}else{
								_alert("삭제 중 오류가 발생하였습니다.");
							}
						}
					});
				}
			}
		}
	});	
}

$().ready(function() {
	$("#del_file_all").change(function() {
		var bChk = this.checked;
		var conAsset = [];
		
		$("[name=del_file]").each(function(nIdx) {
			this.checked = bChk;
		});
	});
})

</script>
<style>

#selected_customer_name{
	margin-top: 20px;
    font-size: 15pt;
    text-align: center;
    width: 68%;
    font-family:NanumGothic, sans-serif;
	font-weight: bold;
}
.patch_download_icon{
    width: 20px;
    height: 20px;
    background-size: 20px;
    cursor:pointer;
    margin-left:32px;
	background-image:url(<c:url value="/resources/images/patch/patch_download_icon.png"/>);
}

.patch_download_icon:hover{
	background-image:url(<c:url value="/resources/images/patch/patch_download_icon_over.png"/>);
}

</style>
<form name="searchForm" id="patchFileListForm" action="<c:url value="/download/patch_file_management.do" />">
	<input type="hidden" name="page_num" value="0">
	<input type="hidden" name="s_log_psr_id" value="${param.s_log_psr_id}"/>
	<input type="hidden" name="customer_cnt_value" value="0"/>
	<input type="hidden" name="customer_type" value=""/>
	<input type="hidden" name="customer_name" value=""/>
	<div class="sub_search" style="border:0px; margin-left:-15px;">
		<div class="sub_title03">패치파일 생성</div>
	</div>
	${pagingTop}
	<br>
	<table class="tbl_type" id="patch_file_table" style="table-layout:fixed;margin-top:18px;">
		<colgroup>
		<col style="width:3%;" />
		<col style="width:5%;" />
		<col style="width:19%;" />
		<col style="width:19%;" />
		<col style="width:22%;" />
		<col style="width:17%;" />
		<col />
		<col style="width:8%;" />
		</colgroup>
		<tr>
			<th><input type="checkbox" id="del_file_all"></th>
			<th>번호</th>
			<th>파일이름</th>
			<th>파일크기</th>
			<th>MD5</th>
			<th>패치대상</th>
			<th>생성일자</th>
			<th>다운로드</th>
		</tr>
		
		<!-- List Start -->
		<c:choose>
			<c:when test="${empty list}">
				<tr>
					<td colspan="8">There is no Patch File</td>
				</tr>
			</c:when>
			<c:otherwise>
				<c:forEach var="map" items="${list}" varStatus="calCount">
					<c:set var="type_key">${map.type}</c:set>
						<tr>
							<td style="padding: 4px 0px 3px 0px;"><input type="checkbox" name="del_file" value="${map.file_id}"></td>
							<td>${calCount.count + startIndex}</td>
							<td style='font-size:9pt'>${map.file_nm}</td>
							<td style='font-size:9pt'>${map.file_size}</td>
							<td style='font-size:9pt'>${map.md5}</td>
							<td style='font-size:9pt'>${map.patch_target}</td>
							<td style='font-size:9pt'>${map.reg_dt}</td>
							<td><div onclick='javascript:patchFileDownload(${map.file_id})' class='patch_download_icon'></div></td>
						</tr>
				</c:forEach>
			</c:otherwise>
		</c:choose>
	</table>
	${pagingBottom}
	<div class="tbl_bt02">
		<div class="btn_both">
			<div class="fl"><a class="btn_big" href="javascript:patchFileDelete();"><span>삭제</span></a></div>
			<div class="fr"><a class="btn_big" href="javascript:goGenerateForm();"><span>생성</span></a></div>				
		</div>
	</div>		
		
</form>
<form name="downloadForm" id="downloadForm" action="/download/patch_file_download.do">
	<input type="hidden" name="file_id" id="file_id" /> 
</form>
