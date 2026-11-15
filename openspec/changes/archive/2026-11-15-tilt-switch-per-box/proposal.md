## Why

Whether a box has a tilt switch, and which way round it reads, is different for each box, but it's set in the shared `scheduler/config.js`. #84 set it on (`{ gpio: 17, closed: 'portrait' }`) there for the basement box, so every box now reads GPIO17. A box with no switch reads it open (the pin is pulled up), takes the TV as landscape, and, with the Halloween videos all portrait, shows black. This happened on tvbox on 2026-11-15, a minute after a restart. The README, the spec and the skill all still say the switch is off as shipped.

## What Changes

- **BREAKING** The tilt switch is switched on per box on its website, under TV ("This TV has a tilt switch…"), and is off until then. A box that had it on in `config.js` (the basement box) needs it switched on there once.
- Also under TV, "The tilt switch gets it the wrong way round" replaces editing `closed` in `config.js`.
- Saved on the box in `~/video-scheduler/tilt.json` (`{ on, closed }`), so it lasts through restarts and updates. The player reads it every tick: switched on, the switch is followed within 2 seconds; switched off, the pin isn't read.
- `config.js` keeps only the pin, `tiltGpio: 17`.
- New `GET /api/tilt` and `POST /api/tilt { on, closed }`.

## Capabilities

### Modified Capabilities

- `box-player`: "Follows a tilt switch on the TV" follows the per-box setting, not `config.js`.
- `override-website`: switches the tilt switch on and off, and says which way round it reads.

## Impact

- **Code:** `scheduler/config.js` (`tiltSwitch` → `tiltGpio`), `scheduler/logic.js` (`TILT_PATH`, `readTilt`), `scheduler/player.js` (`followTilt` reads the setting each tick), `scheduler/website.js` (`/api/tilt` and the two switches).
- **Tests and docs:** `player.test.js`, `website.test.js`, the rehearsal's check label, the README's tilt switch steps, and the tvbox-schedule skill.
