## MODIFIED Requirements

### Requirement: Flips back photos stored mirrored
The box SHALL show a JPEG stored mirrored (EXIF orientation 2, 4, 5 or 7) the way its orientation says, as the phone shows it. Since mpv takes only the turn from such a photo and drops the mirror, the box SHALL have mpv flip it top to bottom as it loads, before mpv's own turn. Photos with any other orientation SHALL be loaded without a flip.

#### Scenario: a photo stored mirrored is marked to be corrected
- **GIVEN** JPEG headers 160 × 96 with each EXIF orientation 1 to 8
- **WHEN** the box measures them
- **THEN** 2, 4, 5 and 7 are marked mirrored, and 1, 3, 6 and 8 are not
- **AND** 5 to 8 measure 96 × 160, the rest 160 × 96

#### Scenario: a photo stored mirrored is corrected as it loads
- **GIVEN** the TV portrait and the uploads `00001-mirrored.jpg` (portrait, stored mirrored) and `00002-a.jpg` (portrait)
- **WHEN** the box plays the tag `upload`
- **THEN** mpv is given the mirrored photo with `vf=%13%lavfi=[vflip]` after its `panscan`
- **AND** the other photo without it
