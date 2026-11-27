## ADDED Requirements

### Requirement: Removes every upload at once
Asked by anyone on the home network, with no PIN, the website SHALL delete every upload and drop their box tags, leaving the videos from GitHub, say how many it removed, and log it. The page SHALL offer a Delete all button under the uploads, only while there are any, that asks before deleting.

#### Scenario: the website removes every upload at once
- **GIVEN** `photos/00001-a.jpg` tagged `family`, `photos/00002-b.mp4`, and `halloween/fuzzy.mp4` from GitHub
- **WHEN** the website is asked to remove all uploads
- **THEN** both uploads are gone, their box tags with them, and `halloween/fuzzy.mp4` is still there
- **AND** the website answers `Removed 2 uploads.`
- **AND** the log says `Removed all 2 uploads (from the website)` and the player is told

#### Scenario: the page offers Delete all, and asks first
- **GIVEN** the website running
- **WHEN** the page is opened
- **THEN** its Photos and videos section has a Delete all button, shown only while there are uploads
- **AND** it asks `Delete all 12 photos and videos added to the box? This can't be undone. Videos from GitHub stay.` (for 12) before deleting anything
