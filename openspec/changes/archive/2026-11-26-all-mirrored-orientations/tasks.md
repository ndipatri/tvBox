## 1. The rule

- [x] 1.1 Measured on tvbox: mpv's turn for orientations 1-8 is 0, 180, 180, 0, 90, 90, 270, 270; with a vertical flip first, 2, 4, 5 and 7 match ffmpeg's reading pixel for pixel
- [x] 1.2 `media_size.js` marks 2, 4, 5 and 7 `mirrored`; `photoFilters` gives them `vflip`
- [x] 1.3 Tests: a photo stored mirrored is marked to be corrected; a photo stored mirrored is corrected as it loads

## 2. On the box

- [x] 2.1 `scheduler/tests/onbox/photo_orientations.sh`: 9 passed with this code; with the earlier `hflip` for 2, orientations 2, 5 and 7 fail
