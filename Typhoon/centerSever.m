clear;
clc;
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
    %将数据返回给请求数据的页面
end
if cmd == '2'
    Section_Identification();
    mess ='Section Sucess'
end
fprintf(tong,cmd); %表示程序运行结束，返回给client端数据
cmd = '0';
pause(1);
end