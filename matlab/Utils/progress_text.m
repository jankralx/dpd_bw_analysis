function [ output_args ] = progress_text( progress, text )
%PROGRESS_TEXT Provides progress information in text format
%   Prints the progress bar in text form into the command line.
%   progress - progress in <0, 1> range
%   text is displayed text

% Authors: Jan Kral <kral.j@lit.cz>
% Date: 11.1.2017

    progr = round(progress*40);
    progr_perc = round(progress*100);
    fprintf('[%-40s] %i%% %s\n', repmat('#',1,progr), progr_perc, text);

end

