rem set DOC=PhysikUncut_Part1
set DOC=FingerUeb1


pdflatex %DOC%

makeindex %DOC%
makeindex personen
makeindex mfiles

bibtex vorwort
bibtex compphys
bibtex bew
bibtex hm
bibtex adyn
bibtex kontmech
bibtex solman1
bibtex bewAB
bibtex hmAB
bibtex adynAB
bibtex kontmechAB
bibtex solman_lsg
bibtex solmanUeb1
bibtex solmanUeb2

rem bibtex edyn
rem bibtex optatm
rem bibtex optbas
rem bibtex optger
rem bibtex optspez
rem bibtex spo

bibtex %DOC%
bib2gls %DOC%

pdflatex %DOC%
pdflatex %DOC%
