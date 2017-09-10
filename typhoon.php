<?php
# $commandBt="C:/Users/Ralph/desktop/test/for_testing/test.exe";
#　exec($commandBt);
date_default_timezone_set('Asia/ShangHai');
require_once './PHPExcel/Classes/PHPExcel/IOFactory.php';  #此处为引用的头文件
$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
$con=socket_connect($socket,'127.0.0.1',4002);
if(!$con){socket_close($socket);exit;}
# echo "Link\n";
$fp = fopen('./Typhoon/inputData.csv', 'w');  
fputcsv($fp,array($_POST['hour'],$_POST['min']));
fclose($fp);
if($_POST['type']=='9')
{
	socket_shutdown($socket);
	sleep(1);
	readExcle();
}
else
{	
$a = 0;
while($con){
        $words='1';
        socket_write($socket,$words);
		$a = $a + 1;
        if($a==1000){break;}//成功将数据发送量减少到原来的1/10
}
$hear=socket_read($socket,1024);
socket_shutdown($socket);
readExcle();
}

function readExcle(){
$reader = PHPExcel_IOFactory::createReader('Excel5'); //设置以Excel5格式(Excel97-2003工作簿)
$PHPExcel = $reader->load("./Typhoon/resource/Typhoon.xls"); // 载入excel文件
$sheet = $PHPExcel->getSheet(1); // 读取第n個工作表
$highestRow = $sheet->getHighestRow(); // 取得总行数
$highestColumm = $sheet->getHighestColumn(); // 取得总列数
/** 循环读取每个单元格的数据 */
for ($row = 1; $row <= $highestRow; $row++){//行数是以第1行开始
    for ($column = 'A'; $column <= $highestColumm; $column++) {//列数是以A列开始
        $dataset1[$row][] = $sheet->getCell($column.$row)->getValue();
        #echo $column.$row.":".$sheet->getCell($column.$row)->getValue()."<br />";
    }
}
$sheet = $PHPExcel->getSheet(2); // 读取第n個工作表
$highestRow = $sheet->getHighestRow(); // 取得总行数
$highestColumm = $sheet->getHighestColumn(); // 取得总列数
/** 循环读取每个单元格的数据 */
for ($row = 1; $row <= $highestRow; $row++){//行数是以第1行开始
    for ($column = 'A'; $column <= $highestColumm; $column++) {//列数是以A列开始
        $dataset2[$row][] = $sheet->getCell($column.$row)->getValue();
        #echo $column.$row.":".$sheet->getCell($column.$row)->getValue()."<br />";
    }
}
$sheet = $PHPExcel->getSheet(3); // 读取第n個工作表
$highestRow = $sheet->getHighestRow(); // 取得总行数
$highestColumm = $sheet->getHighestColumn(); // 取得总列数
/** 循环读取每个单元格的数据 */
for ($row = 1; $row <= $highestRow; $row++){//行数是以第1行开始
    for ($column = 'A'; $column <= $highestColumm; $column++) {//列数是以A列开始
        $dataset3[$row][] = $sheet->getCell($column.$row)->getValue();
        #echo $column.$row.":".$sheet->getCell($column.$row)->getValue()."<br />";
    }
}
$sheet = $PHPExcel->getSheet(4); // 读取第n個工作表
$highestRow = $sheet->getHighestRow(); // 取得总行数
$highestColumm = $sheet->getHighestColumn(); // 取得总列数
/** 循环读取每个单元格的数据 */
for ($row = 1; $row <= $highestRow; $row++){//行数是以第1行开始
    for ($column = 'A'; $column <= $highestColumm; $column++) {//列数是以A列开始
        $dataset4[$row][] = $sheet->getCell($column.$row)->getValue();
        #echo $column.$row.":".$sheet->getCell($column.$row)->getValue()."<br />";
    }
}
$sheet = $PHPExcel->getSheet(5); // 读取第n個工作表
$highestRow = $sheet->getHighestRow(); // 取得总行数
$highestColumm = $sheet->getHighestColumn(); // 取得总列数
/** 循环读取每个单元格的数据 */
for ($row = 1; $row <= $highestRow; $row++){//行数是以第1行开始
    for ($column = 'A'; $column <= $highestColumm; $column++) {//列数是以A列开始
        $dataset5[$row][] = $sheet->getCell($column.$row)->getValue();
        #echo $column.$row.":".$sheet->getCell($column.$row)->getValue()."<br />";
    }
}
$dataset = array($dataset1,$dataset2,$dataset3,$dataset4,$dataset5);
echo json_encode($dataset);
}
?>