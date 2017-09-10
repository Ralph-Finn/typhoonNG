%%%%%%%%%%%%%%%%%%%%%%%%%% Typhoon Fault Model %%%%%%%%%%%%%%%%%%%%%%%%%%
function Typhoon_Fault_Model(time)
tic;                            %��ʼ��ʱ

%% ============== Typhoon Model ==============
% --------------- �㶫ʡ��ͼ���� --------------- 
fnshp_P='china_basic_map\bou2_4p.shp';%ShapeType: 'Polygon'   
infoP = shapeinfo(fnshp_P);    
readP=shaperead(fnshp_P);
mapshow(fnshp_P);
hold on
axis([109 119 18 27])

% --------------- ̨��·������ ---------------
TP=xlsread('1622��̨������.xls');
t_TP=1:24;
%plot(TP(:,1),TP(:,2),'marker','o','markersize',6,'color','r');
for i=1:24
    text(TP(i,1)+0.15,TP(i,2),num2str(t_TP(i)));
end

% ---------------- ���ϵͳ���ݵ��� ----------------
TS_n=xlsread('�㶫�е�ԭ����_20170909.xls','�ڵ�');
TS_l=xlsread('�㶫�е�ԭ����_20170909.xls','��·');
n=size(TS_n,1);
FS=[15 60;1 2];                        %��ʼ���ϼ� 
for i=1:size(FS,2) 
    if FS(2,i)<TS_l(FS(1,i),9)            
        TS_l(FS(1,i),9)=TS_l(FS(1,i),9)-FS(2,i);    %���ٻ�·��
    else
        st=TS_l(FS(1,i),2);
        en=TS_l(FS(1,i),4);
        %plot([TS_n(st,13);TS_n(en,13)],[TS_n(st,14);TS_n(en,14)],'r:','linewidth',3);
        TS_l(FS(1,i),:)=[];                         %�г�����������· 
    end
end
l=size(TS_l,1);

% --------------- ̨��ģ�ͷ���(����-����Ƕ��̨��ģ��) ---------------
c1=0.6;
c2=0.6;
t=time(1);
t_m=time(2);
tt=t*60+t_m;
% x=TP(t,1)-0.125:-0.0625:TP(t,1)-5;
% y=TP(t,2)*ones(1,length(x));
TP_X=TP(t,1)+t_m*(TP(t+1,1)-TP(t,1))/60;
TP_Y=TP(t,2)+t_m*(TP(t+1,2)-TP(t,2))/60;
dita=atan((TP(t+1,2)-TP(t,2))/(TP(t+1,1)-TP(t,1)));              %���з��ټн�
if t_m>0 && t>=7
    TP_P=976.7-17.68*cos(tt*0.003325)-7.914*sin(tt*0.003325);    %̨��������ѹ˥������
else
    TP_P=TP(t,5);
end
se1=TS_l(:,11);
x=TS_l(:,12);
y=TS_l(:,13);

for i=1:l
    r(i)=distance(x(i),y(i),TP_X,TP_Y)*111.1775;
    if isnan(TP(t,6))
        Ro=30-0.4*(TP(t,5)-900)+0.01*(TP_P-900)^2;
        RRo=Ro*3.33;
    else
        Ro=TP(t,6)/10;
        RRo=TP(t,7);
    end
    f=7.27*1e-5*sin(TP_Y*0.0175);
    deta=atan((TP_Y-y(i))/(TP_X-x(i)))+1.5708;
    Vdx=TP(t,4)*cos(deta)+TP(t,8)*cos(dita);
    Vdy=TP(t,4)*sin(deta)+TP(t,8)*sin(dita);
    seta=19.5*0.0175;
    if r(i)<=2*Ro
        P=1013.25-(1013.25-TP_P)/sqrt(1+(r(i)/Ro)^2);
    else
        P=1013.25-(1013.25-TP_P)/(1+r(i)/Ro);
    end
    Vx(i)=c1*Vdx*exp(-0.7854*abs(r(i)-Ro)/Ro)-c2*(-f+sqrt(f^2+2e3*(P-TP(t,5))*(1+2*(r(i)/Ro)^2)^-1.5/(1.2929e-3*Ro^2)))*((x(i)-TP_X)*sin(seta)+(y(i)-TP_Y)*cos(seta));
    Vy(i)=c1*Vdy*exp(-0.7854*abs(r(i)-Ro)/Ro)+c2*(-f+sqrt(f^2+2e3*(P-TP(t,5))*(1+2*(r(i)/Ro)^2)^-1.5/(1.2929e-3*Ro^2)))*((x(i)-TP_X)*cos(seta)-(y(i)-TP_Y)*sin(seta));
    se2(i)=atan(Vy(i)/Vx(i));
    V(i)=sqrt(Vx(i)^2+Vy(i)^2);
    se=sort([se1(i),se2(i)]);           %����·�ͷ��ٵĽǶ���С��������
    se_v(i)=abs(1.5708+se(1)-se(2));    %�����뵼�߷���н�
    V_v(i)=V(i)*cos(se_v(i));           %��ֱ���߷���
end

%% ============== Failure Rate Calculation ==============
% --------------- ���߹����� ---------------
for i=1:l
    if V_v(i)<20
        a1(i)=1.0;                %���߷�ѹ������ϵ��
    else if V_v(i)<=30
            a1(i)=0.85;
         else if V_v(i)<=35
                  a1(i)=0.75;
              else
                  a1(i)=0.70;
             end
         end
    end
end                
kc1=1.1*ones(1,l);               %���߷��������ϵ��
N1=6*ones(1,l);                  %���߷�����
Lo=350*ones(1,l);                %���ߵ���
d=15*ones(1,l);                  %�����⾶
b=10*ones(1,l);                  %���߸������
mo=300*ones(1,l);                %ÿ���ﵼ������
q_max=184.2*ones(1,l);           %��·����Ӧ��
qq_max=q_max/2.5;                %���ǰ�ȫԣ�ȵ��������Ӧ��

I=0;
if I-1
    g1=0.7798*1e-3*a1.*kc1.*N1.*(V_v.^2)./d;        %�ޱ���ѹ���أ�N/(m*mm^2)
    tm=20;
else
    g1=0.7798*1e-3*a1.*kc1.*N1.*(2*b+d).*(V_v.^2)./d.^2; %������ѹ���أ�N/(m*mm^2)
    tm=-5;
end
g=1.2477*1e-2*N1.*mo./d.^2;                       %���ر���
G=sqrt(g1.^2+g.^2);                               %�ۺϱ���
C1=3.3*1e3*Lo.^2.*G.^2;
C2=qq_max-3.3*1e3*Lo.^2.*G.^2./qq_max.^2+1.4896*(tm+5);  
C3=C2.*sqrt(qq_max);
qo=((C3+sqrt(C3.^2+4*C1))/2).^(2/3);
qo=2*sum(qo)/l-qo;
Lm=0.5*Lo+qo./G;
qm=sqrt(qo.^2+Lm.^2.*G.^2);
for i=1:l
    if qm(i)<q_max(i)
        P1(i)=1e-6*exp(qm(i)/18.856);         %���߹�����
    else
        P1(i)=0.01;
    end
end
    
% --------------- ���������ʣ�������ˮƽ���أ� ---------------
N2=3*ones(1,l);                    %�����ϵ�������
kt=1.2*ones(1,l);                  %��������ϵ��
kc2=1.08*ones(1,l);                %�������������ϵ��
kz=1.05*ones(1,l);                 %����ϵ��
At=6.291*ones(1,l);                %�����������
Wtm=2e4*ones(1,l);                 %�������޷����

deta_F=0.7854*1e-6*N2.*N1.*d.^2.*qo.^2; %�������ܵ��߲�ƽ������At��λΪm^2���ʳ�1e-6
Wt1=0.6125*kt.*kc2.*At.*V_v.^2;    %������ֱ��·��������
Wt2=((kt-1)./kt).*kz.*Wt1;         %����ƽ����·��������
Wt=sqrt((deta_F+Wt2).^2+Wt1.^2);   %�����ܷ����
Wt=Wt/max(Wt);                     %��һ��
for i=1:l
    if Wt(i)<Wtm(i)
        P2(i)=1.03e-4*exp(Wt(i));  %����������
    else
        P2(i)=0.01;
    end
end

% --------------- ������߹����� ---------------
VB=25*ones(1,l);                   %���߻�׼����
as=1.308*ones(1,l);                %��·�ܱ߻���ϵ��

Ef=as.*(V_v./VB);                   %�׹һ�������
Lp=N1.*(N2/3)./Lo;                 %�׹���·����
for i=1:l
    if Ef(i)<=0.2
        P3_1(i)=1e-3;
    else if Ef(i)<=0.4
            P3_1(i)=(Ef(i)-0.2)/0.2*2e-3;
        else if Ef(i)<=0.6
                P3_1(i)=(Ef(i)-0.4)/0.2*3e-3;
            else if Ef(i)<=0.8
                    P3_1(i)=(Ef(i)-0.6)/0.2*4e-3;
                else if Ef(i)<=1.0
                        P3_1(i)=(Ef(i)-0.8)/0.2*5e-3;
                    else
                        P3_1(i)=6e-3;
                    end
                end
            end
        end
    end
end
P3=P3_1.*exp(80.03*Lp);

% --------------- �ܹ����� ---------------
P=(1-(1-P1).*(1-P2).*(1-P3));        %��·�ܹ�����

%% ============== Fault Set Generation ==============
N3=round(1e3*(TS_l(:,10)'./Lo))/60;   %ÿ����·����      
P=1-(1-P).^N3;
for i=1:l
    fn(i)=0;
    for j=1:TS_l(i,9)
        if rand<=P(i)
            fn(i)=fn(i)+1;            
        end   
    end
end
FI=find(fn>0);
fs=[FI;fn(FI)];                       %�����¹��ϼ� 
for i=1:size(fs,2) 
    if fs(2,i)<TS_l(fs(1,i),9)            
        TS_l(fs(1,i),9)=TS_l(fs(1,i),9)-fs(2,i); %������·��
    else
        st=TS_l(fs(1,i),2);
        en=TS_l(fs(1,i),4);
        %plot([TS_n(st,13);TS_n(en,13)],[TS_n(st,14);TS_n(en,14)],'r:','linewidth',3);
        TS_l(fs(1,i),:)=[];                      %�г������¹�����· 
    end 
end

% ---------------- ���Ƴ�����ͼ ----------------
l=size(TS_l,1);                                  %����֧·��
for i=1:l
    st=TS_l(i,2);
    en=TS_l(i,4);
    %plot([TS_n(st,13);TS_n(en,13)],[TS_n(st,14);TS_n(en,14)],'k','linewidth',2);
end

%plot(TS_n(:,13),TS_n(:,14),'ko','MarkerFaceColor','r','MarkerSize',8)
%plot(TS_n(1:20,13),TS_n(1:20,14),'ks','MarkerFaceColor','m','MarkerSize',10);
%plot(TS_n(21:24,13),TS_n(21:24,14),'kh','MarkerFaceColor','g','MarkerSize',10);
%plot(TS_n(62:66,13),TS_n(62:66,14),'kh','MarkerFaceColor','g','MarkerSize',10);
                        
ro=Ro/111.1775;
rro=RRo/111.1775;
theta=(0:0.01:2)*pi;
%patch(TP_X+rro*cos(theta),TP_Y+rro*sin(theta),'b','edgecolor','none','facealpha',0.3) %����ʮ����Ȧ  
%patch(TP_X+ro*cos(theta),TP_Y+ro*sin(theta),'m','edgecolor','none','facealpha',0.3)  %����������Ȧ
%plot(TP_X,TP_Y,'ko','Markerfacecolor','r')

% -------------- ��������� -------------- 
TPP = [TP_X,TP_Y,RRo,Ro];%���ĵ���������ʮ����Ȧ�Լ�����Ȧ
 warning off
 %xlswrite('./resource/Typhoon.xls',TS_n,'�ڵ�')
 %xlswrite('./resource/Typhoon.xls',TS_l,'��·')
 xlswrite('./resource/Typhoon.xls',TPP,'̨��')
 xlswrite('./resource/Typhoon.xls',TP,'�켣')
 xlswrite('./resource/Typhoon.xls',' ','����','A1:B30')
 xlswrite('./resource/Typhoon.xls',fs','����')

toc;                                 %ֹͣ��ʱ
end