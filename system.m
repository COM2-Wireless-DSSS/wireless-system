close all; clear all; clc;

M = [4 8 16]; % modulacao M-PSK
SNR_dB = -20:1:20; % SNR do canal AWGN
ts = 1e-6; fd = [100 200]; kdB = 15; % parametros do canal
iterations = 1000;

%%------------------------------------------------| CODIGO DE ESPALHAMENTO
ff= 2; % qtd de flip-flops (ff=2 => 7 chips)
C = 2^ff-1;
MSCode = mls(C,0);  % codigo de sequencia maxima (0b -> 1; 1b -> -1) (flag=0 default)


BER = zeros(length(M), length(SNR_dB));
for m = 1:length(M)
    
    nBits = log2(M(m))*10;
    info_bin = randi([0 1], 1, nBits);
    info = -((info_bin*2)-1); % bits de informacao (0b -> 1; 1b -> -1) 

    spread = (info'*MSCode)'; % espalhando o sinal (0b -> 1; 1b -> -1) [bits espalhados em colunas]
    spread_bin = ((-spread+1)/2); % transformando pra binario [bits espalhados em colunas]

    %%------------------------------------------------| MODULAR ( M-PSK, M={4,8,16} )
    rows_bin = reshape(spread_bin,log2(M(m)),[])';
    rows_dec = bi2de(rows_bin,2);
    modulated = pskmod(rows_dec,M(m));
    %scatterplot(modulated);
    signal_tx = modulated;
    
    for snr = 1:length(SNR_dB)
        
        for i=1:iterations
            
            %%------------------------------------------------| GERAR 2 CANAIS (Rician)
            h0 = ricianchan(ts, fd(1), kdB);
            h1 = ricianchan(ts, fd(2), kdB);

            %%------------------------------------------------| TRANSMISSAO
            signal_rx_0 = filter(h0, signal_tx);
            signal_rx_1 = filter(h1, signal_tx);

            %%------------------------------------------------| RECEPCAO
            signal_rx_0 = awgn(signal_rx_0, SNR_dB(snr));
            signal_rx_1 = awgn(signal_rx_1, SNR_dB(snr));

            %%------------------------------------------------| COMBINAR COMPONENTES (MRC)
            h0_conj = conj(h0.PathGains);
            h1_conj = conj(h1.PathGains);
            signal_rx = h0_conj.*signal_rx_0 + h1_conj.*signal_rx_1;
            %scatterplot(signal_rx);
            
            %%------------------------------------------------| DEMODULAR
            demodulated = pskdemod(signal_rx,M(m));
            rows_dec2 = demodulated;
            rows_bin2 = de2bi(rows_dec2);

            %%------------------------------------------------| DESESPALHAR
            r = -((reshape(rows_bin2', 2^C-1, nBits)*2)-1);
            reconstruct = MSCode*r;
            reconstruct_bin = double(reconstruct<0);
            info_bin;
            
            ber = sum(xor(info_bin, reconstruct_bin));
            BER(m,snr) = BER(m,snr) + ber;
            
        end % i
        
        m;
        snr;
        BER(m,snr) = BER(m,snr)/iterations;
        
        
    end % SNR
    
    BER(m,:) = BER(m,:)/nBits;
    
end % M

BER
figure(1)
semilogy(SNR_dB, BER(1,:))
hold on;
semilogy(SNR_dB, BER(2,:))
semilogy(SNR_dB, BER(3,:))
xlabel('SNR (dB)');
ylabel('BER');
legend('4-PSK', '8-PSK', '16-PSK', 'location', 'best')
grid on;
hold off;
