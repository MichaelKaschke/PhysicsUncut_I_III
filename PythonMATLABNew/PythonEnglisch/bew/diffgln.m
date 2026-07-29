% Differenzengeichung
% Lösung der Differenzengleichung 
% x_{k+1} = a \cdot x_k + b , k=1...n
% unter Variation der Parameter a,b,x_0 und n
% up. 2025-06-30
clear all
a=-0.6
b=1
x(1)=1
n=50
for ix = 1:n
    x(ix+1,1) = a*x(ix,1)+b;
end
figure(1)
plot(x,'.-')
xlabel('Schritt k')
title('Differenzengleichung')
