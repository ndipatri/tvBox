## Why

Under Play, the buttons of what is playing are outlined, but they aren't picked. With `#nick + Halloween grownup` playing, tapping Nick to drop it *picked* it instead, so there was no way to go from a tag plus a filter to just the filter: you had to know to tap only the filter. The outline looked like a selection that couldn't be undone.

## What Changes

- Until someone taps a choice, Play's picks are what is playing (not Black), following the status. Tapping a playing tag or filter unpicks it, and Play then plays the rest, so a filter can be played with no tags.
- After Play, Black or Back to schedule, the picks follow the box again.
- The hint reads "What's playing starts out picked. Tap to pick or unpick, then tap Play."

## Impact

- `scheduler/website.js` (the advanced page), tests.
- Spec `override-website`: "The page highlights the playing tags" also starts the picks as what is playing.
