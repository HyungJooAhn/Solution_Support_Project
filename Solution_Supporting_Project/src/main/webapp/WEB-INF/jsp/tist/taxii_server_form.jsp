<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript">
$().ready(function() {
	$(".modal-head").find("button").css("background","url(<c:url value='/resources/themes/smoothness/images/common/btn_pop_close.png'/>) no-repeat")
	$(".modal-head").find("button").css("background-position", "center")
});

var
// Config 정의
mCfg = {
	formId : '#formTAXIIServer',
	urlSelect : gCONTEXT_PATH + "tist/taxii_server.json",
	urlExist : gCONTEXT_PATH + "tist/taxii_server_check_id.json",
	urlExistIp : gCONTEXT_PATH + "tist/taxii_server_check_ip.json",
	urlExistAgent : gCONTEXT_PATH + "management/rel_agent_exist.json",
	urlDelete : gCONTEXT_PATH + "tist/taxii_server_delete.do",
	add : {
		action : gCONTEXT_PATH + "tist/taxii_server_insert.do",
		message : "등록 하시겠습니까?"
	},
	update : {
		action : gCONTEXT_PATH + "tist/taxii_server_update.do",
		message : "수정 하시겠습니까?"
	}
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
	if (!mState.isNew)
		select();
},

bindEvent = function() {
	// SAVE
	m$.form.find('.btn-save').on('click', onSave);

	// DELETE
	m$.form.find('.btn-delete').on("click", onDelete);
},

select = function() {
	var id = m$.serverId.val(), rqData = {
		'taxii_server_id' : id
	},

	callback = function(data) {
		_SL.setDataToForm(data, m$.form, {
			"taxii_server_ip" : {
				converter : function(cvData, $fld) {
					m$.form.find('[name=server_ip]').val(cvData);
				}
			}
		});
	};

	$('body').requestData(mCfg.urlSelect, rqData, {
		callback : callback
	});
},

onSave = function() {
	if (!_SL.validate(m$.form))return;

	var ip = m$.form.find("[name=server_ip]").val();
	var afterClose = $(this).data('after-close') == true ? true : false;
	//ip중복체크 함수
	var ipCheck = function() {
		// 이전 IP와 현재 IP가 다른 경우
		$('body').requestData(mCfg.urlExistIp, {
			taxii_server_ip : ip
		}, {
			callback : function(rsData) {
				if (rsData == true)
					submit();
				else
					_alert("이미 등록된 IP입니다.");
			
			}
		});
	}

	var submit = function() {
		$('body').requestData(mState.mode.action,
				_SL.serializeMap(m$.form), {
					callback : function(rsData, rsCd, rsMsg) {
						_alert(rsMsg, {
							onAgree : function() {
								parent.refresh();
								m$.form.find("[data-layer-close=true]").click();
							}
						});
					}
				});
	}

	if (mState.isNew) {
		
		$('body').requestData(mCfg.urlExist, {
			taxii_server_id : m$.serverId.val()
		}, {
			callback : function(rsData) {
				if (rsData == true)
					ipCheck();
				else
					_alert("이미 사용 중인 아이디 입니다.");
			}
		});
	} else {
		submit();
	}
},

onDelete = function() {
	var serverId = m$.serverId.val();
	var afterClose = $(this).data('after-close') == true ? true : false;
	var delTaxiiServer = function() {
		_confirm("삭제하시겠습니까?", {
			onAgree : function() {
				$('body').requestData(mCfg.urlDelete,
						_SL.serializeMap(m$.form), {
							callback : function(rsData, rsCd, rsMsg) {
								_alert(rsMsg, {
									onAgree : function() {
										parent.refresh();
										m$.form.find("[data-layer-close=true]").click();
									}
								});
							}
						});
			}
		});
	};

	delTaxiiServer();

},

onClose = function(afterClose) {
	if (afterClose) {
		m$.form.find("[data-layer-close=true]").click();
	}
};

init();

</script>
<div class="section-content">
	<form name="formTAXIIServer" id="formTAXIIServer">
		<input type="hidden" name="slKey" value="${_slKey}">

		<table class="table-group">
			<tr>
				<th scope="row"><span class="mark-required">TAXII 서버 ID</span></th>
				<td><input type="text" name="server_id" value="${param.taxii_server_id}" class="form-input" maxlength="5" data-valid="TAXII 서버 ID,required,alphanum,minLen=3"></td>
			</tr>
			<tr>
				<th scope="row"><span class="mark-required">TAXII 서버 이름</span></th>
				<td><input type="text" name="server_nm" class="form-input" maxlength="30" data-valid="TAXII 서버 이름,required"></td>
			</tr>
			<tr>

				<th scope="row"><span class="mark-required">TAXII 서버 IP</span></th>
				<td>
					<div>
						<div>
							<input placeholder="ip" style="width: 70%;" type="text"
								name="server_ip" class="form-input" data-valid="TAXII 서버 IP,required">
							<text style="font-weight:bold; font-size:10pt">:</text>
							<input placeholder="port" style="width: 25%;" maxlength="5" type="text" name="server_port" class="form-input" data-valid="number,min=0,max=100000">
						</div>
					</div>
				</td>

			</tr>
			<tr>
				<th scope="row"><span class="mark-required">TAXII 서비스명</span></th>
				<td><input type="text" name="server_service" class="form-input" maxlength="80" data-valid="TAXII 서비스명,required"></td>
			</tr>
			<tr>
				<th scope="row"><span>설명</span></th>
				<td><textarea style="height: 80px;" name="server_desc" class="form-area" maxlength="300"></textarea></td>
			</tr>
		</table>

		<div class="table-bottom">
			<button type="button" class="btn-basic btn-save" data-after-close="true">저장</button>
			<button type="button" class="btn-basic btn-delete" data-after-close="true">삭제</button>
			<button type="button" class="btn-basic btn-cancel" data-layer-close="true">취소</button>
		</div>

	</form>

</div>

