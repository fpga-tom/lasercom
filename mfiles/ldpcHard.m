function [dec]=ldpcHard(pcm,codeword)
[n,m]=size(pcm);
I=5;        
H=pcm;
[i,j,s]=find(H);
[q,w]=size(H);
% Lq=zeros(n,m);
% LQ=zeros(1,m);
% Lr=zeros(n,m);
Lq=sparse(i,j,s,q,w);
Lr=sparse(i,j,s,q,w);

for l=1:I

    for i=1:m
        if mod(i,500)==0
            fprintf('iteration %d, col %d\n', l,i);
        end

        for j=find(H(:,i))'
            if H(j,i) == 1
                if l~=1
                    s=setdiff(find(H(:,i))',j);
                    b=getB(pcm,j,i,.3,.3);
                    if nnz(Lr(s,i)-codeword(i).*ones(length(s),1))>=b
                        Lq(j,i)=-codeword(i);
                    else
                        Lq(j,i)=codeword(i);
                    end
%                     degree=length(find(H(:,i)));

%                     mk=-codeword(i)*sum(Lr(s,i));
%                     bj=length(s)-nnz(Lr(s,i)-thi.*ones(length(s),1));
%                     dl=2*bj-(degree-1);
%                     if mk>=dl
%                         Lq(j,i)=-codeword(i);
%                     else
%                         Lq(j,i)=codeword(i);
%                     end
                else
                    
                    Lq(j,i)=codeword(i);
                end
            end
        end
    end

%     l
%     full(Lq)
%     codeword
%     pause;
    for j=1:n
        if mod(j,500)==0
            fprintf('iteration %d, row %d\n', l, j);
        end

        pom=1;
        for i=find(H(j,:))
%             pom=1;
%             for r=find(H(j,:))
%                 if H(j,r)==1 && r~=i
                    Lb=Lq(j,i);
                    pom=pom*Lb;
%                 end
%             end
%             if H(j,i)==1
%                 Lr(j,i)=pom;
%             end
        end
        
        for i=find(H(j,:))
            if H(j,i) == 1
                Lr(j,i)=pom*Lq(j,i);
            end
        end
    end     
%     full(Lr)
%     pause;
end
% Lr
dec=full(sum(Lr));
tmp=dec;
dec(find(tmp>0))=0;
dec(find(tmp<0))=1;
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

