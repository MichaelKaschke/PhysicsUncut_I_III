clear all
close all
tspan=linspace(0,10);
[t,y]=ode45(@myfunc,tspan,1 ); 
figure()
plot(t,y)
function f = myfunc(t,y)
  f=(y-t.^2).*exp((-t));
end
