## Context

`logic.rotationFor(orientation)` returns `config.box.rotate` (portrait) or `landscapeRotate`, and the player only calls `mpv set_property video-rotate` when the saved way (`screen.json`) changes; mpv starts with `--video-rotate=<rotate>` (`mpv.js`). `screen.json` is rewritten whole, with only `orientation`, by `POST /api/screen` and by the tilt switch. The address code's corner is worked out from `rotationFor(facing)`.

## Decisions

**A separate file, `flip.json`, not `screen.json` or `config.js`.** `screen.json` is rewritten by the TV buttons and the tilt switch, which would drop a flip saved beside the orientation. `config.js` is in the repo and copied to `/opt/tvbox` by setup, so changing it from the website would need root and would block `git pull`. `flip.json` lives in `~/video-scheduler` with the box's other settings: `{ "portrait": bool, "landscape": bool }`, a missing key meaning not flipped. Anything unreadable means no flip, logged once.

**Flip adds 180 degrees inside `rotationFor`.** Everything that uses the angle (mpv, the address code's corner) follows it with no other change. `rotate` and `landscapeRotate` stay the defaults in `config.js`.

**Per orientation, applied to the way the TV faces now.** A TV turned onto its side one way needs the flip for portrait but not necessarily for landscape, so each is saved apart. The button sends the explicit value (`flipped: !current`) for the saved orientation, so two phones can't toggle each other into a wrong state silently.

**The player watches the angle, not only the way.** It remembers the angle mpv is turned to (`turned`, starting at `rotate`, as mpv does) and calls `turnFor` when the way or the angle changes. A flip with the way unchanged only sets `video-rotate`, takes the address code down for its new corner (it is back next tick), and logs `Screen: portrait, turned over (the picture turned 90 degrees).`; it doesn't refit or requeue, since the screen's shape is the same.

## Testability

Player scenarios through `player.test.js`'s fake mpv and files (`flip.json` written between ticks); website scenarios through `site()`; the page's markup and script through the existing `/advanced` checks and `assertScriptCompiles`.

## Rehearsal

The change touches `player.js` and `website.js` but not setup, sync, the units or mpv's start options; the e2e rehearsal is unchanged. Check on a real box: tap Flip the picture and see the picture turn over, then reboot and see it stay.

## Box-only

Seeing the picture turn over on a real TV, and the address code move to the new bottom-right corner.
