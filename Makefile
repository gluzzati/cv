all: bending_spoons siemens iit clean

build:
	xelatex cv.tex

bending_spoons:
	xelatex applications/bending_spoons/cv.tex
	xelatex applications/bending_spoons/coverletter.tex
	mv cv.pdf applications/bending_spoons/
	mv coverletter.pdf applications/bending_spoons/

siemens:
	xelatex applications/siemens/cv.tex
	mv cv.pdf applications/siemens/

iit:
	pdflatex applications/iit/slides.tex
	pdflatex applications/iit/slides.tex
	mv slides.pdf applications/iit/slides.pdf

clean:
	- rm *.pdf *.aux *.nav *.out *.toc *.vrb *.log *.snm
