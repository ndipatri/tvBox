## MODIFIED Requirements

### Requirement: Follows a tilt switch on the TV
While the tilt switch is switched on for the box on its website (off as shipped, and off when what is saved can't be read, logged once), the box SHALL read the pin `tiltGpio` from the configuration (17 as shipped) every second and, once the switch has held a new position for 2 seconds, save the way the TV faces as the website's buttons do, so the picture turns to match: the way saved on the website for a closed switch (portrait unless it was said to read the wrong way round), and the other way for an open one. A way chosen on the website SHALL stay until the switch next moves. Switched on, or told it reads the other way round, the box SHALL follow it afresh, saving what it reads once that has held for 2 seconds. Switched off, the box SHALL NOT read the pin. A switch that can't be read SHALL be logged once and otherwise ignored. Setup SHALL let the box read the pins.

#### Scenario: the box follows the tilt switch when the TV is turned
- **GIVEN** the tilt switch on, closed while portrait, the switch closed and the TV portrait
- **WHEN** the switch opens and stays open for 2 seconds
- **THEN** the box saves landscape, logs `Screen: landscape (from the tilt switch).`, and turns the picture by 0 degrees
- **AND** when it closes again for 2 seconds, the box saves portrait

#### Scenario: a tilt switch that flickers while the TV turns is ignored until it settles
- **GIVEN** the tilt switch on, the switch closed and the TV portrait
- **WHEN** the switch reads open for 1 second, then closed again
- **THEN** nothing is saved and the picture isn't turned

#### Scenario: the website's choice stays until the tilt switch moves
- **GIVEN** the tilt switch on and the switch closed (portrait)
- **WHEN** Landscape is chosen on the website and the switch stays closed
- **THEN** the TV stays landscape
- **AND** once the switch opens and closes again, it follows the switch

#### Scenario: a box with the tilt switch off never reads one
- **GIVEN** nothing saved about a tilt switch (as shipped), or it saved as off, and a pin that reads open
- **WHEN** the box runs
- **THEN** it never reads the pin, and the TV stays portrait
- **AND** with what is saved not JSON, it logs `WARNING: Couldn't read <videoRoot>/tilt.json: not reading a tilt switch.` once and reads no pin

#### Scenario: the box follows the tilt switch as soon as it is switched on
- **GIVEN** the tilt switch off, the TV portrait, and a pin that reads open
- **WHEN** the tilt switch is switched on and 2 seconds pass
- **THEN** the box saves landscape
- **AND** once it is switched off again, it stops reading the pin and leaves the TV as the website says

#### Scenario: a tilt switch that reads the wrong way round is followed the other way
- **GIVEN** the tilt switch on and said to read the wrong way round (closed while landscape)
- **WHEN** the switch is closed, then open for 2 seconds
- **THEN** the box saves landscape, then portrait
- **AND** told it reads the usual way round while it stays open, it saves landscape within 2 seconds

#### Scenario: a tilt switch that can't be read is logged once
- **GIVEN** the tilt switch on and a pin that can't be read
- **WHEN** the box runs for several seconds
- **THEN** it logs `WARNING: Couldn't read the tilt switch on GPIO17: ...` once, and the TV stays as it was

#### Scenario: the box reads the tilt switch with the pin pulled up
- **WHEN** the box reads the switch on GPIO17
- **THEN** it runs `gpioget --bias=pull-up --numeric GPIO17`
- **AND** takes `0` as closed, `1` as open, and anything else, or a failure, as unreadable

#### Scenario: setup lets the box read the tilt switch
- **WHEN** setup runs
- **THEN** it installs `gpiod` and adds the box's user to the `gpio` group
