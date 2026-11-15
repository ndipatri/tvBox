## Context

`followCode` (player.js) runs every tick. It took the code down whenever `playlistItems(active).items` was empty, which covers both kinds of black: no filter playing (`active` is null: black chosen under Play, nothing scheduled, clock not set), and a filter or override playing with nothing in it that is there or fits the TV. mpv runs with `--idle=yes --force-window=yes`, so its window stays up while idle and an overlay drawn then shows on the black screen (tried on tvbox: `overlay-add` while `idle-active` was true drew the code).

## Decisions

**Split on `active`, not on the status text.** `active` null means a deliberate black, so the code goes. With `active` set but no items, the code stays up. The status line isn't parsed, and the person chose this split ("when nothing fits"; a black chosen under Play or by the schedule stays dark).

**On black, draw once and leave it.** There's no playlist entry to key the redraw on, so on black the code is drawn when it's down (retrying every `CODE_RETRY_MS` like the playing path), redrawn only when the address changes, and taken away when there's no address. A turn or a flip takes it down (`turnFor`), and the next tick draws it in the new corner. Moving from playing to black leaves the already-drawn code up, since mpv's `stop` doesn't remove overlays.

## Testability

`player.test.js`'s `codeBox` with the fake mpv: black from a turn with only portrait uploads (corner, staying up, not redrawn, new address, no address), black with no uploads at all, black chosen under Play, and nothing scheduled (empty GitHub filters, no override).

## Rehearsal

`inside.sh`'s "on a black screen, the code is taken away" posts black under Play, which still takes it away, so it stays as it is. The rehearsal has no case for nothing fitting; the unit tests cover it and the box check below confirms it.

## Box-only

Seeing the code on the black screen of a real TV.
