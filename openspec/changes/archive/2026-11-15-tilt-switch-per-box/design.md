## Context

`player.js` took `config.box.tiltSwitch` (`{ gpio, closed }` or null) once at start and, when set, read the pin every tick with `tilt.js` (`gpioget --bias=pull-up --numeric`, so an unwired pin reads 1, open). `switchState.acted` starts null, so the first reading that holds for 2 seconds is saved to `screen.json` even if the TV hasn't moved. That's why a box with no switch, set on, went landscape a minute after every restart.

## Decisions

**A per-box file, `tilt.json`, like `flip.json`.** `{ "on": bool, "closed": "portrait"|"landscape" }` in `~/video-scheduler`. Missing means off and closed while portrait. Unreadable means off, logged once. It's not in the repo, so one box's switch can't switch another's on, and nobody edits `config.js` (which would block `git pull`).

**The pin stays in `config.js`** as `tiltGpio: 17`. It depends on the wiring the README describes, not on the box, so it stays a shipped default.

**Read every tick.** `logic.readTilt()` each tick. While it's on, `followTilt(tilt)` runs as before. While it's off, the pin isn't read and `switchState` is reset, so switching it on follows the switch afresh: whatever it reads, once held for 2 seconds, is saved. A change to `closed` also resets `acted`, so "the wrong way round" takes effect within 2 seconds without moving the TV.

**Two switches on the page, not a choice of ways.** "This TV has a tilt switch…" and "…gets it the wrong way round" (`closed: 'landscape'`, disabled while off). Both post `{ on, closed }` together. `POST /api/tilt` keeps the saved `closed` when it isn't given.

**No migration.** A box can't tell whether it has a switch (an unwired pin reads the same as an open switch), so a box that used `config.js` needs it switched on once on its page. The PR says so.

## Testability

`player.test.js`'s `tiltBox` now writes `tilt.json` instead of a config; new tests switch it on while running, switch it off, and change which way round it reads; the "never reads" test covers nothing saved, saved off, and unreadable. Website routes through `site()`, and the page through the `/advanced` checks and `assertScriptCompiles`.

## Rehearsal

The rehearsal has no GPIO. Its check "with no tilt switch set, the box never warns about one" still holds (off as shipped) and is relabelled. Setup is unchanged (it still installs `gpiod` and adds the user to `gpio`).

## Box-only

On tvbox (pin reads open, no switch wired): after setup, the TV stays portrait across a restart. On the basement box: switch it on on its page and turn the TV.
