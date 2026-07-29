% DAE Pendel
clear all
close all
% Daten, Anfangswerte, Zeitspanne, Optionen
L = 5; m0 = 30; g = 9.81; FR = 4; T = 15;
Y0 = [15/360*2*pi; 0];
tspan = [0 20]; 
%Damit der Solver die Masse-Matrix verwenden kann, muss sie ueber die Option Mass auf
%@mass gesetzt werden. Die Loesung erfolgt mit Solver ode15s 
options = odeset('Mass', @mass);
[t Y] = ode15s(@Ydot_pendelmass,tspan,Y0,options,L,m0,g,FR,T);
% Ausgabe
figure()
plot (t,Y(:,1),'linewidth', 2);
hold on
plot (t,Y(:,2),'linewidth', 2);
grid on
legend('Y(1)', 'Y(2)','Location', 'northeast')
legend box off
set(gca,'FontSize',16);
figure()
plot (t,m0*exp(-t/T),'linewidth', 2);
legend('m(t)','Location', 'northeast')
legend box off
grid on
set(gca,'FontSize',16);

%-----------------------------------------------
% Ydot_pendelmass, DGL
function Ydot = Ydot_pendelmass(t,Y,L,m0,g,FR,T)
		m = m0*exp(-t/T);
		Ydot = [Y(2); -m*g/L*sin(Y(1)) - FR*2/pi*atan(10*Y(2))/L];
end
%-----------------------------------------------
% mass.m
% Berechnung der Masse-Matrix wird in der Funktion mass
% realisiert. Daten des Pendels als Parameter vom Solver uebergeben.
function M = mass(t,Y,L,m0,g,FR,T)
		 M = [1 0; 0 m0*exp(-t/T)];
end
