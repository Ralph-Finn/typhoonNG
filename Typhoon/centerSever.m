clear;
clc;
addpath(genpath('./resource'));%��resource������������ļ��м��뵽·����
node = 0;
while(1)
tong=tcpip('localhost', 4002, 'NetworkRole', 'server');% ����tcp����,��������4002�˿�
fopen(tong);  % ��tcpͨ������û����ҳ���󣬸�ģ�齫��������
message = ['start connection at ',datestr(now,0)] 
try
    data = fread(tong,10);%����buff�е���Ϣ,ʹ�ý�С��buffer���ܻ����������ٶ�
    cmd = data(1);
catch
    cmd = '0';
end
command = cmd -48
%data =fread(t,50);
if cmd == '1'
    %�ڴ�ע�ʹ�д��Ҫ�ļ������ĺ���%
    time = csvread('inputData.csv');
    Typhoon_Fault_Model(time); %̨��������
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
    fprintf(tong,cmd); %��ʾ�������н��������ظ�client������
end
cmd = '0';
%pause(1);
end