% -------------------------------------------------------------------------
% WaterRocket.m
% -------------------------------------------------------------------------
% MATLAB-Programm zum Kapitel "Astrodynamik" aus
% "Fingerübungen der Physik" von Michael Kaschke und Holger Cartarius
% unter Mitwirkung von Ulrich Potthoff
% Alle Rechte bei den Autoren
% Freier Gebrauch mit Buch und/oder Angabe der Quelle erlaubt.
% -------------------------------------------------------------------------
% 
% Programm simuliert Wasserrakete.
%--------------------------------------------------------------------------

clc
clear 
close all 
addpath('IncludeFolder')
addpath('Data')
Colors = GetColorLines;
Style = ["-", "-.", ":", "--", ":"];

% ===== Beispielwerte =====
params.Vw0    = 0.000375;       % 0.25 L
params.Va0    = 0.000375;       % 0.25 L
params.Vb     = params.Vw0 + params.Va0;

% Druck: ABSOLUT!
% z.B. 7 bar Überdruck: p0_abs = 101325 + 7e5
params.p0_abs = 6.50e5;       % 6..8 bar abs 
params.dn     = 0.0050;       % 4-5 mm Düsendurchmesser
params.theta  = 55;           % deg

params.mdry   = 0.070;        % 50-75 g

% Aerodynamik / Düse
params.Cd_noz_w = 0.95;
params.Cd_noz_g = 0.95;
params.Cd_aero  = 0.40;
params.Aref     = pi*(0.025^2); % ~10 cm Durchmesser

params.dt   = 1e-3;
params.tmax = 8;

fprintf('\n===== Simulation =====\n');
fprintf('\nParameter\n')
fprintf('Wasservolumen t=0 ~ %.3f l\n', params.Vw0*1e3);
fprintf('Luftvolumen t=0   ~ %.3f l\n', params.Va0*1e3);
fprintf('Masse Flasche     ~ %.2f g\n', params.mdry*1000);
fprintf('Druck t=0         ~ %.2f Pa\n', params.p0_abs);
fprintf('Düsendurchmesser  ~ %.2f mm\n', params.dn*1000);
fprintf('CD-Wert           ~ %.2f \n', params.Cd_aero);
fprintf('Querschnitt       ~ %.2f cm²\n', params.Aref*1e4);
fprintf('Winkel            ~ %.2f °\n', params.theta);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulation
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out = waterRocketSim(params);

fprintf('Messwerte\n')
fprintf('Reichweite ~ %.1f m\n', out.Range);
fprintf('max. Höhe  ~ %.1f m\n', out.Apogee);
fprintf('Flugzeit   ~ %.2f s\n', out.FlightTime);

fprintf('Berechnete Werte\n')
fprintf('MaxThrust  ~ %.0f N\n', out.MaxThrust);

figure; plot(out.x, out.z, 'LineWidth', 1.5); grid on;
xlabel('x [m]'); ylabel('z [m]'); ht=title('Trajektorie x-z');
set(ht,'FontSize',12, 'FontWeight', 'normal');
set(gca,'FontSize',12, 'FontWeight', 'normal');

figure; plot(out.t, out.z, 'LineWidth', 1.5); grid on;
xlabel('t [s]'); ylabel('z [m]'); ht=title('Trajektorie über Zeit');
set(ht,'FontSize',12, 'FontWeight', 'normal');
set(gca,'FontSize',12, 'FontWeight', 'normal');

figure; plot(out.t, out.T, 'LineWidth', 1.5); grid on;
xlabel('t [s]'); ylabel('T [N]'); ht=title('Schub über Zeit');
set(ht,'FontSize',12, 'FontWeight', 'normal');
set(gca,'FontSize',12, 'FontWeight', 'normal');

figure; plot(out.t, out.p/1e5, 'LineWidth', 1.5); grid on;
xlabel('t [s]'); ylabel('p [bar]'); ht=title('Flaschendruck');
set(ht,'FontSize',12, 'FontWeight', 'normal');
set(gca,'FontSize',12, 'FontWeight', 'normal');

figure; stairs(out.t, out.phase, 'LineWidth', 1.5); grid on;
xlabel('t [s]'); ylabel('phase (1=Wasser,2=Luft,0=frei)');
ht=title('Phasen');
ylim([-0.2 2.2]);
set(ht,'FontSize',12, 'FontWeight', 'normal');
set(gca,'FontSize',12, 'FontWeight', 'normal');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vergleich mit Simulation schräger Wurf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameter
%  -----------------------------
par.m   = 0.075;      % kg
par.Cd  = 0.35;       % Widerstandsbeiwert
par.A   = 20e-4;      % 20 cm^2 = 0.002 m^2
par.rho = 1.225;      % kg/m^3
par.g   = 9.81;       % m/s^2
theta_deg = 52.333;   % aus Programm WaterRocketVergleichWurdeg
v0        = 37.500;   % aus Programm WaterRocketVergleichWurf in m/s
% Messwerte
R_meas = 86.1;   % gemessene Reichweite [m]
H_meas = 33.7;   % gemessene maximale Höhe [m]

% Startbedingungen
x0 = 0;
z0 = 0;

bestSim = simulate_throw(v0, theta_deg, x0, z0, par);

%% -----------------------------
%  Plot 1: Trajektorie y(x)
%  -----------------------------
figure('Name','Trajektorie y(x)','Color','w');
hold on 
plot(out.x, out.z,'color',Colors(2,:), 'LineWidth', 1.5); grid on;
plot(bestSim.x, bestSim.z, 'color',Colors(4,:),'LineWidth', 1.5, 'LineStyle', Style(3));
xlabel('x [m]'); ylabel('z [m]'); 
plot(bestSim.range, 0, 'ro', 'MarkerFaceColor', 'r');
[~, idxH] = max(bestSim.z);
plot(bestSim.x(idxH), bestSim.z(idxH), 'ko', 'MarkerFaceColor', 'k');
legend('y(z) Rakete', 'y(z) Wurf', 'Landepunkt', 'Scheitelpunkt', 'Location', 'south');
legend box off
title(sprintf('Trajektorie z(x),  \\theta = %.2f^\\circ,  v_0 = %.2f m/s', theta_deg, v0));
set(ht,'FontSize',12, 'FontWeight', 'normal');
set(gca,'FontSize',12, 'FontWeight', 'normal');


%% -----------------------------
%  Plot 2: zy(t)
%  -----------------------------
figure('Name','Zeitverlauf','Color','w');
hold on
plot(out.t, out.z,'color',Colors(2,:), 'LineWidth', 1.5);
plot(bestSim.t, bestSim.z,'color',Colors(4,:), 'LineWidth',1.5,'LineStyle', Style(3));
grid on;
xlabel('t [s]'); ylabel('z [m]'); ht=title('Trajektorie über Zeit');
legend('y(z) Rakete', 'y(z) Wurf', 'Location', 'south');
legend box off
set(ht,'FontSize',12, 'FontWeight', 'normal');
set(gca,'FontSize',12, 'FontWeight', 'normal');


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Map zur Bestimmung der Parameter
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ------------------------------------------------------------
% Feste Raketenparameter 
% ------------------------------------------------------------
baseParams.Vw0    = 0.375e-3;          % 0.375 L
baseParams.Va0    = 0.375e-3;          % 0.375 L
baseParams.Vb     = baseParams.Vw0 + baseParams.Va0;

baseParams.mdry   = 0.07;           % 55 g
baseParams.dn     = 5e-3;           % 5 mm

baseParams.Aref   = 19.63e-4;        % 19.63 cm^2 = 1.963e-3 m^2

% Winkel und Schiene musst du passend zu deinem Experiment setzen:
baseParams.theta  = 55;              % Beispielwert -> bitte anpassen
baseParams.Lrail  = 0.10;            % 10 cm, falls passend
baseParams.Cd_noz_w = 0.95;
baseParams.Cd_noz_g = 0.95;

baseParams.dt     = 1e-4;
baseParams.tmax   = 8;

baseParams.smoothTransition = true;
baseParams.transFrac = 0.02;

% ------------------------------------------------------------
% Darstellungs-Optionen 
% ------------------------------------------------------------
opts.mode = 'contour';   % oder 'imagesc'
% opts.mode = 'imagesc';   % oder 'contour'
opts.maxLog = 10;         % 2-5
opts.usePercentile = true;
opts.showContours = true;

% ------------------------------------------------------------
% Messwerte
% ------------------------------------------------------------
expData.Rexp = 87.9;                 % m
expData.Hexp = 32.3;                 % m
expData.Texp =  5.7;                 % s

% Gewichte der Kostenfunktion:
% fuer nur Reichweite + Flugzeit:
expData.wR = 1;
expData.wT = 1;
expData.wH = 0;

% ------------------------------------------------------------
% Gitter der freien Parameter
% ------------------------------------------------------------
gridSpec.CdVals = linspace(0.20, 0.60, 41);

% Druck in Pa ABSOLUT
% p_abs = 101325 + p_gauge.
gridSpec.pVals  = linspace(4e5, 8e5, 41);

% ------------------------------------------------------------
% Berechnung
% ------------------------------------------------------------
map = errorMapWaterRocket_CdPressure(baseParams, expData, gridSpec);

fprintf('\n===== Bestes Gitterergebnis =====\n');
fprintf('Bestes C_D          = %.4f\n', map.bestCd);
fprintf('Bester p0_abs       = %.2f Pa\n', map.bestP);
fprintf('Bester p0_abs       = %.3f bar abs\n', map.bestP/1e5);
fprintf('Kostenfunktion J    = %.6g\n', map.bestCost);

iP  = map.bestIndex(1);
iCd = map.bestIndex(2);

if all(~isnan([iP iCd]))
    fprintf('Sim. Reichweite     = %.3f m\n', map.Rsim(iP,iCd));
    fprintf('Sim. Maximalhoehe   = %.3f m\n', map.Hsim(iP,iCd));
    fprintf('Sim. Flugzeit       = %.3f s\n', map.Tsim(iP,iCd));
end

% ------------------------------------------------------------
% Darstellung Error-Map
% ------------------------------------------------------------

plotErrorMapSmart(map, expData, opts, Colors, Style);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = waterRocketSim(params)
% waterRocketSim
% Simuliert eine Wasserrakete mit:
%   - Wasser-Schubphase
%   - geglättetem Übergang Wasser -> Gas
%   - Gas-Schubphase
%   - Startschiene
%   - freiem 2D-Flug mit quadratischem Luftwiderstand
%
% AUSGABEN:
%   out.t, out.x, out.y, out.vx, out.vy
%   out.T         Schub [N]
%   out.phase     1=water, 1.5=transition, 2=gas, 0=coast
%   out.p         Flaschendruck [Pa]
%   out.mw        Wassermasse [kg]
%   out.ma        Luftmasse [kg]
%   out.Range
%   out.Apogee
%   out.FlightTime
%   out.MaxThrust
%   out.RailExitSpeed
%   out.RailExitTime
%   out.WaterEndTime
%   out.GasEndTime
%
% EINGABEN (Pflicht):
%   params.Vw0      [m^3] Anfangs-Wasservolumen
%   params.Va0      [m^3] Anfangs-Luftvolumen
%   params.Vb       [m^3] Flaschenvolumen = Vw0 + Va0
%   params.p0_abs   [Pa]  Anfangsdruck (ABSOLUTDRUCK)
%   params.dn       [m]   Düsendurchmesser
%   params.theta    [deg] Abschusswinkel
%   params.mdry     [kg]  Trockenmasse
%
% OPTIONALE PARAMETER:
%   params.Cd_noz_w        default 0.90
%   params.Cd_noz_g        default 0.90
%   params.Cd_aero         default 0.55
%   params.Aref            default pi*(0.05^2)
%   params.pamb            default 101325
%   params.rho_w           default 1000
%   params.rho_air         default 1.225
%   params.gamma           default 1.4
%   params.R               default 287.05
%   params.T0              default 293.15
%   params.g               default 9.81
%   params.dt              default 1e-4
%   params.tmax            default 30
%   params.Lrail           default 0.5
%   params.smoothTransition default true
%   params.transFrac       default 0.01
%
% HINWEIS:
% Dies ist ein Simulationsmodell, kein vollständiges
% Zweiphasenmodell. Der Übergang Wasser -> Gas wird numerisch geglättet.

    % -------------------- Defaults --------------------
    def = struct();
    def.Cd_noz_w         = 0.90;
    def.Cd_noz_g         = 0.90;
    def.Cd_aero          = 0.55;
    def.Aref             = pi*(0.05^2);
    def.pamb             = 101325;
    def.rho_w            = 1000;
    def.rho_air          = 1.225;
    def.gamma            = 1.4;
    def.R                = 287.05;
    def.T0               = 293.15;
    def.g                = 9.81;
    def.dt               = 1e-4;
    def.tmax             = 30;
    def.Lrail            = 0.5;
    def.smoothTransition = true;
    def.transFrac        = 0.01;

    fn = fieldnames(def);
    for i = 1:numel(fn)
        if ~isfield(params, fn{i})
            params.(fn{i}) = def.(fn{i});
        end
    end

    % -------------------- Unpack --------------------
    Vw0    = params.Vw0;
    Va0    = params.Va0;
    Vb     = params.Vb;
    p0_abs = params.p0_abs;
    dn     = params.dn;
    theta  = deg2rad(params.theta);
    mdry   = params.mdry;

    Cd_noz_w = params.Cd_noz_w;
    Cd_noz_g = params.Cd_noz_g;
    Cd_aero  = params.Cd_aero;
    Aref     = params.Aref;

    pamb   = params.pamb;
    rho_w  = params.rho_w;
    rhoAir = params.rho_air;
    gamma  = params.gamma;
    R      = params.R;
    T0     = params.T0;
    g      = params.g;
    dt     = params.dt;
    tmax   = params.tmax;
    Lrail  = params.Lrail;

    An = pi*(dn/2)^2;

    % -------------------- Initial states --------------------
    mw  = rho_w * Vw0;   % water mass
    mw0 = mw;

    TgasBottle = T0;
    ma  = p0_abs * Va0 / (R * TgasBottle);  % initial air mass
    Va  = Va0;
    p   = p0_abs;

    % Kinematics
    x = 0; y = 0;
    vx = 0; vy = 0;

    onRail = true;
    sRail = 0;

    t = 0;

    % Choked criterion
    critRatio = (2/(gamma+1))^(gamma/(gamma-1));

    % Transition mass threshold
    transitionMass = params.transFrac * mw0;

    % Rail exit data
    railExitRecorded = false;
    railExitSpeed = NaN;
    railExitTime  = NaN;

    % Phase-end times
    waterEndTime = NaN;
    gasEndTime   = NaN;

    % -------------------- Storage --------------------
    Nmax = ceil(tmax/dt) + 5;
    tArr     = nan(Nmax,1);
    xArr     = nan(Nmax,1);
    yArr     = nan(Nmax,1);
    vxArr    = nan(Nmax,1);
    vyArr    = nan(Nmax,1);
    TArr     = nan(Nmax,1);
    phaseArr = nan(Nmax,1);
    pArr     = nan(Nmax,1);
    mwArr    = nan(Nmax,1);
    maArr    = nan(Nmax,1);

    k = 1;

    % -------------------- Main loop --------------------
    while t <= tmax && y >= 0
        m = mdry + mw + ma;

        % ============================================================
        % Candidate water model
        % ============================================================
        T_water = 0;
        mdotw   = 0;
        p_water = p;

        if (mw > 0) && (Va < Vb - 1e-14)
            p_water = p0_abs * (Va0 / Va)^gamma;
            dpw = max(p_water - pamb, 0);

            if dpw > 0
                ve_w  = Cd_noz_w * sqrt(2*dpw/rho_w);
                mdotw = rho_w * An * ve_w;
                T_water = mdotw * ve_w;
            end
        end

        % ============================================================
        % Candidate gas model
        % ============================================================
        T_gas = 0;
        mdotg = 0;
        pe_g  = pamb;

        if (p > pamb*(1+1e-9)) && (ma > 0)
            pr = pamb / p;

            if pr <= critRatio
                % choked flow
                mdotg = Cd_noz_g * An * p * sqrt(gamma/(R*TgasBottle)) ...
                    * (2/(gamma+1))^((gamma+1)/(2*(gamma-1)));
                pe_g = p * (2/(gamma+1))^(gamma/(gamma-1));
            else
                % unchoked flow
                term = pr^(2/gamma) - pr^((gamma+1)/gamma);
                term = max(term, 0);
                mdotg = Cd_noz_g * An * p * sqrt((2*gamma)/(R*TgasBottle*(gamma-1)) * term);
                pe_g = pamb;
            end

            if pe_g < p
                ve_g = sqrt((2*gamma/(gamma-1)) * R * TgasBottle * ...
                    (1 - (pe_g/p)^((gamma-1)/gamma)));
            else
                ve_g = 0;
            end

            T_gas = mdotg * ve_g + (pe_g - pamb) * An;
        end

        % ============================================================
        % Select phase / smooth transition
        % ============================================================
        Tth = 0;
        phase = 0;

        if mw > transitionMass
            % ---------------- pure water phase ----------------
            phase = 1;
            Tth = T_water;

            dmw = mdotw * dt;
            dmw = min(dmw, mw);

            mw = mw - dmw;
            Va = min(Va + dmw/rho_w, Vb);

            p = p0_abs * (Va0 / max(Va, Va0))^gamma;

        elseif mw > 0 && params.smoothTransition
            % ---------------- smoothed transition ----------------
            % Idee:
            % - Schub wird geglaettet
            % - Druck wird NICHT gemischt
            % - solange noch Wasser da ist: Druck weiterhin aus p*V^gamma = const
        
            z = mw / transitionMass;   % z in (0,1]
            wmix = smoothWeightCosine(z);
        
            phase = 1.5;
        
            % Geglaetteter Schub
            Tth = wmix * T_water + (1 - wmix) * T_gas;
        
            % Wasserabtrag weiterfuehren
            dmw = mdotw * dt;
            dmw = min(dmw, mw);
        
            mw = mw - dmw;
            Va = min(Va + dmw/rho_w, Vb);
        
            % Solange noch Wasser vorhanden ist:
            % Druck NICHT mischen, sondern weiter aus adiabatischer Luft-Expansion
            p = p0_abs * (Va0 / max(Va, Va0))^gamma;
        
            % Temperatur des Gasreservoirs konsistent aus dem aktuellen Druck ableiten
            % (isentrop angenaehert, solange noch Wasser da ist)
            TgasBottle = T0 * (p / p0_abs)^((gamma - 1)/gamma);
        
            % Luftmasse konsistent aus idealem Gas im aktuellen Luftvolumen
            ma = (p * Va) / (R * TgasBottle);
        
            if mw <= 0 && isnan(waterEndTime)
                waterEndTime = t;
            end

        else
            % ---------------- pure gas or coast ----------------
            if isnan(waterEndTime)
                waterEndTime = t;
            end

            if (T_gas > 0) && (ma > 0) && (p > pamb*(1+1e-9))
                phase = 2;
                Tth = T_gas;

                dmg = mdotg * dt;
                dmg = min(dmg, ma);

                ma_old = ma;
                ma = ma - dmg;

                if ma_old > 0 && ma > 0
                    TgasBottle = TgasBottle * (ma/ma_old)^(gamma-1);
                end

                p = (ma * R * TgasBottle) / Vb;
                p = max(p, pamb);
            else
                phase = 0;
                Tth = 0;
                p = max(p, pamb);

                if isnan(gasEndTime) && ~isnan(waterEndTime)
                    gasEndTime = t;
                end
            end
        end

        % ============================================================
        % Motion: rail phase or free flight
        % ============================================================
        if onRail
            vRail = hypot(vx, vy);

            FdRail = 0.5 * rhoAir * Cd_aero * Aref * vRail^2;

            a_s = (Tth - FdRail - m*g*sin(theta)) / m;

            vRail = vRail + a_s * dt;
            if vRail < 0
                vRail = 0;
            end

            sRail = sRail + vRail * dt;

            x  = sRail * cos(theta);
            y  = sRail * sin(theta);
            vx = vRail * cos(theta);
            vy = vRail * sin(theta);

            if sRail >= Lrail
                onRail = false;

                if ~railExitRecorded
                    railExitRecorded = true;
                    railExitSpeed = hypot(vx, vy);
                    railExitTime  = t;
                end
            end

        else
            v = hypot(vx, vy);

            if v > 1e-12
                Fd  = 0.5 * rhoAir * Cd_aero * Aref * v^2;
                Fdx = Fd * (vx / v);
                Fdy = Fd * (vy / v);
            else
                Fdx = 0;
                Fdy = 0;
            end

            Tx = Tth * cos(theta);
            Ty = Tth * sin(theta);

            ax = (Tx - Fdx) / m;
            ay = (Ty - Fdy) / m - g;

            vx = vx + ax*dt;
            vy = vy + ay*dt;
            x  = x  + vx*dt;
            y  = y  + vy*dt;
        end

        % -------------------- Store --------------------
        tArr(k)     = t;
        xArr(k)     = x;
        yArr(k)     = y;
        vxArr(k)    = vx;
        vyArr(k)    = vy;
        TArr(k)     = Tth;
        phaseArr(k) = phase;
        pArr(k)     = p;
        mwArr(k)    = mw;
        maArr(k)    = ma;

        k = k + 1;
        t = t + dt;

        if k > Nmax
            break;
        end

        if t > 0.2 && y < 0
            break;
        end
    end

    % -------------------- Trim arrays --------------------
    idx = 1:(k-1);

    out.t     = tArr(idx);
    out.x     = xArr(idx);
    out.z     = yArr(idx);
    out.vx    = vxArr(idx);
    out.vz    = vyArr(idx);
    out.T     = TArr(idx);
    out.phase = phaseArr(idx);
    out.p     = pArr(idx);
    out.mw    = mwArr(idx);
    out.ma    = maArr(idx);

    % -------------------- Impact interpolation --------------------
    range = out.x(end);
    flightTime = out.t(end);

    if numel(out.z) >= 2 && out.z(end) < 0
        z1 = out.z(end-1); z2 = out.z(end);
        x1 = out.x(end-1); x2 = out.x(end);
        t1 = out.t(end-1); t2 = out.t(end);

        alpha = z1 / (z1 - z2);
        range = x1 + alpha*(x2 - x1);
        flightTime = t1 + alpha*(t2 - t1);
    end

    out.Range      = range;
    out.Apogee     = max(out.z);
    out.FlightTime = flightTime;
    out.MaxThrust  = max(out.T);

    out.RailExitSpeed = railExitSpeed;
    out.RailExitTime  = railExitTime;
    out.WaterEndTime  = waterEndTime;
    out.GasEndTime    = gasEndTime;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotErrorMapSmart(map, expData, opts, Colors, Style)
% plotErrorMapSmart
% Stellt Reichweite, Hoehe, Flugzeit und Kostenfunktion dar.
% Robuste Darstellung von Error-Maps (J, Jrel)
% Features:
%   - automatische Skalierung
%   - Bestpunkt-Markierung
%   - Wahl zwischen imagesc und contourf
%
% INPUT:
%   map        : Struktur aus errorMap...
%   expData    : Struktur mit Rexp, Texp, Hexp (optional)
%   opts       : optional:
%       .mode = 'imagesc' (default) oder 'contour'
%       .maxLog = 2 oder 3 (default 2)
%       .usePercentile = true/false (default true)
%       .showContours = true/false (default true)

    % ---------------- Defaults ----------------
    if nargin < 3, opts = struct(); end
    if ~isfield(opts,'mode'), opts.mode = 'imagesc'; end
    if ~isfield(opts,'maxLog'), opts.maxLog = 2; end
    if ~isfield(opts,'usePercentile'), opts.usePercentile = true; end
    if ~isfield(opts,'showContours'), opts.showContours = true; end

    CdVals = map.CdVals;
    pVals  = map.pVals / 1e5;   % bar
    [CD, P] = meshgrid(CdVals, pVals);

    % ---------- Reichweite ----------
    figure;
    imagesc(CdVals, pVals, map.Rsim);
    set(gca,'YDir','normal');
    colorbar;
    xlabel('C_D');
    ylabel('p_0 [bar abs]');
    ht= title(sprintf('Simulierte Reichweite R [m], Ziel: %.2f m', expData.Rexp));
    hold on;
    contour(CD, P, map.Rsim, [expData.Rexp expData.Rexp], 'w-', 'LineWidth', 2);
    if isfinite(map.bestCd) && isfinite(map.bestP)
        plot(map.bestCd, map.bestP/1e5, 'rx', 'MarkerSize', 12, 'LineWidth', 2);
    end
    hold off;
    set(ht,'FontSize',12, 'FontWeight', 'normal');
    set(gca,'FontSize',12, 'FontWeight', 'normal');


    % ---------- Flugzeit ----------
    figure;
    imagesc(CdVals, pVals, map.Tsim);
    set(gca,'YDir','normal');
    colorbar;
    xlabel('C_D');
    ylabel('p_0 [bar abs]');
    ht= title(sprintf('Simulierte Flugzeit T [s], Ziel: %.2f s', expData.Texp));
    hold on;
    contour(CD, P, map.Tsim, [expData.Texp expData.Texp], 'w-', 'LineWidth', 2);
    if isfinite(map.bestCd) && isfinite(map.bestP)
        plot(map.bestCd, map.bestP/1e5, 'rx', 'MarkerSize', 12, 'LineWidth', 2);
    end
    set(ht,'FontSize',12, 'FontWeight', 'normal');
    set(gca,'FontSize',12, 'FontWeight', 'normal');
    hold off;

    % % ---------- Hoehe ----------
    % if isfield(expData,'Hexp') && ~isempty(expData.Hexp)
    %     figure;
    %     imagesc(CdVals, pVals, map.Hsim);
    %     set(gca,'YDir','normal');
    %     colorbar;
    %     xlabel('C_D');
    %     ylabel('p_0 [bar abs]');
    %     title(sprintf('Simulierte Maximalhoehe H [m], Ziel: %.2f m', expData.Hexp));
    %     hold on;
    %     contour(CD, P, map.Hsim, [expData.Hexp expData.Hexp], 'w-', 'LineWidth', 2);
    %     if isfinite(map.bestCd) && isfinite(map.bestP)
    %         plot(map.bestCd, map.bestP/1e5, 'rx', 'MarkerSize', 12, 'LineWidth', 2);
    %     end
    %     hold off;
    % end

    % % ---------- Relative Fehler Reichweite ----------
    % figure;
    % imagesc(CdVals, pVals,  map.errR);
    % set(gca,'YDir','normal');
    % colorbar;
    % xlabel('C_D');
    % ylabel('p_0 [bar abs]');
    % title('Relativer Fehler der Reichweite');
    % 
    % % ---------- Relative Fehler Flugzeit ----------
    % figure;
    % imagesc(CdVals, pVals, map.errT);
    % set(gca,'YDir','normal');
    % colorbar;
    % xlabel('C_D');
    % ylabel('p_0 [bar abs]');
    % title('Relativer Fehler der Flugzeit');

    % % Kostenfunktion------------------
    J = map.J;
    J(~isfinite(J)) = NaN;
    Jbest = min(J(:), [], 'omitnan');
    Jbest = max(Jbest, 1e-12);
        Jrel = J / Jbest;
    Jrel(Jrel < 0) = 0;
    [CD,P] = meshgrid(map.CdVals, map.pVals/1e5);
        figure;
    contourf(CD, P, Jrel, 20, 'LineStyle', 'none');
    colorbar;
    xlabel('C_D');
    ylabel('p_0 [bar abs]');
    ht=title('J/J_{min}');
    set(ht,'FontSize',12, 'FontWeight', 'normal');
    hold on;
    plot(map.bestCd, map.bestP/1e5, 'rx', 'MarkerSize', 12, 'LineWidth', 2);
    contour(CD, P, map.Rsim, [expData.Rexp expData.Rexp], ...
           'Color', Colors(2,:), 'LineStyle',Style(2), 'LineWidth', 2);
    contour(CD, P, map.Tsim, [expData.Texp expData.Texp], ...
           'Color', Colors(4,:), 'LineStyle',Style(4), 'LineWidth', 2);
    if isfield(expData,'Hexp') && ~isempty(expData.Hexp) && expData.wH > 0
        contour(CD, P, map.Hsim, [expData.Hexp expData.Hexp], ...
            'Color', Colors(8,:), 'LineStyle',Style(3), 'LineWidth', 2);
    end
    if isfinite(map.bestCd) && isfinite(map.bestP)
        plot(map.bestCd, map.bestP/1e5, 'rx', 'MarkerSize', 12, 'LineWidth', 2);
        text(map.bestCd, 4.5, ...
            sprintf('  Best: C_D=%.3f, p_0=%.2f bar', map.bestCd, map.bestP/1e5), ...
            'Color', 'w', 'FontWeight', 'bold', 'VerticalAlignment', 'bottom');
    end
    set(ht,'FontSize',12, 'FontWeight', 'normal');
    set(gca,'FontSize',12, 'FontWeight', 'normal');
    hold off;


    % ---------------- Debug-Ausgabe ----------------
    % fprintf('\n--- Plot Info ---\n');
    % fprintf('Jbest      = %.3e\n', Jbest);
    % fprintf('Jrel min   = %.3f\n', min(vals));
    % fprintf('Jrel max   = %.3f\n', max(vals));
    % fprintf('caxis min  = %.3f\n', vmin);
    % fprintf('caxis max  = %.3f\n', vmax);
end


%-------------------------------------------------------------------------
function map = errorMapWaterRocket_CdPressure(baseParams, expData, gridSpec)
% errorMapWaterRocket_CdPressure
% Fehlerlandkarten fuer waterRocketSim mit freien Parametern:
%   1) Cd_aero
%   2) Anfangsdruck p0_abs
%
% INPUT
%   baseParams : Struktur fuer waterRocketSim mit allen festen Parametern
%                ausser Cd_aero und p0_abs
%
%   expData.Rexp : gemessene Reichweite [m]
%   expData.Hexp : gemessene max. Hoehe [m]      (optional)
%   expData.Texp : gemessene Flugzeit [s]
%
%   expData.wR   : Gewicht fuer Reichweite (default 1)
%   expData.wH   : Gewicht fuer Hoehe      (default 0)
%   expData.wT   : Gewicht fuer Flugzeit   (default 1)
%
%   gridSpec.CdVals : Vektor der Cd-Werte
%   gridSpec.pVals  : Vektor der Druckwerte [Pa, absolut]
%
% OUTPUT
%   map.CdVals, map.pVals
%   map.Rsim, map.Hsim, map.Tsim
%   map.errR, map.errH, map.errT
%   map.J
%   map.bestCd, map.bestP, map.bestCost, map.bestIndex

    if ~isfield(expData,'wR'), expData.wR = 1; end
    if ~isfield(expData,'wH'), expData.wH = 0; end
    if ~isfield(expData,'wT'), expData.wT = 1; end

    CdVals = gridSpec.CdVals(:)';
    pVals  = gridSpec.pVals(:)';

    nCd = numel(CdVals);
    nP  = numel(pVals);

    Rsim = nan(nP, nCd);
    Hsim = nan(nP, nCd);
    Tsim = nan(nP, nCd);

    errR = nan(nP, nCd);
    errH = nan(nP, nCd);
    errT = nan(nP, nCd);

    J = nan(nP, nCd);

    bestCost = inf;
    bestIdx = [NaN, NaN];

    wb1=waitbar(0,'Computing Error-Map ...');

    for iP = 1:nP
        for iCd = 1:nCd
            waitbar((iCd+(iP-1)*nCd)/(nP*nCd),wb1);
            params = baseParams;
            params.p0_abs  = pVals(iP);
            params.Cd_aero = CdVals(iCd);

            try
                out = waterRocketSim(params);

                R = out.Range;
                H = out.Apogee;
                T = out.FlightTime;

                Rsim(iP, iCd) = R;
                Hsim(iP, iCd) = H;
                Tsim(iP, iCd) = T;

                eR = (R - expData.Rexp) / max(expData.Rexp, 1e-9);
                eT = (T - expData.Texp) / max(expData.Texp, 1e-9);

                if isfield(expData,'Hexp') && ~isempty(expData.Hexp) && expData.wH > 0
                    eH = (H - expData.Hexp) / max(expData.Hexp, 1e-9);
                else
                    eH = 0;
                end

                errR(iP, iCd) = eR;
                errH(iP, iCd) = eH;
                errT(iP, iCd) = eT;

                cost = expData.wR*eR^2 + expData.wH*eH^2 + expData.wT*eT^2;
                J(iP, iCd) = cost;

                if isfinite(cost) && cost < bestCost
                    bestCost = cost;
                    bestIdx = [iP, iCd];
                end

            catch
                % lasse NaN stehen
            end
        end
    end
    close(wb1);
    map.CdVals = CdVals;
    map.pVals  = pVals;

    map.Rsim = Rsim;
    map.Hsim = Hsim;
    map.Tsim = Tsim;

    map.errR = errR;
    map.errH = errH;
    map.errT = errT;

    map.J = J;

    map.bestCost = bestCost;
    map.bestIndex = bestIdx;

    if all(~isnan(bestIdx))
        map.bestP  = pVals(bestIdx(1));
        map.bestCd = CdVals(bestIdx(2));
    else
        map.bestP  = NaN;
        map.bestCd = NaN;
    end
end


% ============================================================
% Local helper function
% ============================================================

function sim = simulate_throw(v0, theta_deg, x0, z0, par)
    % Anfangswerte
    theta = deg2rad(theta_deg);
    vx0 = v0*cos(theta);
    vz0 = v0*sin(theta);

    Y0 = [x0; z0; vx0; vz0];

    % ODE-Optionen mit Event: Integration stoppen bei y=0 im Abstieg
    opts = odeset('Events', @(t,Y) hit_ground_event(t,Y), ...
                  'RelTol', 1e-8, 'AbsTol', 1e-10);

    % ausreichend großes Zeitfenster
    tspan = [0, 30];

    [t, Y, te, Ye, ~] = ode45(@(t,Y) eom_drag(t,Y,par), tspan, Y0, opts);

    x  = Y(:,1);
    z  = Y(:,2);
    vx = Y(:,3);
    vz = Y(:,4);

    % Falls Event ausgelöst wurde, Endpunkt sauber ergänzen
    if ~isempty(te)
        t_end = te(end);
        x_end = Ye(end,1);
        z_end = Ye(end,2);
        vx_end = Ye(end,3);
        vz_end = Ye(end,4);

        if abs(t(end)-t_end) > 1e-12
            t  = [t;  t_end];
            x  = [x;  x_end];
            z  = [z;  z_end];
            vx = [vx; vx_end];
            vz = [vz; vz_end];
        end
    end

    sim.t     = t;
    sim.x     = x;
    sim.z     = z;
    sim.vx    = vx;
    sim.vz    = vz;
    sim.range = x(end);
    sim.hmax  = max(z);
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

function w = smoothWeightCosine(z)
    z = max(0, min(1, z));
    w = 0.5 * (1 + cos(pi * (1 - z)));
end
