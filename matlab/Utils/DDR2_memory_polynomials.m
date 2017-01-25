function DPDoutput=DDR2_memory_polynomials(x,K,M,coef)

shifted=[];

[a, b]=size(x);
if a>b x=x.';end;

for q=0:M
shifted(q+1,:)=circshift(x,[0, q]);
shifted(q+1,1:q)=0;
end
x=x.';
l=0; 
Ya=[]; Y2=zeros(length(x),1);
  %z=Update_magnitude.*z.*mz;   
 for k=0:((K-1)/2)
         for i=0:M
           l=l+1;
           Ya=coef(l).*(abs(x).^(2*k)).*(shifted(i+1,:).');
           Y2=Y2+Ya;
           
         end;   
 end;
   
Yb=[];
  for k=1:((K-1)/2)
         for i=1:M
             l=l+1;
            Yb=coef(l).*(abs(x).^(2*(k-1))).*(x.^2).*conj(shifted(i+1,:).');
            Y2=Y2+Yb;
           
        end
        
   end;
   
   %Simplified second order dynamics  
Yb=[];
  for k=1:((K-1)/2)
         for i=1:M
             l=l+1;
            Yb=coef(l).*((abs(x).^(2*(k-1))).*(x).*abs(shifted(i+1,:).').^2);
            Y2=Y2+Yb;
          
        end
        
   end;
   
Yb=[];
  for k=1:((K-1)/2)
         for i=1:M
             l=l+1;
            Yb=coef(l).*((abs(x).^(2*(k-1))).*conj(x).*(shifted(i+1,:).').^2);
            Y2=Y2+Yb;
          
        end
        
   end;

 DPDoutput=transpose(Y2(1:end));