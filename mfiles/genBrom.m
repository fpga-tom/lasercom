function [q]=genBrom(H,p0,p)
mmu=[ 4     7     8    11    14     2     6     8     9    12    14    15     2 3     6     9    10    15    16     1     4     7    11    16    17     4 5    11    12    13    17    18     2     3     6     9    18    19     4 5    10    11    19    20     4     8    11    12    20    21     1     2 3     6     9    21    22     2     5     6     9    22    23   4     7  10    11    13    23    24     1     2     6     9    13    14    24];
perm=[  6     9     6     2     0     0     3    12     1     3     0     0     9 11    13     2    12     0     0     1    11     7    11     0     0     4 8     2     5     4     0 0     3     0     8     1     0     0     0 6     5    13     0     0     9     3     3     1     0     0     9     0 13    12     8     0     0     5     1     4     5     0 0     8     8 9     0     0     0     0    10    11     3     0     4     8     0];
dc=[ 5     7     7     6     7     6     6     6     7     6     7     7];
q=[];
done=0;
row=1;
for k=1:length(mmu)
    vi=14*(mmu(k)-1)+1:14*mmu(k);
    for idx=1:length(vi)
        v=vi(idx);
        c=mod(idx-1-perm(k),14)+(row-1)*14+1;       
        b=getB(H,c,v,p0,p);
        q=[q b];
    end
    done=done+1;
    if done==dc(row)
        row=row+1;
        done=0;
    end;
end

x=reshape(q',14,77);
x=x';
q=zeros(77,56);
for n=1:77
    for m=1:14
        q(n,m*4:-1:(m-1)*4+1)=dec2binvec(x(n,m),4);
    end
end
   
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