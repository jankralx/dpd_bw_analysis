function y=FBMC_modulator(N, OSR, Frame)
%FBMC Modulator

N1=N*OSR;

M=4; %MODULATION LEVEL
% Prototype Filter (prof. Maurice Bellanger (CNAM), Phydyas project)
H1=0.971960;
H2=sqrt(2)/2;
H3=0.235147;

K=4; % overlapping factor 
lp=K*N1-1;% prototype filter length
for i=1:lp
     h4(1+i)=1-2*H1*cos(pi*i/(2*N1))+2*H2*cos(pi*i/N1)-2*H3*cos(pi*i*3/(2*N1)); % prototype filter equation K=4
    
end
% Prototype filter impulse response
h4=h4/(1+2*(H1+H2+H3));
h=h4; 

% Initialization for transmission
y=zeros(1,K*N1+(Frame-1)*N1/2);
s=zeros(N,Frame);
x4=[];

indata=randi([0 M-1],N/2,Frame); 
for ntrame=1:Frame
s(:,ntrame)=OQAM_modulator(indata(:,ntrame),M,ntrame);
s1=[s(1:N/2,ntrame);zeros(N1-N,1);s((N/2+1):N,ntrame)];
x=sqrt(N)*ifft(s1);
% Duplication of the signal (overlapping)
for i=1:K
    x4=[x4 x.'];
end;
% filtering
signal=x4.*h;
% Transmitted signal
y(1+(ntrame-1)*N1/2:(ntrame-1)*N1/2+K*N1)=y(1+(ntrame-1)*N1/2:(ntrame-1)*N1/2+K*N1)+signal;
x4=[];
end
y=(y/max(abs(y))).';