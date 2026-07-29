#!/bin/bash
# suchen und ersetzen in allen m-Files
# up. 2023-04-13

for file in hm/*.m hm/IncludeFolder/* bew/*.m bew/IncludeFolder/*.m adyn/*.m adyn/IncludeFolder/*.m
do
f=$(fgrep $1 -n $file)
if [ ! -z "$f" ]
then 
echo --- $file ------------------------------------
#fgrep "DK01" -n $file
#sed -e 's/importfile/ImportFile02/g' $file > tmp
#sed -e 's/KeplerMoon/KeplerMond/g' $file > tmp
#sed -e 's/ReadinOrbitParameter/OrbitParameterEinlesen/g' $file > tmp
#sed -e 's/OrbitParameters/OrbitParameter/g' $file > tmp
#sed -e 's/ReadinKometParameter/KometParameterEinlesen/g' $file > tmp
#sed -e 's/ReadinPlanetParameter/PlanetParameterEinlesen/g' $file > tmp
#sed -e 's/epsErde/EpsErde/g' $file > tmp
#sed -e 's/FRAC/Frac/g' $file > tmp
#sed -e 's/KometsPQR/KometPQR/g' $file > tmp
#sed -e 's/PlanetsPQR/PlanetPQR/g' $file > tmp
#sed -e 's/PlotSunFP/SonneFP/g' $file > tmp
#sed -e 's/KometParameterEinlesen/KometParameter/g' $file > tmp
sed -e 's/6371/6378/g' $file > tmp
#echo -diff-----------------------------------
diffc $file tmp
#mv tmp $file
#rm tmp
echo 
fi

#sed -e 's///g' $file > tmp
#echo -diff-----------------------------------
#diffc $file tmp
##mv tmp $file
done
#

#find ./ -type f -print -exec sed -i 's/test/muster/g' {} \;
#find . -type f -print0 | xargs -0 -n 1 sed -i -e "s/suche/ersetze/g"
#find /home -name core -exec rm {} \;
#find ./ -name *.m -exec grep "DK01_korrekt" {} \;

#find ./ -type f -print -exec sed -i 's/includefolder/IncludeFolder/g' {} \;

#find ./ -type f -print -exec sed -i 's/includefolder/IncludeFolder/g' {} \;

#fgrep -r "MarsPos" 
#fgrep -r "AnHarmonOszillator1" 
#fgrep -r "AnHarmonOszillator2" 

#fgrep -r "BungeeJumping" 
#fgrep -r "ChainFountain" 


# Zeichensatz konvertieren, gelegentlich komische Anführungszeichen
# iconv -f ISO-8859-1 -t UTF-8 AbplattungPlaneten.m 
#for file in *.html; do iconv -t ISO-8859-15 -t UTF-8 $file -o $file; done;

# deutsche Quotes
#\glqq Text\grqq{}

#https://deutsch.heute-lernen.de/grammatik/der-die-das/ellipsoid/deklination
