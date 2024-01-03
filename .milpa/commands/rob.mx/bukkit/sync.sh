#!/usr/bin/env bash

rclone sync \
  --s3-acl=public-read \
  --exclude="_template/*" \
  "$MILPA_ARG_SOURCE" "$MILPA_ARG_DEST" || @milpa.fail "Could not sync assets"

milpa computar notify --title "Bukkit very sync" --sound Purr.aiff "Much gifs. Wow."
