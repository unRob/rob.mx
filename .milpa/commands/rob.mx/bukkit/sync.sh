#!/usr/bin/env bash

rclone sync \
  --s3-acl=public-read \
  --exclude="_template/*"
  "$MILPA_ARG_SOURCE"  || @milpa.fail "Could not sync assets"

if command -v /usr/bin/osascript >/dev/null 2>&1; then
  /usr/bin/osascript -e 'display notification "Much gifs. Wow." with title "Bukkit very sync"'
fi
