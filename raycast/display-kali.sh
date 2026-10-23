#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Displays: Kali (1080)
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐉
# @raycast.packageName Display Profiles
# @raycast.description Monitors at looks-like 1920x1080 so Parallels full screen fits; re-enter full screen (⌃⌘F) if Kali was already full screen

exec "$HOME/.local/bin/display-profile" apply kali
