% -------------------------------------------------------------------------
% Tank.m
% -------------------------------------------------------------------------
% MATLAB-Programm zum Kapitel "Physikalische Grundlagen Aerodynamik" aus
% "Fingerübungen der Physik" von Michael Kaschke und Holger Cartarius
% unter Mitwirkung von Ulrich Potthoff
% Alle Rechte bei den Autoren
% Freier Gebrauch mit Buch und/oder Angabe der Quelle erlaubt.
% -------------------------------------------------------------------------
% Programm stellt das Potential, das Strömungsfeld und die Stromlinien
% einer Staupunktströmung dar. 
% -------------------------------------------------------------------------

clc
clear all
close all 
addpath('IncludeFolder')
addpath('Data')
Colors = GetColorLines;
Style = ["-", "-.", ":", "--", ":"];

%% Parameter
a = 1.;                             % Skalierungsfaktor

Nxy = 100;                          % Gitterpunkte in jede Richtung

xymin = -5;                         % minimaler x- bzw. y-Wert 
xymax =  5;                         % maximaler x- bzw. y-Wert

dxy = (xymax-xymin)/Nxy;            % Abstand zwischen zwei Gitterpunkten

% Setze das Gitter
for i = 1:Nxy+1
    ValX(i) = xymin+dxy*(i-1);
end
for i = 1:Nxy+1
    ValY(i) = xymin+dxy*(i-1);
end

%% Setze das Potential und das Geschwindigkeitsfeld
for i = 1:Nxy+1
    for j = 1:Nxy+1
        Psi(i,j) = Potential(a,ValX(i),ValY(j));
    end
end
[vY,vX] = gradient(Psi,dxy);

%% Darstellung der Ergebnisse

% Selektiere Punkte, die verwendet werden sollen
Dx  = 10;  % jeder Dx-te Punkt entlang der x-Achse wird verwendet
Dy  = 10;  % jeder Dy-te Punkt entlang der y-Achse wird verwendet
NNx = fix(Nxy/Dx);
NNy = fix(Nxy/Dy);
for i = 1:NNx
    ValXt(i) = ValX(Dx*(i-1)+1);
end
for j = 1:NNy         
    ValYt(j) = ValY(Dy*(j-1)+1);
end
for i = 1:NNx
    for j = 1:NNy         
        vXt(i,j) = vX(Dx*(i-1)+1,Dy*(j-1)+1);
        vYt(i,j) = vY(Dx*(i-1)+1,Dy*(j-1)+1);
    end
end


% Psi-Konturplot (Äquipotentiallinien)
figure
subplot(1,2,1)
contour(ValX,ValY,transpose(Psi),30,'linewidth',2, 'color', Colors(3,:));
grid on;
xlabel('{\itx}');
ylabel('{\ity}');
axis([xymin xymax xymin xymax])
axis equal
text(-6.5,5,'\bfa','FontSize',16,'FontName','Times', ...
      'FontWeight','normal');
set(gca,'FontSize',16,'FontName','Times');

% Geschwindigkeitsfeld
subplot(1,2,2)
axis([xymin xymax xymin xymax])
axis square
hold on
q= quiver(ValXt,ValYt,transpose(vYt),-transpose(vXt),'linewidth',2, ...
    'color', Colors(3,:));
grid on;
xlabel('{\itx}');
ylabel('{\ity}');
axis([xymin xymax xymin xymax])
axis square
text(-6.5,5,'{\bfb}','FontSize',16,'FontName','Times', ...
      'FontWeight','normal');
set(gca,'FontSize',16,'FontName','Times');

% -------------------------------------------------------------------------
% Ende Programm
% -------------------------------------------------------------------------



%% Funktionen

% Potential
function Y = Potential(a,x,y)
  Y = 0.5*a*(x^2-y^2);
end

