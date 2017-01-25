function [txSignal, dataSymbolsIn, dataMod]=QAM_Modulator(M, dataIn, numSamplesPerSymbol)
%modulator
% M = 4 ;                    % Size of signal constellation
k = log2(M);                % Number of bits per symbol
% numBits = 1024;              % Number of bits to process
% numSamplesPerSymbol = 6;    % Oversampling factorreturn
%Filter
span = 80;        % Filter span in symbols
rolloff = 0.15;   % Roloff factor of filter
rrcFilter = rcosdesign(rolloff, span, numSamplesPerSymbol);

%--------------------------------------------
%Modulator
%--------------------------------------------

dataInMatrix = reshape(dataIn, length(dataIn)/k, k); % Reshape data into binary 4-tuples
dataSymbolsIn = bi2de(dataInMatrix);                 % Convert to integers
dataMod = qammod(dataSymbolsIn, M);
txSignal = upfirdn(dataMod, rrcFilter, numSamplesPerSymbol, 1);
txSignal=txSignal./max(abs(txSignal));
%--------------------------------------------