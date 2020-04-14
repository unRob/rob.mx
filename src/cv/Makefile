DIST ?= ../../apps/cv
SOURCES := $(wildcard src/*/*.md)
OUTPUTS := $(subst src,$(DIST)/public,$(SOURCES:.md=/index.html))
PDFS := $(subst src,$(DIST)/pdf,$(SOURCES:.md=.pdf))
HTTP_ADDR ?= http://rob.aqui

all: $(OUTPUTS) $(DIST)/public/cv/styles.css $(DIST)/app.conf

clean:
	rm -rf $(DIST)

watch:
	fswatch -r $(HERE) | xargs -n1 make all

.SECONDEXPANSION:

%index.html: $$(subst $(DIST)/public,src,$$(subst /index.html,.md,$$@))
	mkdir -p $(dir $@)
	pandoc $< -o $@ --defaults=pandoc.yml \
		--template src/layout.html \
		--metadata pagetitle="$@"

pdf-runner:
	docker build --tag mx.rob.pdf-render pdf-render
	chrome --headless \
		--remote-debugging-port=5555 --remote-debugging-address=0.0.0.0 \
		--disable-gpu --no-sandbox \
		--run-all-compositor-stages-before-draw --user-data-dir=/tmp &

pdfs: pdf-runner
	mkdir -p $(dir $(PDFS))
	docker run \
		-v $(shell cd $(DIST)/pdf 2> /dev/null && pwd -P):/target \
		--rm mx.rob.pdf-render \
		$(subst $(DIST)/pdf,$(HTTP_ADDR),$(PDFS:.pdf=))

$(DIST)/public/cv/styles.css: src/styles.css
	mkdir -p $(dir $@)
	cp $< $@

$(DIST)/app.conf: nginx.conf
	cp nginx.conf $(DIST)/app.conf

.PHONY: watch