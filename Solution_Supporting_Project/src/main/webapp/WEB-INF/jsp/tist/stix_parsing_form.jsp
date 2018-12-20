<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="/resources/themes/smoothness/zTree/zTreeStyle/zTreeStyle.css" type="text/css">
<script type="text/javascript" src = "<c:url value="/resources/js/sl.form.js" />"></script>
<script type="text/javascript" src="/resources/js/jquery.ztree.core.js"></script>
  
<script type="text/javascript">
function DragAndDrop(){
	
	var obj = $("#dropzone");

    obj.on('dragenter', function (e) {
         e.stopPropagation();
         e.preventDefault();
         $(this).css('border', '2px solid #5272A0');
    });

    obj.on('dragleave', function (e) {
         e.stopPropagation();
         e.preventDefault();
         $(this).css('border', '2px dotted #8296C2');
    });

    obj.on('dragover', function (e) {
         e.stopPropagation();
         e.preventDefault();
    });

    obj.on('drop', function (e) {
         e.preventDefault();
         $(this).css('border', '2px dotted #8296C2');

         var files = e.originalEvent.dataTransfer.files;
         if(files.length < 1)
              return;

         F_FileMultiUpload(files, obj);
    });
}


function F_FileMultiUpload(files, obj) {
	if(files.length != 1){
		_alert("1개의 파일만 등록할 수 있습니다.", {onAgree : function() {}});
		return
	}else{
		var fileName = files[0].name;
		var fileExt = fileName.substring(fileName.lastIndexOf(".")+1);
		if(fileExt != "stix"){
			_alert("STIX 파일만 등록할 수 있습니다.", {onAgree : function() {}});
		}else{
			readFile(files[0], function(e) {
				var fileCont = e.target.result;
				loading.show();
				$.ajax({
			        url: "/tist/stix_parsing.json",
			        method: 'post',
			        data: JSON.stringify({file_cont:fileCont}),
			        dataType: 'json',
			        processData: false,
			        contentType : "application/json",
			        success: function(res) {
			        	loading.hide();

			        	if(res.data == null){
			        		_alert("표시할 STIX Element 값이 없습니다.", {onAgree : function() {}});
			        		return;
			        	}
			        	
			        	var stixEle = res.data[0];
			        	var stixDepth = res.data[1];
			        	
			        	stixEle.splice(0,1);
			        	stixDepth.splice(0,1);
						
						var zTreeNodes = mergeTree(stixEle, stixDepth);			
						var setting = {};
						$("#parsing_result_text").remove();
			        	$.fn.zTree.init($("#treePlace"), setting, zTreeNodes);
			        }
		    	});
			});
		}
	}
}

function readFile(file, onLoadCallback){
    var reader = new FileReader();
    reader.onload = onLoadCallback;
    reader.readAsText(file);
}

function depthCount(depthList){
	var depthMap = new Map();  
	
	for(var i=0; i<depthList.length; i++){
		if(depthMap.has(Object.values(depthList[i])[0])){
			depthMap.set(Object.values(depthList[i])[0], depthMap.get(Object.values(depthList[i])[0])+1)	
		}else{
			depthMap.set(Object.values(depthList[i])[0], 1);
		}
		
	}
	return depthMap;
}

function makezTree(elements, depthList, depthCountMap){
	var node;
	if(elements.length == 1){
		node = {name: "<" + elements[0], open:true};
		return node;
	}
	 
	var thisDepth = Object.values(depthList[0])[0];
	var chldDepth = Object.values(depthList[1])[0];
	
	if(thisDepth < chldDepth){
		var name = elements[0];
		node = {name: extractInfo(name), open:true, children:[]};

		elements.splice(0,1);
		depthList.splice(0,1);
		
		var nodeVal = makezTree(elements, depthList, depthCountMap);
		if(nodeVal != null){
			if(nodeVal.length != null){
				node["children"] = nodeVal;	
			}else{
				node["children"].push(nodeVal);
			}
		}
	}else if(thisDepth == chldDepth){
		
		var nodeList = [];
		var depthCountListSize = depthCountMap.get(thisDepth);
		
		for(var i=0; i<depthCountListSize; i++){
			if(i == depthCountListSize - 1){
				if(depthList.length == 1){
					nodeList.push({name: "<" + elements[0], open:true});
				}else{
					var inThisDepth = Object.values(depthList[0])[0];
					var inNextDepth = Object.values(depthList[1])[0];
					
					if(inThisDepth < inNextDepth){
						var name = elements[0];

						elements.splice(0,1);
						depthList.splice(0,1);
						
						var nodeVal = makezTree(elements, depthList, depthCountMap);
						if(nodeVal != null){
							if(nodeVal.length != null){
								nodeList.push({name: extractInfo(name), open:true, children:nodeVal});
							}else{
								nodeList.push({name: extractInfo(name), open:true, children:[nodeVal]});
							}
						}
					}else{
						nodeList.push({name: "<" + elements[0], open:true});
						elements.splice(0,1);
						depthList.splice(0,1);
					}	
				}
			}else{
				nodeList.push({name: "<" + elements[0], open:true});
				elements.splice(0,1);
				depthList.splice(0,1);
			}
		}
		makezTree(elements, depthList, depthCountMap);
		node = nodeList;
	} 
	return node;
}

function mergeTree(elements, depthList, depthCountMap){
	var dList = divideList(elements, depthList);
	var elementsBond = dList[0];
	var depthListBond = dList[1];

	var zNodes = [];
	
	for(var i=0; i<elementsBond.length; i++){
		var depthCountMap = depthCount(depthListBond[i]);
		var nodeDepth = depthListBond[i][0];
		depthListBond[i].splice(0,1);

		if(i == 0){
			zNodes.push(makezTree(elementsBond[i], depthListBond[i], depthCountMap));	
		}else{
			if(nodeDepth-1 == 0){
				zNodes.push(makezTree(elementsBond[i], depthListBond[i], depthCountMap));
			}else{
				var accessDepth = "zNodes"
				var childLength;
				var lengthCmd = "";
				
				for(var k=0; k<nodeDepth-1; k++){
					if(k == 0){
						accessDepth += "[0]['children']";
						lengthCmd = "childLength = " + accessDepth + ".length - 1;";
						eval(lengthCmd)
					}else{
						accessDepth += "[" + childLength + "]['children']";
						lengthCmd = "childLength = " + accessDepth + ".length - 1";
						eval(lengthCmd)
					}
				}
				accessDepth += ".push(makezTree(elementsBond[i], depthListBond[i], depthCountMap))";
				eval(accessDepth);
			}
		}
	}
	return zNodes;
}

function divideList(elements, depthList){
	var dList = [];
	var elementsBond = [];
	var depthListBond = [];
	for(var i=0; i < elements.length; i++){
		
		if(i < elements.length - 1){

			var thisDepth = Object.values(depthList[i])[0];
			var nextDepth = Object.values(depthList[i+1])[0];
			
			if(thisDepth > nextDepth){
				
				
				var tmpEleList = [];
				var tmpDepthList = [];
				
				tmpDepthList.push(Object.values(depthList[0])[0]);
				for(var k=0; k<=i; k++){
					tmpEleList.push(elements[0]);
					tmpDepthList.push(depthList[0]);
					elements.splice(0,1);
					depthList.splice(0,1);
				}
				
				elementsBond.push(tmpEleList);
				depthListBond.push(tmpDepthList);
				i = -1;
			}else if(i == elements.length - 2){
				elementsBond.push(elements);
				depthList.unshift(Object.values(depthList[0])[0]);
				depthListBond.push(depthList);
			}
		}
	}
	dList.push(elementsBond);
	dList.push(depthListBond);
	return dList;
}

function extractInfo(ele){
	var nodeStr = "";
	var infoStr = "";
	
	if((ele.indexOf(" ") != -1)){
		var endIndex = ele.lastIndexOf(">");
		var spaceIndex = ele.indexOf(" "); 
		if(spaceIndex < endIndex){
			infoStr = ele.substring(0, ele.indexOf(" "));
			nodeStr = ele.substring(ele.indexOf(" ")).trim();
		}
	}else{
		infoStr = ele.substring(0, ele.lastIndexOf(">"))
		return infoStr;
	}
	
	if(ele.indexOf(" ") != -1){
		var tmp = nodeStr.split(" ");
		for(var i=0; i<tmp.length; i++){
			if(tmp[i].indexOf("id") != -1){
				infoStr += " " + tmp[i]
			}
			if(tmp[i].indexOf("xsi:type") != -1){
				infoStr += " " + tmp[i]
			}
		}
	}
	
	if(infoStr.substring(infoStr.length-1) == ">"){
		infoStr = "<" + infoStr;
	}
	return infoStr;
}

function btnColorCtrl($btn){
	var $closeBtn = $("#expandAside").find(".btn-close");
	$closeBtn.on("click", function(){
		initBtnColor();
		if($btn.hasClass("open")){
			$btn.css("background-color", "#274543");
		}else{
			$btn.css("background-color", "#2c726d");			
		}
	});
}

$(function(){
	DragAndDrop();
	btnColorCtrl($("#parsing_stix_btn"));
});

</script>
<style>
#dropzone
    {
        border:2px dotted #3292A2;
        width:100%;
        height:50px;
        color:#92AAB0;
        text-align:center;
        font-size:24px;
        padding-top:12px;
        margin-top:10px;
    }
#treeDiv{
   border:2px solid #3292A2;
        width:100%;
        height:280px;
        color:#0d6c84;
        text-align:center;
        line-height:260px;
        font-size:24px;
        padding-top:12px;
        margin-top:10px;
}
</style>
<div class="section-content" style="margin-left:0px;">
	<form name="formSTIXGen" id="formSTIXGen">
		<input type="hidden" name="slKey" value="${_slKey}">
	</form>
	<div id="dropzone"><br>Drag & Drop STIX File Here</div>

	<div id="treeDiv">
		<span id="parsing_result_text">STIX Parsing Result</span>
		<ul style="height:94%;width:97%;overflow:auto;margin-left:13px;" id="treePlace" class="ztree"></ul>
	</div>
</div>

