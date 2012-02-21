function [dec]=ldpcDec2(H,codeword,p0,p)
[n,m]=size(H);
I=20;        

[i,j,s]=find(H);
[q,w]=size(H);
% Lq=zeros(n,m);

% Lr=zeros(n,m);
Lq=sparse(i,j,zeros(1,length(i)),q,w).*repmat(codeword, q,1);
Lr=sparse(i,j,zeros(1,length(i)),q,w);
% LC=zeros(1,n);

        
        for l=1:I
            for c=1:n
                
                
                vi=find(H(c,:))';
%                 Lq=LQ(vi)-Lr(c,vi);
if l~=1
                for idx=1:length(vi)
                    v=vi(idx);
                    b=getB(H,c,v,p0,p);
                    ci=find(H(:,v));
                    if nnz(Lr(setdiff(ci,c),v)-codeword(v).*ones(length(ci)-1,1))>=b
                      Lq(c,v)=not(codeword(v));
                    else
                      Lq(c,v)=codeword(v);
                    end
                end
end
                
                tmp=mod(sum(Lq(c,vi)),2);
                for idx=1:length(vi)
                    v=vi(idx);
                    Lr(c,v)=xor(tmp,Lq(c,v));                                                                      
                    
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
        
        for v=1:m
            ci=find(H(:,v));
%             full(Lr)
            Lr(ci(find(Lr(ci,v)==0)),v)=-1;
%             full(Lr)
%             pause
        end
        LQ=sum(Lr);
        
        dec=LQ;
        dec(find(LQ<0))=0;
        dec(find(LQ>=0))=1;
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