## ADDED Requirements

### Requirement: Turns the picture over
The website SHALL let anyone on the home network say, without the PIN, that the picture comes out upside down (or no longer does) for a way the TV faces. It SHALL save that on the box, apart from which way the TV faces and for portrait and landscape separately, log it, answer `GET /api/flip` with both, and offer a Flip the picture button in the page's TV section that turns the picture over, or back, for the way the box has the TV facing and is marked while it is turned over.

#### Scenario: the website saves a flip for the way the TV faces
- **GIVEN** nothing saved about flipping
- **WHEN** someone posts `{"orientation": "portrait", "flipped": true}` to `/api/flip`
- **THEN** the box saves portrait as turned over and logs `Picture: turned over for a portrait TV (from the website).`
- **AND** the answer says `The picture is turned over for a portrait TV.`
- **AND** `GET /api/flip` answers portrait true and landscape false (both false before)
- **AND** flipping landscape keeps portrait, and posting `"flipped": false` for portrait says `The picture is the usual way up for a portrait TV.` and logs `Picture: the usual way up for a portrait TV (from the website).`
- **AND** which way the TV faces is not changed

#### Scenario: the website refuses a flip it doesn't understand
- **WHEN** someone posts `{"orientation": "sideways", "flipped": true}`, `{"orientation": "portrait", "flipped": "yes"}` or `{}` to `/api/flip`
- **THEN** each answer is 400 and nothing is saved

#### Scenario: the page offers Flip the picture
- **WHEN** someone opens the page
- **THEN** its TV section has a Flip the picture button, saying it is for an upside-down picture
- **AND** the page reads the saved flip as it refreshes, and the button posts the opposite of it for the way the TV faces
