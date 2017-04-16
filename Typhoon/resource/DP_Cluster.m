function [ Aa ] = DP_Cluster( dist,K )
%自定义聚类子函数
ND=size(dist,1);
percent=2.0;                 %average percentage of neighbours (hard coded)
position=round(ND*(ND-1)*percent/100);
SD=reshape(dist,1,ND^2);
SD(find(SD==0))=[];
sda=sort(SD);
dc=sda(position);            %Computing Rho with gaussian kernel of radius
rho=zeros(1,ND);

% Gaussian kernel
for i=1:ND-1
  for j=i+1:ND
     rho(i)=rho(i)+exp(-(dist(i,j)/dc)^2);
     rho(j)=rho(j)+exp(-(dist(i,j)/dc)^2);
  end
end
maxd=max(max(dist));

[~,ordrho]=sort(rho,'descend');
delta(ordrho(1))=-1.;
nneigh(ordrho(1))=0;

for i=2:ND
   delta(ordrho(i))=maxd;
   for j=1:i-1
     if(dist(ordrho(i),ordrho(j))<delta(ordrho(i)))
        delta(ordrho(i))=dist(ordrho(i),ordrho(j));
        nneigh(ordrho(i))=ordrho(j);
     end
   end
end
delta(ordrho(1))=max(delta(:));

%Select a rectangle enclosing cluster centers'
NCLUST=0;
cl=-1*ones(1,ND);
rhomax=max(rho);
deltamax=max(delta);
for i=1:ND
  if (rho(i)/rhomax>K && delta(i)/deltamax>K)
     NCLUST=NCLUST+1;                %NUMBER OF CLUSTERS
     cl(i)=NCLUST;
  end
end

%Performing assignation
for i=1:ND
  if (cl(ordrho(i))==-1)
    cl(ordrho(i))=cl(nneigh(ordrho(i)));
  end
end

%halo
halo=cl;
if (NCLUST>1)
    bord_rho=zeros(1,NCLUST);
  for i=1:ND-1
    for j=i+1:ND
      if ((cl(i)~=cl(j))&& (dist(i,j)<=dc))
        rho_aver=(rho(i)+rho(j))/2.;
        if (rho_aver>bord_rho(cl(i))) 
          bord_rho(cl(i))=rho_aver;
        end
        if (rho_aver>bord_rho(cl(j))) 
          bord_rho(cl(j))=rho_aver;
        end
      end
    end
  end
  for i=1:ND                        %CLUSTER
    if (rho(i)<bord_rho(cl(i)))
      halo(i)=0;
    end
  end
end

%Performing 2D nonclassical multidimensional scaling
Aa=zeros(ND,2);
nn=0;
for i=1:NCLUST
  for j=1:ND
    if (halo(j)==i)
      nn=nn+1;
      Aa(nn,1:2)=[j,halo(j)];
    end
  end
end

end
