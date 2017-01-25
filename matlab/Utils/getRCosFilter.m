function [ h ] = getRCosFilter( beta, N, Br, OSR )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Authors: Jan Kral <kral.j@lit.cz>
% Date: 17.1.2017

Br = Br/OSR;

h = zeros(1,N);

for i=1:N
    n = i - (N+1)/2;
    if abs(abs(n) - (beta+1)/(2*beta*Br)) < 1e-9
        h(i) = pi/4*sinc(1/(2*beta));
    else
        h(i) = sinc(n*Br/(beta+1))*cos(pi*beta*n*Br/(beta+1))/...
            (1-(2*n*beta*Br/(beta+1))^2);
    end
end

% set filter gain to 1
H = fft(h);
h = h / abs(H(1));

end

