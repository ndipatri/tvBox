## 1. Measuring and playing

- [x] 1.1 Tests: a photo stored mirrored is marked to be flipped back; a photo stored mirrored is flipped back as it loads; the big-photo test takes the quoted option
- [x] 1.2 `media_size.js` adds `flip`; `logic.js` `photoFilters` builds one quoted filter graph

## 2. On the box

- [x] 2.1 By hand: `vf=%N%lavfi=[vflip,scale=…]` is accepted by mpv 0.40 (unquoted, the comma breaks it: "Terminating ']' missing for 'vf'")
- [x] 2.2 After setup, with the TV landscape, the `bisbee` photos `00081-img_3240.jpeg` and `00084-img_2269.jpeg` play upright (checked on the TV); `big_photo.sh` passed with this code
