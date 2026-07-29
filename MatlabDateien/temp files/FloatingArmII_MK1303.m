clc
clear 
close all 
addpath('IncludeFolder')

Colors=GetColorLines;
Style = ["-", "-.", ":", "--", ":"];

g=9.81;                 % g

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

% xW0     = xJ0 + lS*cos(delta0);
% dxW0    = 0;
% zW0     = zJ0 + lS*sin(delta0);
% dzW0    = 0;

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
F0       = [-MG*g;0;0;-mW*g;0];
lambda0   = F0 \ Jacobi10T;

l1_0 = lambda0(1);
l2_0 = lambda0(2);
l3_0 = lambda0(3);
l4_0 = lambda0(4);
fprintf('\n ');
fprintf('\n lambda1_0 = %4.2e', l1_0);
fprintf('\n lambda2_0 = %4.2e', l2_0);
fprintf('\n lambda3_0 = %4.2e', l3_0);
fprintf('\n lambda4_0 = %4.2e', l4_0);
           
l3_0 = mW*g/2/(zW0-zJ0-tan(alpha)*(xW0-xJ0));
l4_0 = MG*g/2/(zG0-zJ0);
l1_0 = 0;
l2_0 = 2*l3_0*(xW0-xJ0);

fprintf('\n ');
fprintf('\n lambda1_0 = %4.2f', l1_0);
fprintf('\n lambda2_0 = %4.2f', l2_0);
fprintf('\n lambda3_0 = %4.2f', l3_0);
fprintf('\n lambda4_0 = %4.2f', l4_0);
l4_0 = -mW*g/(sin(alpha)*tan(delta0)-cos(alpha));
l1_0 = l4_0*sin(alpha);
l2_0 = l1_0*tan(delta0);
l3_0 = b*(l2_0*cos(gamma0)-l1_0*sin(gamma0))/(LQ*cos(gamma0)-sin(gamma0)*(H-zG0));
fprintf('\n ');
fprintf('\n lambda1_0 = %4.2f', l1_0);
fprintf('\n lambda2_0 = %4.2f', l2_0);
fprintf('\n lambda3_0 = %4.2f', l3_0);
fprintf('\n lambda4_0 = %4.2f', l4_0);



 

%% ------------------------------------------------------------------------
% Phase 1 mit Zwangsbedingungen
function M = Mass1(t,q,P)
% Extract parameters
JB = P.JB;
MG = P.MG;
mW = P.mW;
LQ = P.LQ;
b   = P.b;
lS  = P.lS;
alpha = P.alpha;
H = P.H;

% Mass matrix function
d = [1 MG 1 JB 1 mW 1 mW 1 0 0 0 0 0];
M = diag(d)

f1 = [0 0 0 b*sin(q(3)) 0 -1 0 0 0 -lS*sin(q(9)) 0 0 0 0];
f2 = [0 1 0 -b*cos(q(3)) 0 0 0 -1 0 lS*cos(q(9)) 0 0 0 0];
f3 = [0 -cos(q(3)) 0 LQ*cos(q(3))-(H-q(1))*sin(q(3)) 0 0 0 0 0 0 0 0 0 0];
f4 = [0 0 0 0 0 sin(alpha) 0 cos(alpha) 0 0 0 0 0 0];

M(11,:) = f1; % horizontal
M(12,:) = f2;
M(13,:) = f3;
M(14,:) = f4;
M(:,11) = f1; % vertical
M(:,12) = f2;
M(:,13) = f3;
M(:,14) = f4;

end

function dYdt = F1(t,Y,P)
% Extract parameters
    MG = P.MG; mW = P.mW; g = P.g; LQ=P.LQ; H=P.H; lS = P.lS; b = P.b;

    dYdt = [Y(2)
            -MG*g
            Y(4)
            0
            Y(6)
            0
            Y(7)
            -mW*g
            Y(9)
            0
            -b*Y(4)^2*cos(Y(3))+lS*Y(10)^2*cos(Y(9))
            -b*Y(4)^2*sin(Y(3))+lS*Y(10)^2*cos(Y(9))
            -2*Y(2)*Y(4)*sin(Y(3))+Y(4)^2*(LQ*sin(Y(3))+(H-Y(1))*cos(Y(3)))
            0];
end

function M = Mass2(t,q,P)
% Extract parameters
JB = P.JB;
MG = P.MG;
mW = P.mW;
LQ = P.LQ;
b   = P.b;
lS  = P.lS;
alpha = P.alpha;
H = P.H;

d = [1 MG 1 JB 1 mW 1 mW 1 0 0 0 0 0];
M = diag(d);

f1 = [0 0 0 b*sin(q(3)) 0 -1 0 0 0 -lS*sin(q(9)) 0 0 0 0];
f2 = [0 1 0 -b*cos(q(3)) 0 0 0 -1 0 lS*cos(q(9)) 0 0 0 0];
f3 = [0 1 0 -q(1)/tan(q(3))*cos(q(3)) 0 0 0 0 0 0 0 0 0 0]; %reformulated lQ as a function of other variables
f4 = [0 0 0 0 0 sin(alpha) 0 cos(alpha) 0 0 0 0 0 0];

M(11,:) = f1; % horizontal
M(12,:) = f2;
M(13,:) = f3;
M(14,:) = f4;
M(:,11) = f1; % vertical
M(:,12) = f2;
M(:,13) = f3;
M(:,14) = f4;

end

function dYdt = F2(t,Y,P)
% Extract parameters
    MG = P.MG; mW = P.mW; g = P.g; LQ=P.LQ; H=P.H; lS = P.lS; b = P.b;
    
    dYdt = [Y(2)
            -MG*g
            Y(4)
            0
            Y(6)
            0
            Y(7)
            -mW*g
            Y(9)
            0
            -b*Y(4)^2*cos(Y(3))+lS*Y(10)^2*cos(Y(9))
            -b*Y(4)^2*sin(Y(3))+lS*Y(10)^2*sin(Y(9))
            -Y(1)*Y(4)^2*cos(Y(3))
            0];
end