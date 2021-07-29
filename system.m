close all; clear all; clc;

%%% rascunho TX

%%------------------------------------------------| MODULAR ( M-PSK, M={4,8,16} )
% M = [4 8 16]; m = pskmod(x,M(3)); scatterplot(m);

%%------------------------------------------------| ESPALHAR
ff= 2; % qtd de flip-flops (ff=3 => 7 chips)
C = 2^ff-1; % qtd de chips de espalhamento
MSCode = mls(C,0)  % codigo de sequencia maxima (0b -> 1; 1b -> -1) (flag=0 default)

nBits = 10;
info_bin = randi([0 1], 1, nBits)
info = (info_bin'*2)-1 % bits de informacao (0b -> 1; 1b -> -1) 

spread = (info*MSCode)' % espalhando o sinal (0b -> 1; 1b -> -1)
spread_bin = (reshape(-spread,1,[])+1)/2 % transformando pra binario

%%------------------------------------------------| GERAR 2 CANAIS (Rician)

%%------------------------------------------------| TRANSMITIR



%%% rascunho RX

%%------------------------------------------------| DESESPALHAR

r = (reshape(spread_bin, 7, nBits)*2)-1 % 7 para ff=2
reconstruct = MSCode*r
reconstruct_bin = reconstruct<0
info_bin % comparando

%%------------------------------------------------| COMBINAR COMPONENTES (MRC)
%%------------------------------------------------| DEMODULAR
% d = pskdemod(m,M(3));
