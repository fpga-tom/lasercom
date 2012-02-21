function [dec]=ldpcDec4(H,codeword,p0,p)
[n,m]=size(H);
I=5;        

[i,j,s]=find(H);
[q,w]=size(H);
% Lq=zeros(n,m);
LQ=codeword;
% Lr=zeros(n,m);
% Lq=sparse(i,j,zeros(1,length(i)),q,w);
Lr=sparse(i,j,zeros(1,length(i)),q,w);
% LC=zeros(1,n);

        
        for l=1:I
            for c=1:n
                
                
                vi=find(H(c,:))';
                Lq=LQ(vi)-Lr(c,vi);
                lqtmp=Lq;
                for idx=1:length(vi)
                    v=vi(idx);
                    b=getB(H,c,v,p0,p);
                    if -codeword(v)*Lq(idx)>=b
                      Lq(idx)=-codeword(v);
                    else
                      Lq(idx)=codeword(v);
                    end
                end
                
                tmp=prod(Lq);
                for idx=1:length(vi)
                    v=vi(idx);
                    Lr(c,v)=tmp*Lq(idx);                                                                      
%                     LQ(v)=LQ(v)+Lr(c,v);
                    LQ(v)=lqtmp(idx)+Lr(c,v);
                end
            end
            
%             for v=1:m
%                 ci=find(H(:,v))';
%                 LQ(v)=mod(sum(Lr(ci,v)),2);
%                 for idx=1:length(ci)
%                     c=ci(idx);
%                     b=getB(H,c,v,.1,.1);
%                     LQ(v)=sum
%                     if nnz(Lr(ci,v)-codeword(v).*ones(length(ci),1))>=b
%                         LQ(v)=not(codeword(v));
%                     else
%                         LQ(v)=codeword(v);
%                     end
%                 end
%             end
            
            
        end
        dec=LQ;
        dec(find(LQ>=0))=0;
        dec(find(LQ<0))=1;
end

function [b]=getB(pcm,c,v,p0,p)
left=(1-p0)/p0;
dc=sum(pcm(c,:));
dv=sum(pcm(:,v));
dv=full(dv(1,1));
dc=full(dc(1,1));
min=ceil((dv-1)/2);
max=dv;
b=max;
for i=min:max
    t=(1-2*p)^(dc-1);
    right=((1+t)/(1-t))^(2*i-dv+1);
    if left<=right
        b=i;
        break;
    end
end
end