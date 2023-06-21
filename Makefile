%.pdf: %.tex
	xelatex $^;
	mkdir -p artifacts 
	cp $@ artifacts/. 


cv: cv.pdf

coverletter: coverletter.pdf

all: clean cv coverletter


clean:
	- rm *.pdf *.aux *.nav *.out *.toc *.vrb *.log *.snm || /bin/true
