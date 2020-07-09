folders = bending_spoons siemens iit jawbone clean

define compile
	$(1) applications/$(2)/$(3).tex
	mv $(3).pdf applications/$(2)/$(3).pdf
endef


all: $(folders) clean

build:
	xelatex cv.tex

bending_spoons:
	$(call compile,xelatex,bending_spoons,cv)
	$(call compile,xelatex,bending_spoons,coverletter)

siemens:
	$(call compile,xelatex,siemens,cv)
	$(call compile,xelatex,siemens,coverletter)

iit:
	$(call compile,pdflatex,iit,slides)
	$(call compile,pdflatex,iit,slides)

jawbone:
	$(call compile,xelatex,jawbone,cv)

3brain:
	$(call compile,xelatex,3brain,cv)
	$(call compile,xelatex,3brain,coverletter)

clean:
	- rm *.pdf *.aux *.nav *.out *.toc *.vrb *.log *.snm || /bin/true
