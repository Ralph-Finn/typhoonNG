%%%%%%%%%%%%%%%%%%%%%%%% Section Identification %%%%%%%%%%%%%%%%%%%%%%%%
function N_cate = Section_Identification(time)
%% ============== Initial Partition ==============
% ---------------- ���ϵͳ�������� ----------------
TS_n=xlsread('�㶫�е�ԭ����_20170909.xls','�ڵ�');
TS_l=xlsread('�㶫�е�ԭ����_20170909.xls','��·');
FS=xlsread('ʱ����·���ϼ�.xls');
[n,nn]=size(TS_n);                             %����ǰ�ڵ���
[l,ll]=size(TS_l);                             %����ǰ��·��

% -------------- ���������·�ڵ����· --------------
t=time(1);
t_m=time(2);
fs=[];
for i=1:2:2*(t*4+t_m/15)+1
    fs=[fs,FS(i:i+1,2+find(FS(i,3:end)~=0))];    %ʱ����ϼ�
end

YU=[];
for i=1:l
    YG(i)=sum(fs(2,find(fs(1,:)==i)));
    if YG(i)>=TS_l(i,9)
        YU=[YU,i];                               %��¼���г���·
    else
        TS_l(i,9)=TS_l(i,9)-YG(i);
    end
end
find(YG~=0);
TS_l(YU,:)=[];                                   %������·
l=size(TS_l,1);                                  %������·��

% ---------------- �������������� ----------------
R=TS_l(:,6).*TS_l(:,10)./TS_l(:,9);            %��·����
X=TS_l(:,7).*TS_l(:,10)./TS_l(:,9);            %��·���
C=TS_l(:,8)./TS_l(:,10).*TS_l(:,9);            %��·�Եص���
Yb=1./(R+1j*X);                                %֧·����
for i=1:n
    for j=1:l
        A(i,j)=0;
        if TS_l(j,2)==i                        
            A(i,j)=1;                          %���ɹ�������
        end
        if TS_l(j,4)==i
            A(i,j)=-1;
        end
    end
end
cut_n=find(sum(abs(A),2)==0);
A(cut_n,:)=[];                                 %�г������ڵ�
TS_n(cut_n,:)=[];                  
n=size(TS_n,1);                                %�����ڵ���
Yn=A*diag(Yb)*A';                              %����ڵ㵼�ɾ���
Yn=Yn-diag(1j*abs(A)*C);                       %����Եص���
Zn=inv(Yn);                                    %����ڵ��迹����

% -------------- matpower���ݱ�case_GD���ɲ����㳱��--------------
mpc.baseMVA=1000;                              %system MVA base
mpc.bus=[[1:n]',TS_n(:,15),TS_n(:,7:8),TS_n(:,11:12),ones(n,1)*[1,1,0,525,1,1.05,0.95]]; %bus data
N_G=find(TS_n(:,15)~=1);
n_G=size(N_G,1);
QG_max=max(abs(TS_n(N_G,10))*1.5,20);
QG_min=-QG_max;
PG_max=max(abs(TS_n(N_G,9))*1.5,200);
mpc.gen=[N_G,TS_n(N_G,9:10),QG_max,QG_min,ones(n_G,1),sqrt(PG_max.^2+QG_max.^2),ones(n_G,1),PG_max,zeros(n_G,12)]; %generator data
mpc.branch=[TS_l(:,2),TS_l(:,4),TS_l(:,6:8),1.575*(TS_l(:,14).*TS_l(:,9))*ones(1,3),ones(l,1)*[0,0,1,-360,360]];  %branch data
GD=runpf(mpc);

% ---------------- ��������ָ����� ----------------
W=1./abs(Yn);
W=W-diag(diag(W));
Index_1=zeros(n);
for i=1:n
    for j=i+1:n
        path=[];
        [ Index_1(i,j),~ ] = Dijkstra( W,TS_n(:,1),i,j );
        Index_1(j,i)=Index_1(i,j);
    end
end

% ---------------- ����������ָ����� ----------------
numda=real(diag(Yb)*A'*Zn);
U=GD.bus(:,8);
RA=GD.bus(:,9)*0.0175;
for i=1:n
    for j=1:l
        uu=(U(find(TS_n(:,1)==TS_l(j,2)))+U(find(TS_n(:,1)==TS_l(j,4))))/2;
        radio=(RA(find(TS_n(:,1)==TS_l(j,2)))+RA(find(TS_n(:,1)==TS_l(j,4))))/2;
        beta(j,i)=numda(j,i)*uu/U(i)*cos(radio-RA(i));      %���������Ⱦ���
    end
end
F=(abs(GD.branch(:,14))+abs(GD.branch(:,16)))/2;            %��·����
Index_2=1000./abs(beta'*beta);              
Index_2=(Index_2-diag(diag(Index_2)))/1000;

% ---------------- ���ϵͳ�ڵ���� --------------
Index=20*Index_1+5*Index_2;
K=0.28;
Aa=DP_Cluster( Index,K );                                   %ͨ���Զ���DP_Cluster�Ӻ�������          

% ---------------- ���ϵͳ�������� --------------
N_cate=max(Aa(:,2));                                        %�������
n_c=zeros(N_cate,1);                                        %�����ڵ���
l_c=zeros(N_cate,1);                                        %������·��
LL=[];  
for i=1:N_cate 
    L_c=[];
    for j=1:n
        if Aa(j,2)==i
            n_c(i)=n_c(i)+1;
            L_c(n_c(i))=find(TS_n(:,1)==Aa(j,1));
        end
    end
    EZ_n(1:n_c(i),1:nn,i)=TS_n(L_c,:);                      %�����ڵ���Ϣ
    ez_n=EZ_n(:,1,i);
    for j=1:n_c(i)
        for k=1:l
            if (TS_l(k,2)==L_c(j) && ~isempty(find(ez_n==TS_l(k,4))))|| ...
                    (TS_l(k,4)==L_c(j) && ~isempty(find(ez_n==TS_l(k,2))))   %�ҳ�����������·
                l_c(i)=l_c(i)+1;
                L_l(i,l_c(i))=k;
                ez_n(find(ez_n==L_c(j)))=[];
            end
        end
    end
    l_l=L_l(i,find(L_l(i,:)~=0));
    EZ_l(1:l_c(i),1:ll,i)=TS_l(l_l,:);                     %������·��Ϣ
    LL=[LL,l_l];                                           %ѡ����·���
end 
TL=TS_l;
TL(LL,:)=[];                                               %������������
csvwrite('./resource/connect.csv',TL);
% % -------------- �������ϵͳ������� -------------- 
% figure 
% fnshp_P='china_basic_map\bou2_4p.shp';                     %ShapeType: 'Polygon'   
% infoP = shapeinfo(fnshp_P);    
% readP=shaperead(fnshp_P);
% mapshow(fnshp_P);
% hold on
% axis([109 119 18 27])
% for i=1:size(TL,1)
%     st=find(TS_n(:,1)==TL(i,2));
%     en=find(TS_n(:,1)==TL(i,4));
%     plot([TS_n(st,13);TS_n(en,13)],[TS_n(st,14);TS_n(en,14)],'r:','linewidth',4);
% end
% color={'r','b','g','m','c','k','w','y','r','b','g','m','c','k','w','y'};
% for i=1:N_cate
%     for j=1:l_c(i)
%         st=find(EZ_n(:,1,i)==EZ_l(j,2,i));
%         en=find(EZ_n(:,1,i)==EZ_l(j,4,i));
%         plot([EZ_n(st,13,i);EZ_n(en,13,i)],[EZ_n(st,14,i);EZ_n(en,14,i)],color{i},'linewidth',2);
%     end
%     for j=1:n_c(i)
%         plot(EZ_n(j,13,i),EZ_n(j,14,i),'ko','MarkerFaceColor',color{i},'MarkerSize',8);
%     end
% end

% -------------- ���������� -------------- 
 for i=1:N_cate
     point = ['./resource/sectionPoint',num2str(i),'.csv'];
     line = ['./resource/sectionLine',num2str(i),'.csv'];
     csvwrite(point,EZ_n(1:n_c(i),:,i));
     csvwrite(line,EZ_l(1:l_c(i),:,i));
 end


%% ============== Section Identification ==============
for i=1:N_cate
    BETA=abs(beta);
    Cp=[];
    % -------------- ������·ʶ�� -------------- 
    EZl=EZ_l(1:l_c(i),:,i);
    st=EZl(:,2);
    en=EZl(:,4);
    l_l=LL(1+sum(l_c(1:i-1)):l_c(i)+sum(l_c(1:i-1)));          %��������·���
    M=1-0.5*(abs(GD.branch(l_l,14))+abs(GD.branch(l_l,16)))./GD.branch(l_l,6); %��������·��ȫԣ��
    LM=find(M==min(M));                                        %��Σ����·
    J=1;
    if BETA(l_l(LM),st(LM))>BETA(l_l(LM),en(LM));
        Cp(J)=st(LM);                                          %�ҳ����
    else 
        Cp(J)=en(LM);
    end 
    BETA(l_l(LM),st(LM))=0;
    BETA(l_l(LM),en(LM))=0;
    for j=1:n_c(i)-1 
        Sgn=[];
        nod=[];
        branch=[];
        for k=1:J
            bra=[find(EZl(:,2)==Cp(k))];
            branch=[branch;bra];
            nod=[nod;EZl(bra,4)];
            bra=[find(EZl(:,4)==Cp(k))];
            branch=[branch;bra];
            nod=[nod;EZl(bra,2)];
            Sgn=[Sgn;sign([GD.branch(find(EZl(:,2)==Cp(k)),14);GD.branch(find(EZl(:,4)==Cp(k)),16)])]; 
        end
        if size(Sgn,1)==abs(sum(Sgn)) && size(Sgn,1)>1           %�ж���·���������Ƿ�һ�£�������ֵ���֦�
           break;
        else
            J=J+1;
            UJ=BETA(l_l(LM),nod);
            ED=find(UJ==max(UJ));
            Cp(J)=nod(ED(1));
            JU=size(EZl,1);
            Mm=0;
            YU=[];
            for k=1:JU
                if (1-isempty(find(Cp==EZl(k,2)))) && (1-isempty(find(Cp==EZl(k,4))))     %�г���㼯�ڲ�����
                    Mm=Mm+1;
                    YU(Mm)=k;
                end
            end
            EZl(YU,:)=[];
        end
    end
    
    Id_n(i,1:2)=[length(Cp),length(nod)];
    CP(1:Id_n(i,1),i)=Cp;
    if isempty(EZl)
        Id_n(i,1)=0;
        Ident(1:Id_n(i,2),1:ll,i)=zeros(Id_n(i,2),ll);
    else
        Ident(1:Id_n(i,2),1:ll,i)=EZl(branch,:);                             %��¼������������
    end
end
% -------------- ���ڶ������ -------------- 
 for i=1:N_cate
     line = ['./resource/Ident',num2str(i),'.csv'];
     csvwrite(line,Ident(1:Id_n(i,2),1:ll,i));
 end
% % ------------------- ���������� ------------------- 
% figure 
% fnshp_P='china_basic_map\bou2_4p.shp';                                       %ShapeType: 'Polygon'   
% infoP = shapeinfo(fnshp_P);    
% readP=shaperead(fnshp_P);
% mapshow(fnshp_P);
% hold on
% axis([109 119 18 27])
% color={'r','b','g','m','c','k','w','y','r','b','g','m','c','k','w','y'};
% for i=1:N_cate
%     for j=1:l_c(i)
%         st=find(EZ_n(:,1,i)==EZ_l(j,2,i));
%         en=find(EZ_n(:,1,i)==EZ_l(j,4,i));
%         plot([EZ_n(st,13,i);EZ_n(en,13,i)],[EZ_n(st,14,i);EZ_n(en,14,i)],'k','linewidth',2);
%     end
%     for j=1:Id_n(i,2)
%         st=find(EZ_n(:,1,i)==Ident(j,2,i));
%         en=find(EZ_n(:,1,i)==Ident(j,4,i));
%         plot([EZ_n(st,13,i);EZ_n(en,13,i)],[EZ_n(st,14,i);EZ_n(en,14,i)],'y','linewidth',2);
%         plot([EZ_n(st,13,i);EZ_n(en,13,i)],[EZ_n(st,14,i);EZ_n(en,14,i)],color{i},'linewidth',4);
%     end
%     for j=1:n_c(i)
%         plot(EZ_n(j,13,i),EZ_n(j,14,i),'ko','MarkerFaceColor','r','MarkerSize',8);
%     end
%     for j=1:Id_n(i,1)
%         plot(TS_n(CP(j,i),13),TS_n(CP(j,i),14),'kh','MarkerFaceColor','g','MarkerSize',10);
%     end
% end


