function dydt = ode(t, y)

% Extract the state variables
X = y(1);
Y = y(2);
Z = y(3);
Xdot = y(4);
Ydot = y(5);
Zdot = y(6);

%% date du départ 16 juillet 1969

mois = 7;
jours = [16 17 18];
ann = 1969;
%d = 367*Y - (7*(Y + ((M+9)/12)))/4 + (275*M)/9 + D - 730530
d1 = 367*ann - (7*(ann + ((mois+9)/12)))/mois + (275*mois)/9 + jours(1) - 730530;
d2 = 367*ann - (7*(ann + ((mois+9)/12)))/mois + (275*mois)/9 + jours(2) - 730530;
d3 = 367*ann - (7*(ann + ((mois+9)/12)))/mois + (275*mois)/9 + jours(3) - 730530;

%% sun position

if t>=0 & t <= 86400
    d = 0 + (t - 0) / (86400- 0) * (d1 - 0);
elseif t>86400 & t <= 86400*2
    d = d1 + (t - 86400) / (86400*2 - 86400) * (d2 - d1);
else t>86400*2 & t>=86400*3
    d = d2 + (t - 86400*2) / (86400*3 - 86400*2) * (d3 - d2);
end

w = 282.9404 + 4.70935e-5* d ;           %(longitude of perihelion)
a = 1.000000;                            %(mean distance, a.u.)
e = 0.016709 - 1.15e-9* d ;              %(eccentricity)
M = 356.0470 + 0.9856002585* d ;         %(mean anomaly)
oblecl = 23.4393 - 3.563e-7 * d;

L = w + M ;
E = M + (180/pi) * e * sin(M) * (1 + e * cos(M));  %what is the unit of E?
x = cos(E) - e;
yy = sin(E) * sqrt(1 - e*e);
r = sqrt(x*x + yy*yy);
v = atan2( real(yy), real(x) );

lon = v + w;
xs = r * cosd(lon);
ys = r * sind(lon);
zs = 0.0;
 
xequat = xs;
yequat = ys * cosd(oblecl) - zs * sind(oblecl);
zequat = ys * sind(oblecl) + zs * cosd(oblecl);

Xs = xequat*1.496e+11;
Ys = yequat*1.496e+11;
Zs = zequat*1.496e+11;

%% Moon position     

N = 125.1228 - 0.0529538083 * d;         % (Long asc. node)
inc =   5.1454;                          % (Inclination)
w = 318.0634 + 0.1643573223 * d;         % (Arg. of perigee)
a =  60.2666  ;                          % (Mean distance)
e = 0.054900  ;                          % (Eccentricity)
M = 115.3654 + 13.0649929509 * d;        % (Mean anomaly)

% normalisation
M = M + 129*360;
w = w + 360;

E0 = M + (180/pi) * e * sin(M) * (1 + e * cos(M));
E1 = E0 - (E0 - (180/pi) * e * sin(E0) - M) / (1 - e * cos(E0));
E = E1;

x = a * (cos(E) - e);
y = a * sqrt(1 - e*e) * sin(E);

r = sqrt( x*x + y*y );
v = atan2( y, x );

xeclip = r * ( cos(N) * cos(v+w) - sin(N) * sin(v+w) * cos(inc) );
yeclip = r * ( sin(N) * cos(v+w) + cos(N) * sin(v+w) * cos(inc) );
zeclip = r * sin(v+w) * sin(inc);

long =  atan2( yeclip, xeclip );
lat  =  atan2( zeclip, sqrt( xeclip*xeclip + yeclip*yeclip ) );
r    =  sqrt( xeclip*xeclip + yeclip*yeclip + zeclip*zeclip );

% xeq = xeclip;
% yeq = yeclip * cos(oblecl) - zeclip * sin(oblecl);
% zeq = yeclip * sin(oblecl) + zeclip * cos(oblecl);

v = a./sqrt(1-e*sind(lat).*sind(lat));
x1 = (v+r).*cosd(lat).*cosd(long);
y1 = (v+r).*cosd(lat).*sind(long);
z1 = (v.*(1-e)+r).*sind(lat);

Xm = x1*1.496e+11 ;
Ym = y1*1.496e+11;
Zm = z1*1.496e+11;

%% constantes

mu_e = 3.986135e14;     %sets the gravitational parameter for the Earth.
mu_m = 4.89820e12;      %sets the gravitational parameter for the Moon.
mu_s = 1.3253e20;       %sets the gravitational parameter for the Sun.
a = 6.37826e6;          %the equatorial radius of the Earth.
J = 1.6246e-3;          %sets the Earth's second dynamic form factor.

% Calculate the distances and other parameters
r = sqrt(X^2 + Y^2 + Z^2);
rs = sqrt(Xs^2 + Ys^2 + Zs^2);
rm = sqrt(Xm^2 + Ym^2 + Zm^2);
delta_m = sqrt((X - Xm)^2 + (Y - Ym)^2 + (Z - Zm)^2);
delta_s = sqrt((X - Xs)^2 + (Y - Ys)^2 + (Z - Zs)^2);



% Calculate the derivatives
X2dot = -((mu_e*X)/r^3) * (1 + (J*(a/r)^2)*(1 - 5*Z^2/r^2)) ...
    - (mu_m*(X - Xm)/delta_m^3) ...
    - (mu_m*Xm/rm^3) ...
    - (mu_s*(X - Xs)/delta_s^3) ...
    - (mu_s*Xs/rs^3);
Y2dot = -((mu_e*Y)/r^3) * (1 + (J*(a/r)^2)*(1 - 5*Z^2/r^2)) ...
    - (mu_m*(Y - Ym)/delta_m^3) ...
    - (mu_m*Ym/rm^3) ...
    - (mu_s*(Y - Ys)/delta_s^3) ...
    - (mu_s*Ys/rs^3);
Z2dot = -((mu_e*Z)/r^3) * (1 + (J*(a/r)^2)*(3 - 5*Z^2/r^2)) ...
    - (mu_m*(Z - Zm)/delta_m^3) ...
    - (mu_m*Zm/rm^3) ...
    - (mu_s*(Z - Zs)/delta_s^3) ...
    - (mu_s*Zs/rs^3);

% Return the derivative vector

dydt = [Xdot; Ydot; Zdot; X2dot; Y2dot; Z2dot];

end
