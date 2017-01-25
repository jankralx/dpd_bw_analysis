function [ acpr ] = acpr( signal, OSR, chan_edges, is_plot)
% ACPR Calculates ACPR of oversampled signal.
%   signal - to be used for calculation
%   OSR - oversampling factor
%   chan_edges - boundaries of channels on right side from base channel
%   it is assumed that channels are symmetrical in negative and positive
%   frequencies
%   result is in two vectors (in matrix) where first vector is ACPRs for
%   upper channels and second vector is ACPRs for lower channels. Each row
%   is one of adjacent channels. First row is the most adjacent channel.
%   The results are in (dB).

% Authors: Jan Kral <kral.j@lit.cz>
% Date: 10.1.2017

BWd2 = ceil(length(signal)/OSR/2); % half of bandwidht in number of samples
chan_edges = ceil(length(signal)/OSR*chan_edges);

Signal = fft(signal);

% calculate power in base channel
base_pwr = sqrt(sum(abs(Signal(1:1+BWd2)).^2) + ...
                sum(abs(Signal(end-BWd2:end)).^2));

% calculate power in adjacent channels
adj_pwr = zeros(length(chan_edges)/2, 2);
for i = 1:2:length(chan_edges)
    adj_pwr((i+1)/2,1) = sqrt(sum(abs(Signal(chan_edges(i):chan_edges(i+1))).^2));
    adj_pwr((i+1)/2,2) = sqrt(sum(abs(Signal(length(Signal)-chan_edges(i+1):...
                                       length(Signal)-chan_edges(i))).^2));
end

% evaluate ACPR
acpr = 10*log10(adj_pwr./base_pwr);

if (is_plot)
    f=rescale_to(1:length(Signal), [-OSR/2,OSR/2]);
    logSpect = 20*log10(abs(fftshift(Signal)));
    lMin = min(logSpect)-10;
    lMax = max(logSpect)+10;
    
    figure();
    plot(f,logSpect);
    hold on;
    plot([1+BWd2 1+BWd2]./length(Signal)*OSR, [lMin lMax]);
    plot([-BWd2 -BWd2]./length(Signal)*OSR, [lMin lMax]);
    text(0,(lMin+lMax)/2, sprintf('%.2fdB', 10*log10(base_pwr)),...
        'HorizontalAlignment','center');

    for i = 1:2:length(chan_edges)
        plot([chan_edges(i) chan_edges(i)]/length(Signal)*OSR, [lMin lMax]);
        plot([chan_edges(i+1) chan_edges(i+1)]/length(Signal)*OSR, [lMin lMax]);
        plot([-chan_edges(i+1), -chan_edges(i+1)]/length(Signal)*OSR, [lMin lMax]);
        plot([-chan_edges(i), -chan_edges(i)]/length(Signal)*OSR, [lMin lMax]);
        text(sum(chan_edges(i:i+1))/2/length(Signal)*OSR,(lMin+lMax)/2, ...
            sprintf('%.2fdB', 10*log10(adj_pwr((i+1)/2,1))), ...
            'HorizontalAlignment','center');
        text(-sum(chan_edges(i:i+1))/2/length(Signal)*OSR,(lMin+lMax)/2, ...
            sprintf('%.2fdB', 10*log10(adj_pwr((i+1)/2,2))), ...
            'HorizontalAlignment','center');
    end
    hold off;
    
    drawnow;
end

end

