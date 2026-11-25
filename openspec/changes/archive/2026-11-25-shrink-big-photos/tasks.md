## 1. The player

- [x] 1.1 Test: a photo too big for the box's graphics is shrunk as it loads
- [x] 1.2 `logic.js`: `photoOptions` adds `vf=lavfi=[scale=4096:4096:force_original_aspect_ratio=decrease]` for a photo over 4096 on either side

## 2. On the box

- [x] 2.1 Tried by hand over mpv's socket: a 5712 × 4284 photo loaded this way showed at 4096 × 3072 with no texture error, and an upright one kept its EXIF turn
