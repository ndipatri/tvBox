#!/bin/bash
# Checks, on a real tvBox, that a photo comes out the way round its EXIF
# orientation says, for all 8 orientations: what phones write for a photo
# taken turned, or turned and flipped in their photo app.
#
#   ssh tvbox.local bash ~/tvBox/scheduler/tests/onbox/photo_orientations.sh
#
# Run it on a box that is set up and playing (it tests the installed code in
# /opt/tvbox, and the box's own mpv and ffmpeg). It talks to the running mpv:
# for about 15 seconds the TV shows test patterns, then the box goes back to
# what it was playing. Nothing is kept.
#
# For each orientation it makes a small photo, then:
#   - asks the installed media_size.js and logic.js which options the player
#     would give it, and loads it into mpv with them (they must be accepted);
#   - reads the turn mpv takes from the photo itself (video-dec-params);
#   - rebuilds with ffmpeg what that shows: the photo as stored, the player's
#     filter, then mpv's turn;
#   - compares it, pixel for pixel, with ffmpeg's own reading of the
#     orientation (which handles flips as well as turns).
# It also checks that without the player's filter mpv would get orientation
# 4 wrong, so this test can tell a wrong way round from a right one.
# Prints PASS/FAIL per check; exits 1 if any failed.
set -uo pipefail

SOCK=/run/tvbox/mpv.sock
CODE=${TVBOX_CODE:-/opt/tvbox} # or another copy of scheduler/, to try it before setup
for need in "$SOCK" "$CODE/logic.js" "$CODE/media_size.js"; do
  [ -e "$need" ] || { echo "Not a set-up, running tvBox: no $need." >&2; exit 2; }
done
command -v ffmpeg >/dev/null || { echo "ffmpeg is missing." >&2; exit 2; }

work=$(mktemp -d)
restore() { # stopping mpv makes the player queue afresh on its next tick
  node -e '
    const s = require("net").connect(process.argv[1]);
    s.write(JSON.stringify({ command: ["stop"] }) + "\n");
    setTimeout(() => process.exit(0), 300);' "$SOCK"
}
trap 'restore; rm -rf "$work"' EXIT

# A 320 x 240 test pattern (lopsided, so every turn and flip looks different),
# then the same with an EXIF block giving each orientation, 1 to 8.
ffmpeg -v error -f lavfi -i testsrc2=s=320x240 -frames:v 1 "$work/base.jpg" || exit 2
node - "$work" <<'EOF' || exit 2
const fs = require('fs');
const dir = process.argv[2];
const base = fs.readFileSync(dir + '/base.jpg');
for (let o = 1; o <= 8; o++) {
  // Little-endian TIFF: one IFD entry, Orientation (0x0112), SHORT, o.
  const tiff = Buffer.from([0x49, 0x49, 0x2a, 0, 8, 0, 0, 0, 1, 0, 0x12, 0x01, 3, 0, 1, 0, 0, 0, o, 0, 0, 0, 0, 0, 0, 0]);
  const body = Buffer.concat([Buffer.from('Exif\0\0', 'latin1'), tiff]);
  const app1 = Buffer.concat([Buffer.from([0xff, 0xe1, (body.length + 2) >> 8, (body.length + 2) & 255]), body]);
  fs.writeFileSync(dir + '/o' + o + '.jpg', Buffer.concat([base.subarray(0, 2), app1, base.subarray(2)]));
}
EOF

# For each orientation: "<options> | <graph or none> | <mpv's turn> | <error or ok>",
# from the installed code and the live mpv.
node - "$work" "$CODE" "$SOCK" > "$work/mpv.txt" <<'EOF'
const [dir, code, sock] = process.argv.slice(2);
const { readMediaSize } = require(code + '/media_size.js');
const { photoFilters } = require(code + '/logic.js');
const s = require('net').connect(sock);
let buf = '';
s.on('data', (d) => { buf += d; });
const ask = (command, id) => s.write(JSON.stringify({ command, request_id: id }) + '\n');
const reply = (id) => {
  const line = buf.split('\n').find((l) => l.includes('"request_id":' + id + ','));
  return line ? JSON.parse(line) : null;
};
const wait = (ms) => new Promise((r) => setTimeout(r, ms));
(async () => {
  for (let o = 1; o <= 8; o++) {
    const photo = dir + '/o' + o + '.jpg';
    const options = photoFilters(readMediaSize(photo));
    buf = '';
    ask(['loadfile', photo, 'replace', -1, 'image-display-duration=inf' + options], 1);
    await wait(1500);
    ask(['get_property', 'video-dec-params'], 2);
    ask(['get_property', 'vf'], 3);
    await wait(400);
    const loaded = reply(1);
    const dec = reply(2);
    const vf = reply(3);
    const graph = vf && vf.data && vf.data.length ? vf.data[0].params.graph : 'none';
    const turn = dec && dec.data ? dec.data.rotate : '?';
    console.log([options || 'none', graph, turn, loaded && loaded.error === 'success' ? 'ok' : 'refused'].join(' | '));
  }
  process.exit(0);
})();
EOF

passed=0
failed=0
check() { # name, then 0 for pass
  if [ "$2" = 0 ]; then echo "PASS  $1"; passed=$((passed + 1));
  else echo "FAIL  $1"; failed=$((failed + 1)); fi
}
hash() { ffmpeg -v error "$@" -frames:v 1 -f framemd5 - | tail -1 | awk -F, '{print $NF}'; }
turnfilter() { # mpv's turn, as an ffmpeg filter
  case "$1" in 0) echo null;; 90) echo transpose=1;; 180) echo hflip,vflip;; 270) echo transpose=2;; *) echo bad;; esac
}

o=0
while IFS='|' read -r options graph turn loaded; do
  o=$((o + 1))
  graph=$(echo $graph); turn=$(echo $turn); loaded=$(echo $loaded)
  want=$(hash -i "$work/o$o.jpg")
  steps=$(turnfilter "$turn")
  [ "$graph" != none ] && steps="$graph,$steps"
  got=$(hash -noautorotate -i "$work/o$o.jpg" -vf "$steps")
  echo "   orientation $o: options ${options}, mpv turns it ${turn}"
  check "orientation $o comes out the right way round" $([ "$loaded" = ok ] && [ -n "$want" ] && [ "$got" = "$want" ]; echo $?)
  if [ $o = 4 ]; then
    bare=$(hash -noautorotate -i "$work/o4.jpg" -vf "$(turnfilter "$turn")")
    check "without the player's filter, mpv would show orientation 4 wrong (so this test can tell)" $([ "$bare" != "$want" ]; echo $?)
  fi
done < "$work/mpv.txt"
[ $o = 8 ] || check "mpv answered for all 8 orientations" 1

echo "== $passed passed, $failed failed"
[ "$failed" = 0 ]
