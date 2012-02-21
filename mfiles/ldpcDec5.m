function [dec]=ldpcDec5(H,codeword,p0,p)
[i,j,s]=find(H);
[q,w]=size(H);
n=q;
m=w;

Lq=sparse(i,j,s,q,w);
Lr=sparse(i,j,zeros(1,length(i)),q,w);

LQ=codeword;
I=5;
for l=1:I
    for c=1:n
        vi=find(H(c,:));
        Lq(c,vi)=LQ(vi)-Lr(c,vi);

        for idx=1:length(vi)
            tmp=10000;
            for idx1=1:length(vi)
                if idx~=idx1
                    if tmp==10000
                        tmp=Lq(c,vi(idx1));
                    else
                        tmp=boxplus(tmp,Lq(c,vi(idx1)));
                    end
                end
            end
            Lr(c,vi(idx))=tmp;
        end
%         tmp=Lq(c,vi(1));
%         for idx=2:length(vi)
%             tmp=boxplus(tmp,Lq(c,vi(idx)));
%         end
% 
%         
%         for idx=1:length(vi)
%             Lr(c,vi(idx))=boxplus(tmp,-Lq(c,vi(idx)));
%         end
           
        LQ(vi)=Lq(c,vi)+Lr(c,vi);       
    end
    d=LQ;
    d(find(d>0))=0;
    d(find(d<0))=1;
    if d(1:n)*H==zeros(1,m)
        break;
    end
end     
dec=d;
end

function [r]=boxplus(a,b)
    s=log(1+exp(-abs(a+b)))-log(1+exp(-abs(a-b)));
    r=sign(a)*sign(b)*min(abs(a),abs(b))+s;
%     A=log(abs((exp(a)-1)/(exp(a)+1)));
%     B=log(abs((exp(b)-1)/(exp(b)+1)));
%     r=A+B;
end
function [r]=boxminus(a,b)
     r=abs(log(exp(a+b)-1)-log(exp(a-b)-1)-b);
%     A=log(abs((exp(a)-1)/(exp(a)+1)));
%     B=log(abs((exp(b)-1)/(exp(b)+1)));
%     r=A-B;
end