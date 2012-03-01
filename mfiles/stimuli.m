% Hc=[-1 -1 -1 6 -1 -1 9 6 -1 -1 2 -1 -1 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
% -1 0 -1 -1 -1 3 -1 12 1 -1 -1 3 -1 0 0 -1 -1 -1 -1 -1 -1 -1 -1 -1
% -1 9 11 -1 -1 13 -1 -1 2 12 -1 -1 -1 -1 0 0 -1 -1 -1 -1 -1 -1 -1 -1
% 1 -1 -1 11 -1 -1 7 -1 -1 -1 11 -1 -1 -1 -1 0 0 -1 -1 -1 -1 -1 -1 -1
% -1 -1 -1 4 8 -1 -1 -1 -1 -1 2 5 4 -1 -1 -1 0 0 -1 -1 -1 -1 -1 -1
% -1 3 0 -1 -1 8 -1 -1 1 -1 -1 -1 -1 -1 -1 -1 -1 0 0 -1 -1 -1 -1 -1
% -1 -1 -1 0 6 -1 -1 -1 -1 5 13 -1 -1 -1 -1 -1 -1 -1 0 0 -1 -1 -1 -1
% -1 -1 -1 9 -1 -1 -1 3 -1 -1 3 1 -1 -1 -1 -1 -1 -1 -1 0 0 -1 -1 -1
% 9 0 13 -1 -1 12 -1 -1 8 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 0 -1 -1
% -1 5 -1 -1 1 4 -1 -1 5 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 0 -1
% -1 -1 -1 8 -1 -1 8 -1 -1 9 0 -1 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 0
% 10 11 -1 -1 -1 3 -1 -1 0 -1 -1 -1 4 8 -1 -1 -1 -1 -1 -1 -1 -1 -1 0];


    
Hc=[10 11 -1 -1 -1  3 -1 -1  0 -1 -1 -1  4  8 -1 -1 -1 -1 -1 -1 -1 -1 -1  0
        -1 -1 -1  0  6 -1 -1 -1 -1  5 13 -1 -1 -1 -1 -1 -1 -1  0  0 -1 -1 -1 -1
        -1  0 -1 -1 -1  3 -1 12  1 -1 -1  3 -1  0  0 -1 -1 -1 -1 -1 -1 -1 -1 -1
         1 -1 -1 11 -1 -1  7 -1 -1 -1 11 -1 -1 -1 -1  0  0 -1 -1 -1 -1 -1 -1 -1
        -1  3  0 -1 -1  8 -1 -1  1 -1 -1 -1 -1 -1 -1 -1 -1  0  0 -1 -1 -1 -1 -1
        -1 -1 -1  8 -1 -1  8 -1 -1  9  0 -1  0 -1 -1 -1 -1 -1 -1 -1 -1 -1  0  0
         9  0 13 -1 -1 12 -1 -1  8 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1  0  0 -1 -1
        -1 -1 -1  4  8 -1 -1 -1 -1 -1  2  5  4 -1 -1 -1  0  0 -1 -1 -1 -1 -1 -1
        -1  9 11 -1 -1 13 -1 -1  2 12 -1 -1 -1 -1  0  0 -1 -1 -1 -1 -1 -1 -1 -1
        -1 -1 -1  6 -1 -1  9  6 -1 -1  2 -1 -1  0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
        -1  5 -1 -1  1  4 -1 -1  5 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1  0  0 -1
        -1 -1 -1  9 -1 -1 -1  3 -1 -1  3  1 -1 -1 -1 -1 -1 -1 -1  0  0 -1 -1 -1];

[a,b]=size(Hc);
p0=.3;
p=.3;

perm=[  6     9     6     2     0     0     3    12     1     3     0     0     9 11    13     2    12     0     0     1    11     7    11     0     0     4 8     2     5     4     0 0     3     0     8     1     0     0     0 6     5    13     0     0     9     3     3     1     0     0     9     0 13    12     8     0     0     5     1     4     5     0 0     8     8 9     0     0     0     0    10    11     3     0     4     8     0];

s=zeros(a,1);
t=Hc';
r=t(find(t~=-1));
mmu=[]
for i=1:a
    s(i,1)=length(find(Hc(i,:)~=-1));
    mmu=[mmu find(Hc(i,:)~=-1)];
    find(Hc(i,:)~=-1)
end
dc=s
perm=r'
mmu

Hc(:,10)
SNRdB=[3];
z=1;
R=1/2;
enc = fec.ldpcenc(sparse(ldpcg9960(3)));
msg = randi([0 1],1,enc.NumInfoBits);
codeword = encode(enc,msg);

modObj = modem.pskmod('M',2,'InputType','Bit');

      % Modulate the signal (map bit 0 to 1 + 0i, bit 1 to -1 + 0i)
      modulatedsig = modulate(modObj, codeword);

       %dB to actual SNR
      SNR(z)=10^(SNRdB(z)/10);
      ebno_c(z)=SNR(z)*R; %Eb/No for coded signal!!!!!!!!!!!!!!<----!

      % Noise parameters
      var(z) = 1 / (2 * ebno_c(z));%No/2 !!!!!!!!!!!!!!!

      %or-->sigma = sqrt((10^(-SNRdB(z)/10))/(2*R));
      
      % Transmit signal through AWGN channel
      receivedsig = modulatedsig+sqrt(var(z)).*randn(1,enc.blocklength);

      %or-->receivedsig = modulatedsig+sigma.*randn(1,enc.blocklength);
      
      
      % Construct a BPSK demodulator object to compute log-likelihood ratios
      demodObj = modem.pskdemod(modObj,'DecisionType','LLR','NoiseVariance',var(z));

      %or-->demodObj = modem.pskdemod(modObj,'DecisionType','LLR','NoiseVariance',sigma^2);
      
      
      % Compute log-likelihood ratios (AWGN channel)
      llr = demodulate(demodObj, receivedsig);

      % Decode received signal
      
      asd=llr;
      
      asd(find(llr>0))=1;
      asd(find(llr<0))=-1;
      
      codeword=llr;
      
      codeword(find(llr>0))=0;
      codeword(find(llr<0))=1;

dlmwrite('codeword.dat', codeword, 'delimiter','','newline','pc');
perm1=zeros(length(perm),4);
dc1=zeros(length(dc),3);
mmu1=zeros(length(mmu),5);
for idx=1:length(perm)
    perm1(idx,4:-1:1)=dec2binvec(perm(idx),4);
end
for idx=1:length(dc)
    dc1(idx,3:-1:1)=dec2binvec(dc(idx),3);
end
for idx=1:length(mmu)
    mmu1(idx,5:-1:1)=dec2binvec(mmu(idx)-1,5);
end
dlmwrite('perm.dat',perm1,'delimiter','','newline','pc');
dlmwrite('blk_mem_gen_v6_7.mif',perm1,'delimiter','','newline','pc');
dlmwrite('dc.dat',dc1,'delimiter','','newline','pc');
dlmwrite('blk_mem_gen_v6_8.mif',dc1,'delimiter','','newline','pc');
dlmwrite('mmu.dat',mmu1,'delimiter','','newline','pc');
dlmwrite('blk_mem_gen_v6_4.mif',mmu1,'delimiter','','newline','pc');
cq_lq=zeros(1,336*4);
for idx=1:length(codeword)
    if codeword(idx)==0
        cw_lq(idx*4:-1:(idx-1)*4+1)=[1 0 0 0];
    else
        cw_lq(idx*4:-1:(idx-1)*4+1)=[1 1 1 1];
    end
end
dlmwrite('codeword_lq.dat',cw_lq,'delimiter','','newline','pc');
stimuliLdpc(sparse(ldpcg9960(3)),asd,p0,p,mmu,dc',perm);
dlmwrite('brom.dat',genBrom(ldpcg9960(3),p0,p),'delimiter','','newline','pc');
dlmwrite('blk_mem_gen_v6_6.mif',genBrom(ldpcg9960(3),p0,p),'delimiter','','newline','pc');