folders := $(notdir $(wildcard applications/*))
SHA_SUFFIX := $(if $(CI_COMMIT_SHORT_SHA),_$(CI_COMMIT_SHORT_SHA),)

define compile
	if [ -f applications/$(1)/$(2).tex ]; then \
		xelatex "\newcommand{\cvversion}{$(CI_COMMIT_SHORT_SHA)} \input{applications/$(1)/$(2).tex}"; \
		mkdir -p artifacts/$(1); \
		mv $(2).pdf artifacts/$(1)/$(2)$(SHA_SUFFIX).pdf; \
	fi
endef

define compile-folder
$(foreach file,$(notdir $(basename $(wildcard applications/$(1)/*.tex))),artifacts/$(1)/$(file)$(SHA_SUFFIX).pdf)
endef

all: $(foreach folder,$(folders),$(call compile-folder,$(folder))) clean

artifacts/%$(SHA_SUFFIX).pdf: applications/%.tex
	$(call compile,$(*D),$(*F))

clean:
	- rm *.aux *.nav *.out *.toc *.vrb *.log *.snm || /bin/true

mrclean: clean
	- rm artifacts/* -rf

.PHONY: $(folders)

$(folders):
	make $(call compile-folder,$@)

	