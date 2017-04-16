function [ Tbest,Epbest ] = fuzzycluster( NB,P,e )
%transmission sections : fuzzy cluster;
T = 2;%分类数；初始分类数为2；
Tmax = ceil(sqrt(NB)) - 1;%最大分类数；
[L,N] = size(P);
s = zeros(NB,1);
 for j = 1 : L
     for i = 1 : N
      s(j) = s(j) + P(j,i);
     end
 end
smax = max(s);
smin = min(s);
while T < Tmax
%计算当前聚类中心；
alpha = zeros(NB,1);%线路归一化模糊值；
for j = 1 : NB
    alpha(j) = (T-1)*(s(j)-smin)/(smax-smin) + 1;
end
%聚类，并计算初始聚类中心；
c = zeros(T,1);
Nt = zeros(T,1);
for j = 1 : NB
    if ceil(alpha(j))-alpha(j) <= 0.5
        c(ceil(ahpha(j))) = c(ceil(ahpha(j))) + s(j);
        Nt(ceil(ahpha(j))) = Nt(ceil(ahpha(j))) + 1;
    else
        c(ceil(ahpha(j))-1) = c(ceil(ahpha(j)-1)) + s(j);
        Nt(ceil(ahpha(j))-1) = Nt(ceil(ahpha(j))-1) + 1;
    end
end
c = c ./ Nt;
%计算隶属度；
U = zeros(NB,T);%隶属度矩阵；
m = 2;
for j = 1 : NB
    for t = 1 : T
        a = 0;
        for r = 1 : T
            a = a + (norm(s(j)-c(t))/norm(s(j)-c(r))) ^ (2/(m-1));
        end
        U(j,t) = 1 / a;
    end
end
c0 = c;
ca = 0;
cb = 0;
for j = 1 : NB
    ca = ca + (U(j,t)^m)*s(j);
    cb = cb + U(j,t)^m;
end
c = ca / cb;
%更新聚类中心；
while abs(c(:)-c0(:)) >= e %e为阈值；
    for j = 1 : NB
    for t = 1 : T
        a = 0;
        for r = 1 : T
            a = a + (norm(s(j)-c(t))/norm(s(j)-c(r))) ^ (2/(m-1));
        end
        U(j,t) = 1 / a;
    end
    end
    c0 = c;
    ca = 0;
    cb = 0;
    for j = 1 : NB
       ca = ca + (U(j,t)^m)*s(j);
       cb = cb + U(j,t)^m;
    end
    c = ca / cb;
end
%计算划分熵指数；
Ep = 0;
for j = 1 : NB
    for t = 1 : T
        Ep = Ep + U(j,t)*log(U(j,t));
    end
end
Ep = (-Ep)/NB;
Eprem(T) = Ep;
    
 T = T + 1;   
end
%计算曲率，找到最佳分类；
K = zeros(Tmax,1);
for i = 1 : Tmax
    K(i) = abs(Eprem(i))/((1+Eprem(i)^2)^1.5);
end
Kmax = max(K);
Tbest = find(K==Kmax);
Epbest = Eprem(Tbest);

end

