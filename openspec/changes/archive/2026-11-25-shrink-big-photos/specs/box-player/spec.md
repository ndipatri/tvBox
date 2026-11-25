## ADDED Requirements

### Requirement: Shrinks photos too big for the box's graphics
The box SHALL have mpv shrink a photo more than 4096 pixels wide or high (as measured, after its EXIF orientation) as it loads, to fit within 4096 × 4096 with its shape and orientation kept, since the Pi's graphics can't show a bigger picture. Photos up to 4096 on both sides, and videos, SHALL be loaded without this.

#### Scenario: a photo too big for the box's graphics is shrunk as it loads
- **GIVEN** the TV portrait and the uploads `00001-huge.jpg` (4284 × 5712), `00002-a.jpg` (a small portrait photo) and `00003-b.mp4`
- **WHEN** the box plays the tag `upload`
- **THEN** mpv is given the huge photo with `vf=lavfi=[scale=4096:4096:force_original_aspect_ratio=decrease]` after its `panscan`
- **AND** the small photo and the video without it
