SOURCES := $(wildcard sources/*.jpg)
VARIANTS := $(shell ls -1 transparent/*.png | cut -d '-' -f 1 | uniq)
TILES := $(VARIANTS:transparent/%=%)

sources/%.jpg: transparent/%.png
	mkdir -p transparent
	convert $@ \
		-bordercolor white -border 1x1 \
    -alpha set -channel RGBA -fuzz 25% \
    -fill none -floodfill +0+0 white \
    -shave 1x1 $^
transparent: $(SOURCES)

$(TILES):
	mkdir -p tiles
	montage transparent/$@-*.png \
	  -tile x1 \
	  -geometry 200x200+0x+0 \
	  -colorspace Gray \
	  -background none \
	  tiles/$@.png

dist: $(TILES)
	mkdir -p dist
	montage transparent/tiles/*.png \
		-tile 1x \
		-geometry x200+0 \
		-background none \
		dist/caras@2x.png
	convert dist/caras@2x.png -scale 50% dist/caras.png
	pngquant dist/*.png --force --ext '.png'


all: transparent dist