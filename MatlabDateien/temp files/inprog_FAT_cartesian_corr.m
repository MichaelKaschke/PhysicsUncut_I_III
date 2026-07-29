clc
clear 
close all 
addpath('IncludeFolder')

Colors=GetColorLines;
Style = ["-", "-.", ":", "--", ":"];

g=9.81;                 % g

%% Eingabe Parameter 

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


%%

% Parameter TrÃ¤gheitsmomente etc.

b1 = LQ/cos(gamma0);
b2 = b-b1;
JB  = mT*(b1^3+b2^3)/(3*(b1+b2));

%Parametersatzstruktur fÃ¼r ODE45 und ODE15s
P.LQ =LQ; P.lS=lS; P.JB= JB; P.MG = MG; P.mW = mW; P.mT = mT; 
P.g = g; P.b = b; P.H = H; P.alpha = alpha;

% Zeitspanne in s
tmax = 0.8;
NPoints = 2000; tstep = tmax/NPoints;             
tv=(0.0:tstep:tmax); N=length(tv);          %Simulationszeit, Zeit-Vektor

%% Berechnung Phase 1

%zG0 = H + LQ/cos(gamma0);
xG0 = 0;
dxG0 = 0;
zG0 = H + LQ*tan(gamma0);
dzG0 = 0;
dgamma0 = 0;

Q = -b*cos(gamma0); %AbkÃ¼rzung fÃ¼r delta0 AbhÃ¤ngigkeit
HLOW = zG0-b*sin(gamma0);
testparam = (-Q*cos(alpha)+HLOW*sin(alpha))^2-...
    Q^2-HLOW^2+lS^2;
t0 = -Q*cos(alpha)+HLOW*sin(alpha)-sqrt((-Q*cos(alpha)+HLOW*sin(alpha))^2-...
    Q^2-HLOW^2+lS^2); %Parameter fÃ¼r Aufliegepunkt auf Schiefer Ebene

% Anfangswerte Phase 1
xJ0 = -b*cos(gamma0);
dxJ0 = 0;
zJ0 = zG0 - b*sin(gamma0);
dzJ0 = 0;
xW0 = -t0*cos(alpha);
dxW0 = 0;
zW0 = t0*sin(alpha);
dzW0 = 0;
delta0 = -acos((b*cos(gamma0)+xW0)/lS);
ddelta0 = 0;

% Lagrange-Multiplikatoren Startwerte
l1_0 = 0;
l3_0 = mW*g/2/(zW0-zJ0-tan(alpha)*(xW0-xJ0));
l2_0 = 2*l3_0*(xW0-xJ0);
l4_0 = MG*g/2/(zG0-zJ0);
fprintf('\n ');
fprintf('\n lambda1_0 = %4.2e', l1_0);
fprintf('\n lambda2_0 = %4.2e', l2_0);
fprintf('\n lambda3_0 = %4.2e', l3_0);
fprintf('\n lambda4_0 = %4.2e', l4_0);

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
           


% Plot Anfangskonstellation
figure()
subplot(1,2,1);
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

%AB Winkel in rad
AB1=[xG0;dxG0;zG0;dzG0;xJ0;dxJ0;zJ0;dzJ0;xW0;dxW0;zW0;dzW0;...
    l1_0;l2_0;l3_0;l4_0];

opts = odeset('Mass',@(t,Y) Mass1(t,Y,P),'RelTol',1e-6);
%[t,Y] = ode15s(@(t,Y) F1(t,Y,P),tv,AB1,opts);
[t,Y] = ode113(@(t,Y) F1(t,Y,P),tv,AB1,opts);
xG = Y(:,1); dxG = Y(:,2);
zG  = Y(:,3); dzG = Y(:,4); 
xJ = Y(:,5); dxJ = Y(:,6);
zJ = Y(:,7); dzJ = Y(:,8);
xW  = Y(:,9); dxW = Y(:,10); 
zW = Y(:,11); dzW = Y(:,12);
lambda1 = Y(:,13);
lambda2 = Y(:,14);
lambda3 = Y(:,15);
lambda4 = Y(:,16);
zeit   = t;


xJE = xJ(end);
xWE = xW(end);
xGE = xG(end);
zJE = zJ(end);
zWE = zW(end);
zGE = zG(end);

% Plot Zeitkonstellation
subplot(1,2,2);
line([0 xJE],[zGE zJE],'Color', Colors(2,:), 'LineWidth',2);     %Balken
line([xJE xWE],[zJE, zWE],'Color', Colors(4,:), 'LineWidth',2);  %Seil
line([-b 2],[0, 0],'Color', Colors(15,:),'LineStyle',Style(3),'LineWidth',1);
line([-b 0],[b*tan(alpha) 0],'Color', Colors(15,:),'LineStyle',Style(3),'LineWidth',1);
line([-LQ -LQ],[0, 1.1*H],'Color', Colors(15,:),'LineStyle',Style(3),'LineWidth',1);
line([xJE 0],[zJE, zJE],'Color', Colors(15,:),'LineStyle',Style(3),'LineWidth',1);
line([0 -2*LQ],[H H],'Color', Colors(3,:), 'LineWidth',2);
line([0 0],[0 2*H],'Color', Colors(3,:), 'LineWidth',2);
axis([-1.2*b,2,-2,b+H]);
text(-1.1*b,b+H-2,strcat('\alpha = ',' ', num2str(rad2deg(alpha),4),'°'));
text(-1.1*b,b+H-4,strcat('\gamma_0 = ',' ', num2str(rad2deg(gamma0),4),'°'));
text(-1.1*b,b+H-8,strcat('\delta_0 = ',' ', num2str(rad2deg(delta0),4),'°'));
check  = sqrt((xW0-xJ0)^2+(zW0-zJ0)^2);
text(-1.1*b,b+H-10,strcat('l_S = ',num2str(check,2),' m'));


% figure()
% plot(zeit, xG, 'Color', Colors(2,:),'LineWidth',2);
% hold on;
% line([0,1],[0,0],'Color', Colors(3,:),'LineWidth',2)
% axis([0,2,-2,2])
% grid on;
% xlabel('\it{t} \rm in s','FontSize',14);
% ylabel('f_1 \rm','FontSize',14)
% grid on;
% 
% figure()
% plot(zeit, -xW-zW/tan(alpha), 'Color', Colors(2,:),'LineWidth',2);
% hold on;
% line([0,1],[0,0],'Color', Colors(3,:),'LineWidth',2)
% axis([0,2,-2,5])
% grid on;
% xlabel('\it{t} \rm in s','FontSize',14);
% ylabel('f_2 \rm','FontSize',14)
% grid on;
% 
% disp((xG(1)-xJ(1)).^2+(zG(1)-zJ(1)).^2);
% 
% figure()
% plot(zeit, (xW-xJ).^2+(zW-zJ).^2-lS^2, 'Color', Colors(2,:),'LineWidth',2);
% hold on;
% line([0,1],[0,0],'Color', Colors(3,:),'LineWidth',2)
% axis([0,2,-2,150])
% grid on;
% xlabel('\it{t} \rm in s','FontSize',14);
% ylabel('f_3 \rm','FontSize',14)
% grid on;
% 
% figure()
% plot(zeit, (xG-xJ).^2+(zG-zJ).^2-b^2, 'Color', Colors(2,:),'LineWidth',2);
% hold on;
% line([0,1],[0,0],'Color', Colors(3,:),'LineWidth',2)
% axis([0,2,-4,30])
% grid on;
% xlabel('\it{t} \rm in s','FontSize',14);
% ylabel('f_4 \rm','FontSize',14)
% grid on;

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

vorf = JB/b^4;

% Mass matrix function

Ms = zeros(6,6);
Ms(1,1) = vorf*(q(3)-q(7))^2;
Ms(1,2) = -vorf*(q(3)-q(7))*(q(1)-q(5));
Ms(1,5) = -vorf*(q(3)-q(7))^2;
Ms(1,6) = vorf*(q(3)-q(7))*(q(1)-q(5));
Ms(2,1) = -vorf*(q(3)-q(7))*(q(1)-q(5));
Ms(2,2) = vorf*(q(1)-q(5))^2+MG;
Ms(2,5) = vorf*(q(3)-q(7))*(q(1)-q(5));
Ms(2,6) = -vorf*(q(1)-q(5))^2;
Ms(3,3) = mW;
Ms(4,4) = mW;
Ms(5,1) = -vorf*(q(3)-q(7))^2;
Ms(5,2) = vorf*(q(3)-q(7))*(q(1)-q(5));
Ms(5,5) = vorf*(q(3)-q(7))^2;
Ms(5,6) = -vorf*(q(3)-q(7))*(q(1)-q(5));
Ms(6,1) = vorf*(q(3)-q(7))*(q(1)-q(5));
Ms(6,2) = -vorf*(q(1)-q(5))^2;
Ms(6,5) = -vorf*(q(3)-q(7))*(q(1)-q(5));
Ms(6,6) = vorf*(q(1)-q(5))^2;

M = eye(16);

for i = 1:6
    for j = 1:6
        M(2*i,2*j) = Ms(i,j);
    end
end

f1 = [0 1 0 0           0 0          0 0            0 0         0 0             0 0 0 0];
f2 = [0 0 0 0           0 0          0 0            0 -1        0 -1/tan(alpha)   0 0 0 0];
f3 = [0 0 0 0           0 -2*(q(9)-q(5)) 0 -2*(q(11)-q(7))   0 2*(q(9)-q(5)) 0 2*(q(11)-q(7))     0 0 0 0];
f4 = [0 0 0 2*(q(3)-q(7))   0 2*q(5)       0 -2*(q(3)-q(7))   0 0         0 0             0 0 0 0];

M(13,:) = f1; % horizontal
M(14,:) = f2;
M(15,:) = f3;
M(16,:) = f4;
M(:,13) = f1; % vertical
M(:,14) = f2;
M(:,15) = f3;
M(:,16) = f4;

end

function dYdt = F1(t,Y,P)
% Extract parameters
    MG = P.MG; mW = P.mW; g = P.g; LQ=P.LQ; H=P.H; lS = P.lS; b = P.b;
    
     dYdt = [Y(2)
            0
            Y(4)
            -MG*g
            Y(6)
            0
            Y(8)
            0
            Y(10)
            0
            Y(12)
            -mW*g
            0
            0
            2*(Y(10)-Y(6))^2+2*(Y(12)-Y(8))^2
            2*(Y(6)-Y(2))^2+2*(Y(8)-Y(4))^2];
end