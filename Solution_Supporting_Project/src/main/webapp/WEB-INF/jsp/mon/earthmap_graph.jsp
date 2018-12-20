<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">

<script src="https://www.amcharts.com/lib/3/ammap.js"></script>
<script src="https://www.amcharts.com/lib/3/maps/js/worldLow.js"></script>
<script src="https://www.amcharts.com/lib/3/plugins/export/export.min.js"></script>
<link rel="stylesheet" href="https://www.amcharts.com/lib/3/plugins/export/export.css" type="text/css" media="all" />
<script src="https://www.amcharts.com/lib/3/themes/dark.js"></script>
<script type="text/javascript">

var mapData = {
		  "type": "map",
		  "theme": "dark",
		  "projection": "miller",

		  "imagesSettings": {
		    "rollOverColor": "#089282",
		    "rollOverScale": 3,
		    "selectedScale": 3,
		    "selectedColor": "#089282",
		    "color": "#13564e"
		  },

		  "areasSettings": {
		    "unlistedAreasColor": "#15A892"
		  },

		  "dataProvider": {
		    "map": "worldLow",
		    "images": []
		  }
	};
	
function getNation(){
	$.ajax({
		type : "POST",
		url : "/mon/nation_latitude_longitude.json",
		contentType : "application/json",
		data : JSON.stringify({all:true}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			var list = rsJson.data
			for(var i=0; i<list.length; i++){
				var dataForm = {"zoomLevel": 5, "scale": 0.5, "title": list[i]["country"], "latitude": list[i]["latitude"], "longitude": list[i]["longitude"]}
				mapData["dataProvider"]["images"].push(dataForm);
			}
		}
	})
}
getNation();

	
var map = AmCharts.makeChart( "chartdiv",  mapData);

	// add events to recalculate map position when the map is moved or zoomed
map.addListener( "positionChanged", updateCustomMarkers );

// this function will take current images on the map and create HTML elements for them
function updateCustomMarkers( event ) {
  // get map object
  var map = event.chart;

  // go through all of the images
  for ( var x in map.dataProvider.images ) {
    // get MapImage object
    var image = map.dataProvider.images[ x ];

    // check if it has corresponding HTML element
    if ( 'undefined' == typeof image.externalElement )
      image.externalElement = createCustomMarker( image );

    // reposition the element accoridng to coordinates
    var xy = map.coordinatesToStageXY( image.longitude, image.latitude );
    image.externalElement.style.top = xy.y + 'px';
    image.externalElement.style.left = xy.x + 'px';
  }
}

// this function creates and returns a new marker element
function createCustomMarker( image ) {
  // create holder
  var holder = document.createElement( 'div' );
  holder.className = 'map-marker';
  holder.title = image.title;
  holder.style.position = 'absolute';

  // maybe add a link to it?
  if ( undefined != image.url ) {
    holder.onclick = function() {
      window.location.href = image.url;
    };
    holder.className += ' map-clickable';
  }

  // create dot
  var dot = document.createElement( 'div' );
  dot.className = 'dot';
  holder.appendChild( dot );

  // create pulse
  var pulse = document.createElement( 'div' );
  pulse.className = 'pulse';
  holder.appendChild( pulse );

  // append the marker to the map container
  image.chart.chartDiv.appendChild( holder );

  return holder;
}

function getRandomColor() {
	  var letters = '0123456789ABCDEF';
	  var color = '#';
	  for (var i = 0; i < 6; i++) {
	    color += letters[Math.floor(Math.random() * 16)];
	  }
	  return color;
}

function IPToolTip(){
	
	$.ajax({
		type : "POST",
		url : "/mon/nation_ip_list.json",
		contentType : "application/json",
		data : JSON.stringify({all:true}),
		dataType : "json",
		async : false,
		success : function(rsJson) {
			var list = rsJson.data
			var nationList = mapData["dataProvider"]["images"];
			var pulseList = $("#chartdiv").find(".map-marker");
			
			for(var i=0; i<nationList.length;i++){
				var tmp = [];
				for(var k=0; k<list.length; k++){
					if(nationList[i]["title"] == list[k]["nation"]){
						
						if(!tmp.includes(list[k]["blacklist_ip"])){
							tmp.push(list[k]["blacklist_ip"]);	
						}
					}
				}
				
				for(var t=0; t<pulseList.length; t++){
					if($(pulseList[t]).attr("title") == nationList[i]["title"]){
						$(pulseList[t]).addClass("tooltip");
						
						if(tmp.length < 6){
							$(pulseList[t]).append("<span class='tooltiptext'><table id='blacklist_table_" + t + "'><tr><th style='background-color:#ffc000'>" + $(pulseList[t]).attr("title") + "</th></tr></table></span>")								
						}else{
							$(pulseList[t]).append("<span class='tooltiptext' style='height:150px;overflow:auto'><table id='blacklist_table_" + t + "'><tr><th style='background-color:#ffc000'>" + $(pulseList[t]).attr("title") + "</th></tr></table></span>")
						}
						
						$("#blacklist_table_" + t).css("color", "black")
						$(pulseList[t]).attr("title", "");
						
						for(var j=0; j<tmp.length; j++){
							$("#blacklist_table_" + t).append("<tr><td style='background-color:white'>" + tmp[j] + "</td></tr>")							
						}
					}
					
				}
			}
		}
	})
}

window.onload = function(){
	$("#chartdiv").find("path").css("fill", "rgb(250, 234, 155)");

	IPToolTip();
	
	$("#chartdiv").find("path").css("fill-opacity", "1");
	$($("#chartdiv").find("svg").find("g")[0]).find("path").css("fill-opacity", "0");
	
	var gList = $("#chartdiv").find("svg").find("g");
	$(gList[gList.length-3]).remove();
	
}
</script>
<style>

.tooltip {
    position: relative;
    display: inline-block;
    border-bottom: 1px dotted black;
}

.tooltip .tooltiptext {
    visibility: hidden;
    width: 180px;
    background-color: #a0a0a0;
    color: #fff;
    text-align: center;
    border-radius: 6px;
    padding: 5px 0;
    position: absolute;
    z-index: 15;
    bottom: 155%;
    left: 50%;
    margin-left: -86px;
    margin-bottom: 6px;
    font-size:10pt;
    font-family:NanumGothic, sans-serif;
    opacity: 0;
    transition: opacity 0.3s;
}
.tooltip .tooltiptext table, th, td{
	border:solid 1px;
	width:90%;
	margin-left:9.5px;
	text-align:center;
} 

/* .tooltip .tooltiptext::after {
    content: "";
    position: absolute;
    top: 100%;
    left: 50%;
    margin-left: -5px;
    border-width: 5px;
    border-style: solid;
    border-color: #555 transparent transparent transparent;
} */

.tooltip:hover .tooltiptext {
    visibility: visible;
    opacity: 1;
}

/* body { background-color: #30303d; color: #fff; } */
#chartdiv {
  width: 100%;
  height: 500px;
}

.map-marker {
    /* adjusting for the marker dimensions
    so that it is centered on coordinates */
    margin-left: -8px;
    margin-top: -8px;
}
.map-marker.map-clickable {
    cursor: pointer;
}
.pulse {
    width: 5px;
    height: 5px;
    border: 4px solid #a73333;
    -webkit-border-radius: 30px;
    -moz-border-radius: 30px;
    border-radius: 30px;
    background-color: #a73333;
    z-index: 10;
    position: absolute;
  }
.map-marker .dot {
    border: 10px solid #ef4949;
    background: transparent;
    -webkit-border-radius: 60px;
    -moz-border-radius: 60px;
    border-radius: 60px;
    height: 50px;
    width: 50px;
    -webkit-animation: pulse 3s ease-out;
    -moz-animation: pulse 3s ease-out;
    animation: pulse 3s ease-out;
    -webkit-animation-iteration-count: infinite;
    -moz-animation-iteration-count: infinite;
    animation-iteration-count: infinite;
    position: absolute;
    top: -21px;
    left: -21px;
    z-index: 1;
    opacity: 0;
  }
  @-moz-keyframes pulse {
   0% {
      -moz-transform: scale(0);
      opacity: 0.0;
   }
   25% {
      -moz-transform: scale(0);
      opacity: 0.1;
   }
   50% {
      -moz-transform: scale(0.1);
      opacity: 0.3;
   }
   75% {
      -moz-transform: scale(0.5);
      opacity: 0.5;
   }
   100% {
      -moz-transform: scale(1);
      opacity: 0.0;
   }
  }
  @-webkit-keyframes "pulse" {
   0% {
      -webkit-transform: scale(0);
      opacity: 0.0;
   }
   25% {
      -webkit-transform: scale(0);
      opacity: 0.1;
   }
   50% {
      -webkit-transform: scale(0.1);
      opacity: 0.3;
   }
   75% {
      -webkit-transform: scale(0.5);
      opacity: 0.5;
   }
   100% {
      -webkit-transform: scale(1);
      opacity: 0.0;
   }
  }
</style>
