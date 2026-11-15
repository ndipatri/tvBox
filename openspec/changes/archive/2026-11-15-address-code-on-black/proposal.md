## Why

When the screen is black because nothing it was told to play is left (every photo removed, nothing tagged yet, or nothing the TV's shape), the address code goes away too. Then a visitor standing at the TV has nothing to scan, so there's no way to add the photos that would make it play again.

## What Changes

- The address code stays up on a black screen when something was picked to play (an override or a scheduled filter) but none of it is there or fits the TV. It is drawn in the viewer's bottom-right corner as usual, moves with a turn or a flip, follows a new address, and goes when there is no address.
- A black chosen under Play, and a time with nothing scheduled (or before the clock is set), stay fully dark, with no code, so a window at night stays dark.
- The switch under TV still turns the code off everywhere.

## Capabilities

### Modified Capabilities

- `box-player`: "Keeps its address on the TV while something plays" also keeps it up on a black screen when nothing fits, and takes it away only on a black chosen on the website or by the schedule.

## Impact

- **Code:** `scheduler/player.js` (`followCode`).
- **Tests and docs:** `player.test.js` (the black-screen scenario is split in two), the README's QR code paragraph, the tvbox-schedule skill.
