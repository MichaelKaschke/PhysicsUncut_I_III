set DOC=FingerUeb3_WB

pdflatex %DOC%

makeindex %DOC%
makeindex personen

bibtex vorwort3
bibtex hm
bibtex adyn

bibtex %DOC%
bib2gls %DOC%

pdflatex %DOC%
pdflatex %DOC%
