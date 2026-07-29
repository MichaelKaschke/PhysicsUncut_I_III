set DOC=FingerUeb1_WB

pdflatex %DOC%

makeindex %DOC%
makeindex personen

bibtex vorwort1
bibtex hm
bibtex adyn

bibtex %DOC%
bib2gls %DOC%

pdflatex %DOC%
pdflatex %DOC%
