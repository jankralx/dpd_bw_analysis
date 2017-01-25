%**************************************************************************
%   OQAM Modulation
%   14.01.2015
%   Tomas Gotthans 2014
%   Brno University of Technology
%   gotthans@feec.vutbr.cz
%   Based on: Michel Terré and Mahmoud Al-dababseh 
%**************************************************************************

% for even frame: output=[real(QAM symbol 1); Imag(QAM symbol 1); real(QAM
% symbol 2); Imag(QAM symbol 2);...]3


function outdata=OQAM_modulator(data,M, nframe)
% outdata:  OQAM output data
% data:  input data
% M: modulation level
% nframe: sub-channel number (power of 2) 


X=data; % input data
Y = qammod(X,M); % QAM modulation 
% plot(Y,'.');

if rem(nframe,2)==1
    for k=0:1:length(data)-1 % for k even (k from 0 to M-1)
        v(k+1,:)=[real(Y(k+1));j*imag(Y(k+1))];
    end
else
    for k=0:1:length(data)-1 % for k odd
    v(k+1,:)=[j*imag(Y(k+1)); real(Y(k+1))];
   
    end
end;

[nRowsA,nCols] = size(v);

outdata = zeros(2*nRowsA,1);
outdata(1:2:end,:) = v(:,1);
outdata(2:2:end,:) = v(:,2);



