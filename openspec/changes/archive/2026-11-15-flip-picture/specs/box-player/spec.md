## MODIFIED Requirements

### Requirement: Turns the picture for the way the TV faces
The box SHALL turn the picture by `rotate` from the configuration (270 as shipped) while the TV is portrait, and by `landscapeRotate` (0 as shipped) while it is landscape, as saved from the website; with nothing saved, the TV is portrait. When the saved way changes, the box SHALL turn the picture straight away without restarting, refit the item on screen for the new shape (or move on from it, when it no longer matches the TV), and queue the items behind it again for the new shape.

#### Scenario: the box turns the picture when the TV is turned to landscape
- **GIVEN** the TV portrait, playing the uploads `00001-tall.jpg` (portrait) and `00002-wide.jpg` (landscape), with tall on screen and filling it
- **WHEN** the TV is saved as landscape
- **THEN** mpv turns the picture by 0 degrees
- **AND** tall, no longer the TV's shape, gives way at once to wide, which fills the screen
- **AND** the box logs `Screen: landscape`
- **AND** when the TV is saved as portrait again, tall comes back, filling the screen

#### Scenario: a box started with the TV landscape turns the picture straight away
- **GIVEN** the TV saved as landscape
- **WHEN** the box starts
- **THEN** mpv turns the picture by 0 degrees before anything plays

## ADDED Requirements

### Requirement: Turns the picture over when it is flipped
The box SHALL turn the picture 180 degrees more than `rotate` (portrait) or `landscapeRotate` (landscape) while the picture is turned over for the way the TV faces, as saved from the website, separately for portrait and for landscape; with nothing saved, neither is turned over. When that changes, the box SHALL turn the picture straight away without restarting, keep the item on screen, and log `Screen: <way>, turned over (the picture turned <degrees> degrees).` A box started with the picture turned over SHALL turn it before anything plays. A saved setting that can't be read SHALL be logged once and treated as nothing turned over.

#### Scenario: the box turns the picture over when it is flipped on the website
- **GIVEN** the TV portrait, playing uploads
- **WHEN** the picture is saved as turned over for portrait
- **THEN** mpv turns the picture by `rotate` plus 180 degrees (90 as shipped), once
- **AND** the box logs `Screen: portrait, turned over (the picture turned 90 degrees).`
- **AND** the same item stays on screen and nothing is queued again
- **AND** when it is saved as not turned over, mpv turns the picture by `rotate` again

#### Scenario: a box started with the picture flipped turns it over straight away
- **GIVEN** the picture saved as turned over for portrait, and the TV portrait
- **WHEN** the box starts
- **THEN** mpv turns the picture by `rotate` plus 180 degrees before anything plays

#### Scenario: a flip for one way of the TV leaves the other alone
- **GIVEN** the picture saved as turned over for portrait only, and the TV landscape
- **WHEN** the box plays
- **THEN** mpv turns the picture by `landscapeRotate`
- **AND** when it is also saved as turned over for landscape, by `landscapeRotate` plus 180 degrees

#### Scenario: the box ignores a flip setting it can't read
- **GIVEN** the saved flip setting is not JSON
- **WHEN** the box plays for two seconds
- **THEN** the picture stays turned by `rotate`, and `WARNING: Couldn't read <videoRoot>/flip.json: not turning the picture over.` is logged once
