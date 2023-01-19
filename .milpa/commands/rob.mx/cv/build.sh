#!/usr/bin/env bash

repo="$(dirname "$MILPA_COMMAND_REPO")"
html_root="$repo/apps/cv/public"
src_root="$repo/src/cv"

cd "$src_root" || @milpa.fail "could not cd into dir"
while read -r f; do
  html="${f%.md}/index.html"
  dst="$html_root/${html#*src/}"
  @milpa.log info "$f => $dst"
	mkdir -p "$(dirname "$dst")"
  pandoc "$f" -o "$dst" \
    --defaults="$src_root/pandoc.yaml" \
    --template "$src_root/src/layout.html" || @milpa.fail "Could not build $f"
  @milpa.log success "built $dst"
done < <(find src -name '*.md')
cp src/styles.css "$html_root/cv/styles.css"

@milpa.log info "building pdfs"

cd "$html_root" || @milpa.fail "could not cd into $html_root"
@milpa.log info "starting http server"
if ! {
    python -m http.server 8080 &
    pid=$!
  } ; then
  @milpa.fail "Could not serve pdfs"
fi

function cleanup() {
  kill -9 "$pid" 2>/dev/null
  docker stop gotenberg >/dev/null
  @milpa.log info "http server and gotenberg container stopped"
}
trap "cleanup" ERR EXIT HUP

@milpa.log info "starting gotenberg container"
docker run --name gotenberg --rm -p 3000:3000 -v "$HOME/Library/Fonts:/usr/share/fonts/opentype" -d gotenberg/gotenberg:7 || @milpa.fail "could not start gotenberg container"

while read -r f; do
  path="${f%/index.html}"
  path=${path#./}
  @milpa.log info "Converting $path to PDF"
  curl --silent --show-error --fail \
    --request POST 'http://localhost:3000/forms/chromium/convert/url' \
    --form 'url="http://host.docker.internal:8080/'"$path"'"' \
    --form 'paperWidth="8.5"' \
    --form 'paperHeight="11"' \
    --form 'preferCssPageSize="true"' \
    --form 'marginTop="1"' \
    --form 'marginBottom="1"' \
    --form 'marginLeft="1"' \
    --form 'marginRight="1"' \
    -o "$html_root/$path.pdf" || @milpa.fail "could not turn $path into pdf"
done < <(find . -name 'index.html')

@milpa.log complete "PDFs and HTML rendered to $html_root"
