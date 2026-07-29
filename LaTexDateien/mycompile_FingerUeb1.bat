set DOC=FingerUeb1


pdflatex %DOC%

makeindex %DOC%
makeindex personen
makeindex mfiles

bibtex vorwort
bibtex compphys
bibtex bew
bibtex kontmech

bibtex %DOC%
bib2gls %DOC%

pdflatex %DOC%
pdflatex %DOC%
