DIST ?= ../../apps/cv
SOURCES := $(wildcard src/*/*.md)
OUTPUTS := $(subst src,$(DIST)/public,$(SOURCES:.md=/index.html))

all: $(OUTPUTS) $(DIST)/public/cv/styles.css $(DIST)/_app.conf

clean:
	rm -rf $(DIST)

watch:
	fswatch -r $(HERE) | xargs -n1 make all

.SECONDEXPANSION:

%index.html: $$(subst $(DIST)/public,src,$$(subst /index.html,.md,$$@))
	mkdir -p $(dir $@)
	pandoc $< -o $@ \
		--template src/layout.html \
		--metadata pagetitle="$@"

$(DIST)/public/cv/styles.css: src/styles.css
	mkdir -p $(dir $@)
	cp $< $@

$(DIST)/_app.conf: nginx.conf
	cp nginx.conf $(DIST)/_app.conf

.PHONY: watch