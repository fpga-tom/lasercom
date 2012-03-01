function [ber,snr]=bersimLDPCDec6(pcm,SNRdB,trials,p0,p)
R=1/2;
snr=SNRdB;
t_er=zeros(1,length(SNRdB));
er=zeros(1,length(SNRdB));



      enc = fec.ldpcenc(pcm); % Construct a default LDPC encoder object
      dec = fec.ldpcdec(pcm); % Construct a companion LDPC decoder object
      dec.DecisionType = 'Hard decision'; % Set decision type
      dec.OutputFormat = 'Information part'; % Set output format
      dec.NumIterations = 20; % Set number of iterations
      dec.DoParityChecks = 'Yes'; % Stop if all parity-checks are satisfied
      

for z=1:length(trials)%length(SNRdB)
    
    trial=trials(z);
    fprintf('trial %d %d\n', z,trial);
    for run=1:trial
      msg = randi([0 1],1,enc.NumInfoBits); % Generate a random binary message
      codeword = encode(enc,msg); % Encode the message

      % Construct a BPSK modulator object
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
      
        llr=asd;
      
      %decodedmsg = decodeBitFlip(llr',pcm,10);%ldpcHard(pcm,asd);%decode(dec, llr);
      decodedmsg = ldpcDec6(pcm,asd,p0,p);
%       pause
%       decodedmsg
      
      decodedmsg = decodedmsg(1:enc.numInfoBits);
%       decodedmsg1=decode(dec, llr)
%       pause;

      % Actual number of iterations executed
%       iter = ...
%            num2str(dec.ActualNumIterations);

      % Number of parity-checks violated
%       parity_checks_violated = num2str(sum(dec.FinalParityChecks));
           
      % Compare with original message
      er(z) = (nnz(decodedmsg-msg));
       t_er(z)=t_er(z)+er(z);
    end
    av_er(z)=t_er(z)/trial;
    ber(z)=av_er(z)/enc.blocklength;%32400; %for R=1/3-->ber(z)=av_er(z)/21600;
end