## Why

Which way `rotate` should turn a portrait picture depends on which way the TV was turned onto its side, so it differs from box to box (it was changed from 90 to 270 on 2026-11-11, and the next box needed 90 again). Today the only fix is editing `scheduler/config.js` over SSH and rerunning setup, which also leaves a local change that blocks the box's `git pull`. Someone who set up their own tvBox should be able to fix an upside-down picture from their phone.

## What Changes

- **Flip the picture** on the advanced page's TV section turns the picture over (180 degrees more than the configuration says) for the way the TV faces now; tapping it again turns it back. No PIN, like the TV buttons.
- The choice is saved on the box in `~/video-scheduler/flip.json`, separately for portrait and landscape, so it lasts through restarts, reboots, syncs and updates, and the repo's `config.js` stays untouched.
- The player turns the picture within a second, without restarting and without refitting or queueing again (the screen's shape doesn't change). A box that starts with the picture turned over turns it before anything plays.
- New `GET /api/flip` and `POST /api/flip { orientation, flipped }`.
- The box-player spec's "90 as shipped" is corrected to 270, as `config.js` ships.

## Capabilities

### Modified Capabilities

- `box-player`: turns the picture over when it is flipped for the way the TV faces; `rotate` is 270 as shipped.
- `override-website`: saves a flip for the way the TV faces and offers Flip the picture on the page.

## Impact

- **Code:** `scheduler/logic.js` (`FLIP_PATH`, `readFlip`, `rotationFor`), `scheduler/player.js` (turns the picture when its angle changes, not only its way), `scheduler/website.js` (`/api/flip` and the button).
- **Tests and docs:** `player.test.js`, `website.test.js`, the README's note on an upside-down picture, and the tvbox-schedule skill.
