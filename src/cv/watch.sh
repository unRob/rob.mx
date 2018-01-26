#!/usr/bin/env bash

make -f "$1/Makefile" all

osascript <<-SCPT
tell application "Safari"
  set windowCount to number of windows
  repeat with x from 1 to windowCount
    set tabCount to number of tabs in window x
    repeat with y from 1 to tabCount
      set tabURL to URL of tab y of window x
      if {tabURL starts with "http://rob.dev/cv"} then
        set URL of tab y of window x to tabURL
        return tabURL
      end if
    end repeat
  end repeat
end tell
SCPT