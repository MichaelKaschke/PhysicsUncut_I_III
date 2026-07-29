% LegendrePolynome.m
% -------------------------------------------------------------------------
% MATLAB-Programm zum Kapitel "Astrodynamik" aus
% "Physikalische Fingerübungen" von Michael Kaschke und Holger Cartarius
% unter Mitwirkung von Ulrich Potthoff
% Alle Rechte bei den Autoren
% Freier Gebrauch mit Buch und/oder Angabe der Quelle erlaubt.
% -------------------------------------------------------------------------
% Legendre-Polynome 
% -------------------------------------------------------------------------

%%
clc
clear all
close all 
addpath('IncludeFolder')
addpath('Data')
Colors = GetColorLines;
Style = ["-", "-.", ":", "--", ":"];


%%

x = linspace(0,1,100);
for n = 1:5
    y(n,:) = legendreP(n,x);
    lgdstr(n,:)=strcat('n=',num2str(n,1));
end

figure()
hold on
for n = 1:5
    plot(x,y(n,:),'color', Colors(n,:), 'Linewidth', 2, 'LineStyle', ...
        Style(1));
end
grid on
legend(lgdstr,'location','northwest','Numcolumns',2)
legend box off
h=title('Legendre-Polynome');
set(h,'FontSize',14,'FontWeight','normal'); 
set(gca,'FontSize',16);
