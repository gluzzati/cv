folders := $(notdir $(wildcard job_applications/*))

define compile
	if [ -f job_applications/$(1)/$(2).tex ]; then \
		xelatex "\newcommand{\cvversion}{$(GITHUB_SHA_SHORT)} \input{applications/$(1)/$(2).tex}"; \
		mkdir -p artifacts/$(1); \
		mv $(2).pdf artifacts/$(1)/$(2).pdf; \
	fi
endef

define compile-folder
	$(foreach file,$(notdir $(basename $(wildcard job_applications/$(1)/*.tex))),artifacts/$(1)/$(file).pdf)
endef

all: $(foreach folder,$(folders),$(call compile-folder,$(folder))) clean

artifacts/%.pdf: job_applications/%.tex
	$(call compile,$(*D),$(*F))

clean:
	- rm *.aux *.nav *.out *.toc *.vrb *.log *.snm || /bin/true

mrclean: clean
	- rm artifacts/* -rf

.PHONY: $(folders)

$(folders):
	make $(call compile-folder,$@) clean

