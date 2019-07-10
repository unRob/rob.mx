ROOT := $(realpath $(dir $(realpath $(firstword $(MAKEFILE_LIST))))../../)
HERE := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
SHELL := /bin/zsh
SOURCES := $(notdir $(wildcard $(HERE)*.md))
LOCALES := $(SOURCES:.md=)
DEST ?= "$(ROOT)/apps/cv/public"

$(LOCALES):
	mkdir -p $(DEST)/$@
	pandoc $@.md -o $(DEST)/$@/index.html \
		--template $(HERE)layout.html \
		--metadata pagetitle="$@"

template: $(LOCALES)

clean:
	rm -rf $(DEST)/*

$(DEST):
	mkdir -p $(DEST)

dest_dir: $(DEST)

all: dest_dir template $(DEST)/styles.css
	ln -sf $(DEST)/es/index.html $(DEST)

$(DEST)/styles.css:
	cp $(HERE)style.css $(DEST)/styles.css

watch:
	fswatch -r $(HERE) | xargs -n1 make all

.PHONY: template watch