clear;
clc;
addpath('./resource');
while(1)
tong=tcpip('localhost', 4002, 'NetworkRole', 'server');% 建立tcp连接,开启本地4002端口
fopen(tong);  % 打开tcp通道，若没有网页请求，该模块将会阻塞。
mess = 'start connection'
cmd = '0';
try
    data = fread(tong,512);%读入buff中的信息。
    %data = fscanf(tong,'%f',[1,512])
    cmd = data(1);
catch
    cmd = '0';
end
cmd
%data =fread(t,50);
if cmd == '1'
    %在此注释处写你要的计算程序的函数%
    time = csvread('inputData.csv');
    Typhoon_Fault_Model(time); %台风计算程序
    mess = 'Typhoon Success' 
     fprintf(tong,cmd); 
end
if cmd == '2'
    node = Section_Identification();
    mess ='Section Sucess'
    fprintf(tong,int2str(node));
end
if cmd == '0'
    fprintf(tong,cmd); %表示程序运行结束，返回给client端数据
end
cmd = '0';
pause(1);
end