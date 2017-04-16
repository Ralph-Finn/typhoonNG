var map = new BMap.Map("allmap");
map.centerAndZoom("广州", 8);
map.enableScrollWheelZoom();
var mapStyle={ style : "light" }; 
map.setMapStyle(mapStyle);
//drawBoundary();			
$(function(){
	$("#timepicker").css("margin-bottom","0px");
	$("#send1,#send2").css("margin-top","10px");
	$( "#send1,#send2" ).button();
	$( "#swatch" ).html("12:30");
	initMap();
  $("#send1").click(function(){
	var params = {type:'2'};
	$( "#send1" ).button( "disable");
   $.ajax({
    //url:'http://localhost/SE/section.php',  //真的是翻皮水，神tm有趣。
	url:'./section.php',
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
		 refreshSwatch(data);
		}
		$( "#send1" ).button( "enable"); 
    },
	error: function(){
		alert('系统繁忙，请稍后重试！！！');
		$( "#send1" ).button( "enable"); 
	}
   });
  }); 

 });
 
 function drawPoint(data)
 {
	var myIcon1 = new BMap.Icon("./resouce/1.png", new BMap.Size(10, 10), {});
	var myIcon2 = new BMap.Icon("./resouce/2.png", new BMap.Size(10, 10), {});
	var myIcon3= new BMap.Icon("./resouce/3.png", new BMap.Size(10, 10), {});
	var myIcon4= new BMap.Icon("./resouce/feng.png", new BMap.Size(10, 10), {});
	var pointLib = data[0];
	var myIcon = [myIcon1,myIcon2,myIcon3,myIcon4];
	for(var key in pointLib){
		var pointClub = pointLib[key];
		somePoint(pointClub,key,myIcon[key]);
	}
	

 }
 
 function somePoint(pointClub,index,myIcon){
	 var point=new BMap.Point(113.14,23.08);
	 for(var key in pointClub){ 	
		point.lng=pointClub[key][12];
		point.lat=pointClub[key][13];
		var marker = new BMap.Marker(point,{icon: myIcon});
		map.addOverlay(marker);
	 }
 }
 
 
 function drawLine(data)
 {
	var point1=new BMap.Point(113.14,23.08);
	var point2=new BMap.Point(113.14,23.08);
	var pointClub = data[2];
	var lineLib = data[1];
	var color = ['red','yellow','blue','#921AFF']
	for(var index in lineLib){
		var lineClub = lineLib[index];
		for(var key in lineClub){ 
		  point = getLineData(key, lineClub, pointClub);
		  //覆盖物点坐标
			var polyline = new BMap.Polyline([
				point[0],
				point[1]
			], {strokeColor:color[index], strokeWeight:3, strokeOpacity:1}); 
			map.addOverlay(polyline); 
		}
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
	var city = ["广州市", "韶关市", "深圳市", "珠海市","汕头市", "佛山市", "江门市", "湛江市", "茂名市", "肇庆市", "惠州市", "梅州市" ,"汕尾市", "河源市","阳江市" ,"清远市", "东莞市", "中山市", "潮州市", "揭阳市", "云浮市"];
	 var color = ["#C8C1E3", "#FBC5DC", "#DBEDC7", "#E7CCAF", "#DBEDC7",
        "#FEFCBF", "#E7CCAF", "#C8C1E3", "#FBC5DC", "#C8C1E3",
        "#DBECC8", "#DBECC8", "#FCFBBB", "#FCFBBB", "#FCFBBB", "#FCFBBB",
        "#FCFBBB", "#E7CCAF", "#E7CCAF", "#E7CCAF", "#E7CCAF"];
	for(var key in city){
		getBoundary(city[key],color[key]);
	}
}

 function refreshSwatch(data){
	var hour = data[3][0][0];
	var min = data[3][0][1];
    $( "#swatch" ).html(hour+':'+min);
  }  
  
function initMap(){
	drawBoundary();
}
