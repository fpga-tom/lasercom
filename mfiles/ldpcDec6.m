function [dec]=ldpcDec6(H,codeword,p0,p)
[n,m]=size(H);
I=5;        

[i,j,s]=find(H);
[q,w]=size(H);
% Lq=zeros(n,m);
LQ=codeword;
% Lr=zeros(n,m);
% Lq=sparse(i,j,zeros(1,length(i)),q,w);
mmu=[     1     2     6     9    13    14    24     4     5    10    11    19    20     2     6     8     9    12    14    15     1     4     7 11    16    17     2     3     6     9    18    19     4     7    10    11    13    23    24     1     2     3     6     9    21    22 4     5    11    12    13    17    18     2     3     6     9    10    15    16     4     7     8    11    14     2     5     6     9 22    23     4     8    11    12    20    21];
dc=[  7      6     7     6     6     7     7     7     7     5     6     6];
perm=[     10    11     3     0     4     8     0     0     6     5    13     0     0     0     3    12     1     3     0     0     1    11     7 11     0     0     3     0     8     1     0     0     8     8     9     0     0     0     0     9     0    13    12     8     0     0 4     8     2     5     4     0     0     9    11    13     2    12     0     0     6     9     6     2     0     5     1     4     5 0     0     9     3     3     1     0     0];
%Lr=sparse(i,j,zeros(1,length(i)),q,w);

Lr=zeros(length(mmu),14);

        for l=1:I
            row=1;
            done=0;
            regi=ones(1,14);
            si=1;
            ci=1;
            lq_reg=zeros(7,14);
            lq_reg1=zeros(7,14);
            for k=1:length(mmu)
                vi=14*(mmu(k)-1)+1:14*mmu(k);
                Lq=LQ(vi)-Lr(k,:);
                lq_reg1(ci,:)=Lq;
                for idx=1:length(vi)
                    v=vi(idx);
                    c=mod(idx-1-perm(k),14)+(row-1)*14+1;       
                    b=getB(H,c,v,p0,p);
                    if -codeword(v)*Lq(idx)>=b
                      Lq(idx)=-codeword(v);
                    else
                      Lq(idx)=codeword(v);
                    end
                end
                lq_reg(ci,:)=Lq;
                ci=ci+1;
                Lq=circshift(Lq,[0 -perm(k)]);
                regi=regi.*Lq;
                done=done+1;
                if dc(row)==done
                    for u=1:dc(row)
                        p=si+u-1;
                        Lr(p,:)=lq_reg(u,:).*circshift(regi,[0 perm(p)]);
                        vi=14*(mmu(p)-1)+1:14*mmu(p);
                        LQ(vi)=lq_reg1(u,:)+Lr(p,:);
%                         LQ(vi)=LQ(vi)+Lr(p,:);
                    end
                    regi=ones(1,14);
                    lq_reg=zeros(7,14);
                    lq_reg1=zeros(7,14);
                    done=0;
                    row=row+1;
                    si=k+1;
                    ci=1;
                end
            end
            
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