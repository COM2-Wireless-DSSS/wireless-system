close all; clear all; clc;

%%% rascunho TX

%%------------------------------------------------| ESPALHAR
ff= 2; % qtd de flip-flops (ff=3 => 7 chips)
C = 2^ff-1; % qtd de chips de espalhamento
MSCode = mls(C,0);  % codigo de sequencia maxima (0b -> 1; 1b -> -1) (flag=0 default)

nBits = 2*100;
info_bin = randi([0 1], 1, nBits);
info = -((info_bin*2)-1); % bits de informacao (0b -> 1; 1b -> -1) 

spread = (info'*MSCode)'; % espalhando o sinal (0b -> 1; 1b -> -1) [bits espalhados em colunas]
spread_bin = ((-spread+1)/2); % transformando pra binario [bits espalhados em colunas]

%%------------------------------------------------| MODULAR ( M-PSK, M={4,8,16} )
%m = pskmod(x,M(3)); scatterplot(m); % x = fliplr(); flipud
M = [4 8 16];
m = 3;

rows_bin = reshape(spread_bin,log2(M(m)),[])';
rows_dec = bi2de(rows_bin,2);
modulated = pskmod(rows_dec,M(m));
scatterplot(modulated);

%%------------------------------------------------| GERAR 2 CANAIS (Rician)

%%------------------------------------------------| TRANSMITIR



%%% rascunho RX

%%------------------------------------------------| COMBINAR COMPONENTES (MRC)
%%------------------------------------------------| DEMODULAR
demodulated = pskdemod(modulated,M(m));
rows_dec2 = demodulated;
rows_bin2 = de2bi(rows_dec2);

%%------------------------------------------------| DESESPALHAR
r = -((reshape(rows_bin2', 7, nBits)*2)-1); % 7 para ff=2
reconstruct = MSCode*r;
reconstruct_bin = reconstruct<0;
if info_bin == reconstruct_bin
    disp('reconstruct OK') % verificando se espalhamento/desespalhamento funcionou
end
