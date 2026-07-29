
close all
clear all; clc;

%% Set the initial conditions
% all is in METERS, SECONDS, vitesse launching 3280 km/h

% (Cap Kennedy) Kennedy Space Center (LC-39A) coordinates      
    R = 6371e3;             %radius of the earth
    lat = 28.3922;           %latitude %theta
    lon = -80.6077;         %longitude

   
    X0 = R * cosd(lat)*sind(lon); 
    Y0 = R * sind(lat)*sind(lon); 
    Z0 = R * sind(lat);
    
% méthode pour calculer la vitesse, sachant que la vitesse de 
earth = [0 0  7.2921150e-5*180/pi]; %earth speed rate
pos = [X0 Y0 Z0]; % position
res = cross (earth, pos); %cross product

Xdot0 = res(1);
Ydot0 = res(2);
Zdot0 = res(3);

% données vitesse (NASA Horizon System)
%  Xdot0 = -1.714291364186439E2;
%  Ydot0 = -1.108454190274563E2 ;
%  Zdot0 = -2.994086798460337E2;
  
    y0 = [X0; Y0; Z0; Xdot0; Ydot0; Zdot0];
   
% Call ODE45   
    
  tspan = 0:1:3*86400;
  [t, y] = ode45(@odde, tspan, y0);
  plot3(y(:,1),y(:,2),y(:,3)), hold on
  plot3(X0,Y0,Z0,'o'), hold on
  title('Solution of the Motion Equation with ODE45');
    
% plot la position de la lune   
xm = -3.7295e+08;
ym =  9.3436e+06;
zm = -3.4376e+07;

 plot3(xm,ym,zm,'*');
 legend ('Apollo 11','Terre','Lune')



    
  
   




