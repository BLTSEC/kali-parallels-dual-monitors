#!/bin/bash
# Exercise display-profile against a fake displayplacer. Touches no real displays.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

export DISPLAY_PROFILE_DIR="$TMP/profiles"
export DISPLAYPLACER="$TMP/displayplacer"
export LAYOUT="$TMP/layout"
cat >"$DISPLAYPLACER" <<'EOF'
#!/bin/bash
if [ "$1" = list ]; then
  echo "Persistent screen id: AAA"
  echo
  cat "$LAYOUT"
else
  printf '%s\n' "$@" >"$LAYOUT.applied"
fi
EOF
chmod +x "$DISPLAYPLACER"

dp() { "$ROOT/bin/display-profile" "$@"; }
fail() { echo "FAIL: $*" >&2; exit 1; }

echo 'displayplacer "id:A res:1920x1080 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" "id:B res:1920x1080 hz:120 color_depth:8 enabled:true scaling:on origin:(-1920,0) degree:0"' >"$LAYOUT"
dp save kali | grep -q "Guest width 7680 <= 8192" || fail "1080 pair should fit"
[ "$(wc -l <"$DISPLAY_PROFILE_DIR/kali" | tr -d ' ')" = 2 ] || fail "expected 2 screens"

echo 'displayplacer "id:A res:2560x1440 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" "id:B res:2560x1440 hz:120 color_depth:8 enabled:true scaling:on origin:(-2560,0) degree:0"' >"$LAYOUT"
dp save mac | grep -q "Guest width 10240 > 8192" || fail "1440 pair should be too wide"

echo 'displayplacer "id:A res:2560x1440 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" "id:B res:1920x1080 hz:120 color_depth:8 enabled:true scaling:on origin:(-1920,0) degree:0"' >"$LAYOUT"
dp save mixed | grep -q "Guest width 8960 > 8192" || fail "mixed pair should be too wide"

echo 'displayplacer "id:A res:3840x2160 hz:60 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0"' >"$LAYOUT"
dp save native | grep -q "Guest width 3840 <= 8192" || fail "scaling:off is 1x"

dp apply kali >/dev/null
[ "$(head -n 1 "$LAYOUT.applied")" = "id:A res:1920x1080 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" ] \
  || fail "apply should pass each screen as one argument"
[ "$(wc -l <"$LAYOUT.applied" | tr -d ' ')" = 2 ] || fail "apply should pass 2 screens"

dp check mac | grep -q "will go black" || fail "check mac"
[ "$(dp list | tr '\n' ' ')" = "kali mac mixed native " ] || fail "list"
! dp apply 'x/../y' 2>/dev/null || fail "path traversal accepted"
! dp apply missing 2>/dev/null || fail "missing profile accepted"

echo "All tests passed"
