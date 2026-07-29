
%% fonction pour déterminer la position du soleil
function [Xs,Ys,Zs] = soleil(d)

w = 282.9404 + 4.70935e-5* d ;           %(longitude of perihelion) degré
e = 0.016709 - 1.15e-9* d ;              %(eccentricity) degré
M = 356.0470 + 0.9856002585* d ;         %(mean anomaly) degré
oblecl = 23.4393 - 3.563e-7 * d;

M = rev(M); %pour que la valeur de M soit entre [0;360]
E = M + (180/pi) * e * sind(M) * (1 + e * cosd(M));  %degré
x = cosd(E) - e;
yy = sind(E) * sqrt(1 - e*e);
r = sqrt(x*x + yy*yy);
v = atan2d(yy, x);

lon = v + w;
xs = r * cosd(lon);
ys = r * sind(lon);
zs = 0.0;
 
xequat = xs ;
yequat = ys * cosd(oblecl) - zs * sind(oblecl);
zequat = ys * sind(oblecl) + zs * cosd(oblecl);

 Xs = xequat * 1.496e+11; 
 Ys = yequat * 1.496e+11;
 Zs = zequat * 1.496e+11;

end

