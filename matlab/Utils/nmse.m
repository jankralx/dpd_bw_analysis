function error=nmse(x,y)
%Normalized Mean Square Error in [dB]
%--------------------------------------------
%       Tomas GOTTHANS, Roman MARSALEK 2015
%       gotthans@feec.vutbr.cz, marsaler@feec.vutbr.cz
%--------------------------------------------

[a b]=size(x);
if b>a x=x.';end;

[a b]=size(y);
if b>a y=y.';end;


error=10*log10((sum(abs(x-y).^2))./(sum(abs(x).^2)));