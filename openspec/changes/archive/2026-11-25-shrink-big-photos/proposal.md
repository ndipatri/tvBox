## Why

Photos from newer iPhones are 5712 × 4284 (24 MP), and some phones take larger ones still. The Pi 5's graphics can't hold a picture more than 4096 pixels across or high, so mpv logged `texture could not be created` and the TV showed a blank blue screen for each such photo (seen on tvbox on 2026-11-25 after uploading iPhone photos). Photos up to 4096, like the iPhone's 12 MP 4032 × 3024, played fine.

## What Changes

- A photo more than 4096 pixels wide or high is shrunk by mpv as it loads (a `scale` video filter for that item only) to fit within 4096 × 4096, keeping its shape and its EXIF turn. Smaller photos and every video are loaded as before.
- Nothing about the upload changes: the file is kept as sent.

## Impact

- `scheduler/logic.js`: sizes measured once per item (`sizeOf`), and the per-item option added in `keepPlaying`.
- Spec: `box-player`, new requirement "Shrinks photos too big for the box's graphics".
