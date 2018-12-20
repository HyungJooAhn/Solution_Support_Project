if(window.console == undefined) { 	console = {log:function(){} }; }

(function ($) {
	var procList = new Map(), $selectNode, fileUploadPath = $("[name=file_upload_path]").val();
	event = {
			select: function(name, folderName, depth){
				$("#tree_name_" + name + "_" + folderName + "_" + depth).on("click", function(){
					$("#patch_file_info").hide();
					$("#patch_file_info_message").css("display", "block");
					$("#patch_file_info_message").hide();
					$("#patch_file_info_message").fadeIn();
		    		$selectNode = $(this);
		    		if($selectNode.hasClass("selected")){
		    			$selectNode.removeClass("selected");
		        		$selectNode.css("border", "");
		        		$selectNode.css("border-color", "white");        			
		        		$selectNode.css("background-color", "white");     
		    		}else{
		    			var $preSelected = $($("#tree_li_" + name + "_" + name + "_0").find(".selected")[0]);
		    			$preSelected.removeClass("selected");
		    			$preSelected.css("border", "");
		    			$preSelected.css("border-color", "white");        			
		    			$preSelected.css("background-color", "white");     
		        		
		    			$selectNode.addClass("selected");
		        		$selectNode.css("border", "solid 1px");        			
		        		$selectNode.css("border-color", "#ffc000");        			
		        		$selectNode.css("background-color", "rgba(226, 255, 51, 0.5)");
		    		}
		    	});
		    },
		    select_file: function(name, folderName, depth, file, filePath){
				$("#tree_name_" + name + "_" + folderName + "_" + depth).on("click", function(){
		    		$selectNode = $(this);
		    		if($selectNode.hasClass("selected")){
		    			$("#patch_file_info").hide();
						$("#patch_file_info_message").css("display", "block");
						$("#patch_file_info_message").hide();
						$("#patch_file_info_message").fadeIn();
		    			$selectNode.removeClass("selected");
		        		$selectNode.css("border", "");
		        		$selectNode.css("border-color", "white");        			
		        		$selectNode.css("background-color", "white");     
		    		}else{
		    			$("#patch_file_info_message").hide();
						$("#patch_file_info").css("display", "block");
						$("#patch_file_info").hide();
						$("#patch_file_info").fadeIn();
		    			var $preSelected = $($("#tree_li_" + name + "_" + name + "_0").find(".selected")[0]);
		    			$preSelected.removeClass("selected");
		    			$preSelected.css("border", "");
		    			$preSelected.css("border-color", "white");        			
		    			$preSelected.css("background-color", "white");     
		        		
		    			$selectNode.addClass("selected");
		        		$selectNode.css("border", "solid 1px");        			
		        		$selectNode.css("border-color", "#ffc000");        			
		        		$selectNode.css("background-color", "rgba(226, 255, 51, 0.5)");
		    		}
		    		
					$.ajax({
						type : "POST",
						url : "/download/patch_file_md5.do",
						contentType : "application/json",
						data : JSON.stringify({upload_path:filePath}),
						dataType : "json",
						async : false,
						success : function(rsJson) {
							var md5 = rsJson.data;
							
							$("#patch_file_name").text(file.name);
							$("#patch_file_info_type").text(file.type);
							
							var fileSize = Number(file.size);
							if(fileSize > 1024 * 1024){
								fileSize = fileSize / (1024 * 1024);
								fileSize = fileSize.toFixed(2) + " MB (" + file.size + " bytes)";
							}else if(fileSize > 1024){
								fileSize = fileSize / 1024;
								fileSize = fileSize.toFixed(2) + " KB (" + file.size + " bytes)";
							}else{
								fileSize = fileSize + " bytes";
							}
							var date = new Date(file.lastModifiedDate);
							$("#patch_file_info_size").text(fileSize);
							$("#patch_file_info_md5").text(md5);
							$("#patch_file_info_ldate").text(date.getFullYear() + "-" + dateToString((date.getMonth() + 1)) + "-" + dateToString(date.getDate()) + " " 
									+ dateToString(date.getHours()) + ":" + dateToString(date.getMinutes()) + ":" + dateToString(date.getSeconds()));
							
							if($($("#tree_ul_" + name + "_" + folderName + "_" + depth).parent()[0]).attr("id") == "tree_li_lib_lib_0"){
								if(file.name.substring(file.name.lastIndexOf(".") + 1) == "jar"){
									$(".patch_file_info_lib_tr").show();
									var libPatchProcInfo = libPatchMap[file.name];
									var libPatchKey = Object.keys(libPatchProcInfo)[0];
									
									if(libPatchKey.indexOf(":") > -1){
										$("#patch_file_info_ptype").text("변경 " + libPatchKey.substring(0, libPatchKey.indexOf(":")) + " -> " + libPatchKey.substring(libPatchKey.indexOf(":") + 1))
									}else{
										$("#patch_file_info_ptype").text("신규")
									}
									var patchTarget = "";
									for(var i=0; i<libPatchProcInfo[libPatchKey].length; i++){
										if(i == libPatchProcInfo[libPatchKey].length - 1){
											patchTarget += libPatchProcInfo[libPatchKey][i]
										}else{
											patchTarget += libPatchProcInfo[libPatchKey][i] + ", ";											
										}
									}
									$("#patch_file_info_ptarget").text(patchTarget);
								}else{
									$(".patch_file_info_lib_tr").hide();
								}
							}else{
								$(".patch_file_info_lib_tr").hide();
							}
						}
					});
					
		    	});
		    }
	/*,
		    plus: function(name, depth){
		    	$("#tree_plus_" + name + "_" + depth).on("click", function(){
		    		var ulList = $("#tree_ul_" + name + "_0").find("ul");
		    		for(var i=0; i<ulList.length; i++){
		    			var ulID = ulList[i]["id"];
		    			var ulDepth = ulID.substring(ulID.length-1);
		    			if(Number(depth) < Number(ulDepth)){
		    				if(Number(ulDepth) - Number(depth) == 1){
		    					$(ulList[i]).css("display", "block");
		    				}else if($($(ulList[i])).hasClass("open")){
		    						$(ulList[i]).css("display", "block");
		    					}
		    				//if($($(ulList[i]).find("div")[0]).hasClass("tree_minus")){
		    						
		    				//}
		    				$(ulList[i]).animate({
		    					"height":"14px"
		    				},{step:function _completeCallback(){
		    					
		    				}});
		    			}
		    		}
		    		$("#tree_ul_" + name + "_" + depth).addClass("open");
			    	$("#tree_plus_" + name + "_" + depth).remove();
	        		$("#tree_li_" + name + "_" + depth).prepend("<div class='tree_minus' id='tree_minus_" + name + "_" + depth + "'></div>");
	        		event.minus(name, depth);
		    	});
		    },
		    minus: function(name, depth){
		    	$("#tree_minus_" + name + "_" + depth).on("click", function(){
		    		var ulList = $("#tree_ul_" + name + "_0").find("ul");
		    		for(var i=0; i<ulList.length; i++){
		    			var ulID = ulList[i]["id"];
		    			var ulDepth = ulID.substring(ulID.length-1);
		    			if(Number(depth) < Number(ulDepth)){
		    				$(ulList[i]).css("display", "none");
		    				//$(ulList[i]).removeClass("open");
		    				$(ulList[i]).animate({
		    					"height":"0px"
		    				},{step:function _completeCallback(){
		    					//$(this).css("overflow", "hidden");
		    					
		    				}});
		    			}
		    		}
		    		$("#tree_ul_" + name + "_" + depth).removeClass("open");
			    	$("#tree_minus_" + name + "_" + depth).remove();
	        		$("#tree_li_" + name + "_" + depth).prepend("<div class='tree_plus' id='tree_plus_" + name + "_" + depth + "'></div>");
	        		event.plus(name, depth);
		    	});
		    }*/
	}
    	
    $.fn.fileTree = {
        init: function(obj, name) {
        	var depth = 0;
        	$(obj).append("<ul id='tree_ul_" + name + "_" + name + "_0'><li class='tree_li' id='tree_li_" + name + "_" + name + "_0'>"
        			+ "<div class='tree_folder' id='tree_folder_" + name + "_" + name + "_0'></div>"
        			+ "<div class='tree_name folder' id='tree_name_" + name + "_" + name + "_0'>" + name + "</div></li></ul>");
        	
        	event.select(name, name, depth);
        	DragAndDropEvent($("#tree_name_" + name + "_" + name + "_" + depth))

        	var rootFolderPath = rebuildUploadPath(fileUploadPath, name);
        	makeFolder(rootFolderPath);
        	$(".patch_file_info_lib_tr").hide();
        },
        add: function(obj, name, newFolderName, selectedFolder){
        	var objID = obj[0]["id"];
        	var selectedDepth = Number(objID.substring(objID.length-1));
        	var newCreateDepth = Number(objID.substring(objID.length-1)) + 1;
        	var newFolderPath = rebuildUploadPath(fileUploadPath, name);
        	
    		$("#tree_li_" + name + "_" + selectedFolder + "_" + selectedDepth).append("<ul class='tree_ul' id='tree_ul_" + name + "_" + newFolderName + "_" + newCreateDepth + "'><br><li class='tree_li' id='tree_li_" + name + "_" + newFolderName + "_" + newCreateDepth + "'>"
        			+ "<div class='tree_folder' id='tree_folder_" + name + "_" + newFolderName + "_" + newCreateDepth + "'></div>"
        			+ "<div class='tree_name folder' id='tree_name_" + name + "_" + newFolderName + "_" + newCreateDepth + "'>" + newFolderName + "</div></li></ul>");
        	
        	$("#tree_folder_" + name + "_" + selectedFolder + "_" + selectedDepth).addClass("open");
        	event.select(name, newFolderName, newCreateDepth);
        	$("#tree_ul_" + name + "_" + newFolderName + "_" + newCreateDepth).hide();
        	$("#tree_ul_" + name + "_" + newFolderName + "_" + newCreateDepth).fadeIn();
        	
        	var startDepth = newCreateDepth;
        	var traceUl = $("#tree_ul_" + name + "_" + newFolderName + "_" + newCreateDepth);
        	var traceFolderName = newFolderName;
        	var traceFolderNameList = [];
        	newFolderPath = traceParentPath(newFolderPath, name, startDepth, traceUl, traceFolderName, false);
        	
        	makeFolder(newFolderPath);
        	DragAndDropEvent($("#tree_name_" + name + "_" + newFolderName + "_" + newCreateDepth))
        },
        remove: function(name, folderName, depth, fileName){
        	var startDepth = depth;
        	var traceUl = $("#tree_ul_" + name + "_" + folderName + "_" + depth);
        	var traceFolderName = folderName;
        	var deletePath = rebuildUploadPath(fileUploadPath, name);
        	if(fileName != null){
        		deletePath = traceParentPath(deletePath, name, startDepth, traceUl, traceFolderName, true) + "/" + fileName;	
        	}else{
        		deletePath = traceParentPath(deletePath, name, startDepth, traceUl, traceFolderName, false);
        	}
        	removeFolder(deletePath);
        	
        	var deleteParent = $("#tree_ul_" + name + "_" + folderName + "_" + depth).parent()[0];

        	if($(deleteParent).attr("id") == "tree_li_lib_lib_0"){
        		if(fileName.indexOf(".") > -1){
        			var fileExt = fileName.substring(fileName.lastIndexOf(".") + 1);
        			if(fileExt == "jar"){
        				delete libPatchMap[fileName];
        			}
        		}
        	}
        	$("#tree_ul_" + name + "_" + folderName + "_" + depth).remove();
        	var deleteParentUlList = $(deleteParent).find("ul");
        	if(deleteParentUlList.length == 0){
        		$($(deleteParent).find(".tree_folder")[0]).removeClass("open");
        	}
        }
    };
})(jQuery);


function DragAndDropEvent(obj){
	
    obj.on('dragenter', function (e) {
         e.stopPropagation();
         e.preventDefault();
         $(this).css("background-color", "#ffc733");
         $(this).css("border", "solid 1px");        			
         $(this).css("border-color", "#ffc000");  
         
         return false;
    });

    obj.on('dragleave', function (e) {
         e.stopPropagation();
         e.preventDefault();
         if($(this).hasClass("selected")){
        	 $(this).css("background-color", "rgba(226, 255, 51, 0.5)");
             $(this).css("border", "solid 1px");        			
             $(this).css("border-color", "#ffc000");  
         }else{
        	 $(this).css("background-color", "white"); 
        	 $(this).css("border", "");
        	 $(this).css("border-color", "white");        			
         }
         return false;
    });

    obj.on('dragover', function (e) {
         e.stopPropagation();
         e.preventDefault();
         return false;
    });

    obj.on('drop', function (e) {
        e.preventDefault();
         //$(this).css('border', '2px dotted #8296C2');
		if($(this).hasClass("selected")){
			$(this).css("background-color", "rgba(226, 255, 51, 0.5)");
			$(this).css("border", "solid 1px");        			
			$(this).css("border-color", "#ffc000");  
		}else{
			$(this).css("background-color", "white"); 
			$(this).css("border", "");
			$(this).css("border-color", "white");        			
		}
		 
		var files = e.originalEvent.dataTransfer.files;
		if(files.length < 1)
			return;
		
		if(obj.attr("id") == "tree_name_lib_lib_0"){
			var jarLibCnt = 0;
			var jarIdx = 0;
			for(var i=0; i<files.length; i++){
				var extIdx = files[i].name.lastIndexOf(".");
				var fileExt = files[i].name.substring(extIdx + 1);			
				if(fileExt == "jar"){
					jarLibCnt ++;
					jarIdx = i;
				}
			}
			if(jarLibCnt > 1){
				_alert("Lib 패치 라이브러리는<br>하나씩 등록하세요.");
			}else if(jarLibCnt == 1){
				
				$("#popup_background_lib").css("display", "block");
				$("#patch_process_lib_file_name").text(files[jarIdx].name);
				
				$("#btn_lib_regedit").unbind("click");
				$("#btn_lib_regedit").on("click", function(){
					
					var selectedProcList = $("#patch_process_list_popup").find(".selected");
					for(var i=0; i<selectedProcList.length; i++){
						$(selectedProcList[i]).removeClass("selected");
						$(selectedProcList[i]).css("box-shadow", "");
						$(selectedProcList[i]).find(".patch_process_icon_popup").css("background-image", "url(/resources/images/patch/process_icon.png)");
						$(selectedProcList[i]).find(".patch_process_name_popup").css("color", "#adadad");
					}
					
					var patchTypeVal = $("input:radio[name=lib_patch_type]:checked").val();
					
					if(procLibList.length == 0){
						_alert("라이브러리 패치를<br>적용할 프로세스를 선택하세요.")
					}else{
						var libPatchKey = files[jarIdx].name;
						var oldLibName = $("[name=old_lib_name]").val();
						
						if(patchTypeVal == 0){
							$("#popup_background_lib").css("display", "none");
							D_FileMultiUpload(files, obj, libPatchKey);								
						}else{
							if(oldLibName == ""){
								_alert("변경할 라이브러리 이름을 입력하세요.")
							}else{
								$("#popup_background_lib").css("display", "none");
								libPatchKey = oldLibName + ":" + libPatchKey;
								D_FileMultiUpload(files, obj, libPatchKey);									
							}
						}
						resetLibPopup();			
					}
				});
				
				$("#btn_lib_close").unbind("click");
				$("#btn_lib_close").on("click", function(){
					$("#popup_background_lib").css("display", "none");	
					
					var selectedProcList = $("#patch_process_list_popup").find(".selected");
					for(var i=0; i<selectedProcList.length; i++){
						$(selectedProcList[i]).removeClass("selected");
						$(selectedProcList[i]).css("box-shadow", "");
						$(selectedProcList[i]).find(".patch_process_icon_popup").css("background-image", "url(/resources/images/patch/process_icon.png)");
						$(selectedProcList[i]).find(".patch_process_name_popup").css("color", "#adadad");
					}
					procLibList = [];
					resetLibPopup();
				});
			}else{
				D_FileMultiUpload(files, obj, "");
			}
		}else{
			D_FileMultiUpload(files, obj, "");
		}
	});
}

var fileIdx = 0;
var libPatchMap = {};
function D_FileMultiUpload(files, obj, libPatchKey) {
	
	var formData = new FormData();
	var dupFormData = new FormData();
	
	var objID = obj.attr("id");
	var selectedDepth = Number(objID.substring(objID.length-1));
	var selectedFolderName = obj[0].outerText;
	var namespace = objID.substring(0, objID.length-2).replace("tree_name_", "").split("_")[0];
	var newCreateDepth = Number(objID.substring(objID.length-1)) + 1;

	var newFileChk = false;
	var dupFileNameChk = false;
	var dupFileUlID = "";
	
	for(var i=0; i<files.length; i++){
		var newFilePath = rebuildUploadPath($("[name=file_upload_path]").val(), namespace);
		var dupFileNameChk = false;
		var selectedChildUls = $("#tree_ul_" + namespace + "_" + selectedFolderName + "_" + selectedDepth).find("ul");
		var selectedChildNames = $($("#tree_ul_" + namespace + "_" + selectedFolderName + "_" + selectedDepth)[0]).find(".tree_name");
		for(var k=0; k<selectedChildUls.length; k++){
			var childUlID = $(selectedChildUls[k]).attr("id");
			var childDepth = Number(childUlID.substring(childUlID.length-1));
			var childFileName = selectedChildNames[k + 1].outerText;
			if((selectedDepth + 1) == childDepth){
				if(files[i].name == childFileName){
					dupFileNameChk = true;
					dupFileUlID = childUlID.substring(0, childUlID.length-2).replace("tree_ul_" + namespace + "_", "");
				}
			}
		}
		
		if(dupFileNameChk){
			if(libPatchKey != ""){
				$("#popup_background_lib").css("display", "none");
			}
			var startDepth = newCreateDepth;
	    	var traceUl = $("#tree_ul_" + namespace + "_" + dupFileUlID + "_" + newCreateDepth);
	    	var traceFileName = dupFileUlID;
	    	var dupFilePath = rebuildUploadPath($("[name=file_upload_path]").val(), namespace);
	    	dupFilePath = traceParentPath(dupFilePath, namespace, startDepth, traceUl, traceFileName, true) + "/" + files[i].name;
	    	dupFormData.append('drop_file_upload_files', files[i]);
	    	dupFormData.append('drop_file_upload_pathes', dupFilePath);
		}else{
			formData.append('drop_file_upload_files', files[i]);
			$("#tree_li_" + namespace + "_" + selectedFolderName + "_" + selectedDepth).append("<ul class='tree_ul' id='tree_ul_" + namespace + "_" + selectedFolderName + "_" + fileIdx + "_" + newCreateDepth + "'><br><li class='tree_li' id='tree_li_" + namespace + "_" + selectedFolderName + "_" + fileIdx + "_" + newCreateDepth + "'>"
					+ "<div class='tree_file' id='tree_file_" + namespace + "_" + selectedFolderName + "_" + fileIdx + "_" + newCreateDepth + "'></div>"
					+ "<div class='tree_name' id='tree_name_" + namespace + "_" + selectedFolderName + "_" + fileIdx + "_" + newCreateDepth + "'>" + files[i].name + "</div></li></ul>");
					
			mappingIconImage(files[i].name, $("#tree_file_" + namespace + "_" + selectedFolderName + "_" + fileIdx + "_" + newCreateDepth), $("#tree_ul_" + namespace + "_" + selectedFolderName + "_" + fileIdx + "_" + newCreateDepth));
			
			$("#tree_folder_" + namespace + "_" + selectedFolderName + "_" + selectedDepth).addClass("open");
	    	$("#tree_ul_" + namespace + "_" + selectedFolderName + "_" + fileIdx + "_" + newCreateDepth).hide();
	    	$("#tree_ul_" + namespace + "_" + selectedFolderName + "_" + fileIdx + "_" + newCreateDepth).fadeIn();
	    	
	    	var startDepth = newCreateDepth;
	    	var traceUl = $("#tree_ul_" + namespace + "_" + selectedFolderName + "_" + fileIdx + "_" + newCreateDepth);
	    	var traceFileName = selectedFolderName + "_" + fileIdx;
	    	newFilePath = traceParentPath(newFilePath, namespace, startDepth, traceUl, traceFileName, true) + "/" + files[i].name;

	    	event.select_file(namespace, selectedFolderName + "_" + fileIdx, newCreateDepth, files[i], newFilePath);
	    	formData.append('drop_file_upload_pathes', newFilePath);
	    	fileIdx ++;
	    	newFileChk = true
		}
	}

	if(newFileChk){
		if(libPatchKey != ""){
			var libPatchProcName = libPatchKey;
			if(libPatchKey.indexOf(":") > -1){
				libPatchProcName = libPatchKey.substring(libPatchKey.indexOf(":") + 1);
			}
			var infoMap = {};
			infoMap[libPatchKey] = procLibList;
			
			libPatchMap[libPatchProcName] = infoMap;
			procLibList = [];			
		}
		$.ajax({
		    url: "/download/patch_file_upload.do",
		    type: 'POST',
		    data: formData,
			enctype:'multipart/form-data',
			dataType: 'json',
			processData: false,
			contentType: false,
			success: function(res) {
				var result = res.data;
				if(!result){
					_alert("파일 업로드 중 오류가 발생하였습니다.")
				}
			}
		});
	}
	
	if(dupFileNameChk){
		_confirm("추가 항목 중 중복되는 파일(들)이 존재합니다.<br>덮어쓰시겠습니까?", {
			onAgree : function() {
				if(libPatchKey != ""){
					var libPatchProcName = libPatchKey;
					if(libPatchKey.indexOf(":") > -1){
						libPatchProcName = libPatchKey.substring(libPatchKey.indexOf(":") + 1);
					}
					var infoMap = {};
					infoMap[libPatchKey] = procLibList;
					
					libPatchMap[libPatchProcName] = infoMap;
					procLibList = [];
				}		
				
		    	$.ajax({
				    url: "/download/patch_file_upload.do",
				    type: 'POST',
				    data: dupFormData,
					enctype:'multipart/form-data',
					dataType: 'json',
					processData: false,
					contentType: false,
					success: function(res) {
						var result = res.data;
						if(!result){
							_alert("파일을 덮어쓰는 중 오류가 발생하였습니다.")
						}
					}
				});
			}
		});	
	}
}

function rebuildUploadPath(uploadPath, namespace){
	var path = uploadPath;
	if(namespace == "shovel"){
		path = path + "/shovel_server";
	}else{
		path = path + "/" + namespace;
	}
	return path;
}
function traceParentPath(uploadPath, namespace, startDepth, traceUl, traceName, isFile){
	var _startDepth = startDepth;
	var _traceUl = traceUl;
	var _traceName = traceName;
	var _traceFolderNameList = [];
	for(var i=0; i<startDepth; i++){
		_traceUl = $("#tree_ul_" + namespace + "_" + _traceName + "_" + _startDepth).parent();
		_traceName = _traceUl.find(".tree_name")[0].outerText
		_startDepth --;
		_traceFolderNameList.push(_traceName);
	}
	for(var j=_traceFolderNameList.length-2; j>=0; j--){
		uploadPath += "/" + _traceFolderNameList[j];
	}
	if(!isFile){
		uploadPath += "/" + traceName;	
	}
	
	return uploadPath;
}

function resetLibPopup(){
	$("input:radio[name=lib_patch_type]:radio[value='0']").prop("checked", "true");
	$("#popup_input_table_div").css("display", "none");	
	$("[name=old_lib_name]").val("");
	$("#popup_background_frame_lib").css("height", "328px");
	$("#popup_background_all_lib").css("margin-top","48px");
}

function mappingIconImage(fileName, obj, obj_p){
	var fileExtList = ["aif", "cda", "mp3", "wav", "wma", "wpl", // Audio
	                   "7z", "arj", "deb", "pkg", "rar", "rpm", "z", "zip", "gz", "tar", // Compress
	                   "bin", "dmg", "iso", "toast", "vcd", // Disc
	                   "csv", "dat", "db", "dbf", "log", "mdb", "sav", "sql", "xml", // Data
	                   "apk", "bat", "bin", "cgi", "com", "exe", "gadget", "jar", "py", "wsf", // Executable
	                   "fnt", "fon", "otf", "ttf", // Font
	                   "ai", "bmp", "gif", "ico", "jpeg", "jpg", "png", "ps", "psd", "svg", "tif", "tiff", // Image
	                   "asp", "cer", "cfm", "css", "html", "htm", "js", "jsp", "part", "php", "py", "rss", "xhtml", // Internet
	                   "key", "odp", "pps", "ppt", "pptx", // Presentation
	                   "c", "class", "cpp", "cs", "h", "java", "sh", "swift", "vb", //Programming
	                   "ods", "xlr", "xls", "xlsx", // Excel
	                   "bak", "cab", "cfg", "cpl", "cur", "dll", "dmp", "drv", "icns", "ico", "ini", "lnk", "msi", "sys", "tmp", // System
	                   "3g2", "3gp", "avi", "flv", "h264", "m4v", "mkv", "mov", "mp4", "mpg", "mpeg", "rm", "swf", "vob", "wmv", // Video
	                   "doc", "docx", "odt", "pdf", "rtf", "tex", "txt", "wks", "wps", "wpd" // Word
	                   ];
	if(fileName.indexOf(".") > -1){
		var extIdx = fileName.lastIndexOf(".");
		var fileExt = fileName.substring(extIdx + 1);
		if(fileExtList.includes(fileExt)){
			switch(fileExt){
			case "aif": case "cda": case "mp3": case "wav": case "wma": case "wpl":
				obj.css("background-image", "url(/resources/images/patch/tree/audio_file_icon.png)");
				obj.css("width", "13.9px");
				obj.css("height", "16.1px");
				obj.css("background-size", "14px");
				break;
			case "7z": case "arj": case "deb": case "pkg": case "rar": case "rpm": case "z": case "zip": case "gz": case "tar": case "jar":
				obj.css("background-image", "url(/resources/images/patch/tree/jar_icon.png)");
				obj.css("width", "13.9px");
				obj.css("height", "18.2px");
				obj.css("background-size", "14px");
				break;
			case "dmg": case "iso": case "toast": case "vcd":
				obj.css("background-image", "url(/resources/images/patch/tree/disc_file_icon.png)");	
				obj.css("width", "15.5px");
				obj.css("height", "15.5px");
				obj.css("background-size", "15px");	
				break;
			case "csv": case "dat": case "db": case "dbf": case "mdb": case "sav":
				obj.css("background-image", "url(/resources/images/patch/tree/data_file_icon.png)");
				obj.css("width", "14.2px");
				obj.css("height", "16.2px");
				obj.css("background-size", "14px");
				break;
			case "sql":
				obj_p.css("margin-left", "15px");
				obj.css("background-image", "url(/resources/images/patch/tree/sql_file_icon.png)");
				obj.css("width", "15px");
				obj.css("height", "16.8px");
				obj.css("background-size", "16px");
				break;
			case "xml":
				obj_p.css("margin-left", "15px");
				obj.css("background-image", "url(/resources/images/patch/tree/xml_file_icon.png)");
				obj.css("width", "15.5px");
				obj.css("height", "16.8px");
				obj.css("background-size", "17px");
				break;
			case "fnt": case "fon": case "otf": case "ttf":
				obj_p.css("margin-left", "17px");
				obj.css("background-image", "url(/resources/images/patch/tree/font_file_icon.png)");
				obj.css("width", "13px");
				obj.css("height", "17.8px");
				obj.css("background-size", "13px");
				break;
			case "ai": case "bmp": case "gif": case "ico": case "jpeg": case "jpg": case "png": 
			case "ps": case "psd": case "svg": case "tif": case "tiff": case "pdf":
				obj_p.css("margin-left", "18px");
				obj.css("background-image", "url(/resources/images/patch/tree/image_file_icon.png)");
				break;
			case "key": case "odp": case "pps": case "ppt": case "pptx":
				obj_p.css("margin-left", "17px");
				obj.css("background-image", "url(/resources/images/patch/tree/ppt_file_icon.png)");
				obj.css("width", "15px");
				obj.css("height", "17px");
				obj.css("background-size", "15px");
				break;
			case "ods": case "xlr": case "xls": case "xlsx":
				obj_p.css("margin-left", "17px");
				obj.css("background-image", "url(/resources/images/patch/tree/excel_file_icon.png)");
				obj.css("width", "15px");
				obj.css("height", "17px");
				obj.css("background-size", "15px");
				break;
			case "3g2": case "3gp": case "avi": case "flv": case "h264": case "m4v": case "mkv": 
			case "mov": case "mp4": case "mpg": case "mpeg": case "rm": case "swf": case "vob": case "wmv":
				obj_p.css("margin-left", "17px");
				obj.css("background-image", "url(/resources/images/patch/tree/video_file_icon.png)");
				obj.css("width", "14px");
				obj.css("height", "17.5px");
				obj.css("background-size", "14px");
				break;
			case "doc": case "docx": case "odt": case "rtf": case "tex": case "txt": case "wks": case "wps": case "wpd":
				obj.css("background-image", "url(/resources/images/patch/tree/text_file_icon.png)");
				break;
			default:
				obj.css("background-image", "url(/resources/images/patch/tree/file_icon.png)");
				obj.css("width", "12.8px");
				obj.css("background-size", "13px");
				break;
			}
		}else{
			obj.css("background-image", "url(/resources/images/patch/tree/file_icon.png)");
			obj.css("width", "12.8px");
			obj.css("background-size", "13px");
		}
	}else{
		obj.css("background-image", "url(/resources/images/patch/tree/file_icon.png)");
		obj.css("width", "12.8px");
		obj.css("background-size", "13px");
	}
}
function dateToString(dateNum){
	if(dateNum < 10){
		dateNum = "0" + dateNum;
	}
	return dateNum;
}