clear ;
snr=[3:1:12];
trials=[10 10 10 100 100 300 300 1200 1200 1200 10 10 10 80 40 40 40];
trials=trials(1:length(snr));
length(snr)
length(trials)
trials1=[100 100 100 100 800 10800 20000];
H=[0     0     0     1     0     0     0     0     0     0     0     0     0     0     1     0     1     1     0     1;
     0     1     0     0     1     1     1     0     0     1     0     0     1     0     0     0     0     0     1     0;
     1     0     0     0     0     0     1     1     0     0     0     1     1     1     0     0     1     0     0     0;
     0     0     0     0     0     0     1     0     1     1     0     0     0     0     1     0     0     1     0     0;
     1     0     1     0     1     1     0     0     0     1     0     1     0     1     0     0     0     0     0     0;
     0     1     1     1     1     0     0     0     0     0     0     0     0     0     0     1     1     0     0     0;
     0     0     1     1     0     1     0     1     1     0     1     0     0     0     0     0     0     1     1     0;
     0     1     0     0     0     0     0     1     1     0     0     1     0     0     0     1     0     0     0     1;
     1     0     0     0     0     0     0     0     0     0     1     0     0     1     1     1     0     0     1     0;
     0     0     0     0     0     0     0     0     0     0     1     0     1     0     0     0     0     0     0     1];

%     [ber,snr1]=bersimLDPC(sparse(ldpcg9960(1)),snr,trials)
    % [ber1,snr]=bersimLDPC(sparse(ldpcg9960(2)),snr,trials1);
    % [ber2,snr]=bersimLDPC(sparse(H),snr,trials);
%     [ber3,snr2]=bersimLDPCHard(sparse(ldpcg9960(1)),snr,trials)
    [ber4,snr3]=bersimLDPCFlip(sparse(ldpcg9960(1)),snr,trials)
    
    % [ber5,snr]=bersimLDPCDec(sparse(ldpcg9960(1)),snr,trials)
    [ber6,snr]=bersimLDPCDec1(sparse(ldpcg9960(1)),snr,trials,.1,.1)
%     [ber7,snr]=bersimLDPCDec1(sparse(ldpcg9960(1)),snr,trials,.3,.3)
    
    [ber8,snr]=bersimLDPCDec3(sparse(ldpcg9960(1)),snr,trials,.3,.3)
    [ber9,snr]=bersimLDPCDec4(sparse(ldpcg9960(1)),snr,trials,.3,.3)
    [ber10,snr]=bersimLDPCDec6(sparse(ldpcg9960(3)),snr,trials,.3,.3)
%     [ber10,snr]=bersimLDPCDec5(sparse(ldpcg9960(1)),snr,trials,.3,.3)
%     [ber8,snr]=bersimLDPCDec2(sparse(H),snr,trials,.3,.3)
    [berBPSK,snr4]=bersimBPSK(snr,trials);

semilogy(snr,berBPSK,'--bs', 'LineWidth',2,'MarkerEdgeColor', 'b');
hold;
% semilogy(snr,ber,'--rs', 'LineWidth',2,'MarkerEdgeColor', 'r');

% semilogy(snr,ber1,'--gs', 'LineWidth',2,'MarkerEdgeColor', 'g');
% semilogy(snr,ber2,'--ys', 'LineWidth',2,'MarkerEdgeColor', 'y');


% semilogy(snr,ber3,'--ms', 'LineWidth',2,'MarkerEdgeColor', 'm');
semilogy(snr,ber4,'--gs', 'LineWidth',2,'MarkerEdgeColor', 'g');
% hold
% semilogy(snr,ber5,'--gs', 'LineWidth',2,'MarkerEdgeColor', 'g');
semilogy(snr,ber6,'--ks', 'LineWidth',2,'MarkerEdgeColor', 'k');
% semilogy(snr,ber7,'--gs', 'LineWidth',2,'MarkerEdgeColor', 'k');
semilogy(snr,ber8,'--gs', 'LineWidth',2,'MarkerEdgeColor', 'b');
semilogy(snr,ber9,'--rs', 'LineWidth',2,'MarkerEdgeColor', 'b');
semilogy(snr,ber10,'--ys', 'LineWidth',2,'MarkerEdgeColor', 'b');
% semilogy(snr,ber10,'--ys', 'LineWidth',2,'MarkerEdgeColor', 'b');
% semilogy(snr,ber8,'--bs', 'LineWidth',2,'MarkerEdgeColor', 'y');