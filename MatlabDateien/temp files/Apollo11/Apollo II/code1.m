close all
clear all; clc;

%% Set the initial conditions
% all is in METERS, SECONDS, vitesse launching 3280 km/h

% Cap Kennedy coordinate
    lat = 28.573469;        %latitude
    lon = -80.65107;        %longitude
    R = 6371e3;             %radius of the earth

    X0 = R * cosd(lat) * cosd(lon)*10^3;
    Y0 = R * cosd(lat) * sind(lon)*10^3;
    Z0 = R * sind(lat) *10^3;

%   ChatGPT proposition  
%     X0 = 0%
%     Y0 = 0%
%     Z0 = 1.34e+7;
   
    Xdot0 = 0;           %1.152%-1.923e4;
    Ydot0 = 0;          %1.789%1.49e4;
    Zdot0 = 10.9e3;     %2.35e3  6.37826e6 + 200e3
  
    y0 = [X0; Y0; Z0; Xdot0; Ydot0; Zdot0];
   
% Call ODE45   
    
    tspan = 0:1:3*86400;
    [t, y] = ode45(@ode, tspan, y0);
    plot3(y(:,1),y(:,2),y(:,3)), hold on
    plot3(X0,Y0,Z0,'o'), hold on
    title('Solution of the Motion Equation with ODE45');
    legend ('Apollo 11','Terre')
% 
% xmm = -231919e+03;
% ymm = 379692e+03;
% zmm = -52385e+03;
% plot3(xmm,ymm,zmm);
%     
    
  
   




