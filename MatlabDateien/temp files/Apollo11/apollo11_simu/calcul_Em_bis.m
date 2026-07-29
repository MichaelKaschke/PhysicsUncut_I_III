clc, clear all;

mois = 7;
jours = [16 17 18];
ann = 1969;

d = round(367*ann - (7*(ann + ((mois+9)/12)))/mois + (275*mois)/9 + jours(3) - 730530);
N = rev(125.1228 - 0.0529538083 * d);         % (Long asc. node)
inc =   5.1454;                          % (Inclination)
w = rev(318.0634 + 0.1643573223 * d);         % (Arg. of perigee)
a =  60.2666 * 6371e3 ;                          % (Mean distance)
e = 0.054900  ;                          % (Eccentricity)
M = rev(115.3654 + 13.0649929509 * d);        % (Mean anomaly)

% normalisation
 M = M + 129*360;
% w = w + 360;
E0 = M + e * sind(M) * (1 + e * cosd(M));
diff = inf;
while (diff>0.005)
    
    E1 = E0 - (E0 -  e * sind(E0) - M) / (1 - e * cosd(E0));
    E0 = E1;
    diff = abs(E0-E1)
   if diff <= 0.05
       Em = E1
       E0
       break
   end
end
