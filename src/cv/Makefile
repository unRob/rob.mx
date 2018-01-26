ROOT := $(realpath $(dir $(realpath $(firstword $(MAKEFILE_LIST))))../../)
HERE := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
SHELL := /bin/zsh
SOURCES := $(notdir $(wildcard $(HERE)*.md))
LOCALES := $(SOURCES:.md=)
DEST ?= "$(ROOT)/apps/cv/public"

$(LOCALES):
	mkdir -p $(DEST)/$@
	@m4 -d -DHTML_DATA='$(shell maruku --html-frag $(HERE)/$@.md -o - | tr -d "\n")' $(HERE)layout.html > $(DEST)/$@/index.html
template: $(LOCALES)

clean:
	rm -rf $(DEST)/*

all: template
	mkdir -p $(DEST)
	ln -sf $(DEST)/es/index.html $(DEST)

watch:
	fswatch -r $(HERE) | xargs -n1 $(HERE)watch.sh "$(HERE)"

.PHONY: template watch