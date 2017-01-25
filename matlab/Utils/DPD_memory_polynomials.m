function DPDoutput=DPD_memory_polynomials(x,K,M,coef,speed)

% if speed is not provided, use fastest algorithm
if nargin < 5
    speed = 2;
end

% if given x is row make it column
[a, b]=size(x);
if b>a
    x=x.';
end

if speed == 1
    % pre-calculate absolute values for faster algorithm
    abs_x = abs(x);

    % allocate memory for shifted array
    shifted = zeros(M+1,length(x));
    abs_shifted = zeros(size(shifted));
    for q=0:M
        shifted(q+1,:)=circshift(x,[q, 0]);
        shifted(q+1,1:q)=0;
        abs_shifted(q+1,:)=circshift(abs_x,[q, 0]);
        abs_shifted(q+1,1:q)=0;
    end

    DPDoutput=zeros(1,length(x));
    for q=0:M
        for k=1:K
           DPDoutput= DPDoutput+coef(k+(q*K))*(abs(shifted(q+1,:)).^(k-1).*shifted(q+1,:));
        end
    end
    
elseif speed == 2
    
    % pre-calculate absolute values for faster algorithm
    abs_x = abs(x);

    DPDoutput=zeros(length(x),1);
    
    for k=1:K
        abs_x_k = abs_x.^(k-1);         % precalculate for faster operation
        temp_x = abs_x_k .* x;          % calculate non-shifted version of abs(x).^(k-1).*x
        for q=0:M
           shifted = circshift(temp_x,[q, 0]);
           shifted(1:q) = 0;
           DPDoutput= DPDoutput+coef(k+(q*K))*shifted;
        end
    end
    
    DPDoutput = DPDoutput.';
end