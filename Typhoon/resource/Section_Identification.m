%%%%%%%%%%%%%%%%%%%%%%%% Section Identification %%%%%%%%%%%%%%%%%%%%%%%%
function Section_Identification()
tic;                            %开始计时

%% ============== Initial Partition ==============
% ---------------- 输电系统参数计算 ----------------
TS_n=xlsread('Typhoon.xls','节点');
TS_l=xlsread('Typhoon.xls','线路');
[n,nn]=size(TS_n);                                %故障后节点数
[l,ll]=size(TS_l);                                %故障后线路数
 
R=TS_l(:,6).*TS_l(:,10)./TS_l(:,9);            %线路电阻
X=TS_l(:,7).*TS_l(:,10)./TS_l(:,9);            %线路电感
C=TS_l(:,8)./TS_l(:,10).*TS_l(:,9);            %线路对地电容
Yb=1./(R+1j*X);                                %支路导纳
for i=1:n
    for j=1:l
        if TS_l(j,2)==i                        
            A(i,j)=1;                          %生成关联矩阵
        end
        if TS_l(j,4)==i
            A(i,j)=-1;
        end
    end
end
cut_n=find(sum(abs(A),2)==0);
A(cut_n)=[];                                   %切除孤立节点
TS_n(cut_n,:)=[];                  
n=size(TS_n,1);                                %修正节点数
Yn=A*diag(Yb)*A';                              %计算节点导纳矩阵
Yn=Yn-diag(1j*abs(A)*C);                       %加入对地导纳
Zn=inv(Yn);                                    %加入节点阻抗矩阵

% -------------- matpower数据表case_GD生成并计算潮流--------------
mpc.baseMVA=1000;                               %system MVA base
mpc.bus=[[1:n]',TS_n(:,15),TS_n(:,7:8),TS_n(:,11:12),ones(n,1)*[1,1,0,525,1,1.05,0.95]]; %bus data
N_G=find(TS_n(:,15)~=1);
n_G=size(N_G,1);
QG_max=max(abs(TS_n(N_G,10))*1.5,20);
QG_min=-QG_max;
PG_max=max(abs(TS_n(N_G,9))*1.5,200);
mpc.gen=[N_G,TS_n(N_G,9:10),QG_max,QG_min,ones(n_G,1),sqrt(PG_max.^2+QG_max.^2),ones(n_G,1),PG_max,zeros(n_G,12)]; %generator data
mpc.branch=[TS_l(:,2),TS_l(:,4),TS_l(:,6:8),1.575*(TS_l(:,14).*TS_l(:,9))*ones(1,3),ones(l,1)*[0,0,1,-360,360]];  %branch data
GD=runpf(mpc);

% ---------------- 电气距离指标计算 ----------------
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

% ---------------- 功率灵敏度指标计算 ----------------
numda=real(diag(Yb)*A'*Zn);
U=GD.bus(:,8);
RA=GD.bus(:,9)*0.0175;
for i=1:n
    for j=1:l
        uu=(U(find(TS_n(:,1)==TS_l(j,2)))+U(find(TS_n(:,1)==TS_l(j,4))))/2;
        radio=(RA(find(TS_n(:,1)==TS_l(j,2)))+RA(find(TS_n(:,1)==TS_l(j,4))))/2;
        beta(j,i)=numda(j,i)*uu/U(i)*cos(radio-RA(i));      %功率灵敏度矩阵
    end
end
F=(abs(GD.branch(:,14))+abs(GD.branch(:,16)))/2;            %线路潮流
Index_2=1000./abs(beta'*diag(F)*beta);              
Index_2=Index_2-diag(diag(Index_2));

% ---------------- 输电系统节点聚类 --------------
Index=20*Index_1+5*Index_2;
K=0.55;
Aa=DP_Cluster( Index,K );                                   %通过自定义DP_Cluster子函数聚类          

% ---------------- 输电系统参数分区 --------------
N_cate=max(Aa(:,2));                                        %分区类别
n_c=zeros(N_cate,1);                                        %各区节点数
l_c=zeros(N_cate,1);                                        %各区线路数
LL=[];  
for i=1:N_cate 
    L_c=[];
    for j=1:n
        if Aa(j,2)==i
            n_c(i)=n_c(i)+1;
            L_c(n_c(i))=find(TS_n(:,1)==Aa(j,1));
        end
    end
    EZ_n(1:n_c(i),1:nn,i)=TS_n(L_c,:);                      %各区节点信息
    ez_n=EZ_n(:,1,i);
    for j=1:n_c(i)
        for k=1:l
            if (TS_l(k,2)==L_c(j) && ~isempty(find(ez_n==TS_l(k,4))))|| ...
                    (TS_l(k,4)==L_c(j) && ~isempty(find(ez_n==TS_l(k,2))))   %找出各区域内线路
                l_c(i)=l_c(i)+1;
                L_l(i,l_c(i))=k;
                ez_n(find(ez_n==L_c(j)))=[];
            end
        end
    end
    l_l=L_l(i,find(L_l(i,:)~=0));
    EZ_l(1:l_c(i),1:ll,i)=TS_l(l_l,:);                     %各区线路信息
    LL=[LL,l_l];                                           %选中线路标记
end 
TL=TS_l;
TL(LL,:)=[];                                               %各区域联络线

% -------------- 绘制输电系统分区结果 -------------- 
%figure 
fnshp_P='china_basic_map\bou2_4p.shp';%ShapeType: 'Polygon'   
infoP = shapeinfo(fnshp_P);    
readP=shaperead(fnshp_P);
mapshow(fnshp_P);
hold on
axis([109 119 18 27])
for i=1:size(TL,1)
    st=find(TS_n(:,1)==TL(i,2));
    en=find(TS_n(:,1)==TL(i,4));
    %plot([TS_n(st,13);TS_n(en,13)],[TS_n(st,14);TS_n(en,14)],'r:','linewidth',4);
end
color={'r','b','g','m','c','k','w','y'};
for i=1:N_cate
    for j=1:l_c(i)
        st=find(EZ_n(:,1,i)==EZ_l(j,2,i));
        en=find(EZ_n(:,1,i)==EZ_l(j,4,i));
        %plot([EZ_n(st,13,i);EZ_n(en,13,i)],[EZ_n(st,14,i);EZ_n(en,14,i)],color{i},'linewidth',2);
    end
    for j=1:n_c(i)
        %plot(EZ_n(j,13,i),EZ_n(j,14,i),'ko','MarkerFaceColor',color{i},'MarkerSize',8);
    end
end

% -------------- 分区结果输出 -------------- 
 for i=1:N_cate
     % xlswrite('./resource/Section',EZ_n(1:n_c(i),:,i),['节点_',num2str(i)])
     % xlswrite('./resource/Section',EZ_l(1:l_c(i),:,i),['线路_',num2str(i)])
     point = ['./resource/sectionPoint',num2str(i),'.csv'];
     line = ['./resource/sectionLine',num2str(i),'.csv'];
     csvwrite(point,EZ_n(1:n_c(i),:,i));
     csvwrite(line,EZ_l(1:l_c(i),:,i));
 end

%% ============== Section Identification ==============
for i=1:N_cate
    BETA=abs(beta);
    Cp=[];
    % -------------- 重载线路识别 -------------- 
    EZl=EZ_l(1:l_c(i),:,i);
    st=EZl(:,2);
    en=EZl(:,4);
    l_l=LL(1+sum(l_c(1:i-1)):l_c(i)+sum(l_c(1:i-1)));          %各区域线路编号
    M=1-0.5*(abs(GD.branch(l_l,14))+abs(GD.branch(l_l,16)))./GD.branch(l_l,6); %各区域线路安全裕度
    LM=find(M==min(M));                                        %最危险线路
    J=1;
    if BETA(l_l(LM),st(LM))>BETA(l_l(LM),en(LM));
        Cp(J)=st(LM);                                          %找出割点
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
        if size(Sgn,1)==abs(sum(Sgn)) && size(Sgn,1)>1           %判断线路潮流方向是否一致，避免出现单树枝割集
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
                if (1-isempty(find(Cp==EZl(k,2)))) && (1-isempty(find(Cp==EZl(k,4))))     %切除割点集内部连线
                    Mm=Mm+1;
                    YU(Mm)=k;
                end
            end
            EZl(YU,:)=[];
        end
    end
    
    Id_n(i,1:2)=[length(Cp),length(nod)];
    CP(1:Id_n(i,1),i)=Cp;
    Ident(1:Id_n(i,2),1:ll,i)=EZl(branch,:);                             %记录各分区输电断面
end

% ------------------- 绘制输电断面 ------------------- 
%figure 
fnshp_P='china_basic_map\bou2_4p.shp';%ShapeType: 'Polygon'   
infoP = shapeinfo(fnshp_P);    
readP=shaperead(fnshp_P);
mapshow(fnshp_P);
hold on
axis([109 119 18 27])
color={'r','b','g','m','c','k','w','y'};
for i=1:N_cate
    for j=1:l_c(i)
        st=find(EZ_n(:,1,i)==EZ_l(j,2,i));
        en=find(EZ_n(:,1,i)==EZ_l(j,4,i));
        %plot([EZ_n(st,13,i);EZ_n(en,13,i)],[EZ_n(st,14,i);EZ_n(en,14,i)],'k','linewidth',2);
    end
    for j=1:Id_n(i,2)
        st=find(EZ_n(:,1,i)==Ident(j,2,i));
        en=find(EZ_n(:,1,i)==Ident(j,4,i));
        %plot([EZ_n(st,13,i);EZ_n(en,13,i)],[EZ_n(st,14,i);EZ_n(en,14,i)],'y','linewidth',2);
        %plot([EZ_n(st,13,i);EZ_n(en,13,i)],[EZ_n(st,14,i);EZ_n(en,14,i)],color{i},'linewidth',4);
    end
    for j=1:n_c(i)
        %plot(EZ_n(j,13,i),EZ_n(j,14,i),'ko','MarkerFaceColor','r','MarkerSize',8);
    end
    for j=1:Id_n(i,1)
        %plot(TS_n(CP(j,i),13),TS_n(CP(j,i),14),'kh','MarkerFaceColor','g','MarkerSize',10);
    end
end

toc; 
end%停止计时

