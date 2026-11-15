## MODIFIED Requirements

### Requirement: Keeps its address on the TV while something plays
While something plays and the address code is switched on, the box SHALL keep a QR code of its website's address (`http://<its IPv4 address>/`) on top of the picture in the viewer's bottom-right corner, left up from item to item without being redrawn. It SHALL also keep it up while the screen is black because nothing in what is playing (an override or a scheduled filter) is there or fits the TV, redrawing it there only for a new address. It SHALL take it away only when switched off, with no address, or on a black chosen on the website or by the schedule (nothing playing), and put it back straight away after a turn or being switched back on.

#### Scenario: the address code stays up while items play
- **GIVEN** the box at 10.0.0.25 with the address code on, playing the uploads a and b, 10 seconds each
- **WHEN** a starts, and a minute passes with a and b taking turns
- **THEN** mpv is told to draw the code of `http://10.0.0.25/` when a starts
- **AND** it is up every second of that minute, and is not drawn again as each item starts

#### Scenario: the address code sits bottom-right however the TV faces
- **GIVEN** a 1920×1080 panel and a 120-pixel code
- **WHEN** the picture is turned 0, 90, 180 or 270 degrees
- **THEN** the code is drawn 24 pixels in from the panel's bottom-right, bottom-left, top-left or top-right corner, in that order

#### Scenario: the address code is a QR code of the box's address
- **GIVEN** `qrencode`'s text output for `http://10.0.0.25/`
- **WHEN** the box makes the code
- **THEN** each dark module is black and each light one white, every module the same whole number of pixels, inside a white border two modules wide
- **AND** the whole code is at most 120 pixels square

#### Scenario: the address code follows a new address
- **GIVEN** the box showing the code of `http://10.0.0.25/`
- **WHEN** the router gives it 10.0.0.31 and the next item starts
- **THEN** the code drawn is of `http://10.0.0.31/`

#### Scenario: no address code without an address or when switched off
- **GIVEN** the box with no network address, or with the address code switched off
- **WHEN** an item plays
- **THEN** no code is drawn
- **AND** once it is switched back on, it is drawn within a second and stays up

#### Scenario: no address code on a black screen chosen on the website or by the schedule
- **GIVEN** the box showing the address code
- **WHEN** black is chosen under Play, or nothing is scheduled
- **THEN** the screen is black and the code is taken away straight away, and stays away

#### Scenario: the address code stays up on a black screen when nothing fits
- **GIVEN** the box showing the address code, playing portrait uploads
- **WHEN** the TV is turned landscape, so nothing playing fits and the screen goes black
- **THEN** the code is drawn again in the new corner straight away, and stays up without being redrawn
- **AND** a new address draws it again for that address, and no address takes it away
- **AND** with every upload removed, the code is up on the black screen from the start

#### Scenario: setup installs qrencode for the address code
- **GIVEN** a fresh box
- **WHEN** setup runs
- **THEN** it installs `qrencode`
