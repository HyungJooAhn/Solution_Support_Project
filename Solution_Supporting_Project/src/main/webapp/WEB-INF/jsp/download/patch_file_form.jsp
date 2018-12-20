<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript" src="<c:url value="/resources/js/jquery.filetree.maker.js" />"></script>
<script type="text/javascript">

var procList = [];
var procLibList = [];
var sqlMapList = [];

function goAction(pageNum, pointer){
	var pageOffset = Number($("#patch_step_all").css("margin-left").replace("px", ""));
	
	$("#patch_step_move_right").attr("onclick", "");
	$("#patch_step_move_left").attr("onclick", "");
	
	if(pointer){
		$("#patch_step_all").animate({
			"margin-left":(pageOffset - 683) + "px"
		},{complete:function _completeCallback(){
			$("#patch_step_move_right").attr("onclick", "javascript:goNext()");
			$("#patch_step_move_left").attr("onclick", "javascript:goBack()");
			if(pageNum == 3){
				$("#patch_step_move_right").css("display", "none");
			}else if(pageNum >= 0){
				$("#patch_step_move_left").css("display", "inline");
			}
		}});
	}else{
		$("#patch_step_all").animate({
			"margin-left":(pageOffset + 683) + "px"
		},{complete:function _completeCallback(){
			$("#patch_step_move_right").attr("onclick", "javascript:goNext()");
			$("#patch_step_move_left").attr("onclick", "javascript:goBack()");
			if(pageNum == 1){
				$("#patch_step_move_left").css("display", "none");
			}else{
				$("#patch_step_move_right").css("display", "inline");
			}
		}});
	}
}

function goNext(){
	
	var pageNum = (Number($("#patch_step_all").css("margin-left").replace("px", "")) / 683) * -1;
	
	switch(pageNum){
	case 0:
		var fileName = $("[name=patch_file_name]").val();
		if(fileName == ""){
			_alert("패치파일 이름을 입력하세요.");
		}else if(fileName.length < 3){
			_alert("패치파일 이름은<br>최소 3글자 이상이여야 합니다.");
		}else if(!/^[0-9|a-z|A-Z|_|\*]+$/.test(fileName)){
			_alert("패치파일 이름은<br>영문, 숫자 또는 '_'(밑줄)만<br>입력할 수 있습니다.");
		}else{
			goAction(pageNum, true);
		}
		break;
	case 1:
		if(procList.length == 0){
			_alert("패치할 프로세스를 선택하세요.");
		}else{
			goAction(pageNum, true);
			drawFileRegeditForm();
			makeFolder($("[name=file_upload_path]").val());
			if(procList.length == 1){
				$("#patch_file_info").css("margin-left", "-13px");
			}else{
				$("#patch_file_info").css("margin-left", "0px");
			}
		}
		break;
	case 2:
		var regFileChk = true;
		for(var i=0; i<procList.length; i++){
			if($("#tree_ul_" + procList[i] + "_" + procList[i] + "_0").find("ul").length == 0){
				regFileChk = false;
			}
		}
		if(!regFileChk){
			_alert("각 프로세스에 패치 파일을<br>하나 이상 등록하세요.")
		}else{
			goAction(pageNum, true);
		}
		break;
	case 3:
		goAction(pageNum, true);
		break;
	}
} 

function goBack(){
	var pageNum = (Number($("#patch_step_all").css("margin-left").replace("px", "")) / 683) * -1;
	
	switch(pageNum){
	case 2:
		_confirm("이전 페이지로 돌아갈 시<br>등록한 파일은 없어집니다.<br>돌아가시겠습니까?", {
			onAgree : function() {
				removeFolder($("[name=file_upload_path]").val());
				goAction(pageNum, false);
				$("#patch_file_info").css("display", "none");
			}
		});	
		break;
	default:
		goAction(pageNum, false);
		break;
	}
} 

function makeFolder(path){
	$.ajax({
		type : "POST",
		url : "/download/patch_folder_add.do",
		contentType : "application/json",
		data : JSON.stringify({path:path}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			var result = rsJson.data;
			if(!result){
				_alert("폴더 생성 중 오류가 발생하였습니다.");
			}
		}
	});
}

function removeFolder(path){
	$.ajax({
		type : "POST",
		url : "/download/patch_folder_remove.do",
		contentType : "application/json",
		data : JSON.stringify({path:path}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			var result = rsJson.data;
			if(!result){
				_alert("폴더 삭제 중 오류가 발생하였습니다.");
			}
		}
	});
}

function drawProcessList(){
	var procNameList = ["Agent", "Analyzer", "Collector", "Store", "Netflow", "Normalizer", "Procmonitor", "Searcher", "Web", "Shovel", "Bigdata", "Provider", "Proxy", "PMS", "Lib"];
	for(var i=0; i<procNameList.length; i++){
		var procName = procNameList[i].toLowerCase();
		if(procName == "web"){
			procName = "www";
		}
		var newLine = "";
		if(i % 5 == 0){
			newLine = "_first";
		}
		$("#patch_process_list").append("<div class='patch_process_element" + newLine + "' id='patch_process_" + procName + "' data-value='" + procName + "' onclick='javascript:selectProc(\"" + procName + "\")'>"
										+ "<div class='patch_process_icon'></div>" 
										+ "<div class='patch_process_name'>" + procNameList[i] + "</div></div>"); 
	}
}

function drawProcessListPopup(){
	var procNameList = ["Agent", "Analyzer", "Collector", "Store", "Netflow", "Normalizer", "Procmonitor", "Searcher", "Web", "Shovel", "Bigdata", "Proxy", "PMS"];
	for(var i=0; i<procNameList.length; i++){
		var procName = procNameList[i].toLowerCase();
		if(procName == "web"){
			procName = "www";
		}
		var newLine = "";
		if(i % 3 == 0){
			newLine = "_first";
		}
		$("#patch_process_list_popup").append("<div class='patch_process_element" + newLine + "_popup' id='patch_process_" + procName + "_popup' data-value='" + procName + "' onclick='javascript:selectProcPopup(\"" + procName + "\")'>"
										+ "<div class='patch_process_icon_popup'></div>" 
										+ "<div class='patch_process_name_popup'>" + procNameList[i] + "</div></div>"); 
	}
}

function selectProc(proc){
	if($("#patch_process_" + proc).hasClass("selected")){
		$("#patch_process_" + proc).removeClass("selected");	
		$("#patch_process_" + proc).css("box-shadow", "");
		$("#patch_process_" + proc).find(".patch_process_icon").css("background-image", "url(<c:url value="/resources/images/patch/process_icon.png"/>)");
		$("#patch_process_" + proc).find(".patch_process_name").css("color", "#adadad");
		
		for(var i=0; i<procList.length; i++){
			if(proc == procList[i]){
				procList.splice(i, 1);
			}
		}
	}else{
		$("#patch_process_" + proc).addClass("selected");
		$("#patch_process_" + proc).css("border-radius", "12px");
		$("#patch_process_" + proc).css("box-shadow", "-0.5px -0.5px 2px");
		$("#patch_process_" + proc).find(".patch_process_icon").css("background-image", "url(<c:url value="/resources/images/patch/process_icon_select.png"/>)");
		$("#patch_process_" + proc).find(".patch_process_name").css("color", "black");
		procList.push(proc);
	}
}

function selectProcPopup(proc){
	if($("#patch_process_" + proc + "_popup").hasClass("selected")){
		$("#patch_process_" + proc + "_popup").removeClass("selected");	
		$("#patch_process_" + proc + "_popup").css("box-shadow", "");
		$("#patch_process_" + proc + "_popup").find(".patch_process_icon_popup").css("background-image", "url(<c:url value="/resources/images/patch/process_icon.png"/>)");
		$("#patch_process_" + proc + "_popup").find(".patch_process_name_popup").css("color", "#adadad");
		
		for(var i=0; i<procLibList.length; i++){
			if(proc == procLibList[i]){
				procLibList.splice(i, 1);
			}
		}
	}else{
		$("#patch_process_" + proc + "_popup").addClass("selected");
		$("#patch_process_" + proc + "_popup").css("border-radius", "12px");
		$("#patch_process_" + proc + "_popup").css("box-shadow", "-0.5px -0.5px 2px");
		$("#patch_process_" + proc + "_popup").find(".patch_process_icon_popup").css("background-image", "url(<c:url value="/resources/images/patch/process_icon_select.png"/>)");
		$("#patch_process_" + proc + "_popup").find(".patch_process_name_popup").css("color", "black");
		procLibList.push(proc);
	}
}

function popupFolderCreate(){
	var folderName = $("[name=folder_name]").val();
	var dupFolderNameChk = false;
	
	if("" == folderName){
		_alert("폴더 이름을 입력하세요.")
	}else{
		if(!/^[0-9|a-z|A-Z|_|\*]+$/.test(folderName)){
			_alert("폴더 이름은<br>영문, 숫자 또는 '_'(밑줄)만<br>입력할 수 있습니다.");
		}else{
			var selectedID = $(chkSelect[0]).attr("id");
			var selectedDepth = Number(selectedID.substring(selectedID.length-1));
			var selectedFolderName = chkSelect[0].outerText;
			
			var selectedChildUls = $("#tree_ul_" + thisDataVal + "_" + selectedFolderName + "_" + selectedDepth).find("ul");
			var selectedChildNames = $($("#tree_ul_" + thisDataVal + "_" + selectedFolderName + "_" + selectedDepth)[0]).find(".tree_name");
			for(var i=0; i<selectedChildUls.length; i++){
				var childUlID = $(selectedChildUls[i]).attr("id");
				var childDepth = Number(childUlID.substring(childUlID.length-1));
				var childFileName = selectedChildNames[i + 1].outerText;
				
				if((selectedDepth + 1) == childDepth){
					if(folderName == childFileName){
						dupFolderNameChk = true;
					}
				}
			}
			
			if(!dupFolderNameChk){
				$("[name=folder_name]").val("");
				$("#popup_background_folder").css("display", "none");
				$(this).fileTree.add($(chkSelect[0]), thisDataVal, folderName, chkSelect[0].outerText);			
			}else{
				_alert("이미 사용 중인 이름 입니다.")
			}
		}
	}
}

function popupClose(){
	$("[name=folder_name]").val("");
	$("#popup_background_folder").css("display", "none");
}

var thisDataVal;
var chkSelect;
function drawFileRegeditForm(){
	$("#patch_file_reg").empty();
	
	$("#patch_file_reg").append("<div class='patch_file_reg_element_list' id='patch_file_reg_element_list'>")
	
	for(var i=0; i<procList.length; i++){
		var procName = procList[i];
		if(procName == "shovel_server"){
			procName = "Shovel";
		}else if(procName == "www"){
			procName = "Web";
		}else{
			procName = procList[i].substring(0,1).toUpperCase() + procList[i].substring(1);
		}
		if(i == 0){
			$("#patch_file_reg_element_list").append("<div class='patch_file_reg_element_first'>"
					+ "<div class='patch_file_reg_element_title'><div style='margin-top:7px;'>" + procName + "</div></div>"
					+ "<div class='patch_file_tree_remove' id='patch_file_tree_remove_" + procList[i] + "' data-value='" + procList[i] + "'>- 삭제 </div>"
					+ "<div class='patch_file_tree_add' id='patch_file_tree_add_" + procList[i] + "' data-value='" + procList[i] + "'>+ 새 폴더</div>"
					+ "<div class='patch_file_tree' id='patch_file_tree_" + procList[i] + "'></div></div></div>");
		}else{
			$("#patch_file_reg_element_list").append("<div class='patch_file_reg_element'>"
					+ "<div class='patch_file_reg_element_title'><div style='margin-top:7px;'>" + procName + "</div></div>"
					+ "<div class='patch_file_tree_remove' id='patch_file_tree_remove_" + procList[i] + "' data-value='" + procList[i] + "'>- 삭제 </div>"
					+ "<div class='patch_file_tree_add' id='patch_file_tree_add_" + procList[i] + "' data-value='" + procList[i] + "'>+ 새 폴더</div>"
					+ "<div class='patch_file_tree' id='patch_file_tree_" + procList[i] + "'></div></div></div>");
		}
		$("#patch_file_tree_add_" + procList[i]).on("click", function(){
			thisDataVal = $(this).attr("data-value");
			chkSelect = $("#patch_file_tree_" + thisDataVal).find(".selected");
			
			$("[name=folder_name]").focus();
			
			if(chkSelect.length == 0 || !$(chkSelect[0]).hasClass("folder")){
				_alert("폴더를 선택하세요.")
			}else{
				$("#popup_background_folder").css("display", "block");
			}
		});

		$("#patch_file_tree_remove_" + procList[i]).on("click", function(){
			thisDataVal = $(this).attr("data-value");
			chkSelect = $("#patch_file_tree_" + thisDataVal).find(".selected");
			if(chkSelect.length == 0){
				_alert("삭제할 항목을 선택하세요.")
			}else{
				var selectedID = $(chkSelect[0]).attr("id");
				var selectedDepth = Number(selectedID.substring(selectedID.length-1));
				var selectedName;
				if(selectedDepth != 0){
					if(!$(chkSelect[0]).hasClass("folder")){
						selectedName = selectedID.substring(0, selectedID.length-2).replace("tree_name_", "");
						selectedName = selectedName.substring(selectedName.indexOf("_") + 1);
						_confirm("삭제하시겠습니까?", {
							onAgree : function() {
								$(this).fileTree.remove(thisDataVal, selectedName, selectedDepth, chkSelect[0].outerText);
							}
						});	
					}else{
						selectedName = chkSelect[0].outerText;
						_confirm("삭제 시 하위 항목들도 함께 삭제됩니다.<br>삭제하시겠습니까?", {
							onAgree : function() {
								$(this).fileTree.remove(thisDataVal, selectedName, selectedDepth, null);
							}
						});	
					}
				}else{
					_alert("최상위 폴더는 삭제할 수 없습니다.");			
				}
			}
		});
		$("#patch_file_tree_" + procList[i]).fileTree.init("#patch_file_tree_" + procList[i], procList[i]);
	}
}

function sqlHeadEvent(obj, idx){
	
	if($(obj).hasClass("selected")){
		$(obj).css("background-color", "#565656");
		$(obj).removeClass("selected");
		$("#query_generator_area").empty();
		$("#query_head_selector").css("display", "none");
		$("#query_generator_area").css("background-color", "");
		$("#query_generator_area").append("<div id='query_empty_text'>생성할 쿼리를 선택하세요</div>");
		
	}else{
		$("#query_generator_area").css("background-color", "#b3b3b3");
		var headSelectorOffset = 11 + (105 * idx);
		$("#query_head_selector").css("display", "block");
		$("#query_head_selector").css("margin-left", headSelectorOffset + "px");
		
		var selectedHead = $("#query_head_area").find(".selected")[0];
		$(selectedHead).css("background-color", "#565656");
		$(selectedHead).removeClass("selected");
		
		$(obj).addClass("selected");
		$(".query_head").css("background-color", "#565656");
		$(obj).css("background-color", "#212121");
	}
}

function sqlElementEvent(obj, type){
	if(!$(obj).hasClass("e_selected")){
		var selectedElement = $("#query_generator_area").find(".e_selected")[0];
		$(selectedElement).css("background-color", "#13597f");
		$(selectedElement).removeClass("e_selected");
		
		$(obj).addClass("e_selected");
		$(obj).css("background-color", "#0e3246");
		
		$("#query_generating_area").empty();
		
		$("[name=n_query]").val(type);
		switch(type){
		case "CREATE_DATABASE":
			$("#query_generating_area").append("<div class='query_generating_text'><div style='float:left'>CREATE&nbsp;&nbsp;</div><div style='float:left;color:#13597f'>DATABASE</div></div>"
								+ "<input class='query_text_input' type='text' name='create_database_name'><div class='query_place_holder'>;</div>"
								+ "<div class='query_info_message' style='left:359px;top:132px;'>데이터베이스 이름</div></div>");	
			break;
		case "CREATE_TABLE":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:47px;'><div style='float:left'>CREATE&nbsp;&nbsp;</div><div style='float:left;color:#13597f'>TABLE</div></div>"
					+ "<input class='query_text_input' type='text' name='create_table_name' style='width:155px;'>" 
					+ "<div class='query_place_holder' style='margin-right:10px;'>(</div><textarea style='width:175px;' class='query_textarea' name='create_table_cont' id='create_table_cont'/><div class='query_place_holder'>);</div>"
					+ "<div class='query_info_message' style='left:242px;top:132px;'>테이블 이름</div>"
					+ "<div class='query_info_message' style='left:428px;top:183px;'>테이블 컬럼 정보</div></div>");
			break;
		case "CREATE_VIEW":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:49px;'><div style='float:left'>CREATE&nbsp;&nbsp;</div><div style='float:left;color:#13597f'>VIEW</div></div>"
					+ "<input class='query_text_input' type='text' name='create_view_name' style='width:155px;'>" 
					+ "<div class='query_place_holder' style='margin-right:10px;'>AS</div><textarea style='width:175px;' class='query_textarea' name='create_view_cont' id='create_view_cont'/><div class='query_place_holder'>;</div>"
					+ "<div class='query_info_message' style='left:249px;top:132px;'>뷰 이름</div>"
					+ "<div class='query_info_message' style='left:447px;top:183px;'>뷰 상세정보</div></div>");
			break;
		case "INSERT_ALL_COL":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:60px;margin-top:68px;width:584px;'>"
					+ "<div><div class='query_place_holder'>INSERT&nbsp;&nbsp;INTO</div><input class='query_text_input' style='float:unset' type='text' name='insert_table_name'></div>"
					+ "<div style='margin-top:32px;margin-left:1px;'><div class='query_place_holder'>VALUES&nbsp;&nbsp;(</div><input class='query_text_input' style='width:371px;' type='text' name='insert_value'><div class='query_place_holder'>);</div></div>"
					+ "<div class='query_info_message' style='left:248px;top:102px;'>테이블 이름</div>"
					+ "<div class='query_info_message' style='left:344px;top:157px;'>컬럼 값</div></div>");	
			break;
		case "INSERT_SOME_COL":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:60px;margin-top:45px;width:584px;'>"
					+ "<div><div class='query_place_holder'>INSERT&nbsp;&nbsp;INTO</div><input class='query_text_input' style='float:unset' type='text' name='insert_table_name'></div>"
					+ "<div style='margin-top:28px;margin-left:1px;'><div class='query_place_holder'>(</div><input class='query_text_input' style='width:371px;' type='text' name='insert_column'><div class='query_place_holder'>);</div></div>"
					+ "<div style='margin-top:78px;margin-left:1px;'><div class='query_place_holder'>VALUES&nbsp;&nbsp;(</div><input class='query_text_input' style='width:371px;' type='text' name='insert_value'><div class='query_place_holder'>);</div></div>"
					+ "<div class='query_info_message' style='left:248px;top:78px;'>테이블 이름</div>"
					+ "<div class='query_info_message' style='left:256px;top:128px;'>컬럼 이름</div>"
					+ "<div class='query_info_message' style='left:350px;top:179px;'>컬럼 값</div></div>");	
			break;
		case "UPDATE_NORMAL":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:98px;margin-top:68px;width:584px;'>"
					+ "<div><div class='query_place_holder'>UPDATE</div><input class='query_text_input' style='float:unset' type='text' name='update_table_name'></div>"
					+ "<div style='margin-top:32px;margin-left:1px;'><div class='query_place_holder'>SET</div><input class='query_text_input' style='width:371px;' type='text' name='update_set_value'><div class='query_place_holder'>;</div></div>"
					+ "<div class='query_info_message' style='left:242px;top:102px;'>테이블 이름</div>"
					+ "<div class='query_info_message' style='left:253px;top:157px;'>변경할 컬럼과 값(ex. name='query')</div></div>");	
			break;
		case "UPDATE_WHERE":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:71px;margin-top:42px;width:584px;'>"
					+ "<div><div class='query_place_holder'>UPDATE</div><input class='query_text_input' style='float:unset' type='text' name='update_table_name'></div>"
					+ "<div style='margin-top:32px;margin-left:1px;'><div class='query_place_holder'>SET</div><input class='query_text_input' style='width:371px;' type='text' name='update_set_value'></div>"
					+ "<div style='margin-top:83px;margin-left:1px;'><div class='query_place_holder'>WHERE</div><input class='query_text_input' style='width:371px;' type='text' name='update_where'><div class='query_place_holder'>;</div></div>"
					+ "<div class='query_info_message' style='left:218px;top:76px;'>테이블 이름</div>"
					+ "<div class='query_info_message' style='left:226px;top:130px;'>변경할 컬럼과 값(ex. name='query')</div>"
					+ "<div class='query_info_message' style='left:327px;top:180px;'>조건부</div></div>");	
			break;
		case "ALTER_ADD":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:42px;margin-top:68px;width:584px;'>"
					+ "<div><div class='query_place_holder'>ALTER&nbsp;&nbsp;TABLE</div><input class='query_text_input' style='float:unset' type='text' name='alter_table_name'></div>"
					+ "<div style='margin-top:32px;margin-left:1px;'><div class='query_place_holder' style='color:#13597f'>ADD</div><input class='query_text_input' style='width:150px;' type='text' name='alter_column_name'>"
					+ "<input class='query_text_input' style='width:100px;' type='text' name='alter_column_type'>"
					+ "<input class='query_text_input' style='width:185px;' type='text' name='alter_column_option'><div class='query_place_holder'>;</div></div>"
					+ "<div class='query_info_message' style='left:236px;top:102px;'>테이블 이름</div>"
					+ "<div class='query_info_message' style='left:158px;top:157px;'>컬럼 이름</div>"
					+ "<div class='query_info_message' style='left:293px;top:157px;'>컬럼 타입</div>"
					+ "<div class='query_info_message' style='left:447px;top:157px;'>컬럽 옵션</div></div>");	
			break;
		case "ALTER_DROP":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:38px;margin-top:100px;width:584px;'>"
					+ "<div><div class='query_place_holder'>ALTER&nbsp;&nbsp;TABLE</div><input class='query_text_input' type='text' name='alter_table_name'>"
					+ "<div class='query_place_holder' style='color:#13597f'>DROP</div><input class='query_text_input' style='width:150px;' type='text' name='alter_column_name'></div>"
					+ "<div class='query_info_message' style='left:231px;top:134px;'>테이블 이름</div>"
					+ "<div class='query_info_message' style='left:466px;top:134px;'>컬럽 이름</div></div>");	
			break;
		case "ALTER_CHANGE":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:100px;margin-top:45px;width:584px;'>"
					+ "<div><div class='query_place_holder'>ALTER&nbsp;&nbsp;TABLE</div><input class='query_text_input' style='float:unset' type='text' name='alter_table_name'></div>"
					+ "<div style='margin-top:30px;margin-left:1px;'><div class='query_place_holder' style='color:#13597f'>CHANGE</div><input class='query_text_input' style='width:150px;' type='text' name='alter_column_name'>"
					+ "<input class='query_text_input' style='width:150px;' type='text' name='alter_column_name_new'></div>"
					+ "<div style='margin-top:82px;margin-left:1px;'><input class='query_text_input' style='width:100px;' type='text' name='alter_column_type'>"
					+ "<input class='query_text_input' style='width:185px;' type='text' name='alter_column_option'><div class='query_place_holder'>;</div></div></div>"
					+ "<div class='query_info_message' style='left:293px;top:79px;'>테이블 이름</div>"
					+ "<div class='query_info_message' style='left:244px;top:130px;'>기존 컬럼 이름</div>"
					+ "<div class='query_info_message' style='left:407px;top:130px;'>새 컬럼 이름</div>"
					+ "<div class='query_info_message' style='left:140px;top:182px;'>컬럼 타입</div>"
					+ "<div class='query_info_message' style='left:294px;top:182px;'>컬럽 옵션</div></div>");	
			break;
		case "ALTER_MODIFY":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:23px;margin-top:68px;width:584px;'>"
					+ "<div><div class='query_place_holder'>ALTER&nbsp;&nbsp;TABLE</div><input class='query_text_input' style='float:unset' type='text' name='alter_table_name'></div>"
					+ "<div style='margin-top:32px;margin-left:1px;'><div class='query_place_holder' style='color:#13597f'>MODIFY</div><input class='query_text_input' style='width:150px;' type='text' name='alter_column_name'>"
					+ "<input class='query_text_input' style='width:100px;' type='text' name='alter_column_type'>"
					+ "<input class='query_text_input' style='width:185px;' type='text' name='alter_column_option'><div class='query_place_holder'>;</div></div>"
					+ "<div class='query_info_message' style='left:217px;top:102px;'>테이블 이름</div>"
					+ "<div class='query_info_message' style='left:170px;top:157px;'>컬럼 이름</div>"
					+ "<div class='query_info_message' style='left:306px;top:157px;'>컬럼 타입</div>"
					+ "<div class='query_info_message' style='left:458px;top:157px;'>컬럽 옵션</div></div>");	
			break;
		case "ALTER_RENAME":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:27px;margin-top:100px;width:584px;'>"
					+ "<div><div class='query_place_holder'>ALTER&nbsp;&nbsp;TABLE</div><input class='query_text_input' type='text' name='alter_table_name'>"
					+ "<div class='query_place_holder' style='color:#13597f'>RENAME</div><input class='query_text_input' style='width:150px;' type='text' name='alter_table_name_new'></div>"
					+ "<div class='query_info_message' style='left:222px;top:134px;'>테이블 이름</div>"
					+ "<div class='query_info_message' style='left:470px;top:134px;'>새 테이블 이름</div></div>");	
			break;
		case "DROP_DATABASE":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:137px;'><div style='float:left'>DROP&nbsp;&nbsp;</div><div style='float:left;color:#13597f'>DATABASE</div>"
								+ "<input class='query_text_input' type='text' name='drop_target_name'><div class='query_place_holder'>;</div>"
								+ "<div class='query_info_message' style='left:347px;top:132px;'>데이터베이스 이름</div></div>");	
			break;
		case "DROP_TABLE":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:170px;'><div style='float:left'>DROP&nbsp;&nbsp;</div><div style='float:left;color:#13597f'>TABLE</div>"
								+ "<input class='query_text_input' type='text' name='drop_target_name'><div class='query_place_holder'>;</div>"
								+ "<div class='query_info_message' style='left:350px;top:132px;'>테이블 이름</div></div>");	
			break;
		case "DROP_FUNCTION":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:152px;'><div style='float:left'>DROP&nbsp;&nbsp;</div><div style='float:left;color:#13597f'>FUNCTION</div>"
								+ "<input class='query_text_input' type='text' name='drop_target_name'><div class='query_place_holder'>;</div>"
								+ "<div class='query_info_message' style='left:375px;top:132px;'>함수 이름</div></div>");	
			break;
		case "DROP_PROCEDURE":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:142px;'><div style='float:left'>DROP&nbsp;&nbsp;</div><div style='float:left;color:#13597f'>PROCEDURE</div>"
								+ "<input class='query_text_input' type='text' name='drop_target_name'><div class='query_place_holder'>;</div>"
								+ "<div class='query_info_message' style='left:372px;top:132px;'>프로시저 이름</div></div>");	
			break;
		case "DROP_TRIGGER":
			$("#query_generating_area").append("<div class='query_generating_text' style='margin-left:159px;'><div style='float:left'>DROP&nbsp;&nbsp;</div><div style='float:left;color:#13597f'>TRIGGER</div>"
								+ "<input class='query_text_input' type='text' name='drop_target_name'><div class='query_place_holder'>;</div>"
								+ "<div class='query_info_message' style='left:363px;top:132px;'>트리거 이름</div></div>");	
			break;
		}
	}
}

function sqlGeneratorEvent(){
	$("#query_generator_area").append("<div id='query_empty_text'>생성할 쿼리를 선택하세요</div>");
	
	$("#query_head_create").on("click", function(){
		$("#query_generator_area").empty();
		
		if(!$(this).hasClass("selected")){
			$("#query_generator_area").append("<div style='margin-left:-5px;padding-top:10px;'>"
					+ "<div class='query_element' id='query_element_database'><div class='query_head_label'>DATABASE</div></div>"
					+ "<div class='query_element' id='query_element_table'><div class='query_head_label'>TABLE</div></div>"
					+ "<div class='query_element' id='query_element_view'><div class='query_head_label'>VIEW</div></div></div>");
			
			$("#query_generator_area").append("<div id='query_generating_area'><div id='query_target_text'>CREATE 대상을 선택하세요</div></div>");
			
			$("#query_element_database").on("click", function(){
				sqlElementEvent(this, "CREATE_DATABASE");
			});
			
			$("#query_element_table").on("click", function(){
				sqlElementEvent(this, "CREATE_TABLE");
			});
			
			$("#query_element_view").on("click", function(){
				sqlElementEvent(this, "CREATE_VIEW");
			});
		}
		sqlHeadEvent(this, 0);
	});
	
	$("#query_head_insert").on("click", function(){
		$("#query_generator_area").empty();
		
		if(!$(this).hasClass("selected")){
			$("#query_generator_area").append("<div style='margin-left:-5px;padding-top:10px;'>"
					+ "<div class='query_element' id='query_element_all_col'><div class='query_head_label'>모든 컬럼</div></div>"
					+ "<div class='query_element' id='query_element_some_col'><div class='query_head_label'>일부 컬럼</div></div></div>");
			
			$("#query_generator_area").append("<div id='query_generating_area'><div id='query_target_text'>INSERT 종류를 선택하세요.</div></div>");
			
			$("#query_element_all_col").on("click", function(){
				sqlElementEvent(this, "INSERT_ALL_COL");
			});
			
			$("#query_element_some_col").on("click", function(){
				sqlElementEvent(this, "INSERT_SOME_COL");
			});
			
		}
		
		sqlHeadEvent(this, 1);
	});
	
	$("#query_head_update").on("click", function(){
		$("#query_generator_area").empty();
		
		$("#query_generator_area").append("<div style='margin-left:-5px;padding-top:10px;'>"
				+ "<div class='query_element' id='query_element_update_normal'><div class='query_head_label'>기본</div></div>"
				+ "<div class='query_element' id='query_element_update_where'><div class='query_head_label'>WHERE</div></div></div>");
		
		$("#query_generator_area").append("<div id='query_generating_area'><div id='query_target_text'>UPDATE 종류를 선택하세요.</div></div>");
		
		$("#query_element_update_normal").on("click", function(){
			sqlElementEvent(this, "UPDATE_NORMAL");
		});
		
		$("#query_element_update_where").on("click", function(){
			sqlElementEvent(this, "UPDATE_WHERE");
		});
		
		sqlHeadEvent(this, 2);
	});
	
	$("#query_head_alter").on("click", function(){
		$("#query_generator_area").empty();
		
		$("#query_generator_area").append("<div style='margin-left:-5px;padding-top:10px;'>"
				+ "<div class='query_element' id='query_element_alter_add'><div class='query_head_label'>ADD</div></div>"
				+ "<div class='query_element' id='query_element_alter_drop'><div class='query_head_label'>DROP</div></div>"
				+ "<div class='query_element' id='query_element_alter_change'><div class='query_head_label'>CHANGE</div></div>"
				+ "<div class='query_element' id='query_element_alter_modify'><div class='query_head_label'>MODIFY</div></div>"
				+ "<div class='query_element' id='query_element_alter_rename'><div class='query_head_label'>RENAME</div></div></div>");
		
		$("#query_generator_area").append("<div id='query_generating_area'><div id='query_target_text'>ALTER 종류를 선택하세요.</div></div>");
		
		$("#query_element_alter_add").on("click", function(){
			sqlElementEvent(this, "ALTER_ADD");
		});
		
		$("#query_element_alter_drop").on("click", function(){
			sqlElementEvent(this, "ALTER_DROP");
		});
		
		$("#query_element_alter_change").on("click", function(){
			sqlElementEvent(this, "ALTER_CHANGE");
		});
		
		$("#query_element_alter_modify").on("click", function(){
			sqlElementEvent(this, "ALTER_MODIFY");
		});
		
		$("#query_element_alter_rename").on("click", function(){
			sqlElementEvent(this, "ALTER_RENAME");
		});
		
		sqlHeadEvent(this, 3);
	});
	
	$("#query_head_drop").on("click", function(){
		$("#query_generator_area").empty();
		
		$("#query_generator_area").append("<div style='margin-left:-5px;padding-top:10px;'>"
				+ "<div class='query_element' id='query_element_drop_database'><div class='query_head_label'>DATABASE</div></div>"
				+ "<div class='query_element' id='query_element_drop_table'><div class='query_head_label'>TABLE</div></div>"
				+ "<div class='query_element' id='query_element_drop_function'><div class='query_head_label'>FUNCTION</div></div>"
				+ "<div class='query_element' id='query_element_drop_procedure'><div class='query_head_label'>PROCEDURE</div></div>"
				+ "<div class='query_element' id='query_element_drop_trigger'><div class='query_head_label'>TRIGGER</div></div></div>");
		
		$("#query_generator_area").append("<div id='query_generating_area'><div id='query_target_text'>DROP 대상을 선택하세요.</div></div>");
		
		$("#query_element_drop_database").on("click", function(){
			sqlElementEvent(this, "DROP_DATABASE");
		});
		
		$("#query_element_drop_table").on("click", function(){
			sqlElementEvent(this, "DROP_TABLE");
		});
		
		$("#query_element_drop_function").on("click", function(){
			sqlElementEvent(this, "DROP_FUNCTION");
		});
		
		$("#query_element_drop_procedure").on("click", function(){
			sqlElementEvent(this, "DROP_PROCEDURE");
		});
		
		$("#query_element_drop_trigger").on("click", function(){
			sqlElementEvent(this, "DROP_TRIGGER");
		});
		
		sqlHeadEvent(this, 4);
	});
	
	$("#query_head_delimiter").on("click", function(){
		$("#query_generator_area").empty();
		$("[name=n_query]").val("DELIMITER");
		$("#query_generator_area").append("<div id='query_generating_area'></div>");
		$("#query_generating_area").append("<div class='query_generating_text' style='margin-top:0px;margin-left:15px;'>"
				+ "<div><div class='query_place_holder delimiter' style='margin-top:11px;font-size:12pt;'>-- @DELIMITER $$</div></div>"
				+ "<div><textarea style='width:283px;margin-left:-133px;margin-top:35px;' class='query_textarea' name='delimiter_cont' id='delimiter_cont'/></div>"
				+ "<div><div class='query_place_holder delimiter' style='margin-top:11px;font-size:12pt;width:215px;'>-- @DELIMITER $$</div></div>"
				+ "<div style='float:left;width:1px;height:100px;background-color:black;height:170px;top:17px;left:319px;position:absolute;'></div>"
				+ "<div class='query_info_message' style='left:258px;top:165px;'>상세 내용</div>"
				+ "<div class='query_info_message' style='left:330px;top:17px;'><div style='font-size: 10pt;'>작성예시</div><br>CREATE<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FUNCTION `CloudESM`.`EXAMPLE_TABLE`()<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;RETURNS INT<br>"
				+ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;BEGIN<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DECLARE result INT DEFAULT -1;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SELECT COUNT(*) INTO result FROM TEST_TABLE;<br>"
				+ "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;RETURN result;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;END;</div></div>");
		sqlHeadEvent(this, 5);
	});
}

function sqlPopupInit(){
	$("#popup_background_sql").css("display", "none");
	$("#query_generator_area").css("background-color", "");
	$("#query_head_selector").css("display", "none");
	$("#query_generator_area").empty();
	$(".query_head_first").css("background-color", "#565656");
	$(".query_head").css("background-color", "#565656");
	$(".query_head_first").removeClass("selected");
	$(".query_head").removeClass("selected");
	$("#query_generator_area").append("<div id='query_empty_text'>생성할 쿼리를 선택하세요</div>");
}

function sqlRegistration(){
	var queryTypeName = $("[name=n_query]").val();
	if(queryTypeName == ""){
		_alert("쿼리를 생성하세요.");
	}else{
		var query;
		switch(queryTypeName){
		case "CREATE_DATABASE":
			var createDatabaseName = $("[name=create_database_name]").val();
			if(createDatabaseName == ""){
				_alert("데이터베이스 이름을 입력하세요.");
			}else{
				query = "CREATE DATABASE " + createDatabaseName + ";";	
				sqlPopupInit();
			}
			break;
		case "CREATE_TABLE":
			var createTableName = $("[name=create_table_name]").val();
			var createTableColInfo = $("[name=create_table_cont]").val();
			
			if(createTableName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else if(createTableColInfo == ""){
				_alert("테이블 컬럼 정보를 입력하세요.");
			}else{
				query = "CREATE TABLE " + createTableName + " (" + createTableColInfo + ");";
				while(query.indexOf("\n") > -1){
					query = query.replace(/(\n)/gm, " ");	
				}
				sqlPopupInit();
			}
			break;
		case "CREATE_VIEW":
			var createViewName = $("[name=create_view_name]").val();
			var createViewInfo = $("[name=create_view_cont]").val();
			
			if(createViewName == ""){
				_alert("뷰 이름을 입력하세요.");
			}else if(createViewInfo == ""){
				_alert("뷰 컬럼 정보를 입력하세요.");
			}else{
				query = "CREATE VIEW " + createViewName + " AS " + createViewInfo + ";";
				while(query.indexOf("\n") > -1){
					query = query.replace(/(\n)/gm, " ");	
				}
				sqlPopupInit();
			}
			break;
		case "INSERT_ALL_COL":
			var insertTableName = $("[name=insert_table_name]").val();
			var insertValue = $("[name=insert_value]").val();
			
			if(insertTableName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else if(insertValue == ""){
				_alert("컬럼 값을 입력하세요.");
			}else{
				query = "INSERT INTO " + insertTableName + " VALUES (" + insertValue + ");";
				sqlPopupInit();
			}
			break;
		case "INSERT_SOME_COL":
			var insertTableName = $("[name=insert_table_name]").val();
			var insertColumnName = $("[name=insert_column]").val();
			var insertValue = $("[name=insert_value]").val();
			
			if(insertTableName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else if(insertColumnName == ""){
				_alert("컬럼 이름을 입력하세요.");
			}else if(insertValue == ""){
				_alert("컬럼 값을 입력하세요.");
			}else{
				query = "INSERT INTO " + insertTableName + " (" + insertColumnName + ") VALUES (" + insertValue + ");";
				sqlPopupInit();
			}
			break;
		case "UPDATE_NORMAL":
			var updateTableName = $("[name=update_table_name]").val();
			var updateSetValue = $("[name=update_set_value]").val();
			
			if(updateTableName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else if(updateSetValue == ""){
				_alert("변경할 컬럼과 값을 입력하세요.");
			}else{
				query = "UPDATE " + updateTableName + " SET " + updateSetValue + ";";
				sqlPopupInit();
			}
			break;
		case "UPDATE_WHERE":
			var updateTableName = $("[name=update_table_name]").val();
			var updateSetValue = $("[name=update_set_value]").val();
			var updateWhere = $("[name=update_where]").val();
			
			if(updateTableName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else if(updateSetValue == ""){
				_alert("변경할 컬럼과 값을 입력하세요.");
			}else if(updateWhere == ""){
				_alert("조건부를 입력하세요.");
			}else{
				query = "UPDATE " + updateTableName + " SET " + updateSetValue + " WHERE " + updateWhere + ";";
				sqlPopupInit();
			}
			break;
		case "ALTER_ADD":
			var alterTableName = $("[name=alter_table_name]").val();
			var alterColumnName = $("[name=alter_column_name]").val();
			var alterColumnType = $("[name=alter_column_type]").val();
			var alterColumnOption = $("[name=alter_column_option]").val();
			
			if(alterTableName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else if(alterColumnName == ""){
				_alert("컬럼 이름을 입력하세요.");
			}else if(alterColumnType == ""){
				_alert("컬럼 타입을 입력하세요.");
			}else{
				query = "ALTER TABLE " + alterTableName + " ADD " + alterColumnName + " " + alterColumnType + " " + alterColumnOption + ";";
				sqlPopupInit();
			}
			break;
		case "ALTER_DROP":
			var alterTableName = $("[name=alter_table_name]").val();
			var alterColumnName = $("[name=alter_column_name]").val();
			
			if(alterTableName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else if(alterColumnName == ""){
				_alert("컬럼 이름을 입력하세요.");
			}else{
				query = "ALTER TABLE " + alterTableName + " DROP " + alterColumnName + ";";
				sqlPopupInit();
			}
			break;
		case "ALTER_CHANGE":
			var alterTableName = $("[name=alter_table_name]").val();
			var alterColumnName = $("[name=alter_column_name]").val();
			var alterColumnNameNew = $("[name=alter_column_name_new]").val();
			var alterColumnType = $("[name=alter_column_type]").val();
			var alterColumnOption = $("[name=alter_column_option]").val();
			
			if(alterTableName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else if(alterColumnName == ""){
				_alert("컬럼 이름을 입력하세요.");
			}else if(alterColumnNameNew == ""){
				_alert("새 컬럼 이름을 입력하세요.");
			}else if(alterColumnType == ""){
				_alert("컬럼 타입을 입력하세요.");
			}else{
				query = "ALTER TABLE " + alterTableName + " CHANGE " + alterColumnName + " " + alterColumnNameNew + " " + alterColumnType + " " + alterColumnOption + ";";
				sqlPopupInit();
			}
			break;
		case "ALTER_MODIFY":
			var alterTableName = $("[name=alter_table_name]").val();
			var alterColumnName = $("[name=alter_column_name]").val();
			var alterColumnType = $("[name=alter_column_type]").val();
			var alterColumnOption = $("[name=alter_column_option]").val();
			
			if(alterTableName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else if(alterColumnName == ""){
				_alert("컬럼 이름을 입력하세요.");
			}else if(alterColumnType == ""){
				_alert("컬럼 타입을 입력하세요.");
			}else{
				query = "ALTER TABLE " + alterTableName + " MODIFY " + alterColumnName + " " + alterColumnType + " " + alterColumnOption + ";";
				sqlPopupInit();
			}
			break;
		case "ALTER_RENAME":
			var alterTableName = $("[name=alter_table_name]").val();
			var alterTableNameNew = $("[name=alter_table_name_new]").val();
			
			if(alterTableName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else if(alterTableNameNew == ""){
				_alert("새 테이블 이름을 입력하세요.");
			}else{
				query = "ALTER TABLE " + alterTableName + " RENAME " + alterTableNameNew + ";";
				sqlPopupInit();
			}
			break;
		case "DROP_DATABASE":
			var dropTargetName = $("[name=drop_target_name]").val();
			
			if(dropTargetName == ""){
				_alert("데이터베이스 이름을 입력하세요.");
			}else{
				query = "DROP DATABASE " + dropTargetName + ";";
				sqlPopupInit();
			}
			break;
		case "DROP_TABLE":
			var dropTargetName = $("[name=drop_target_name]").val();
			
			if(dropTargetName == ""){
				_alert("테이블 이름을 입력하세요.");
			}else{
				query = "DROP TABLE " + dropTargetName + ";";
				sqlPopupInit();
			}
			break;
		case "DROP_FUNCTION":
			var dropTargetName = $("[name=drop_target_name]").val();
			
			if(dropTargetName == ""){
				_alert("함수 이름을 입력하세요.");
			}else{
				query = "DROP FUNCTION " + dropTargetName + ";";
				sqlPopupInit();
			}
			break;
		case "DROP_PROCEDURE":
			var dropTargetName = $("[name=drop_target_name]").val();
			
			if(dropTargetName == ""){
				_alert("프로시저 이름을 입력하세요.");
			}else{
				query = "DROP PROCEDURE " + dropTargetName + ";";
				sqlPopupInit();
			}
			break;
		case "DROP_TRIGGER":
			var dropTargetName = $("[name=drop_target_name]").val();
			
			if(dropTargetName == ""){
				_alert("트리거 이름을 입력하세요.");
			}else{
				query = "DROP TRIGGER " + dropTargetName + ";";
				sqlPopupInit();
			}
			break;
		case "DELIMITER":
			var delimiterCont = $("[name=delimiter_cont]").val();
			
			if(delimiterCont == ""){
				_alert("상세 내용을 입력하세요.");
			}else{
				query = "-- @DELIMITER $$@br@" + delimiterCont + "@br@-- @DELIMITER $$";
				query = query.replace(/(\n)/gm, "@br@");	
				sqlPopupInit();
			}
			break;
		}
		
		var queryMap = {};
		if(queryTypeName == "DELIMITER"){
			queryMap["DELIMITER"] = query;
		}else{
			queryMap[queryTypeName.split("_")[0]] = query;	
		}
		
		sqlMapList.push(queryMap);
		drawSqlMapTable();
		
		$("#sql_reg_table_area").hide();
		$("#sql_reg_table_area").fadeIn();
	}
}

function drawSqlMapTable(){
	$("#sql_reg_table_area").empty();
	if(sqlMapList.length == 0){
		$("#sql_reg_icon").css("height", "30px");
		$("#sql_reg_icon").css("width", "81px");
		$("#sql_reg_icon").css("margin-left", "294px");
		$("#sql_reg_icon").css("margin-top", "152px");
		$("#sql_reg_icon").css("background-size", "86px");
	}else{
		
		$("#sql_reg_icon").css("height", "24px");
		$("#sql_reg_icon").css("width", "56px");
		$("#sql_reg_icon").css("margin-left", "603px");
		$("#sql_reg_icon").css("margin-top", "6px");
		$("#sql_reg_icon").css("background-size", "67px");
		
		$("#sql_reg_table_area").append("<table class='tbl_type' id='sql_reg_table' style='margin-top:12px;'><tr><th style='width:12%;'>No</th><th style='width:22%;'>Type</th><th>Query</th></tr></table>");
		
		for(var i=0; i<sqlMapList.length; i++){
			var key = Object.keys(sqlMapList[i])[0];
			var query = sqlMapList[i][key];
			if(key == "DELIMITER"){
				while(query.indexOf("@br@") > -1){
					query = query.replace("@br@", "<br>");	
				}
			}
			$("#sql_reg_table").append("<tr id='sql_tr_id_" + (i+1) + "'><td>" + (i+1) + "</td><td>" + key + "</td><td style='text-align:left;'>"
								+ "<div style='float:left;width:400px;'>" + query + "</div><div onclick='javascript:removeQuery(" + i + ")' class='sql_query_remove_icon'></div></td></tr>")
		}
	}
}

function removeQuery(idx){
	sqlMapList.splice(idx, 1);
	drawSqlMapTable();
}

function patchContInputEvent(){
	var patchCont = $("[name=patch_file_cont]").val();
	
	if(patchCont.length == 0){
		$("#generate_icon").attr("onclick", "");
		$("#generate_icon").css("background-image", "url(<c:url value="/resources/images/patch/generate_icon_over.png"/>)")
		$("#generate_icon").css("cursor", "unset");
		$("#generate_icon").off("hover");
	}else{
		$("#generate_icon").attr("onclick", "javascript:generatePatchFile()");
		$("#generate_icon").css("background-image", "url(<c:url value="/resources/images/patch/generate_icon.png"/>)")
		$("#generate_icon").css("cursor", "pointer");
		$("#generate_icon").hover(
			function() {
				$("#generate_icon").css("background-image", "url(<c:url value="/resources/images/patch/generate_icon_over.png"/>)")
			}, function() {
				$("#generate_icon").css("background-image", "url(<c:url value="/resources/images/patch/generate_icon.png"/>)")
			}
		);
	}
}

function generatePatchFile(){
	_confirm("패치파일을 생성하시겠습니까?", {
		onAgree : function() {
			var fileName = $("[name=patch_file_name]").val();
			var fileUploadPath = $("[name=file_upload_path]").val();
			var patchCont = $("[name=patch_file_cont]").val();
			var formData = new FormData();
			formData.append('file_upload_path', fileUploadPath);
			formData.append('file_name', fileName);
 			formData.append('sql_list', JSON.stringify(sqlMapList));
 			formData.append('lib_patch_map', JSON.stringify(libPatchMap));
 			formData.append('proc_list', JSON.stringify(procList));
 			formData.append('patch_cont', patchCont);
 			
			$.ajax({
			    url: "/download/patch_file_generate.do",
			    type: 'POST',
			    data: formData,
				enctype:'multipart/form-data',
				dataType: 'json',
				processData: false,
				contentType: false,
				success: function(res) {
					var result = res.data;
					if(!result){
						_alert("패치 파일 생성 중 오류가 발생하였습니다.")
					}else{
						parent.refresh();
					}
				}
			});
		}
	});	
}

function patchFileNameDupChk(){
	var fileName = $("[name=patch_file_name]").val();
	
	$.ajax({
		type: 'POST',
	    url: "/download/patch_file_name_dup.do",
	    contentType : "application/json",
	    data: JSON.stringify({file_name:fileName}),
		dataType: 'json',
		success: function(res) {
			var result = res.data;
			
			if(result > 0){
				$("#patch_step_move_right").attr("onclick", "");
				$("#patch_step_move_right").css("background-image", "url(<c:url value="/resources/images/patch/right_pointer_over.png"/>)");
				$("#patch_step_move_right").css("cursor", "unset");
				$("#patch_step_move_right").off("hover");
				$("#patch_file_name_warning").css("display", "block");
			}else{
				$("#patch_step_move_right").attr("onclick", "javascript:goNext()");
				$("#patch_step_move_right").css("background-image", "url(<c:url value="/resources/images/patch/right_pointer.png"/>)");
				$("#patch_file_name_warning").css("display", "none");
				$("#patch_step_move_right").css("cursor", "pointer");
				$("#patch_step_move_right").hover(
					function() {
						$("#patch_step_move_right").css("background-image", "url(<c:url value="/resources/images/patch/right_pointer_over.png"/>)");
					}, function() {
						$("#patch_step_move_right").css("background-image", "url(<c:url value="/resources/images/patch/right_pointer.png"/>)");
					}
				)
			}
		}
	});
}

$().ready(function() {
	$(".modal-head").find("button").css("background","url(<c:url value='/resources/themes/smoothness/images/common/btn_pop_close.png'/>) no-repeat")
	$(".modal-head").find("button").css("background-position", "center")
	
	$("input").on('keydown', function(e) { 
 		var keyCode = e.keyCode || e.which; 

		if (keyCode == 9) { 
	    e.preventDefault(); 
	  	} 
	});
	
	$(".btn-close").on("click", function(){
		var pageNum = (Number($("#patch_step_all").css("margin-left").replace("px", "")) / 683) * -1;
		if(pageNum >= 2){
			removeFolder($("[name=file_upload_path]").val());
		}
	}) 
	
	$('#patch_file_reg').on("dragenter dragstart dragend dragleave dragover drag drop", function (e) {
        		e.stopPropagation();
        	    e.preventDefault();
        	    return false;
    });
	
	$("[name=patch_file_name]").focus();
	
	var pageNum = (Number($("#patch_step_all").css("margin-left").replace("px", "")) / 683) * -1;
	if(pageNum == 0){
		$("#patch_step_move_left").css("display", "none");
	}
	
	$("input:radio[name=lib_patch_type]:radio[value='0']").prop("checked", "true");
	$("input:radio[name=lib_patch_type]").on("change", function(){
		var patchTypeVal = $("input:radio[name=lib_patch_type]:checked").val();
		if(patchTypeVal == 0){
			$("#popup_input_table_div").css("display", "none");	
			$("[name=old_lib_name]").val("");
			$("#popup_background_frame_lib").css("height", "328px")
			$("#popup_background_all_lib").animate({
				"margin-top":"48px"				
			});
		}else{
			$("#popup_input_table_div").css("display", "block");
			$("#popup_background_frame_lib").css("height", "380px")
			$("#popup_background_all_lib").animate({
				"margin-top":"27px"				
			});
		}
	});
	
	$("#sql_reg_icon").on("click", function (){
		$("#popup_background_sql").css("display", "block");
	});
	
	$("#btn_sql_registration").on("click", function(){
		sqlRegistration();
	});
	
	$("#btn_sql_close").on("click", function(){
		sqlPopupInit();
	});
	
	drawProcessList();
	drawProcessListPopup();
	
	sqlGeneratorEvent();
});


</script>
<style>

#patch_step_all{
	height:383px;
	width:3415px;
}

.patch_step_area{
	float:left;
	height:100%;
	width:683px;
}

.patch_step_title{
	margin-top:14px;
	margin-left:10px;
	font-size:20pt;
	font-weight:bold;
	color:#565656;
	font-family:NanumGothic, sans-serif;
}

#patch_step_btn_area{
	float:right;
}

#patch_step_move_left{
	float:left;
	height:30px;
	width:30px;
	margin-top:12px;
	background-image:url(<c:url value="/resources/images/patch/left_pointer.png"/>);
	background-size: 30px;
	cursor:pointer;
}

#patch_step_move_left:hover{
	background-image:url(<c:url value="/resources/images/patch/left_pointer_over.png"/>);
}

#patch_step_move_right{
	float:left;
	height:30px;
	width:30px;
	margin-top:12px;
	margin-left:5px;
	background-image:url(<c:url value="/resources/images/patch/right_pointer.png"/>);
	background-size: 30px;
	cursor:pointer;
}

#patch_step_move_right:hover{
	background-image:url(<c:url value="/resources/images/patch/right_pointer_over.png"/>);
}

#patch_process_list{
	margin-top: 33px;
    margin-left: 30px;
    width: 614px;
    height:290px;
}

.patch_process_element_first{
	float:left;
	margin-top:11px;
	height:74px;
	width:90px;
	text-align:center;
	cursor:pointer;
}

.patch_process_element_first:hover{
	border-radius:12px;
	box-shadow:0.5px 0.5px 2px;
}

.patch_process_element{
	float:left;
	margin-left:35px;
	margin-top:11px;
	height:74px;
	width:93px;
	text-align:center;
	cursor:pointer;
}

.patch_process_element:hover{
	border-radius:12px;
	box-shadow:0.5px 0.5px 2px;
}

.patch_process_icon{
	float:left;
	height:45px;
	width:45px;
	margin-left:22px;
	margin-top:6px;
	background-image:url(<c:url value="/resources/images/patch/process_icon.png"/>);
	background-size: 45px;
}
.patch_process_name{
	padding-top:54px;
	color:#adadad;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

#patch_process_list_popup{
	margin-top: 2px;
	margin-left:23px;
    width: 400px;
    height:185px;
}

.patch_process_element_first_popup{
	float:left;
	margin-top:11px;
	height:26px;
	width:105px;
	text-align:center;
	cursor:pointer;
}

.patch_process_element_first_popup:hover{
	border-radius:12px;
	box-shadow:0.5px 0.5px 2px;
}

.patch_process_element_popup{
	float:left;
	margin-top:11px;
	margin-left:20px;
	height:26px;
	width:105px;
	text-align:center;
	cursor:pointer;
}

.patch_process_element_popup:hover{
	border-radius:12px;
	box-shadow:0.5px 0.5px 2px;
}

.patch_process_icon_popup{
	float:left;
	height:25px;
	width:25px;
	margin-left:5px;
	margin-top:-1px;
	background-image:url(<c:url value="/resources/images/patch/process_icon.png"/>);
	background-size: 25px;
}
.patch_process_name_popup{
    float: left;
    width: 60px;
	padding-top:5.1px;
	padding-left:3px;
	color:#adadad;
	text-align:left;
	font-size:8pt;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

#patch_file_reg{
	float:left;
	height:321px;
	width:404px;
	margin-left:20px;
	margin-top:20px;
	overflow:auto;
	z-index:-1;
}

.patch_file_reg_element_title{
	height: 32px;
    width: 100px;
    margin-top: -16px;
    margin-left: 11px;
	background-color: #bdbdbd;    
    border:solid 1px;
    border-radius:7px;
    text-align:center;
    font-size:10pt;
    font-weight:bold;
    font-family:NanumGothic, sans-serif;
}

.patch_file_reg_element_first{
	height:170px;
	width:381px;
	margin-top:15px;
	background-color:white;
	border:solid 1px;
	border-radius:12px;
}

.patch_file_reg_element{
	height:170px;
	width:381px;
	margin-top:35px;
	background-color:white;
	border:solid 1px;
	border-radius:12px;
}

.patch_file_tree{
	height:120px;
	width:367px;
	margin-top:7px;
	margin-left:11px;
	overflow:auto;
}

.patch_file_tree_add{
	float:right;
	width:61px;
	color:#1c4688;
	font-size:8pt;
	font-weight:bold;
    font-family:NanumGothic, sans-serif;
    cursor:pointer;
}

.patch_file_tree_remove{
	float:right;
	width:53px;
	color:#d22929;
	font-size:8pt;
	font-weight:bold;
    font-family:NanumGothic, sans-serif;
    cursor:pointer;
}

.patch_file_tree_add:hover{
	color:#1c6386;
}

.patch_file_tree_remove:hover{
	color:#d66969;
}

.popup_background{
	width: 699px;
    margin-left: -16px;
    margin-top: -59px;
    height: 473px;
    background-color: rgba(0,0,0,0.4);
    position: absolute;
    display:none;
}

.popup_background_all{
	margin-top: 145px;
    margin-left: 155px;
}

.popup_background_title_bar{
	width:400px;
	height:18px;
	background-image: linear-gradient(#656565,#0a0a0a);
	border-top-left-radius: 5px;
    border-top-right-radius: 5px;
    color:white;
    font-size:8pt;
    font-weight:bold;
    font-family:NanumGothic, sans-serif;
}

.popup_background_frame{
	width:400px;
	background-color:#efefef;
	border-bottom-right-radius: 5px;
    border-bottom-left-radius: 5px;
    font-weight:bold;
    font-family:NanumGothic, sans-serif;
}
#patch_process_lib_file_name{
	text-align:center;
	width:400px;
	height:17px;
}

#popup_input_table_div{
	padding-top:11px;
	margin-left:23px;
	display:none;
}

.popup_input_table th{
	font-size:9pt;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

.popup_input_table td{
	font-size:10pt;
	font-weight:bold;
	font-family:NanumGothic, sans-serif;
}

.patch_file_tree ul{
	margin-top:3px;
}

.radio_btn{
	float:left;
}

.radio_label{
	float:left;
	width: 100px;
	font-size: 8pt;
	font-family:NanumGothic, sans-serif;
    margin-top: 2px;
    margin-left: 5px;
}

#patch_file_info_area{
    float:left;
    width:235px;
    font-size:11pt;
    font-weight:bold;
    font-family:NanumGothic, sans-serif;
    text-align:center;
}

#patch_file_info_message{
	font-size:10pt;
	text-align:center;
	margin-top:153px;
	margin-left:20px;
}

#patch_file_info{
	display:none;
	margin-top:10px;
}

#patch_file_info_table{
	margin-top:15px;
	margin-left:15px;
	min-width:225px;
}

#patch_file_info_table th{
	height:40px;
	width:60px;
	max-width:60px;
	min-width:60px;
	border: 1px solid;
	border-color: #b5b5b5;
	font-size:9pt;
	font-weight:bold;
    font-family:NanumGothic, sans-serif;
}

#patch_file_info_table td{
	height:40px;
	min-width:165px;
	border: 1px solid;
	border-color: #b5b5b5;
	background-color:#d2d2d2;
	font-size:9pt;
	font-weight:bold;
    font-family:NanumGothic, sans-serif;
    word-break:break-all;
}

/* ============= File Tree CSS ============= */

.tree_plus{
	float:left;
	width:10px;
	height:10px;
	background-size:10px;
	background-image:url(<c:url value="/resources/images/patch/tree/tree_plus_icon.png" />);
	cursor:pointer;
}

.tree_minus{
	float:left;
	width:10px;
	height:10px;
	background-size:10px;
	background-image:url(<c:url value="/resources/images/patch/tree/tree_minus_icon.png" />);
	cursor:pointer;
}

.tree_folder{
	float:left;
	width:16px;
	height:13.8px;
	margin-top:-2px;
    margin-left:5px;
	background-size:16px;
	background-image:url(<c:url value="/resources/images/patch/tree/folder_icon.png" />);
}

.tree_folder.open{
	float:left;
	width:16px;
	height:12.8px;
	margin-top:-2px;
    margin-left:5px;
	background-size:16px;
	background-image:url(<c:url value="/resources/images/patch/tree/folder_icon_open.png" />);
}

.tree_file{
	float:left;
	width:12px;
	height:16.2px;
	margin-top:-4px;
    margin-left:5px;
	background-size:12px;
}

.tree_name{
	float:left;
	margin-top:-4px;
	margin-left:7px;
	font-size:9pt;
	font-weight:bold;
    font-family:NanumGothic, sans-serif;
    cursor:pointer;
}

.tree_ul{
	margin-left:16px;
}

.tree_li{
	margin-top:5px;
}

/* ============= **** ============= */

#query_head_area{
	height:24px;
}

.query_head_first{
	float:left;
	width:80px;
	height:25px;
	font-family:Verdana, sans-serif;
	font-size:9pt;
	border-radius:12px;
	font-weight:100;
	background-color:#565656;
	color:white;
	text-align:center;
	margin-left:21.5px;
	cursor:pointer;
}

.query_head{
	float:left;
	width:80px;
	height:25px;
	font-family:Verdana, sans-serif;
	font-size:9pt;
	border-radius:12px;
	font-weight:100;
	background-color:#565656;
	color:white;
	text-align:center;
	margin-left:25px;
	cursor:pointer;
}

.query_head_label{
	padding-top:4px;
}

.query_head:hover{
	background-color:#848484;
}

.query_element{
	float:left;
	width:80px;
	height:25px;
	font-family:Verdana, sans-serif;
	font-size:8pt;
	font-weight:100;
	border-radius:12px;
	background-color:#13597f;
	color:white;
	text-align:center;
	margin-left:15px;
	cursor:pointer;
}

#query_generator_area{
	width:621px;
	height:208px;
	margin-left:14px;
	margin-top:2px;
	border-radius: 10px;
    position:relative;
    z-index:200;
}

#query_head_selector{
	width: 100px;
    height: 40px;
    background-color: #b3b3b3;
    position: absolute;
    z-index: 100;
    border-radius: 10px;
    margin-left: 11px;
    margin-top: 7px;
    display:none;
}
#query_empty_text{
    padding-left: 216px;
    padding-top: 108px;
    font-size: 13pt;
}

#query_target_text{
	width: 300px;
    font-size: 11pt;
    margin-top: 95px;
    margin-left: 226px;
}

.query_generating_text{
	width: 500px;
    font-size: 14pt;
    margin-top: 97px;
    margin-left: 133px;
}

.query_text_input{
	float:left;
	width:160px;
	height:28px;
	font-size: 12pt;
	margin-left:10px;
	margin-top:-6px;
	background-color:transparent;
	border:1px solid;
}

.query_place_holder{
	float:left;
	font-size: 14pt;
	margin-left:10px;
}

.query_textarea{
	float: left;
    margin-top: -58px;
    border: 1px solid;
    width: 200px;
    height: 130px;
    font-size:11pt;
	background-color:transparent;
	resize: none;
	overflow:auto;
}

.query_info_message{
    position: absolute;
    font-size: 8pt;
    color: #182482;
    font-weight: bold;
}

#sql_reg_icon{
	height:30px;
	width:81px;
	margin-left: 294px;
    margin-top: 152px;
	background-image:url(<c:url value="/resources/images/patch/sql_reg_icon.png"/>);
	background-size: 86px;
	cursor:pointer;
}

#sql_reg_icon:hover{
	background-image:url(<c:url value="/resources/images/patch/sql_reg_icon_over.png"/>);
}

#sql_reg_table_area{
	height:295px;
	overflow:auto;
}

.sql_query_remove_icon{
	float:left;
	width:15px;
	height:15px;
	margin-top:2px;
	background-size:15px;
	background-image:url(<c:url value="/resources/images/patch/sql_query_remove_icon.png"/>);
	cursor:pointer;
}

.sql_query_remove_icon:hover{
	background-image:url(<c:url value="/resources/images/patch/sql_query_remove_icon_over.png"/>);
}

#patch_file_cont{
	width:627px;
	height:165px;
	margin-top:23px;
	margin-left:20px;
	border: 1px solid;
    font-size:11pt;
	background-color:transparent;
	resize: none;
}

#generate_icon{
    width: 50px;
    height: 57px;
    margin-top: 43px;
    margin-left: 312px;
    background-size: 60px;
	background-image:url(<c:url value="/resources/images/patch/generate_icon_over.png"/>);
}

#generate_icon:hover{
	background-image:url(<c:url value="/resources/images/patch/generate_icon_over.png"/>);
}

#patch_file_name_warning{
	position:absolute;
	top: 183px;
    left: 272px;
    color: red;
    font-weight: bold;
    display:none;
}

</style>
<div class="section-content">
	<form name="patchFileForm" id="patchFileForm" style="overflow:hidden;">
		<input type="hidden" name="slKey" value="${_slKey}">
		<input type="hidden" name="file_upload_path" value="${file_upload_path}">
		<input type="hidden" name="n_query" value="">
		<div id="patch_step_all">
			<div class="patch_step_area">
				<div class="patch_step_title">
					<span>패치파일 이름</span>
					<img style="width:30px;height:30px;"src="<c:url value="/resources/images/patch/file_name_icon.png" />"/>
				</div>
				<div id="patch_file_name_warning">이미 존재하는 패치파일이름 입니다.</div>
				<div style="margin-top:150px;margin-left:160px;">
					<table>
						<tr>
							<th style="width:67px;font-weight:bold;"><span>이름설정</span></th>
							<td><input onInput='javascript:patchFileNameDupChk()' type="text" name="patch_file_name" style="width:260px;" class="form-input" maxlength="40" data-valid="패치파일 이름,required"></td>
						</tr>
					</table>
				</div>
				<div style="margin-top:20px;margin-left:227px;">
					<span>- 파일 이름의 길이는 3 ~ 40자까지 가능합니다.<br>- 영문, 숫자, '_'(밑줄)만 입력 가능합니다.</span>
				</div>
			</div>
			
			<div class="patch_step_area">
				<div class="patch_step_title">
					<span>패치 프로세스 선택</span>
					<img style="width:30px;height:30px;"src="<c:url value="/resources/images/patch/proc_select_icon.png" />"/>
				</div>
				<div id="patch_process_list"></div>
				<div style="text-align:center;font-family:NanumGothic, sans-serif;font-weight:bold;">패치할 프로세스를 선택하세요.</div>
			</div>
			
			<div class="patch_step_area">
				<div class="patch_step_title">
					<span>패치 파일 등록</span>
					<img style="width:30px;height:30px;"src="<c:url value="/resources/images/patch/reg_file_icon.png" />"/>
				</div>
				<div class="popup_background" id="popup_background_folder">
					<div class="popup_background_all">
						<div class="popup_background_title_bar"><div style="margin-left:7px;padding-top:1px;">폴더 이름 설정</div></div>
						<div class="popup_background_frame" style="height:100px;">
							<div style="padding-top:25px;margin-left:26px;">
								<table>
									<tr>
										<th style="width:73px;font-size:9pt;font-weight:bold;font-family:NanumGothic, sans-serif;">폴더 이름</th>
										<td><input type="text" name="folder_name" style="width:250px;" class="form-input" maxlength="20" onKeyDown="if(event.keyCode==13) { popupFolderCreate(); }"></td>
									</tr>
								</table>
							</div>
							<div class="table-bottom">
								<button type="button" class="btn-basic" onclick="javascript:popupFolderCreate()">생성</button>
								<button type="button" class="btn-basic" onclick="javascript:popupClose()">닫기</button>
							</div>
						</div>
					</div>
				</div>
				<div class="popup_background" id="popup_background_lib">
					<div class="popup_background_all" id="popup_background_all_lib" style="margin-top:48px;">
						<div class="popup_background_title_bar"><div style="margin-left:7px;padding-top:1px;">라이브러리 설정</div></div>
						<div class="popup_background_frame" id="popup_background_frame_lib" style="height:328px;">
							<div style="padding-top:14px;margin-left:14px;width:100%;height:18px;">
								<input type="radio" name="lib_patch_type" class="radio_btn" value="0"><div class="radio_label">신규 / 덮어쓰기</div>
								<input type="radio" name="lib_patch_type" class="radio_btn" value="1"><div class="radio_label">변경</div>
							</div>
							<br>
							<div id="patch_process_lib_file_name"></div>
							<div id="patch_process_list_popup"></div>
							<div style="text-align:center;font-size:9pt;margin-top:6px;margin-bottom:5px;">라이브러리를 적용할 프로세스를 선택하세요.</div>
							<div id="popup_input_table_div">
								<table class="popup_input_table">
									<tr>
										<th style="width:107px;">변경할<br>라이브러리 이름</th>
										<td><input type="text" name="old_lib_name" style="width:200px;" class="form-input" maxlength="20" onKeyDown="if(event.keyCode==13) { popupFolderCreate(); }">&nbsp;.jar</td>
									</tr>
								</table>
							</div>
							<div class="table-bottom" style="margin-top:9px">
								<button type="button" class="btn-basic" id="btn_lib_regedit">저장</button>
								<button type="button" class="btn-basic" id="btn_lib_close">닫기</button>
							</div>
						</div>
					</div>
				</div>
				<div id="patch_file_reg">
				</div>
				<div id="patch_file_info_area">
					<div id="patch_file_info_message">등록할 파일을 폴더에<br>끌어다 놓으세요.(파일만 등록)</div>
					<div id="patch_file_info">
						<div style="text-align:center;margin-left:18px;">
							<img style="width:28px;height:28px;" src="<c:url value="/resources/images/patch/file_icon.png" />"/>
							<div id="patch_file_name" style="margin-top:8px;"></div>
						</div>
						
						<table id="patch_file_info_table">
							<tr>
								<th>타입</th>
								<td id="patch_file_info_type"></td>
							</tr>
							<tr>
								<th>크기</th>
								<td id="patch_file_info_size"></td>
							</tr>
							<tr>
								<th>MD5</th>
								<td id="patch_file_info_md5"></td>
							</tr>
							<tr>
								<th>수정날짜</th>
								<td id="patch_file_info_ldate"></td>
							</tr>
							<tr class="patch_file_info_lib_tr">
								<th>패치타입</th>
								<td id="patch_file_info_ptype"></td>
							</tr>
							<tr class="patch_file_info_lib_tr">
								<th>패치대상</th>
								<td id="patch_file_info_ptarget"></td>
							</tr>
						</table>
					</div>
				</div>
			</div>
			<div class="patch_step_area">
				<div class="patch_step_title">
					<span>SQL 패치 등록</span>
					<img style="width:26px;height:30px;"src="<c:url value="/resources/images/patch/sql_icon.png" />"/>
				</div>
				<div class="popup_background" id="popup_background_sql">
					<div class="popup_background_all" id="popup_background_all_sql" style="margin-top:48px;margin-left:28px;">
						<div class="popup_background_title_bar" style="width:651px;"><div style="margin-left:7px;padding-top:1px;">SQL 생성</div></div>
						<div class="popup_background_frame" id="popup_background_frame_sql" style="height:325px;width:650px;">
							<div id="query_head_selector"></div>
							<div style="position: relative;padding-top:15px;z-index:200;">
								<div id="query_head_area">
									<div class="query_head_first" id="query_head_create"><div class="query_head_label">CREATE</div></div>
									<div class="query_head" id="query_head_insert"><div class="query_head_label">INSERT</div></div>
									<div class="query_head" id="query_head_update"><div class="query_head_label">UPDATE</div></div>
									<div class="query_head" id="query_head_alter"><div class="query_head_label">ALTER</div></div>
									<div class="query_head" id="query_head_drop"><div class="query_head_label">DROP</div></div>
									<div class="query_head" id="query_head_delimiter"><div class="query_head_label">DELIMITER</div></div>
								</div>
								<div style="width:620px;height:2px;background-color:black;margin-top:10px;margin-left:14px;"></div>
							</div>
							<div id="query_generator_area"></div>
							<div class="table-bottom" style="padding-top:20px;">
								<button type="button" class="btn-basic" id="btn_sql_registration">등록</button>
								<button type="button" class="btn-basic" id="btn_sql_close">닫기</button>
							</div>
						</div>
					</div>
				</div>
				<div id="patch_sql_area">
					<div id="sql_reg_icon"></div>
					<div id="sql_reg_table_area"></div>
				</div>
			</div>
			<div class="patch_step_area">
				<div class="patch_step_title">
					<span>패치 내용 등록</span>
					<img style="width:26px;height:30px;"src="<c:url value="/resources/images/patch/patch_content_icon.png" />"/>
				</div>
				<div>
					<div style="text-align:center;margin-left:-16px;font-size:11pt;font-weight:bold;margin-top:30px;font-family:NanumGothic, sans-serif;">패치 내용을 입력하세요.</div>
					<textarea name='patch_file_cont' id='patch_file_cont' onInput='javascript:patchContInputEvent()'></textarea>
					<div id='generate_icon' onclick='javascript:generatePatchFile()'></div>
				</div>
			</div>
		</div>
		
		<div id="patch_step_btn_area">
			<div id="patch_step_move_left" onclick="javascript:goBack()"></div>
			<div id="patch_step_move_right" onclick="javascript:goNext()"></div>
		</div>
	</form>
</div>
