## Why

Two of the four photos uploaded under `bisbee` on 2026-11-25 played upside down. Both are iPhone photos with EXIF orientation 4 ("stored flipped top to bottom"), which an iPhone writes when a photo is turned and flipped in Photos. mpv applies EXIF turns (3, 6, 8) but not flips: for orientation 4 it reported `rotate 0` and showed the photo as stored, upside down. The phone, and the box's own measuring, show it flipped back.

## What Changes

- `media_size.js` marks a JPEG with orientation 2 or 4 with `flip: 'horizontal'` or `'vertical'`.
- The player flips such a photo back as it loads (`hflip` / `vflip` in an ffmpeg filter for that item).
- The flip and the big-photo shrink share one filter graph; the option is now length-quoted (`vf=%N%lavfi=[…]`), since mpv would otherwise take the graph's comma as the end of the option. `photoShrink` becomes `photoFilters`.
- Orientations 5 and 7 (mirrored and turned a quarter) are not corrected: mpv's handling of them isn't known, and no phone in use here makes them.

## Impact

- `scheduler/media_size.js`, `scheduler/logic.js`, `scheduler/tests/onbox/big_photo.sh` (calls `photoFilters`).
- Spec `box-player`: new requirement "Flips back photos stored mirrored"; "Shrinks photos too big for the box's graphics" gives the quoted option.
