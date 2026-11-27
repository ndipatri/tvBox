## MODIFIED Requirements

### Requirement: The page highlights the playing tags
The page SHALL show the status line inside the Play section, above its buttons, and SHALL outline, and mark as current, the buttons of the tags and filters the status names (picked under Play, or a filter playing on its schedule), or Black when it is black, and none otherwise or when the box can't be reached, following the status as it changes. Until someone taps a tag or filter, the page SHALL also pick the playing tags and filters (not Black), so tapping one unpicks it and Play plays the rest; after Play, Black or Back to schedule the picks SHALL follow the status again.

#### Scenario: the page shows the status under Play and outlines what is playing
- **GIVEN** the website running
- **WHEN** the page is opened
- **THEN** the status line is inside the Play section, before its buttons, with no separate status card above it
- **AND** the buttons for what is playing are outlined and have `aria-current="true"`, and the outline is updated with the status

#### Scenario: the page works out which tags are playing from the status
- **GIVEN** the page, and the filters Halloween kid and Thanksgiving
- **WHEN** the status is `#halloween + #thanksgiving (override until cleared)`, `#favorites + Halloween kid (override until 6:30 PM)`, `Thanksgiving (scheduled until 11:00 PM)`, `black (nothing scheduled)`, `black (waiting for the clock to be set)`, and no status
- **THEN** the playing choices are the tags `halloween` and `thanksgiving`; the tag `favorites` and the filter Halloween kid; the filter Thanksgiving; black; black; and none

#### Scenario: the page starts the Play picks as what is playing
- **GIVEN** the page, with `#nick + Halloween grownup (override until cleared)` playing
- **WHEN** it is opened, and no choice has been tapped
- **THEN** Nick and Halloween grownup start out picked (black never is), following the status until a choice is tapped
- **AND** after Play, Black or Back to schedule the picks follow the status again
