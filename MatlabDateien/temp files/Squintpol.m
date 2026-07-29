
function [xroot1, xroot2, xnroot]= squintpol(y_minus,y_0,y_plus)
   nroot = 0;
   xnroot = nroot;
   root1 = 0;
   root2 = 0;
   a = 0.5*(y_plus+y_minus)-y_0;
   b = 0.5*(y_plus-y_minus);
   c = y_0;
   rd = 1-4*a*c/(b*b);
   if rd ==1  % Es gibt genau eine Wurzel !
       root1=-b/(2*a);
       root2=-root1;
       nroot=1;
   else
     if rd >=0 % Es gibt eine oder zwei Wurzeln !
       root1=(-2*c/b)/(1-sqrt(rd));
       root2=(-2*c/b)/(1+sqrt(rd));
       if abs(root1)<=1 
           nroot=nroot+1;
       end
       if abs(root2)<=1 
          nroot=nroot+1;
       end
       if (root1 < -1.0) || (root1 > 1.0)
           root1=root2;
       end
     end
   end
   xroot1=root1;
   xroot2=root2;
   xnroot=nroot;
 end
