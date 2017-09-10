<?php
# $commandBt="C:/Users/Ralph/desktop/test/for_testing/test.exe";
#　exec($commandBt);
set_time_limit(0);
date_default_timezone_set('Asia/ShangHai');
require_once './PHPExcel/Classes/PHPExcel/IOFactory.php';  #此处为引用的头文件
$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
$con=socket_connect($socket,'127.0.0.1',4002);
if(!$con){socket_close($socket);exit;}	
$a = 0;
while($con){
        $words=$_POST['type'];//将数据类类型发送到MATLAB程序中
        socket_write($socket,$words);
		$a = $a + 1;
        if($a==1000){break;}
}
$hear=socket_read($socket,1024);
socket_shutdown($socket);
$hear = $hear - 0;
readCSV($hear, readExcle());

function readExcle(){
$reader = PHPExcel_IOFactory::createReader('Excel5'); //设置以Excel5格式(Excel97-2003工作簿)
$PHPExcel = $reader->load("./Typhoon/resource/Typhoon.xls"); // 载入excel文件
$data = array();
$sheet = $PHPExcel->getSheet(1); // 读取第n個工作表
$highestRow = $sheet->getHighestRow(); // 取得总行数
$highestColumm = $sheet->getHighestColumn(); // 取得总列数
/** 循环读取每个单元格的数据 */
for ($row = 1; $row <= $highestRow; $row++){//行数是以第1行开始
	for ($column = 'A'; $column <= $highestColumm; $column++) {//列数是以A列开始
		$dataset[$row][] = $sheet->getCell($column.$row)->getValue();
		#echo $column.$row.":".$sheet->getCell($column.$row)->getValue()."<br />";
	}
}
return $dataset;
}

function readCSV($num,$data4){
	$data = array();
	$data1 = array();
	$data2 = array();
	for($key =1;$key<($num+1);$key++){
		$name = './Typhoon/resource/sectionPoint'.strval($key).'.csv';
		//$name = './Typhoon/resource/sectionPoint1.csv';
		$file = fopen($name,'r');
		$dataset = array();		
		while ($row = fgetcsv($file)) {
			$dataset[] = $row;
		}
	$data1[] = $dataset;
	}
	for($key =1;$key<($num+1);$key++){
		$name = './Typhoon/resource/sectionLine'.strval($key).'.csv';
		//$name = './Typhoon/resource/sectionPoint1.csv';
		$file = fopen($name,'r');
		$dataset = array();		
		while ($row = fgetcsv($file)) {
			$dataset[] = $row;
		}
	$data2[] = $dataset;
	}
	$name = './Typhoon/resource/connect.csv';
	//$name = './Typhoon/resource/sectionPoint1.csv';
	$file = fopen($name,'r');
	$dataset = array();		
	while ($row = fgetcsv($file)) {
		$dataset[] = $row;
	}
	$data3[] = $dataset;
	//////////////////////////////////////////////////////
	for($key =1;$key<($num+1);$key++){
		$name = './Typhoon/resource/Ident'.strval($key).'.csv';
		//$name = './Typhoon/resource/sectionPoint1.csv';
		$file = fopen($name,'r');
		$dataset = array();		
		while ($row = fgetcsv($file)) {
			$dataset[] = $row;
		}
	$data6[] = $dataset;
	}
	////////////////////////////////////////
	$data[] = $data1;//分区点数据
	$data[] = $data2;//分区线数据
	$data[] = $data3;//分区连接数据
	$data[] = $data4;//总点数据
	$data[] = readTime();//当前的观测时间
	$data[] = $data6;//断面识别的数据
	echo json_encode($data);
}

function readTime(){
	$name = './Typhoon/inputData.csv';
	$file = fopen($name,'r');
	$dataset = array();		
	while ($row = fgetcsv($file)) {
		$dataset[] = $row;
	}
	return $dataset;
}
?>