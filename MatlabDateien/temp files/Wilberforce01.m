% -------------------------------------------------------------------------
% Wilberforce01.m
% -------------------------------------------------------------------------
% MATLAB-Programm zum Kapitel "Physik der Bewegung" aus
% "Physikalische Fingerübungen" von Michael Kaschke und Holger Cartarius
% unter Mitwirkung von Ulrich Potthoff
% Alle Rechte bei den Autoren
% Freier Gebrauch mit Buch und/oder Angabe der Quelle erlaubt.
% -------------------------------------------------------------------------
% Wilberforce Pendel
% Berechnung der Dynamik des Wilberforce-Pendels auf 
% Basis von Lagrange-Gleichungen (allgemeiner Fall)
% -------------------------------------------------------------------------

%clc
clear all
%close all 
addpath('IncludeFolder')
addpath('Data')
Colors = GetColorLines;
Style = ["-", "-.", ":", "--", ":"];

%% Numerische Lösung
% Parameter
mF = 0.52;              % Masse Federpendel, kg
kF = 3.2;               % Federkonstante, N/m
LF = 1.765;             % Länge Feder, m
JT = 1.4e-4;            % Trägheitsmoment der Torsionsstange, kg m2
DT = 7.9e-4;            % Torsionsmomemt, Nm/rad
k = 9.27e-3;            % Kopplungskonstante 1, N

wF = sqrt(kF/mF)        % Eigenfrequenz Feder
wT = sqrt(DT/JT)        % Eigenfrequenz Torsion

nF = 1e-4;              % Reibungsterm Feder
nT = 1e-6;              % Reibungsterm Torsion

AF = 0.1;               % Amplitude Antrieb Feder
BT = 0;                 % Amplitude Antrieb Torsion
w = 1*wF+0*wT           % Antriebsfrequenz

eF=0.03                  % nichtlinearer Anteil Feder
eT=0.00                  % nichtlinearer Anteil TTorsion

%% Berechnungen
% Anfangswerte
Y10 = 0.3;              % z     Federposition
Y20 = 0;                % dz    Federgeschwindigkeit
Y30 = 0;                % phi   Torsionswinkel
Y40 = 0;                % dphi  Torsionswinkelgeschwindigkeit
Y0 = [Y10 Y20 Y30 Y40]  % Anfangsvektor

tmax = 60;              % Simulationszeit
t = linspace(0,tmax,1000);

% Numerische Lösung volle Lagrangegleichung
opt=odeset('AbsTol',1.e-7,'RelTol',1.e-6);
% Numerische Lösung LGL
[t,Y]=ode45(@dgl_Wilberforce,t,Y0,opt,mF,wF,nF,k,nT,wT,JT,0*AF,0*BT,w,eF,eT); 
%[t,Y]=ode45(@dgl_WilberforceH,t,Y0,opt,mF,wF,nF,k,nT,wT,JT); 

%% Graphische Ausgabe
figure(1)
subplot(211),plotyy(t,Y(:,1),t,2*pi*Y(:,3)), title('homogene Lösung')
subplot(212),plotyy(t,Y(:,2),t,2*pi*Y(:,4))

% Numerische Lösung volle L agrangegleichung
opt=odeset('AbsTol',1.e-7,'RelTol',1.e-6);
% Numerische Lösung LGL
[t,Y]=ode45(@dgl_Wilberforce,t,0*Y0,opt,mF,wF,nF,k,nT,wT,JT,AF,BT,w,eF,eT); 

%% Graphische Ausgabe
figure(2)
subplot(211),plotyy(t,Y(:,1),t,2*pi*Y(:,3)), title('inhomogene Lösung')
subplot(212),plotyy(t,Y(:,2),t,2*pi*Y(:,4))

% -------------------------------------------------------------------------
% Ende Programm
% -------------------------------------------------------------------------

%% Funktionen
% Lagrange-Gleichung
function dY = dgl_WilberforceH(t,Y,mF,wF,nF,k,nT,wT,JT)
    dY = [   Y(2)
            -wF^2*Y(1)-1/2*k*Y(3)-nF/mF*Y(2)
             Y(4)
            -wT^2*Y(3)-1/2*k*Y(1)-nT/JT*Y(4)
         ];
end
function dY = dgl_Wilberforce(t,Y,mF,wF,nF,k,nT,wT,JT,AF,BT,w,eF,eT)
    dY = [   Y(2)
            -wF^2*(Y(1)+eF*Y(1)^3)-1/2*k/mF*Y(3)-nF/mF*Y(2) + AF*sin(w*t)
             Y(4)
            -wT^2*(Y(3)+eT*Y(3)^3)-1/2*k/JT*Y(1)-nT/JT*Y(4) + BT*sin(w*t)
         ];
end
% -------------------------------------------------------------------------
% Ende Funktionen
% -------------------------------------------------------------------------
