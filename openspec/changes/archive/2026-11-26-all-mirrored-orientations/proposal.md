## Why

`flip-mirrored-photos` fixed the two `bisbee` photos (EXIF orientation 4) with a vertical flip, and guessed a horizontal flip for orientation 2, leaving 5 and 7 alone. Asked for a fix that holds for any photo, mpv was measured on the box for all 8 orientations: it takes only the turn from a mirrored orientation and drops the mirror (2 comes out turned 180°, 5 a quarter clockwise, 7 a quarter anticlockwise). So the guessed `hflip` for 2 was wrong, and 5 and 7 were wrong too.

## What Changes

- Any photo stored mirrored (EXIF orientation 2, 4, 5 or 7) is flipped top to bottom as it loads; mpv's own turn then gives exactly the picture the orientation means. Compared pixel for pixel with ffmpeg's reading of all 8 orientations on the box.
- `media_size.js` marks such a photo `mirrored: true` (instead of `flip: 'horizontal' | 'vertical'`).
- New on-box test `scheduler/tests/onbox/photo_orientations.sh`: all 8 orientations through the installed code and the live mpv, against ffmpeg.

## Impact

- `scheduler/media_size.js`, `scheduler/logic.js`, tests.
- Spec `box-player`: "Flips back photos stored mirrored" now covers all four mirrored orientations.
