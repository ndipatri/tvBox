## 1. The player

- [x] 1.1 Tests: the tilt switch scenarios with the per-box setting; a box with the tilt switch off never reads one; the box follows the tilt switch as soon as it is switched on; a tilt switch that reads the wrong way round is followed the other way
- [x] 1.2 `config.js` `tiltGpio`; `logic.js` `TILT_PATH`, `readTilt`; `player.js` reads it each tick

## 2. The website

- [x] 2.1 Tests: the website switches the tilt switch on and off; the website refuses a tilt setting it doesn't understand; the page offers the tilt switch
- [x] 2.2 `website.js`: `GET`/`POST /api/tilt` and the two switches under TV

## 3. Docs and rehearsal

- [x] 3.1 README's tilt switch steps, the tvbox-schedule skill, the rehearsal's check label
