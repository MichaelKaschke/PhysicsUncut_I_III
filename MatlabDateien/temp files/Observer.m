%--------------------------------------------------------------------------
function OBS = Observer(t_UT, lambda, SITE, BESSEL)
%
% Observer: 
% Projektion des Beobachtungsortes auf die Fundamentalebene
%
% Eingabe:
%   t_UT        Berechnungszeit in Julianischen Jahrhunderten UT seit J2000
%   Bessel.IJK  Basisvektoren der Fundamentalebene (aequatorial)
%   SITE        Geozentrische Beobachterkoordinaten
% Ausgabe:      Koordinaten des Beobachters auf der Fundamentalebene 
%               in [Erdradien]
%--------------------------------------------------------------------------
    % Stundenwinkel des Beobachters in Grad
    Tau = 15*LMST(t_UT*36525+51544.5,lambda);
    % Äquatoriale kartesische Korodinaten des Beobachters
    OBS.equ = [SITE.c*cosd(Tau);SITE.c*sind(Tau);SITE.s];
    % Projektion in die Hauptebene
    OBS.xi   = dot(OBS.equ, BESSEL.IJK1);
    OBS.eta  = dot(OBS.equ, BESSEL.IJK2);
    OBS.zeta = dot(OBS.equ, BESSEL.IJK3);  
end
%--------------------------------------------------------------------------
