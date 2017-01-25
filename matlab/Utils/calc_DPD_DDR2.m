function coef=calc_DPD_DDR2(x,y,K,M)


[a, b]=size(x);
if a>b x=x.';end;

for q=0:M
shifted(q+1,:)=circshift(x,[0, q]);
shifted(q+1,1:q)=0;
end
x=x.';


%separated for better undestainting  
   Ya=[];Y=[];
  for k=0:((K-1)/2)
         for i=0:M
           Ya=(abs(x).^(2*k)).*(shifted(i+1,:).');
           Y=[Y Ya];
        end
        
   end;
   
    Yb=[];
  for k=1:((K-1)/2)
         for i=1:M
           Yb=(abs(x).^(2*(k-1))).*(x.^2).*conj(shifted(+1,:).');
           Y=[Y Yb];
          
        end
        
   end;
 %Simplified second order dynamics  
    Yb=[];
  for k=1:((K-1)/2)
         for i=1:M
           Yb=(abs(x).^(2*(k-1))).*(x).*abs(shifted(+1,:).').^2;
           Y=[Y Yb];
          
        end
        
   end;
   
    Yb=[];
  for k=1:((K-1)/2)
         for i=1:M
           Yb=(abs(x).^(2*(k-1))).*conj(x).*(shifted(+1,:).').^2;
           Y=[Y Yb];
          
        end
        
   end;

if b>a y=y.';end;

coef=lscov(Y, y); 

