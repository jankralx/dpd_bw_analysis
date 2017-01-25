function coef=calc_DPD(x,y,K,M)


[a b]=size(x);
if b>a x=x.';end;


for q=0:M
shifted(q+1,:)=circshift(x,[q, 0]);
shifted(q+1,1:q)=0;
end

for q=0:M
    for k=1:1:K
       psi(:,k+(q*K))=(abs(shifted(q+1,:)).^(k-1).*shifted(q+1,:));
    end
end
[a b]=size(y);
if b>a y=y.';end;
coef=lscov(psi, y); 