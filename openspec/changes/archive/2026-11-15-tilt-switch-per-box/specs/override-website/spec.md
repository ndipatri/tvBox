## ADDED Requirements

### Requirement: Switches the tilt switch on and off
The website SHALL let anyone on the home network, without the PIN, switch the box's tilt switch on or off and say whether it reads the wrong way round (closed while landscape). It SHALL save that on the box, log it, answer `GET /api/tilt` with it (off, closed while portrait, when nothing is saved), and offer two switches in the page's TV section, "This TV has a tilt switch, so the box notices by itself when it's turned" and "The tilt switch gets it the wrong way round", showing what is saved.

#### Scenario: the website switches the tilt switch on and off
- **GIVEN** nothing saved about a tilt switch
- **WHEN** someone posts `{"on": true}` to `/api/tilt`
- **THEN** the box saves it on, closed while portrait, logs `Tilt switch: on, closed while portrait (from the website).`, and answers `The box follows the tilt switch on the TV.`
- **AND** `GET /api/tilt` answered off, closed while portrait, before
- **AND** posting `{"on": true, "closed": "landscape"}` saves closed while landscape
- **AND** posting `{"on": false}` saves it off, keeps closed while landscape, logs `Tilt switch: off (from the website).`, and answers `The box doesn't read a tilt switch. Tap Portrait or Landscape when you turn the TV.`

#### Scenario: the website refuses a tilt setting it doesn't understand
- **WHEN** someone posts `{}`, `{"on": "yes"}` or `{"on": true, "closed": "sideways"}` to `/api/tilt`
- **THEN** each answer is 400 and nothing is saved

#### Scenario: the page offers the tilt switch
- **WHEN** someone opens the page
- **THEN** its TV section has the two tilt switch switches, filled from `/api/tilt` as the page refreshes
- **AND** changing either posts both to `/api/tilt`
