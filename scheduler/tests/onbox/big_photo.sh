#!/bin/bash
# Checks, on a real tvBox, that a photo too big for the Pi's graphics is
# drawn instead of leaving the TV blank blue. Only the Pi's own graphics can
# show this, so it can't run on a Mac or in the Docker rehearsal (e2e/).
#
#   ssh tvbox.local bash ~/tvBox/scheduler/tests/onbox/big_photo.sh
#
# Run it on a box that is set up and playing (after `sudo bash
# scheduler/setup.sh`, so it tests the installed code in /opt/tvbox). It
# talks to the running mpv: for about 15 seconds the TV shows a test
# pattern, then the box goes back to what it was playing. Nothing is kept.
#
# Two loads of a 5712 x 4284 photo (the size of a 24 MP iPhone photo):
#   1. as it is, with no shrinking: this must fail with mpv's "texture could
#      not be created", or the test can't tell a blue screen from a picture;
#   2. with the options the installed logic.js gives that photo: this must
#      draw it no bigger than 4096 on a side, with no texture error.
# Prints PASS/FAIL per check; exits 1 if any failed.
set -uo pipefail

SOCK=/run/tvbox/mpv.sock
LOG="$HOME/video-scheduler/scheduler.log"
CODE=${TVBOX_CODE:-/opt/tvbox} # or another copy of scheduler/, to try it before setup
for need in "$SOCK" "$LOG" "$CODE/logic.js"; do
  [ -e "$need" ] || { echo "Not a set-up, running tvBox: no $need." >&2; exit 2; }
done
command -v ffmpeg >/dev/null || { echo "ffmpeg is missing." >&2; exit 2; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
photo="$work/big.jpg"
ffmpeg -loglevel error -f lavfi -i testsrc2=s=5712x4284 -frames:v 1 -q:v 3 "$photo" || exit 2

passed=0
failed=0
check() { # name, then 0 for pass
  if [ "$2" = 0 ]; then echo "PASS  $1"; passed=$((passed + 1));
  else echo "FAIL  $1"; failed=$((failed + 1)); fi
}

# Loads the photo with mpv options $1, waits, and prints the size mpv draws
# it at ("WxH", or "none") and how many texture errors were logged meanwhile.
show() {
  local before after size
  before=$(wc -l < "$LOG")
  size=$(node - "$SOCK" "$photo" "$1" <<'EOF'
const [sock, photo, options] = process.argv.slice(2);
const s = require('net').connect(sock);
let buf = '';
s.on('data', (d) => { buf += d; });
const send = (command) => s.write(JSON.stringify({ command, request_id: 7 }) + '\n');
send(['loadfile', photo, 'replace', -1, 'image-display-duration=inf' + options]);
setTimeout(() => {
  buf = '';
  send(['get_property', 'video-out-params']);
  setTimeout(() => {
    const line = buf.split('\n').find((l) => l.includes('"request_id":7'));
    const data = line ? JSON.parse(line).data : null;
    console.log(data && data.w ? data.dw + 'x' + data.dh : 'none');
    process.exit(0);
  }, 1000);
}, 5000);
EOF
)
  sleep 1
  after=$(tail -n +"$((before + 1))" "$LOG" | grep -c 'texture could not be created')
  echo "$size $after"
}

# Puts the box back: stopping mpv makes the player queue afresh on its next tick.
restore() {
  node -e '
    const s = require("net").connect(process.argv[1]);
    s.write(JSON.stringify({ command: ["stop"] }) + "\n");
    setTimeout(() => process.exit(0), 300);' "$SOCK"
}
trap 'restore; rm -rf "$work"' EXIT

echo "== A 5712 x 4284 photo, as it is (expected to fail)"
read -r size errors < <(show '')
echo "   drawn at: $size, texture errors: $errors"
check "the Pi's graphics can't draw it as it is (so this test can see a blue screen)" $([ "$errors" -gt 0 ]; echo $?)

echo "== The same photo, with the options the installed logic.js gives it"
options=$(node -e 'console.log(require(process.argv[1]).photoFilters({ width: 5712, height: 4284 }))' "$CODE/logic.js")
echo "   options: ${options:-none}"
read -r size errors < <(show "$options")
echo "   drawn at: $size, texture errors: $errors"
check "it is drawn, with no texture error" $([ "$errors" = 0 ] && [ "$size" != none ]; echo $?)
w=${size%x*}; h=${size#*x}
check "it is drawn no bigger than 4096 on a side, the same shape" \
  $([ "$size" != none ] && [ "$w" -le 4096 ] && [ "$h" -le 4096 ] && { [ $((w * 4284)) -eq $((h * 5712)) ] || [ $((w * 5712)) -eq $((h * 4284)) ]; }; echo $?)

echo "== $passed passed, $failed failed"
[ "$failed" = 0 ]
