#!/usr/bin/env bash

mkdir -p "$MILPA_ARG_SOURCE/_preview"

templateDir="$(dirname "$MILPA_COMMAND_REPO")/src/bukkit/src"

data=()
while IFS= read -r -d $'\n' image; do
  filename=$(basename "$image")
  name="${filename%.*}"
  preview="$MILPA_ARG_SOURCE/_preview/$name.jpg"

  if [[ ! -f "${preview}" ]]; then
    @milpa.log info "Generating preview for ${image} > ${preview}"
    echo convert "${image}[0,-1]" \
      -thumbnail '200x200>' \
      -quality 40 \
      -coalesce \
      +append \
      "${preview}" || @milpa.fail "Could not generate preview for $name"
    @milpa.log success "Generated preview"
  fi

  data+=( "$name|$filename" )
done < <(find "$MILPA_ARG_SOURCE" -name '*.gif' -o -name '*.jpg' -maxdepth 1 | sort --ignore-case)

jq -r '
  ($ARGS.positional | map(split("|") | {key: .[0], value: .[1]}) | from_entries) as $images |
  $indexTpl | gsub("%images%"; (
    $images | to_entries | map(
      .key as $name |
      .value as $filename |
      $imageTpl+"" |
      gsub(
        "%url%";
        (if ($cdn != "") then
          ([$cdn, $filename] | join("/"))
        else
          $filename
        end)
      ) |
      gsub(
        "%preview%";
        (if ($cdn != "") then
          ([$cdn, "_preview", $name] | join("/"))
        else
          (["_preview", $name] | join("/"))
        end)+".jpg"
      ) |
      gsub("%name%"; $name)
    ) | join("\n")
  ))
' \
--null-input \
--arg "cdn" "${MILPA_OPT_CDN}" \
--rawfile indexTpl "$templateDir/index.html" \
--rawfile imageTpl "$templateDir/image.html" \
--args "${data[@]}" > "$MILPA_ARG_SOURCE/index.html" || @milpa.fail "Could not build bukkit"

@milpa.log complete "Bukkit built to $MILPA_ARG_SOURCE"
