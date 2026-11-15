## 1. The player

- [x] 1.1 Tests: the box turns the picture over when it is flipped on the website; a box started with the picture flipped turns it over straight away; a flip for one way of the TV leaves the other alone; the box ignores a flip setting it can't read
- [x] 1.2 `logic.js`: `FLIP_PATH`, `readFlip`, and 180 degrees more in `rotationFor`; `player.js`: remember the angle and turn when it changes

## 2. The website

- [x] 2.1 Tests: the website saves a flip for the way the TV faces; the website refuses a flip it doesn't understand; the page offers Flip the picture
- [x] 2.2 `website.js`: `GET /api/flip`, `POST /api/flip`, and the Flip the picture button in the TV section

## 3. Docs

- [x] 3.1 README's note on an upside-down picture; the tvbox-schedule skill
