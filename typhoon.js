var map = new BMap.Map("allmap");
map.centerAndZoom("广州", 8);
map.enableScrollWheelZoom();
var mapStyle={ style : "light" }; 
map.setMapStyle(mapStyle);
drawBoundary();			
$(function(){
	$("#timepicker,#tableBox").css("margin-bottom","30px")
	$("#up,#send").css("margin-top","10px")
	$( "#up,#send" ).button();
	/*$("#fakeloader").fakeLoader({
        timeToHide:12000, //Time in milliseconds for fakeLoader disappear
        zIndex:999, // Default zIndex
        spinner:"spinner7",//Options: 'spinner1', 'spinner2', 'spinner3', 'spinner4', 'spinner5', 'spinner6', 'spinner7' 
        bgColor:"#2ecc71"
    }); */
	$( "#time" ).slider({
      orientation: "horizontal",
      range: "min",
      max: 288,
      value: 150,
      slide: refreshSwatch,
      change: refreshSwatch
    });
	$( "#swatch" ).html("12:30");
	initMap();
  $("#send").click(function(){
	var time = $("#swatch").html(); //获取滑块的数值
	time = time.split(":");
	var params = {hour:time[0],min:time[1],type:'1'};
	$( "#send" ).button( "disable");
   $.ajax({
    //url:'http://localhost/SE/typhoon.php',  //偶尔需要使用这样的方法来获取
	url:'./typhoon.php',
    type:'post',
    dataType:'json',
	data: params, 
    success:function(data){
		console.log(data);
		if(typeof(data) == "number")
		{
			 alert("系统繁忙，请稍后重试！！！");
		}
		else{
		 map.clearOverlays();//清除全部标记物体，为浏览器释放内存
		 drawLine(data);
		 drawPoint(data);
		 drawRoute(data);
		 drawCircle(data);
		 showTable(data);
		}
		$( "#send" ).button( "enable"); 
    },
	error: function(){
		alert('系统繁忙，请稍后重试！！！');
		$( "#send" ).button( "enable"); 
	}
   });
  }); 
	$("#up").click(function(){
	openFileWin();
  });
 });
 
 function drawPoint(data)
 {
	var myIcon1 = new BMap.Icon("./resource/n1.png", new BMap.Size(15, 15), {});
	var myIcon2 = new BMap.Icon("./resource/n2.png", new BMap.Size(15, 15), {});
	var myIcon3= new BMap.Icon("./resource/n3.png", new BMap.Size(15, 15), {});
	var point1=new BMap.Point(113.14,23.08);
	var pointClub = data[0];
	for(var key in pointClub){ 	
		point1.lng=pointClub[key][12];
		point1.lat=pointClub[key][13];
	  //覆盖物点坐标
		if(pointClub[key][14]==1){
			var marker = new BMap.Marker(point1,{icon: myIcon1});
			}
		if(pointClub[key][14]==2){
			var marker = new BMap.Marker(point1,{icon: myIcon2});
		}
		if(pointClub[key][14]==3){
			var marker = new BMap.Marker(point1,{icon: myIcon3});
		}
		map.addOverlay(marker);
	}

 }
 
 function drawLine(data)
 {
	var point1=new BMap.Point(113.14,23.08);
	var point2=new BMap.Point(113.14,23.08);
	var pointClub = data[0];
	var lineClub = data[1];
	for(var key in lineClub){ 
	  point = getLineData(key, lineClub, pointClub);
	  //覆盖物点坐标
		var polyline = new BMap.Polyline([
			point[0],
			point[1]
		], {strokeColor:"black", strokeWeight:3, strokeOpacity:1}); 
		map.addOverlay(polyline); 
	}

 }
 
 function getLineData(key, lineClub, pointClub){
	var point1=new BMap.Point(113.14,23.08);
	var point2=new BMap.Point(113.14,23.08);
	var keygen1 = lineClub[key][1];
	point1.lng=pointClub[keygen1][12];
	point1.lat=pointClub[keygen1][13];
	var keygen2 = lineClub[key][3];
	point2.lng=pointClub[keygen2][12];
	point2.lat=pointClub[keygen2][13];
	return [point1,point2];
 }
function drawCircle(data){
	var typhoon = data[2][1];
	point.lng=typhoon[0];
	point.lat=typhoon[1];
	var circle1 = new BMap.Circle(point,typhoon[2]*1000, {fillColor:'#28FF28', strokeColor:'#28FF28', fillOpacity:0.5,strokeOpacity:0.5});
	map.addOverlay(circle1); 
	var circle2 = new BMap.Circle(point,typhoon[3]*1000, {fillColor:'#921AFF', strokeColor:'#921AFF', fillOpacity:0.5,strokeOpacity:0.5}); 	
	map.addOverlay(circle2);
	map.panTo(point); 
	var myIcon = new BMap.Icon("./resource/feng.png", new BMap.Size(15, 15), {});
	var marker = new BMap.Marker(point,{icon: myIcon});
	map.addOverlay(marker);
	var opts = {
	  width : 200,     // 信息窗口宽度
	  height: 100,     // 信息窗口高度
	  title : "海底捞王府井店"// 信息窗口标题
	};
	var infoWindow = new BMap.InfoWindow("地址：北京市东城区王府井大街88号乐天银泰百货八层", opts);  // 创建信息窗口对象 
	marker.addEventListener("click", function(){          
		map.openInfoWindow(infoWindow,point); //开启信息窗口
	});
}
function drawRoute(data){
	var typhoon = data[3];
	var route = getRoutePoints(typhoon);
	var polyline = new BMap.Polyline(route, {strokeColor:'#F75000', strokeWeight:4, strokeOpacity:1,strokeStyle:'dashed'}); 
	map.addOverlay(polyline);
	//var pc = new BMap.PointCollection(route,{color:'#000000'}); 
	//map.addOverlay(pc);
	
}
function getRoutePoints(typhoon){
	var points = [];
	for(var key in typhoon){
		var point = new BMap.Point(113.14,23.08);	
		point.lng=typhoon[key][0];
		point.lat=typhoon[key][1];
		points.push(point);
	}
	return points;
}
function getBoundary(province, color){         
    var bdary = new BMap.Boundary();  
    var name = province;  
    bdary.get(name, function(rs){       //获取行政区域  
        //map.clearOverlays();        //清除地图覆盖物  
        var count = rs.boundaries.length; //行政区域的点有多少个  
        for(var i = 0; i < count; i++){  
            var ply = new BMap.Polygon(rs.boundaries[i] ,{strokeWeight: 2, strokeColor: 'black',fillColor:color,enableMassClear:false,fillOpacity:0.5}); //建立多边形覆盖物  
            map.addOverlay(ply);  //添加覆盖物  
            //map.setViewport(ply.getPath());    //调整视野           
        }                  
    }); 
}

function drawBoundary(){
	getBoundary('广东','#FFED97');
}

 function refreshSwatch(){
    var time = $( "#time" ).slider( "value" );
	var hour = parseInt(time/12);
	var min = (time - hour*12)*5;
    $( "#swatch" ).html(hour+':'+min);
  }  
  
function showTable(data){
	var notWork = data[4];
	var lineClub = data[1];
	var tableData = getTableData(notWork, lineClub);
	console.log(tableData);
	setTable(tableData);
}

function getTableData(notWork, lineClub){
	var tableData = [];
	for(var key in notWork){
		if(notWork[key][0]!=' '){
			var gu = [];
			gu.push(notWork[key][0],notWork[key][1],lineClub[key][1],lineClub[key][3],'500KV');
			//表格中每一行均包含有四个数据
			tableData.push(gu);
		}
	}
	return(tableData);
}

function setTable(tableData){
	$('#myTable').dataTable( {
		"dom": '<"top">t<"bottom"><"clear"iflp>',
        "data": tableData,
		"autoWidth": false,
		"scrollX": false,
		 "info": false,
		 "paging": false,
		 "jQueryUI": true,
		 "scrollY": 200,
         "scrollCollapse": true,
		 "hover":true,
		 "destroy": true,
		 "searching": false,
        "columns": [
            { "title": "线路","width":"50px" },
            { "title": "断线回数" ,"width":"80px"},
            { "title": "起点" ,"width":"50px"},
			{ "title": "终点" ,"width":"50px"},
			{ "title": "电压等级" ,"width":"90px"},
        ]
    } );
	$("#myTable tr").hover(function(){
    $(this).css("background-color","#81C0C0");
    },function(){
    $(this).css("background-color","white");
	});
}


function openFileWin(){ 
	window.open("./fileUp.html","newwindow","height=200,width=500,toolbar=no,menubar=no,scrollbars=no,resizable=no, location=no,status=no") ;
	} 

function initMap(){
	var initTable = [[0,0,0,0,'0KV']];
	setTable(initTable);
	var time = $("#swatch").html(); //获取滑块的数值
	time = time.split(":");
	var params = {hour:time[0],min:time[1],type:'9'};
	$.ajax({
    //url:'http://localhost/SE/typhoon.php',  //真的是翻皮水，神tm有趣。
	url:'./typhoon.php',
    type:'post',
    dataType:'json',
	data: params, 
    success:function(data){
		if(typeof(data) == "number")
		{
			 alert("系统繁忙，请稍后重试！！！");
		}
		else{
		 drawLine(data);
		 drawPoint(data);
		} 
    }
   });
}
