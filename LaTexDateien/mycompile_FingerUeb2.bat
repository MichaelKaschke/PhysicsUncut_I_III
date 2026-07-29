set DOC=FingerUeb2

pdflatex %DOC%

makeindex %DOC%
makeindex personen

bibtex vorwort2
bibtex hm
bibtex adyn

bibtex %DOC%
bib2gls %DOC%

pdflatex %DOC%
pdflatex %DOC%
