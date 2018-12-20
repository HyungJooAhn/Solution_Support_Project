<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript">

var
// Config 정의
mCfg = {
	formId : '#formSTIXGen',
	urlSTIXGen : gCONTEXT_PATH + "tist/stix_generator.do",
	urlSTIXGenTpl : gCONTEXT_PATH + "tist/stix_template.json",
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
	// 이벤트 Binding
	bindEvent();
	// DOM 설정 Start
	if (mState.isNew) {
		m$.form.find(".btn-delete").hide();
	} else {
		m$.serverId.addClass("form-text").prop("readonly", true);
	}
	// DOM 설정 End

	// 데이타 조회
	/* if (!mState.isNew)
		select(); */
	btnColorCtrl($("#gen_stix_btn"));
},

bindEvent = function() {
	m$.form.find('.btn-stix-tpl-gen').on('click', genSTIXTpl);
	
	m$.form.find('.btn-stix-gen').on('click', genSTIX);
},

genSTIXTpl = function(){
	$("#stix_print").val("");
	
	if (!_SL.validate(m$.form))return;
	loading.show();
 	$('body').requestData(mCfg.urlSTIXGenTpl,
			_SL.serializeMap(m$.form), {
				callback : function(rsData, rsCd, rsMsg) {
					loading.hide();
					if(rsData.length == 0){
						_alert("STIX Template 생성 중 오류가 발생하였습니다\n다시 시도하세요.", {onAgree : function() {}});
					}else{
						$("#stix_print").val(rsData);	
					}
				}
	});
},

genSTIX = function(){
	if($("#stix_print").val() == ""){
		_alert("STIX Template을 먼저 생성하세요.", {onAgree : function() {}});
		return;
	}
	
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
</script>
<div class="section-content" style="margin-left:0px;">
	<form name="formSTIXGen" id="formSTIXGen">
		<input type="hidden" name="slKey" value="${_slKey}">
		<div>
			<div style="float:left;width:40%;margin-left:35px;margin-top:18px;">
				<table class="table-group" style="width:100%;border-right:solid 1.5px gray;border-left:solid 1.5px gray;">
					<tr>
						<th scope="row"><span>File Name</span></th>
						<td><input type="text" name="file_nm" class="form-input" data-valid="File Name,required,alphanum"></td>
					</tr>
					<tr>
						<th scope="row"><span>Header Namespace URI</span></th>
						<td><input placeholder="http://example.com/" type="text" name="header_namespace" class="form-input" data-valid="Header Namespace URI"></td>
					</tr>
					<tr>
						<th scope="row"><span>Header Prefix</span></th>
						<td><input type="text" name="header_prefix" class="form-input" data-valid="Header Prefix,alpha"></td>
					</tr>
					<tr>
						<th scope="row"><span>Header Description</span></th>
						<td><input type="text" name="header_description" class="form-input" data-valid="Header Description"></td>
					</tr>
					<tr>
						<th scope="row"><span>Indicator Title</span></th>
						<td><input type="text" name="indicator_title" class="form-input" data-valid="Indicator Title"></td>
					</tr>
					<tr>
						<th scope="row"><span>Indicator Namespace URI</span></th>
						<td><input placeholder="http://example.com/" type="text" name="indicator_namespace" class="form-input" maxlength="30" data-valid="Indicator Namespace URI"></td>
					</tr>
					<tr>
						<th scope="row"><span>Indicator Prefix</span></th>
						<td><input type="text" name="indicator_prefix" class="form-input" data-valid="Indicator Prefix,alpha"></td>
					</tr>
				
					<tr>
						<th scope="row"><span>Indicator Description</span></th>
						<td><input type="text" name="indicator_description" class="form-input" data-valid="Indicator Description"></td>
					</tr>
				</table>
				<div class="table-bottom">
					<button style=""type="button" class="btn-basic btn-stix-tpl-gen" data-after-close="true">생성</button>
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
		<div id="stix_template_div" style="float:left;width:50%;margin-top:18px;">
			<table class="table-group" style="border-right:solid 1.5px gray;border-left:solid 1.5px gray;">
				<tr><th scope="row"><span>STIX Template</span></th></tr>
				<tr>
					<td><textarea style="height:254px;width:100%;" name="stix_print" id="stix_print" class="form-input"></textarea></td>
				</tr>
			</table>
			<div class="table-bottom">
					<button type="button" class="btn-basic btn-stix-gen" data-after-close="true">STIX</button>
			</div>
		</div>
	</div>
	</form>
</div>

