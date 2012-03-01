function [s]=sched(szPop,Hc,pCross,pMut)
[n,m]=size(Hc);
len=11;
CD=8;
IDX=9;
ERR=10;
FIT=11;
LAT=10;
elitism=5;
pop=zeros(n,len,szPop);
mtmp=zeros(n,len);
for i=1:n
    vi=find(Hc(i,:)~=-1);
    mtmp(i,1:length(vi))=vi;
    mtmp(i,CD)=length(vi);
    mtmp(i,IDX)=i;
end
mtmp=fitness(mtmp,CD,ERR,FIT,LAT);
for io=1:szPop
    ip=1:12;
    for i=1:length(ip)-1
        i1=randi(length(ip)+1-i,1,1)-1;
        ip([i (i+i1)])=ip([(i+i1) i]);
    end
    g=fitness(mtmp([ip],:),CD,ERR,FIT,LAT);
    pop(:,:,io)=g;
end

matlabpool('open',4);
[f,e,pop]=minErr(pop,FIT,ERR);
iter=1;
eo=0;
while e~=0
    if e~=eo
        fprintf('iter %d %d\n',iter,e);
        pop(:,:,1)
        eo=e;
    end
    iter=iter+1;
    tmpPop=zeros(n,len,szPop);
    parfor i=1:szPop-elitism
        [g1,g2]=select(pop,f,FIT);
        g=mutate(crossover(g1,g2,pCross,IDX),pMut,CD);
        g=fitness(g,CD,ERR,FIT,LAT);
        tmpPop(:,:,i)=g;
    end
    for i=1:elitism
        tmpPop(:,:,i+szPop-elitism)=pop(:,:,i);
    end
    [f,e,pop]=minErr(tmpPop,FIT,ERR);
end
matlabpool('close');
pop(:,:,1)
end

function [g1,g2]=select(pop,f,FIT)
sum=0;
g=zeros(1,2);
for i=1:2
    r=rand(1)*f;
    idx=1;
    sum=pop(1,FIT,idx);
    while sum<r
        idx=idx+1;
        sum=sum+pop(1,FIT,idx);
    end
    g(i)=idx;    
end
g1=pop(:,:,g(1));
g2=pop(:,:,g(2));
end

function [g]=crossover(g1,g2,p,IDX)
[n,m]=size(g1);
g=g1;
if rand(1)<p
    g=zeros(n,m);
    cp=randi(n-1,1);
    g(1:cp,:)=g1(1:cp,:);    
    d=setdiff(g2(:,IDX),g1(1:cp,IDX));
    loc=find(ismember(g2(:,IDX),d));
    g((cp+1):n,:)=g2(loc,:);
end
if length(unique(g(:,IDX)))~=12
    g1(1:cp,IDX)
    g2(:,IDX)
    setdiff(g2(:,IDX),g1(1:cp,IDX))
    g(:,IDX)
    pause
end
end

function [g]=mutate(gi,p,CD)
g=gi;
if rand(1)<p
    [n,m]=size(g);
    idx=randi(n,1,2);
    while idx(1)==idx(2)
        idx=randi(n,1,2);
    end
    g([idx(1) idx(2)],:)=g([idx(2) idx(1)],:);
    ix=randi(g(idx(1),CD),1,2);
    while ix(1)==ix(2)
        ix=randi(g(idx(1),CD),1,2);
    end
    g(idx(1),[ix(1) ix(2)])=g(idx(1),[ix(2) ix(1)]);
    
    ix=randi(g(idx(2),CD),1,2);
    while ix(1)==ix(2)
        ix=randi(g(idx(2),CD),1,2);
    end
    g(idx(2),[ix(1) ix(2)])=g(idx(2),[ix(2) ix(1)]);
end
end

function [go]=fitness(g,CD,ERR,FIT,LAT)
lin=zeros(1,77);
idx=1;
[n,m]=size(g);
for i=1:12
    for j=1:g(i,CD)
        lin(idx)=g(i,j);
        idx=idx+1;
    end
end
e=0;
a=zeros(24,13);
for idx=1:77
    a(lin(idx),13)=a(lin(idx),13)+1;
    a(lin(idx),a(lin(idx),13))=idx;
end
for i=1:24
    for j=1:a(i,13)-1
        if a(i,j)+LAT>=a(i,j+1)
%             i
%             j
%             a
%             pause
            e=e+1;
        end
    end
    if a(i,a(i,13))+LAT>=a(i,1)+77
        e=e+1;
    end
end
g(:,ERR)=e*ones(n,1);
if e==0
    e=1;
end
g(:,FIT)=(1/e)*ones(n,1);
go=g;
end

function [f,e,pop]=minErr(tmpPop,FIT,ERR)
f=0;
e=inf;
% l=length(tmpPop(1,ERR,:))/4;
% bees=[];
% ixes=[];
% parfor i=1:4
%     vi=((i-1)*l+1):(i*l);
%     [b,ix]=sort(tmpPop(1,ERR,vi));
%     bees=[bees b];
%     ixes=[ixes ix];
% end
% [b,ix]=sort(bees(1:l:end));
% ix=(ix-1)*l+1;
% tmp=[];
% for w=ix(1:end)
%     tmp=[tmp w:(w+l-1)];
% end
% pop=tmpPop(:,:,ixes(tmp));
[b,ix]=sort(tmpPop(1,ERR,:));
pop=tmpPop(:,:,ix);
e=pop(1,ERR,1);
f=sum(pop(1,FIT,:));
end