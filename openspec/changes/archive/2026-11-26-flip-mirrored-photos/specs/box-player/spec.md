## ADDED Requirements

### Requirement: Flips back photos stored mirrored
The box SHALL have mpv flip back, as it loads, a JPEG whose EXIF orientation says it is stored mirrored: left to right for orientation 2, top to bottom for orientation 4, so it is shown as the phone shows it. Photos with any other orientation SHALL be loaded without a flip.

#### Scenario: a photo stored mirrored is marked to be flipped back
- **GIVEN** JPEG headers 160 × 96 with EXIF orientation 4, 2 or 3
- **WHEN** the box measures them
- **THEN** they are 160 × 96, marked to be flipped top to bottom, left to right, and not at all

#### Scenario: a photo stored mirrored is flipped back as it loads
- **GIVEN** the TV portrait and the uploads `00001-mirrored.jpg` (portrait, stored flipped top to bottom) and `00002-a.jpg` (portrait)
- **WHEN** the box plays the tag `upload`
- **THEN** mpv is given the mirrored photo with `vf=%13%lavfi=[vflip]` after its `panscan`
- **AND** the other photo without it

## MODIFIED Requirements

### Requirement: Shrinks photos too big for the box's graphics
The box SHALL have mpv shrink a photo more than 4096 pixels wide or high (as measured, after its EXIF orientation) as it loads, to fit within 4096 × 4096 with its shape and orientation kept, since the Pi's graphics can't show a bigger picture. Photos up to 4096 on both sides, and videos, SHALL be loaded without this. The shrink and any flip SHALL go to mpv as one filter graph, length-quoted (`vf=%N%lavfi=[…]`) so its commas are kept.

#### Scenario: a photo too big for the box's graphics is shrunk as it loads
- **GIVEN** the TV portrait and the uploads `00001-huge.jpg` (4284 × 5712), `00002-a.jpg` (a small portrait photo) and `00003-b.mp4`
- **WHEN** the box plays the tag `upload`
- **THEN** mpv is given the huge photo with `vf=%60%lavfi=[scale=4096:4096:force_original_aspect_ratio=decrease]` after its `panscan`
- **AND** the small photo and the video without it
