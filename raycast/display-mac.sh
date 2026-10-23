#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Displays: Mac (1440)
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️
# @raycast.packageName Display Profiles
# @raycast.description Monitors at looks-like 2560x1440 for macOS work

exec "$HOME/.local/bin/display-profile" apply mac
