% -------------------------------------------------------------------------
% Grenzschicht01.m
% -------------------------------------------------------------------------
% MATLAB-Programm zum Kapitel "Physikalische Grundlagen AeroDznamik" aus
% "Fingerübungen der Physik" von Michael Kaschke und Holger Cartarius
% unter Mitwirkung von Ulrich Potthoff
% Alle Rechte bei den Autoren
% Freier Gebrauch mit Buch und/oder Angabe der Quelle erlaubt.
% -------------------------------------------------------------------------
% Programm berechnet den Aufbau einer Grenzschicht, die sich an zwei
% Rändern bildet, an den eine Flüssigkeit entlang der Flächen der Platten
% bewegt wird. Die beiden Platten bewegen sich mit der Geschwindigkeit
% v0 gegeneinander. In diesem Beispiel liegt keine Druckdifferenz
% innerhalb der Flüssigkeit vor, was durch ein lineares
% Geschwindigkeitsprofil erkannt wird.
% -------------------------------------------------------------------------

clc
clear all
close all 
addpath('IncludeFolder')
addpath('Data')
Colors = GetColorLines;
Style = ["-", "-.", ":", "--", ":"];

%% Parameter
Nit = 500000;                       % (maximale) Zahl an Iterationen
s = 0.1;                            % Konvergenzparameter

dh = 3.e-3;                         % Abstand zwischen zwei Gitterpunkten
                                    % in m
Ny = 100;                           % Gitterpunkte in y-Richtung
Nz = 100;                           % Gitterpunkte in z-Richtung

maxY = dh*Ny;                       % Rechter Rand
maxZ = dh*Nz;                       % Oberer Rand

nu  = 2.5e-3;                       % kinematische Viskosität

% Setze das Gitter
for i = 1:Ny+1
    ValY(i) = dh*(i-1);
end
for i = 1:Nz+1
    ValZ(i) = dh*(i-1);
end

% Geschwindigkeit
v0 = 2.;                            % am rechten Rand

%% Bereite die Gitter vor
u = zeros(Ny+1,Nz+1);
Omega = zeros(Ny+1,Nz+1);


fprintf('\n');
fprintf('\n Numerische Integration läuft');
fprintf('\n Bitte etwas Geduld ...');
fprintf('\n');

%% Integration der Lösung
it = 0;
while it < Nit
    % Interation für u
    Y          = SetzeRaender(u,Omega,dh,Ny,Nz,v0);
    u(:,:)     = Y(1,:,:);
    Omega(:,:) = Y(2,:,:);
    for i = 2:Ny
        for j = 2:Nz
            r1 = s*((u(i+1,j)+u(i-1,j)+u(i,j+1)+u(i,j-1) ...
                +2*dh*dh*Omega(i,j))*0.25-u(i,j));
            u(i,j) = u(i,j) + r1;
        end
    end

    % Iteration für Omega
    Y          = SetzeRaender(u,Omega,dh,Ny,Nz,v0);
    u(:,:)     = Y(1,:,:);
    Omega(:,:) = Y(2,:,:);
    for i = 2:Ny
        for j = 2:Nz
            a1 = Omega(i+1,j)+Omega(i-1,j)+Omega(i,j+1)+Omega(i,j-1);
            a2 = (u(i,j+1)-u(i,j-1))*(Omega(i+1,j)-Omega(i-1,j));
            a3 = (u(i+1,j)-u(i-1,j))*(Omega(i,j+1)-Omega(i,j-1));
            r2 = s*(0.25*(a1+(0.25/nu)*(a3-a2))-Omega(i,j));
            Omega(i,j) = Omega(i,j)+r2;
        end
    end

    it = it+1;
end

fprintf('\n');
fprintf('\n Numerische Integration fertig');
fprintf('\n');
pause(0.2);


%% Darstellung der Ergebnisse
% Berechne Geschwindigkeitsvektoren
[gZ,gY] = gradient(u,dh);

% Selektiere Punkte, die verwendet werden sollen
Dy  = 5;  % jeder Dy-te Punkt entlang der y-Achse wird verwendet
Dz  = 5;  % jeder Dz-te Punkt entlang der z-Achse wird verwendet
NNy = fix(Ny/Dy);
NNz = fix(Nz/Dz);
for i = 1:NNy
    ValYt(i) = ValY(Dy*(i-1)+1);
end
for j = 1:NNz         
    ValZt(j) = ValZ(Dz*(j-1)+1);
end
for i = 1:NNy
    for j = 1:NNz         
        gYt(i,j) = gY(Dy*(i-1)+1,Dz*(j-1)+1);
        gZt(i,j) = gZ(Dy*(i-1)+1,Dz*(j-1)+1);
    end
end


% u-Konturplot (Flusslinien)
figure
subplot(1,3,1)
contour(ValY,ValZ,transpose(u),30,'linewidth',2, 'color', Colors(3,:));
grid on;
xlabel('{\itx}/m');
ylabel('{\ity}/m');
axis([0 maxY 0 maxZ])
axis equal
title('{\itu}({\itx},{\ity})','FontSize',14,'FontName','Times', ...
      'FontWeight','normal');
set(gca,'FontSize',16,'FontName','Times');

% Omega-Konturplot (Vortexlinien)
subplot(1,3,2)
contour(ValY,ValZ,transpose(Omega),100,'linewidth',2, 'color', Colors(3,:));
grid on;
xlabel('{\itx}/m');
ylabel('{\ity}/m');
axis([0 maxY 0 maxZ])
axis equal
title('{\Omega}({\itx},{\ity})','FontSize',14,'FontName','Times', ...
      'FontWeight','normal');
set(gca,'FontSize',16,'FontName','Times');

subplot(1,3,3)
axis square
hold on
q= quiver(ValYt,ValZt,transpose(gZt),-transpose(gYt),'linewidth',2, ...
    'color', Colors(3,:));
grid on;
xlabel('{\itx}/m');
ylabel('{\ity}/m');
axis([0 maxY 0 maxZ])
axis square
title('{\bfv}({\itx},{\ity})','FontSize',14,'FontName','Times', ...
      'FontWeight','normal');
set(gca,'FontSize',16,'FontName','Times');

% Verlauf der Geschwindigkeit
figure
plot(ValY,-gY(:,1),'linewidth',6, 'color', ...
      Colors(1,:));
hold on
plot(ValY,-gY(:,Nz/2),'linewidth',4, 'color', ...
      Colors(2,:));
hold on
plot(ValY,-gY(:,Nz+1),'linewidth',2, 'color', ...
      Colors(3,:));
grid on;
xlabel('{\itx}/m');
ylabel('{\itv_y}/m');
%axis([0 0.3 0 0.03])
set(gca,'FontSize',16,'FontName','Times');
% -------------------------------------------------------------------------
% Ende Programm
% -------------------------------------------------------------------------



%% Funktion
% Ränder setzen
function Y = SetzeRaender(u,Omega,dh,Ny,Nz,v0)

  % Breite der Strömung
  b = Ny*dh;

  % rechter Rand
  for j = 1:Nz
      u(Ny+1,j)   = u(Ny,j)-v0*dh;   % du/dy = -vz = -v0
      Omega(Ny,j) = 0.5*v0/b;
  end
  
  % unterer Rand  
  for i = 1:Ny+1
      u(i,1)       = u(i,2);         % du/dz = vy = 0
      Omega(i,1)   = Omega(i,2);     % Stetigkeit von Omega
  end
  
  % oberer Rand
  for i = 1:Ny+1
      u(i,Nz+1)     = u(i,Nz);       % du/dz = vy = 0
      Omega(i,Nz+1) = Omega(i,Nz);   % Stetigkeit von Omega
  end
    
  % linker Rand
  for j = 1:Nz
      u(1,j)     = u(2,j);           % du/dy = -vz = 0
      Omega(1,j) = 0.5*v0/b; 
  end
  
  Y(1,:,:) = u(:,:);
  Y(2,:,:) = Omega(:,:);
end