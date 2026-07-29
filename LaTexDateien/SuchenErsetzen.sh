#!/bin/bash
# suchen und ersetzen in allen tex-Files
# up. 2023-04-13

#for file in hm/*.tex bew/*.tex edyn/*.tex kontmech/*.tex opt*/*.tex solman/*.tex spo/*.tex adyn/*.tex
for file in bew/*.tex 
#for file in adyn/*.tex 
#for file in hm/*.tex 
#for file in optbas/*.tex 
#for file in optger/*.tex 
#for file in optatm/*.tex 
#for file in optspez/*.tex 
#for file in edyn/*.tex 
do
f=$(fgrep "$1" -n $file)
if [ ! -z "$f" ]
then 
echo --- $file ------------------------------------
#sed -e 's/mScr/mscr/g' $file > tmp
#sed -e 's/mscr e /mscre /g' $file > tmp
#sed -e 's/mscr e/mscre/g' $file > tmp
#sed -e 's/mscr s/mscre/g' $file > tmp
#sed -e 's/mscr{} /mscr /g' $file > tmp
#sed -e 's/RollendeKreisscheibe.m/RollendesRad.m/g' $file > tmp
#sed -e 's/Rutherford01.m/Rutherford.m/g' $file > tmp
#sed -e 's/Datenfiles/Daten/g' $file > tmp
#sed -e 's/Lösungsband/Lösungsteil/g' $file > tmp
#sed -e 's/6371/6378/g' $file > tmp
#sed -e 's/Langrange/Lagrange/g' $file > tmp
#sed -e 's/Shoemaker Levy/Shoemaker-Levy/g' $file > tmp
#sed -e 's/Shoemaker--Levy/Shoemaker-Levy/g' $file > tmp
#sed -e 's/eografi/eographi/g' $file > tmp
#sed -e 's/ grafi/ graphi/g' $file > tmp
#sed -e 's/ Grafi/ Graphi/g' $file > tmp
#sed -e 's/rafi/raphi/g' $file > tmp
#sed -e 's/fotograf/photograph/g' -e 's/Fotograf/Photograph/g' $file > tmp
#sed -e 's/roduktes/rodukts/g' $file > tmp
#sed -e 's/M_/m_/g' $file > tmp
#sed -e 's/m_O/m_\\text{O}/g' $file > tmp
#sed -e 's/m_C/m_\\text{C}/g' $file > tmp
#sed -e 's/mlref/mlhmref/g' $file > tmp
#sed -e 's/mlref/mladynref/g' $file > tmp
#sed -e 's/mlref/mlbewref/g' $file > tmp
#sed -e 's/mlref/mloptbasref/g' $file > tmp
#sed -e 's/mlref/mloptgerref/g' $file > tmp
#sed -e 's/mlref/mloptatmref/g' $file > tmp
#sed -e 's/mlref/mloptspezref/g' $file > tmp
#sed -e 's/mlref/mledynref/g' $file > tmp
sed -e 's/\\\href{FingerUeb1_AB.pdf/\\linklsg\\\\\ %\\\href{FingerUeb1_AB.pdf/g' $file > tmp
##sed -e "s/2_AB.pdf\(.*\)textcolor/XXX\\\textcolor/" $file > tmp



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



# fgrep -R --include="*.tex" ".m" .

# \scref{mls:bew_uebungen} \mlref{BallistikCoriolis01.m} 
# \scref{mls:bew_uebungen} \mlref{Billardspiel.m}
# \screfen{mls:bew_uebungen} \mlref{Rollenpendel.m} und \mlref{PerleDraht.m}
# im / in


###in tempshort.sty:
#\newcommand\mscr{\matlab-Skript }
#\newcommand\scref[1]{\mscr{} \ref{#1}}

###in header.tex:
#\newcommand\mfile[2]{%
#\saveexpandmode\noexpandarg
#\StrSubstitute{#2}{_}{\_}[\tmpname]
#\restoreexpandmode
#\href{../MatlabDateien/\chapname/#1\tmpname}{\tmpname}}
#\newcommand\mlref[1]{\mfile{}{#1}}
#\newcommand\mlinclref[1]{\mfile{IncludeFolder/}{#1}}

