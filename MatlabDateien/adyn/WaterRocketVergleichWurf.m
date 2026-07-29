% -------------------------------------------------------------------------
% WaterRocketVergleichWurf.m
% -------------------------------------------------------------------------
% MATLAB-Programm zum Kapitel "Astrodynamik" aus
% "Fingerübungen der Physik" von Michael Kaschke und Holger Cartarius
% unter Mitwirkung von Ulrich Potthoff
% Alle Rechte bei den Autoren
% Freier Gebrauch mit Buch und/oder Angabe der Quelle erlaubt.
% -------------------------------------------------------------------------
% 
% Programm simuliert Wasserrakete und vergleicht mit schrägen Wurf.
%--------------------------------------------------------------------------

clc
clear 
close all 
addpath('IncludeFolder')
addpath('Data')
Colors = GetColorLines;
Style = ["-", "-.", ":", "--", ":"];


%% Schräger Wurf mit Luftreibung:
%  Trajektorie y(x), Zeitverläufe x(t), y(t),
%  sowie Error-Map über Abwurfwinkel theta und Anfangsgeschwindigkeit v0.
%
%  Gegeben:
%    m   = 75 g
%    Cd  = 0.35
%    A   = 20 cm^2
%    Reichweite gemessen: 86.1 m
%    Maximalhöhe gemessen: 33.7 m
%
%  Modell:
%    quadratische Luftreibung
%    F_D = 1/2 * rho * Cd * A * v^2
%    Richtung entgegen der Geschwindigkeit
%
%  Annahmen:
%    - Start- und Landehöhe gleich
%    - konstante Luftdichte
%    - kein Wind
%
%  Das Skript:
%    1) berechnet eine Error-Map in (theta, v0)
%    2) findet den besten Parameterpunkt
%    3) plottet y(x), x(t), y(t)

%% -----------------------------
%  Parameter
%  -----------------------------
par.m   = 0.075;      % kg
par.Cd  = 0.35;       % Widerstandsbeiwert
par.A   = 20e-4;      % 20 cm^2 = 0.002 m^2
par.rho = 1.225;      % kg/m^3
par.g   = 9.81;       % m/s^2

% Messwerte
R_meas = 86.1;   % gemessene Reichweite [m]
H_meas = 33.7;   % gemessene maximale Höhe [m]

% Startbedingungen
x0 = 0;
y0 = 0;

%% -----------------------------
%  Suchbereich für Error-Map
%  -----------------------------
theta_deg_vec = linspace(20, 80, 181);   % Grad
v0_vec        = linspace(20, 80, 241);   % m/s

nTheta = numel(theta_deg_vec);
nV0    = numel(v0_vec);

ErrMap = nan(nTheta, nV0);
R_map  = nan(nTheta, nV0);
H_map  = nan(nTheta, nV0);
T_map  = nan(nTheta, nV0);

%% -----------------------------
%  Error-Map berechnen
%  -----------------------------
for i = 1:nTheta
    theta_deg = theta_deg_vec(i);

    for j = 1:nV0
        v0 = v0_vec(j);

        sim = simulate_throw(v0, theta_deg, x0, y0, par);

        R_map(i,j) = sim.range;
        H_map(i,j) = sim.hmax;
        T_map(i,j) = sim.t(end);

        % Fehlermaß:
        % normierte quadratische Abweichung in Reichweite und Höhe
        eR = (sim.range - R_meas)/R_meas;
        eH = (sim.hmax  - H_meas)/H_meas;

        ErrMap(i,j) = sqrt(eR.^2 + eH.^2);
        % Alternative:
        % ErrMap(i,j) = eR.^2 + eH.^2;
    end
end

%% -----------------------------
%  Besten Punkt finden
%  -----------------------------
[minErr, idx] = min(ErrMap(:));
[iBest, jBest] = ind2sub(size(ErrMap), idx);

theta_best = theta_deg_vec(iBest);
v0_best    = v0_vec(jBest);

bestSim = simulate_throw(v0_best, theta_best, x0, y0, par);

fprintf('Bester Fit:\n');
fprintf('  theta_best = %.3f deg\n', theta_best);
fprintf('  v0_best    = %.3f m/s\n', v0_best);
fprintf('  Reichweite = %.3f m\n', bestSim.range);
fprintf('  H_max      = %.3f m\n', bestSim.hmax);
fprintf('  Flugzeit   = %.3f s\n', bestSim.t(end));
fprintf('  Fehlermaß  = %.6f\n', minErr);

%% -----------------------------
%  Plot 1: Error-Map
%  -----------------------------
figure('Name','Error-Map','Color','w');
imagesc(v0_vec, theta_deg_vec, ErrMap);
set(gca,'YDir','normal');
xlabel('v_0 [m/s]');
ylabel('\theta [deg]');
title('Error-Map: Anpassung an Reichweite und Maximalhöhe');
colorbar;
hold on;
plot(v0_best, theta_best, 'wo', 'MarkerSize', 10, 'LineWidth', 2);
text(v0_best, theta_best, sprintf('  Best Fit: %.2f^\\circ, %.2f m/s', theta_best, v0_best), ...
    'Color','w','FontWeight','bold','VerticalAlignment','bottom');

%% -----------------------------
%  Plot 2: Trajektorie y(x)
%  -----------------------------
figure('Name','Trajektorie y(x)','Color','w');
plot(bestSim.x, bestSim.y, 'LineWidth', 2);
grid on;
xlabel('x [m]');
ylabel('y [m]');
title(sprintf('Trajektorie y(x),  \\theta = %.2f^\\circ,  v_0 = %.2f m/s', theta_best, v0_best));

hold on;
plot(bestSim.range, 0, 'ro', 'MarkerFaceColor', 'r');
[~, idxH] = max(bestSim.y);
plot(bestSim.x(idxH), bestSim.y(idxH), 'ko', 'MarkerFaceColor', 'k');
legend('y(x)', 'Landepunkt', 'Scheitelpunkt', 'Location', 'best');

%% -----------------------------
%  Plot 3: x(t) und y(t)
%  -----------------------------
figure('Name','Zeitverlauf','Color','w');

subplot(2,1,1);
plot(bestSim.t, bestSim.x, 'LineWidth', 2);
grid on;
xlabel('t [s]');
ylabel('x(t) [m]');
title('Horizontalbewegung');

subplot(2,1,2);
plot(bestSim.t, bestSim.y, 'LineWidth', 2);
grid on;
xlabel('t [s]');
ylabel('y(t) [m]');
title('Vertikalbewegung');

%% -----------------------------
%  Plot 4: Vergleich mit Vakuumlösung (optional)
%  -----------------------------
vac = vacuum_throw(v0_best, theta_best, x0, y0, par);

figure('Name','Vergleich Luftreibung / Vakuum','Color','w');
plot(bestSim.x, bestSim.y, 'LineWidth', 2);
hold on;
plot(vac.x, vac.y, '--', 'LineWidth', 2);
grid on;
xlabel('x [m]');
ylabel('y [m]');
title('Trajektorie: mit Luftreibung vs. Vakuum');
legend('mit Luftreibung','ohne Luftreibung','Location','best');

%% -----------------------------
%  Ausgabe der Parameter
%  -----------------------------
fprintf('\nVergleich zu Messwerten:\n');
fprintf('  R_meas = %.3f m,   R_fit = %.3f m,   DeltaR = %.3f m\n', ...
    R_meas, bestSim.range, bestSim.range - R_meas);
fprintf('  H_meas = %.3f m,   H_fit = %.3f m,   DeltaH = %.3f m\n', ...
    H_meas, bestSim.hmax, bestSim.hmax - H_meas);

%% ============================================================
%  Lokale Funktionen
%  ============================================================

function sim = simulate_throw(v0, theta_deg, x0, y0, par)
    % Anfangswerte
    theta = deg2rad(theta_deg);
    vx0 = v0*cos(theta);
    vy0 = v0*sin(theta);

    Y0 = [x0; y0; vx0; vy0];

    % ODE-Optionen mit Event: Integration stoppen bei y=0 im Abstieg
    opts = odeset('Events', @(t,Y) hit_ground_event(t,Y), ...
                  'RelTol', 1e-8, 'AbsTol', 1e-10);

    % ausreichend großes Zeitfenster
    tspan = [0, 30];

    [t, Y, te, Ye, ~] = ode45(@(t,Y) eom_drag(t,Y,par), tspan, Y0, opts);

    x  = Y(:,1);
    y  = Y(:,2);
    vx = Y(:,3);
    vy = Y(:,4);

    % Falls Event ausgelöst wurde, Endpunkt sauber ergänzen
    if ~isempty(te)
        t_end = te(end);
        x_end = Ye(end,1);
        y_end = Ye(end,2);
        vx_end = Ye(end,3);
        vy_end = Ye(end,4);

        if abs(t(end)-t_end) > 1e-12
            t  = [t;  t_end];
            x  = [x;  x_end];
            y  = [y;  y_end];
            vx = [vx; vx_end];
            vy = [vy; vy_end];
        end
    end

    sim.t     = t;
    sim.x     = x;
    sim.y     = y;
    sim.vx    = vx;
    sim.vy    = vy;
    sim.range = x(end);
    sim.hmax  = max(y);
end

function dYdt = eom_drag(~, Y, par)
    % Zustand
    % Y = [x; y; vx; vy]
    vx = Y(3);
    vy = Y(4);

    v = sqrt(vx^2 + vy^2);

    % Drag-Koeffizient vor vx, vy
    k = 0.5 * par.rho * par.Cd * par.A / par.m;

    ax = -k * v * vx;
    ay = -par.g - k * v * vy;

    dYdt = [vx; vy; ax; ay];
end

function [value, isterminal, direction] = hit_ground_event(~, Y)
    % Stoppe, wenn das Projektil den Boden erreicht (y=0) und dabei fällt
    value = Y(2);      % y
    isterminal = 1;    % Integration stoppen
    direction = -1;    % nur abwärts gerichtetes Kreuzen
end

function vac = vacuum_throw(v0, theta_deg, x0, y0, par)
    theta = deg2rad(theta_deg);

    vx0 = v0*cos(theta);
    vy0 = v0*sin(theta);

    % Flugzeit bis y=0
    % y(t) = y0 + vy0 t - 1/2 g t^2
    % bei y0=0: t_f = 2 vy0 / g
    if y0 == 0
        tf = 2*vy0/par.g;
    else
        tf = (vy0 + sqrt(vy0^2 + 2*par.g*y0))/par.g;
    end

    t = linspace(0, tf, 500).';

    x = x0 + vx0*t;
    y = y0 + vy0*t - 0.5*par.g*t.^2;

    vac.t = t;
    vac.x = x;
    vac.y = y;
end