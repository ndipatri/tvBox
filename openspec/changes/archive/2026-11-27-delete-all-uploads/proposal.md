## Why

Clearing the box of added photos meant tapping Remove on each one. Asked for a "delete all" button.

## What Changes

- `POST /api/uploads/remove-all` deletes every upload (not the videos from GitHub) and their box tags, says how many, and logs it. No PIN, like Remove.
- The page's Photos and videos section has a Delete all button under the list, shown only while there are uploads. It asks first ("Delete all 12 photos and videos added to the box? This can't be undone. Videos from GitHub stay.").

## Impact

- `scheduler/website.js`, tests.
- Spec `photo-uploads`: new requirement "Removes every upload at once".
