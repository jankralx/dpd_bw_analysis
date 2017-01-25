function [z]=modul_ofdm2013(bits,M,Ncarrier,NFFT,GI,Fnull,OSR)

km=log2(M);



Nbits=length(bits);
NsymbQAM=floor(Nbits/km);
Nbits=NsymbQAM*km;
NsymbOFDM=floor(NsymbQAM/Ncarrier);


%==========================================================================
%   calcul du signal OFDM
%==========================================================================
%symb=gene_symb(bits,M);
k = log2(M);                % Number of bits per symbol
dataInMatrix = reshape(bits, length(bits)/k, k); % Reshape data into binary 4-tuples
symb = bi2de(dataInMatrix);                 % Convert to integers
%DZ  = qammod(symb,M); % QAM mapping

h = modem.qammod(M);
DZ = modulate(h, symb);

I=real(DZ);
Q=imag(DZ);


DZ=DZ(1:Ncarrier*NsymbOFDM); % pour avoir un nb entier de symboles OFDM
Data=reshape(DZ,Ncarrier,NsymbOFDM);
% Introduction ?ventuelle de la porteuse nulle
if(Fnull==0)
   N1=floor(Ncarrier/2);
    %dif=round(2*(Ncarrier/2-demilong));
    tmp=[Data;zeros(1,NsymbOFDM)];
    tmp(1:N1,:)=Data(1:N1,:);
    
    tmp(N1+1,:)=zeros(1,NsymbOFDM);
    tmp(N1+2:end,:)=Data(N1+1:end,:);
    Data=tmp;
    Ncar=Ncarrier+1;
    N2=Ncar-N1;
else
    Ncar=Ncarrier;
    N1=floor(Ncar/2);
    N2=Ncar-N1;
end
Nzeros=NFFT-Ncar;

SymbOFDM = [Data(Ncar-N2+1:end,:);...
                  zeros(Nzeros,NsymbOFDM);...
                  Data(1:N1,:)];

              % IFFT
SymbIFFT = sqrt(NFFT)*ifft(SymbOFDM,NFFT);
   

SymbIFFTGI  = [SymbIFFT(round((1-GI)*NFFT+1):end,:);SymbIFFT]; 

[lig,col]=size(SymbIFFTGI);

taille=lig*col;
z=reshape(SymbIFFTGI,1,taille);


span = 80;        % Filter span in symbols
rolloff = 0.15;   % Roloff factor of filter
RCCfilter = rcosdesign(rolloff, span, OSR);

% Upsampling
zUps = zeros(OSR*length(z),1);
zUps(1:OSR:end) = z;

L   = length(RCCfilter);
zRC = conv(RCCfilter,zUps);
z   = zRC(ceil(L/2):end-floor(L/2));



