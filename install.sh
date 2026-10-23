#!/bin/sh
# Per-user install of the macOS display switcher. No root needed.
# Usage: ./install.sh [install] | uninstall
set -eu

cd "$(dirname "$0")"
BIN="$HOME/.local/bin"
RAYCAST_DIR="${RAYCAST_SCRIPTS_DIR:-$HOME/.local/share/raycast-scripts}"
PROFILE_DIR="$HOME/.config/display-profiles"

[ "$(uname -s)" = Darwin ] || { echo "Run this on the macOS host, not in Kali." >&2; exit 1; }

case "${1:-install}" in
install)
    if ! command -v displayplacer >/dev/null; then
        command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh" >&2; exit 1; }
        brew install displayplacer
    fi
    mkdir -p "$BIN" "$RAYCAST_DIR"
    install -m 755 bin/display-profile "$BIN/"
    install -m 755 raycast/display-kali.sh raycast/display-mac.sh "$RAYCAST_DIR/"
    cat <<EOF
Installed $BIN/display-profile and Raycast scripts in $RAYCAST_DIR

Next:
  1. System Settings -> Displays: both monitors at 1920x1080, then
       display-profile save kali
  2. Both monitors at 2560x1440 (or whatever you like for macOS), then
       display-profile save mac
  3. Raycast -> Settings -> Extensions -> + -> Add Script Directory:
       $RAYCAST_DIR
     and assign hotkeys to "Displays: Kali" and "Displays: Mac".
EOF
    case ":$PATH:" in *":$BIN:"*) ;; *) echo "Note: $BIN is not on your PATH." ;; esac
    ;;
uninstall)
    rm -f "$BIN/display-profile" "$RAYCAST_DIR/display-kali.sh" "$RAYCAST_DIR/display-mac.sh"
    rmdir "$RAYCAST_DIR" 2>/dev/null || true
    echo "Removed. Saved profiles kept in $PROFILE_DIR; displayplacer left installed."
    echo "Remove the script directory in Raycast settings if you added it."
    ;;
*)
    echo "Usage: $0 [install] | uninstall" >&2
    exit 2
    ;;
esac
