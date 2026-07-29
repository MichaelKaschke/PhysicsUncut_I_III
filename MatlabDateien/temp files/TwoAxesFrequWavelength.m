% -------------------------------------------------------------------------
% LorentzModellDispersionQuarz.m
% -------------------------------------------------------------------------
% MATLAB-Programm zum Kapitel "Optik-Grundlagen" aus
% "Fingerübungen der Physik V" 
% von Michael Kaschke, Michael Kempe und Michael Totzeck
% Alle Rechte bei den Autoren
% Freier Gebrauch mit Buch und/oder Angabe der Quelle erlaubt.
% -------------------------------------------------------------------------
% 
%  Dispersion und Absorption im Lorentz-Modell
% -------------------------------------------------------------------------

clc
clear all
close all 
addpath('IncludeFolder')
addpath('Data')
Colors = GetColorLines;

Style = ["-", "-.", ":", "--", ":"];

%% Parameter

c  = 2.998*10^8;        %Lichtgeschwindigkeit in m/s
ep = 8.854*10^(-12);    %Dielektrizitätskonstante in F/m 

% Parameter for Quarz
la = 100 ;              %Resonanzwellenlänge in nm 
w0 = 2*pi*c/(la*10^(-9));
ka=w0/4;                   % Dämpfung in Hz
el=1.6*10^(-19);           %elementare Ladung in C
m_e=9.1*10^(-31);          %Ruhemasse Elektron
n_e=2.2*10^6*6*10^(23)/60; %molekulare Dichte von Quarz (SiO2)
a=5*n_e*el^2/m_e/ep;       %Amplitude mit Korrekturfaktor 5


%% Berehchnungen

N=200;
for n=1:N
    w=0+w0/(N/5)*n;
    Eps=sqrt(complex_epsilon(a,w0,w,ka)+complex_epsilon(a,w0*4,w,ka));
    Eps_r(n)= real(Eps)-sqrt(2);
    Eps_i(n)=imag(Eps);
    Epa_r(n)= real_epsilon(a,w0,w,ka)-1+real_epsilon(a,w0*4,w,ka)-1;
    Epa_i(n)= imag_epsilon(a,w0,w,ka)+imag_epsilon(a,w0*4,w,ka);
    wn(n) =w;
    ln(n) =2*pi*c/w;
    E_0(n)=0;
end

%% Abbildungen
% figure('name','Dispersion von Quarz')
% hold on;
% ax2 = axes(t);
% plot(wn,Eps_r,'b-',wn,Epa_r,'b--')
% plot(wn,Eps_i,'r-',wn,Epa_i,'r--')
% plot(wn,E_0,'k-')
% ylabel('n-1, \kappa') 
% xlabel("\omega [Hz]")
% legend('n-1','Näherung','\kappa','Näherung','Location','northeast')
% legend box off
% grid on
% set(gca,'FontSize',14);
% ht = title("Dispersion von Quarz");
% set(ht,'FontSize',12,'FontWeight','normal');

% 
% figure(1)
% plot(wn,Eps_r,'b-')
% xlabel('Frequenz \omega (Hz)')
% ylabel('n-1, \kappa') 
% set(gca,'Yscale','linear')
% figure(2)
% plot(ln,Epa_r,'b--')
% xlabel('Wavelength (\mum)')
% ylabel('n-1, \kappa') 
% set(gca,'Yscale','linear')
% 



data = [0.35737704918032787, 92649850.48039015
    0.3819672131147541, 72475211.53588514
    0.41147540983606556, 55967196.301264346
    0.4229508196721312, 51126728.207795605
    0.4557377049180328, 47937263.23846833
    0.5016393442622952, 43803474.996365294
    0.539344262295082, 40544606.59504045
    0.5688524590163934, 34277014.89316264
    0.5950819672131147, 25461360.619704828
    0.6229508196721312, 16618285.037019765
    0.6655737704918033, 10037712.197086804
    0.7213114754098361, 6724703.556947659
    0.7950819672131147, 4169337.0144349397
    0.8836065573770491, 2722604.5977291227
    0.9557377049180328, 1997130.2156342946
    1.0344262295081967, 1523018.3932672704
    1.1049180327868853, 1255113.4937515096
    1.1852459016393442, 1034416.372625131
    1.2737704918032788, 886319.8712540427
    1.359016393442623, 779309.6059234422
    1.4540983606557378, 609961.3425615291
    1.4918032786885247, 502533.5248888627
    1.5098360655737708, 398203.214420678
    1.5196721311475412, 299601.3683763488
    1.5213114754098362, 195504.2893801002
    1.5262295081967214, 119588.7737216253
    1.5360655737704918, 65114.84416472715
    1.5475409836065577, 38316.26954492593
    1.5508196721311474, 25329.082065449114
    1.559016393442623, 18331.533361062826
    1.5688524590163935, 14713.897024069562
    1.5934426229508198, 11361.99263934681
    1.6196721311475408, 8773.786275376307
    1.6508196721311474, 6433.761487810411
    1.6754098360655738, 5032.800618487584
    1.7049180327868854, 3787.196421050415
    1.7327868852459019, 2886.942647505133
    1.7557377049180327, 2287.679320744783
    1.777049180327869, 1933.9100405245356];
fig = figure(5);
% setup bottom axis
ax = axes();
hold(ax);
ax.YAxis.Scale = 'log';
xlabel(ax, 'Wavelength ($\mu$m)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel(ax, '$\alpha$ (m$^{-1}$)', 'Interpreter', 'latex', 'FontSize', 14);
% setup top axis
ax_top = axes(); % axis to appear at top
hold(ax_top);
ax_top.Position = ax.Position;
ax_top.YAxis.Visible = 'off';
ax_top.XAxisLocation = 'top';
% ax_top.XDir = 'reverse';
ax_top.Color = 'none';
xlabel(ax_top, 'Energy($e$V)', 'Interpreter', 'latex', 'FontSize', 14);
h = 4.135e-15; %eV s
c = 3e8; %m/s
lambda = linspace(0.2,1.8,9); %m
E = h*c./lambda*10^6; % 10^6 because lambda is in microns
% configure limits of bottom axis
ax.XLim = [lambda(1) lambda(end)];
ax.XTick = lambda;
ax.XAxis.TickLength = [0.015, 0.00];
ax.YAxis.TickLength = [0.02, 0.00];
ax.XAxis.MinorTick = 'on';
ax.XAxis.MinorTickValues = linspace(0.2,1.8,17);
% configure limits and labels of top axis
y_ticks = [0.7 0.8 0.9 1 2 3 4 5];
lambda_y_tick = h*c./y_ticks*10^6;
ax_top.XLim = [lambda(1) lambda(end)];
ax_top.XTick = fliplr(lambda_y_tick);
ax_top.XTickLabel = compose('%1.1f', fliplr(y_ticks));
ax_top.XAxis.TickLength = [0.02, 0.00];
ax_top.XAxis.MinorTick = 'off';
plot(ax, data(:,1), data(:,2), 'r-', 'LineWidth', 3);

% t = tiledlayout(1,1);
% % plot(wn,Eps_r,'b-')
% ax1.XColor = 'r';
% ax1.YColor = 'r';
% ax2 = axes(t);
% ax2.XAxisLocation = 'top';
% ax2.YAxisLocation = 'right';
% ax2.Color = 'none';
% plot(ln,Epa_r,'b--')
% ax1.Box = 'off';
% ax2.Box = 'off';
% % ax1.ylabel('n-1, \kappa') 
% % ax1.xlabel("\omega [Hz]")
% % ax2.xlabel("\lambda [nm]")
% % legend('n-1','Näherung','Location','northeast')
% % legend box off
% grid on
% set(gca,'FontSize',14);
% ht = title("Dispersion von Quarz");
% set(ht,'FontSize',12,'FontWeight','normal');


%% Funktionen

% Komplexe Dielektrizitätszahl
function Eps = complex_epsilon(a,w0,w,ka)
    Eps = 1+a/(w0^2-w^2-1i*ka*w);
end

% Reale Dielektrizitätszahl Näherung 
function Ear = real_epsilon(a,w0,w,ka)
    Ear = 1+a/2*(w0^2-w^2)/((w0^2-w^2)^2+(ka*w)^2);
end

% Imaginäre Dielektrizitätszahl Näherung 
function Eai = imag_epsilon(a,w0,w,ka)
    Eai = a/2*ka*w/((w0^2-w^2)^2+(ka*w)^2);
end