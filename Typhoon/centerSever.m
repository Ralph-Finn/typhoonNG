clear;
clc;
addpath(genpath('./resource'));%将resource及其下面的子文件夹加入到路径中
node = 0;
while(1)
tong=tcpip('localhost', 4002, 'NetworkRole', 'server');% 建立tcp连接,开启本地4002端口
fopen(tong);  % 打开tcp通道，若没有网页请求，该模块将会阻塞。
message = ['start connection at ',datestr(now,0)] 
try
    data = fread(tong,10);%读入buff中的信息,使用较小的buffer可能会带来更快的速度
    cmd = data(1);
catch
    cmd = '0';
end
command = cmd -48
%data =fread(t,50);
if cmd == '1'
    %在此注释处写你要的计算程序的函数%
    time = csvread('inputData.csv');
    Typhoon_Fault_Model(time); %台风计算程序
    message =  ['Typhoon Success at' ,datestr(now,0)] 
     fprintf(tong,cmd); 
end
if cmd == '2'
    time = csvread('inputData.csv');
    node = Section_Identification(time);
    message =['Section Sucess at',datestr(now,0)]
    fprintf(tong,int2str(node));
end
if cmd == '3'
    message =['SectionIdn Sucess at',datestr(now,0)]
    fprintf(tong,int2str(node));
end
if cmd == '0'
    fprintf(tong,cmd); %表示程序运行结束，返回给client端数据
end
cmd = '0';
%pause(1);
end