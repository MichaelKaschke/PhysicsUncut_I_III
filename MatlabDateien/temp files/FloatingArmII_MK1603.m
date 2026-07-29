clc
clear 
close all 
addpath('IncludeFolder')

Colors=GetColorLines;
Style = ["-", "-.", ":", "--", ":"];


%% Eingabe Parameter 
%__________________________________________________________________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
b  = 9;     % Balkenlaenge
MG = 5000;  % Gegengewicht
mW = 100;   % Wurfgewicht
mT = 600;   % Balkenmasse
lS = 6;     % Seillaenge
H  = 8;     % Hoehe Querarm
LQ = 4;     % Abstand Drehpunkt Querarm
gam_max = acos(LQ/(0.8*b));% maximaler Winkel gamma bei gegebener Geometrie
gamma_max = rad2deg(gam_max);
% Anfangswinkel
gamma0  = 55;
gamma0  = deg2rad(gamma0);
if gamma0 > gam_max 
    gamma0 = gam_max;
end
alpha   = deg2rad(20);          % Neigung Rampe
g       = 9.81;                 % g

%__________________________________________________________________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

% Parameter Traegheitsmomente etc.

b1 = LQ/cos(gamma0);    % Arm 1
b2 = b-b1;              % Arm 2
JB  = mT*(b1^3+b2^3)/(3*(b1+b2));  % Trägheitsmoment Balken

%Parametersatzstruktur fuer ODE45 und ODE15s
P.LQ =LQ; P.lS =lS; P.JB = JB; P.MG    = MG;   P.mW = mW; P.mT = mT; 
P.g = g;  P.b  = b; P.H  = H;  P.alpha = alpha;

% Zeitspanne in s
tmax = 2.0;
NPoints = 2000; tstep = tmax/NPoints;             
tv=(0.0:tstep:tmax); N=length(tv);          %Simulationszeit, Zeit-Vektor

%% Berechnung Phase 1

zG0     = H + LQ*tan(gamma0);   % Anfangshoehe Gegengewicht
dzG0    = 0;                    % Anfangsgeschwindigkeit Gegengewicht
dgamma0 = 0;                    % Anfangsgeschwindigkeit Drehwinkel Balken

Q   = -b*cos(gamma0); %Abkuerzung fuer delta0 Abhaengigkeit
zJ0 = zG0-b*sin(gamma0);
Test= (-Q*cos(alpha)+zJ0*sin(alpha))^2-Q^2-zJ0^2+lS^2;
P   = -Q*cos(alpha)+zJ0*sin(alpha)-sqrt((-Q*cos(alpha)+zJ0*sin(alpha))^2-...
       Q^2-zJ0^2+lS^2); %Parameter fuer Aufliegepunkt auf Schiefer Ebene

% Anfangswerte Phase 1
zJ0    = zG0 - b*sin(gamma0);
xJ0    = -b*cos(gamma0);
if zJ0<lS 
    delta0  = asin(-zJ0/lS);
else
    delta0  = -pi/2;
end
ddelta0 = 0;

xJ0    = -b*cos(gamma0);
zJ0    = zG0 - b*sin(gamma0);
xW0    = -P*cos(alpha);
zW0    = P*sin(alpha);
delta0 = -acos((b*cos(gamma0)+xW0)/lS);

dzJ0    = 0;
dzW0    = 0;
dxW0    = 0;
ddelta0 = 0;

% Plot Anfangskonstellation
figure()
line([0 -2*LQ],[H H],'Color', Colors(3,:), 'LineWidth',2);
line([0 0],[0 2*H],'Color', Colors(3,:), 'LineWidth',2);
line([0 xJ0],[zG0 zJ0],'Color', Colors(2,:), 'LineWidth',2);
line([xJ0 xW0],[zJ0, zW0],'Color', Colors(4,:), 'LineWidth',2);
line([-b 2],[0, 0],'Color', Colors(15,:),'LineStyle',Style(3),'LineWidth',1);
line([-b 0],[b*tan(alpha) 0],'Color', Colors(15,:),'LineStyle',Style(3),'LineWidth',1);
line([-LQ -LQ],[0, 1.1*H],'Color', Colors(15,:),'LineStyle',Style(3),'LineWidth',1);
line([xJ0 0],[zJ0, zJ0],'Color', Colors(15,:),'LineStyle',Style(3),'LineWidth',1);
axis([-1.2*b,2,-2,b+H]);
text(-1.1*b,b+H-2,strcat('\alpha = ',' ', num2str(rad2deg(alpha),4),'°'));
text(-1.1*b,b+H-4,strcat('\gamma_0 = ',' ', num2str(rad2deg(gamma0),4),'°'));
text(-1.1*b,b+H-6,strcat('\gamma_{max} = ',num2str(rad2deg(gam_max),2),'°'));
text(-1.1*b,b+H-8,strcat('\delta_0 = ',' ', num2str(rad2deg(delta0),4),'°'));
check  = sqrt((xW0-xJ0)^2+(zW0-zJ0)^2);
text(-1.1*b,b+H-10,strcat('l_S = ',num2str(check,2),' m'));

% Nun Berechnung der lambda0 und Check der Zwangsbedingungen
Jacobi10 = [0  +b*sin(gamma0) 1  0 -lS*sin(delta0);...
           1  -b*cos(gamma0) 0 -1 +lS*cos(delta0);...
           -cos(gamma0)  LQ*cos(gamma0)-(H-zG0)*sin(gamma0) 0  0 0;...
           0            0   sin(alpha) cos(alpha) 0];          
Jacobi10T = Jacobi10';
F10       = [-MG*g;0;0;-mW*g;0];
lambda0   = F10 \ Jacobi10T;

l1_0 = lambda0(1);
l2_0 = lambda0(2);
l3_0 = lambda0(3);
l4_0 = lambda0(4);
fprintf('\n ');
fprintf('\n lambda1_0 = %4.2e', l1_0);
fprintf('\n lambda2_0 = %4.2e', l2_0);
fprintf('\n lambda3_0 = %4.2e', l3_0);
fprintf('\n lambda4_0 = %4.2e', l4_0);
           
% Lagrange-Multiplikatoren Startwerte (KvB)
l1_0 = 0;
l3_0 = mW*g/2/(zW0-zJ0-tan(alpha)*(xW0-xJ0));
l2_0 = 2*l3_0*(xW0-xJ0);
l4_0 = MG*g/2/(zG0-zJ0);

fprintf('\n ');
fprintf('\n lambda1_0 = %4.2f', l1_0);
fprintf('\n lambda2_0 = %4.2f', l2_0);
fprintf('\n lambda3_0 = %4.2f', l3_0);
fprintf('\n lambda4_0 = %4.2f', l4_0);
fprintf('\n ');
fprintf('\n ');

%AB Winkel in rad
AB1=[zG0;dzG0;gamma0;dgamma0;xW0;dxW0;zW0;dzW0;delta0;ddelta0;
    l1_0;l2_0;l3_0;l4_0]; 

% opts = odeset('Mass',@(t,Y) Mass1(t,Y,P),'RelTol',1e-6);
% [t,Y] = ode15s(@(t,Y) F1(t,Y,P),tv,AB1,opts);

% zG  = Y(:,1); dzG = Y(:,2); 
% gamma = Y(:,3); dgamma = Y(:,4);
% xW  = Y(:,5); dxW = Y(:,6); 
% zW = Y(:,7); dzW = Y(:,8);
% delta = Y(:,9); ddelta = Y(:,10);
% lambda1 = Y(:,11);
% lambda2 = Y(:,12);
% lambda3 = Y(:,13);
% lambda4 = Y(:,14);
% zeit   = t;

