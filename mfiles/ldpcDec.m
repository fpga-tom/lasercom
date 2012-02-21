function [dec]=ldpcDec(H,codeword)
[n,m]=size(H);
I=10;        

[i,j,s]=find(H);
[q,w]=size(H);
% Lq=zeros(n,m);
 LQ=zeros(1,m);
% Lr=zeros(n,m);
Lq=sparse(i,j,s,q,w).*repmat(codeword,n,1);

% Lr=sparse(i,j,s,q,w);
LC=zeros(1,n);
for l=1:I
    
    for v=1:m
        
        ci=find(H(:,v))';
        Lr=xor(LC,Lq(:,v)');
        
        for c=1:length(ci)
            b=getB(H,ci(c),v,.1,.1);
%             pause
            if nnz(Lr(setdiff(ci,ci(c)))-codeword(v).*ones(1,length(ci)-1))>=b
                Lq(ci(c),v)=not(codeword(v));
            else
                Lq(ci(c),v)=codeword(v);
            end
            LC(ci(c))=xor(LC(ci(c)),Lq(ci(c),v));
        end
%         full(Lq)
%         pause

    end
end
for v=1:m
    ci=find(H(:,v))';
        Lr=xor(LC,Lq(:,v)');
        LQ(v)=mod(sum(Lr(ci)),2);
end
dec=LQ;

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