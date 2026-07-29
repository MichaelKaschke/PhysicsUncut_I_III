function dydt = odde(t, y)

% Extract the state variables
X = y(1)
Y = y(2)
Z = y(3)
Xdot = y(4);
Ydot = y(5);
Zdot = y(6);

%% date du départ 16 juillet 1969

mois = 7;
jours = [16 17 18];
ann = 1969;
%d = 367*Y - (7*(Y + ((M+9)/12)))/4 + (275*M)/9 + D - 730530
d1 = round(367*ann - (7*(ann + ((mois+9)/12)))/mois + (275*mois)/9 + jours(1) - 730530);
d2 = round(367*ann - (7*(ann + ((mois+9)/12)))/mois + (275*mois)/9 + jours(2) - 730530);
d3 = round(367*ann - (7*(ann + ((mois+9)/12)))/mois + (275*mois)/9 + jours(3) - 730530);

if t >= 0 && t <= 86400

    d = 0 + (t - 0) / (86400 - 0) * (d1 - 0);
    Em = 4.6520e+04; %eccentric anomaly de la Lune

elseif t > 86400 && t <= 86400*2

    d = d1 + (t - 86400) / (86400*2 - 86400) * (d2 - d1);
    Em =4.6534e+04; 
else 
    
    t > 86400*2 && t >= 86400*3

    d = d2 + (t - 86400*2) / (86400*3 - 86400*2) * (d3 - d2);
    Em = 4.6544e+04;
end

%% calculation of the sun position

 [Xs, Ys, Zs] = soleil(d);

%% calculation of the moon position

N = rev(125.1228 - 0.0529538083 * d);    % (Long asc. node) degré
inc =   5.1454;                          % (Inclination) degré
w = rev(318.0634 + 0.1643573223 * d);    % (Arg. of perigee) degré
a =  60.2666 *  6371e3 ;                 % (Mean distance)
e = 0.054900  ;                          % (Eccentricity) degré


x = a * (cosd(Em) - e);
y2 = a * sqrt(1 - e*e) * sind(Em);

r = sqrt( x*x + y2*y2 );
v = atan2d( y2, x );
%To compute the Moon's position in ecliptic coordinates, we apply these formular:
xeclip = r * ( cosd(N) * cosd(v+w) - sind(N) * sind(v+w) * cosd(inc) );
yeclip = r * ( sind(N) * cosd(v+w) + cosd(N) * sind(v+w) * cosd(inc) );
zeclip = r * sind(v+w) * sind(inc);

long =  atan2d( yeclip, xeclip );
lat  =  atan2d( zeclip, sqrt( xeclip*xeclip + yeclip*yeclip ) );
r    =  sqrt( xeclip*xeclip + yeclip*yeclip + zeclip*zeclip );


x1 = r * cosd(lat)*cosd(long);
y1 = r * sind(lat)*sind(long);
z1 = r * sind(lat);


Xm = x1 
Ym = y1 
Zm = z1 % * 1.496e+11;

%% constantes

mu_e = 3.986135e14;     %sets the gravitational parameter for the Earth. (m^3/s^2)
mu_m = 4.89820e12;      %sets the gravitational parameter for the Moon. (m^3/s^2)
mu_s = 1.3253e20;       %sets the gravitational parameter for the Sun. (m^3/s^2)
a = 6371e3;             %the equatorial radius of the Earth. metre
J = 1.6246e-3;          %sets the Earth's second dynamic form factor.

% Calculate the distances and other parameters
re  = sqrt(X^2 + Y^2 + Z^2)      %distance terre-engin
rs = sqrt(Xs^2 + Ys^2 + Zs^2)   %distance terre-soleil
rm = sqrt(Xm^2 + Ym^2 + Zm^2)   %distance terre-lune
delta_m = sqrt((X - Xm)^2 + (Y - Ym)^2 + (Z - Zm)^2)
delta_s = sqrt((X - Xs)^2 + (Y - Ys)^2 + (Z - Zs)^2)


% Calculate the derivatives
X2dot = -((mu_e*X)/re^3) * (1 + (J*(a/re)^2)*(1 - 5*Z^2/re^2)) ...
    - (mu_m*(X - Xm)/delta_m^3) ...
    - (mu_m*Xm/rm^3) ...
    - (mu_s*(X - Xs)/delta_s^3) ...
    - (mu_s*Xs/rs^3);
Y2dot = -((mu_e*Y)/re^3) * (1 + (J*(a/re)^2)*(1 - 5*Z^2/re^2)) ...
    - (mu_m*(Y - Ym)/delta_m^3) ...
    - (mu_m*Ym/rm^3) ...
    - (mu_s*(Y - Ys)/delta_s^3) ...
    - (mu_s*Ys/rs^3);
Z2dot = -((mu_e*Z)/re^3) * (1 + (J*(a/re)^2)*(3 - 5*Z^2/re^2)) ...
    - (mu_m*(Z - Zm)/delta_m^3) ...
    - (mu_m*Zm/rm^3) ...
    - (mu_s*(Z - Zs)/delta_s^3) ...
    - (mu_s*Zs/rs^3);

% Return the derivative vector

dydt = [Xdot; Ydot; Zdot; X2dot; Y2dot; Z2dot];

end
