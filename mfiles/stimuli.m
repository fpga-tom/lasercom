Hc=[-1 -1 -1 6 -1 -1 9 6 -1 -1 2 -1 -1 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1
-1 0 -1 -1 -1 3 -1 12 1 -1 -1 3 -1 0 0 -1 -1 -1 -1 -1 -1 -1 -1 -1
-1 9 11 -1 -1 13 -1 -1 2 12 -1 -1 -1 -1 0 0 -1 -1 -1 -1 -1 -1 -1 -1
1 -1 -1 11 -1 -1 7 -1 -1 -1 11 -1 -1 -1 -1 0 0 -1 -1 -1 -1 -1 -1 -1
-1 -1 -1 4 8 -1 -1 -1 -1 -1 2 5 4 -1 -1 -1 0 0 -1 -1 -1 -1 -1 -1
-1 3 0 -1 -1 8 -1 -1 1 -1 -1 -1 -1 -1 -1 -1 -1 0 0 -1 -1 -1 -1 -1
-1 -1 -1 0 6 -1 -1 -1 -1 5 13 -1 -1 -1 -1 -1 -1 -1 0 0 -1 -1 -1 -1
-1 -1 -1 9 -1 -1 -1 3 -1 -1 3 1 -1 -1 -1 -1 -1 -1 -1 0 0 -1 -1 -1
9 0 13 -1 -1 12 -1 -1 8 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 0 -1 -1
-1 5 -1 -1 1 4 -1 -1 5 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 0 -1
-1 -1 -1 8 -1 -1 8 -1 -1 9 0 -1 0 -1 -1 -1 -1 -1 -1 -1 -1 -1 0 0
10 11 -1 -1 -1 3 -1 -1 0 -1 -1 -1 4 8 -1 -1 -1 -1 -1 -1 -1 -1 -1 0];

[a,b]=size(Hc);
p0=.3;
p=.3;

s=zeros(a,1);
t=Hc';
r=t(find(t~=-1));
mmu=[]
for i=1:a
    s(i,1)=length(find(Hc(i,:)~=-1));
    mmu=[mmu find(Hc(i,:)~=-1)];
    find(Hc(i,:)~=-1)
end
dc=s'
perm=r'
mmu

Hc(:,10)
SNRdB=[3];
z=1;
R=1/2;
enc = fec.ldpcenc(sparse(ldpcg9960(1)));
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
cq_lq=zeros(1,336*4);
for idx=1:length(codeword)
    if codeword(idx)==0
        cw_lq(idx*4:-1:(idx-1)*4+1)=[1 0 0 0];
    else
        cw_lq(idx*4:-1:(idx-1)*4+1)=[1 1 1 1];
    end
end
dlmwrite('codeword_lq.dat',cw_lq,'delimiter','','newline','pc');
stimuliLdpc(sparse(ldpcg9960(1)),asd,p0,p);