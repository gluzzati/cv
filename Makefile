build:
	xelatex cv.tex

siemens:
	xelatex applications/siemens/cv.tex
	mv cv.pdf applications/siemens/.
	make clean

clean:
	- rm *.pdf *.aux *.nav *.out *.toc *.vrb *.log
