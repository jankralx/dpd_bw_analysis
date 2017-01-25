function y1=rescale_to(y1,R)


%R = [-1 1];
dR = diff( R );
y1 =  y1 - min( y1(:)); % set range of A between [0, inf)
y1 =  y1 ./ max( y1(:)) ; % set range of A between [0, 1]
y1 =  y1 .* dR ; % set range of A between [0, dRange]
y1 =  y1 + R(1); % shift range of A to R
