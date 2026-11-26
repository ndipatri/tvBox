# box-player Specification

## Purpose
Puts the right videos on the TV from the Raspberry Pi box through mpv, keeps the screen black when nothing should play, and reports what it shows, so the tvBox runs on its own.
## Requirements
### Requirement: Black until the clock is set
The box SHALL show black and play nothing until the system says its clock has been set from the network, and SHALL then follow the schedule.

#### Scenario: the box stays black until the clock is set
- **GIVEN** the starting filters and a `halloween` folder with videos, at 6:00 PM on Oct 20, 2026, with the clock not yet set
- **WHEN** the box runs
- **THEN** mpv plays nothing
- **AND** the status is `black (waiting for the clock to be set)`

#### Scenario: the box starts playing once the clock is set
- **GIVEN** the box waiting for the clock at 6:00 PM on Oct 20, 2026, with the starting filters and a `halloween` folder with videos
- **WHEN** the clock is set and the box runs again
- **THEN** mpv plays Halloween kid
- **AND** the status is `Halloween kid (scheduled until 7:30 PM)`

### Requirement: Recovers when mpv stops
When mpv exits, the box SHALL log it and exit with an error, so the system service starts the box again with a fresh mpv.

#### Scenario: the box exits when mpv stops, so it is restarted
- **GIVEN** the box running with mpv
- **WHEN** mpv exits with code 1
- **THEN** `ERROR: mpv stopped (exit code 1). Exiting so the box restarts.` is logged
- **AND** the box exits with code 1

### Requirement: Shows each photo for a set time
The box SHALL have mpv keep each photo on screen for the number of seconds set as `photoSeconds` in the configuration (10 as shipped), with black behind any transparent parts, then move on to the next item. A photo the same shape as the screen (portrait on a portrait TV, landscape on a landscape TV, judged as the photo is shown, after its EXIF orientation) SHALL fill the screen (zoomed until there is no black around it, its edges cropped evenly); any other photo that plays (square, or tagged with a shape it isn't) SHALL be shown whole with black around it. Videos SHALL be fitted to the screen whole, with black around them. When the only item to play is one photo, the box SHALL queue it once and hold it on screen, rather than reloading it (which flashes black), and SHALL let it give way, without going black, as soon as something else is to play.

#### Scenario: the box shows each photo for 10 seconds
- **GIVEN** the shipped configuration
- **WHEN** the box starts mpv
- **THEN** mpv is told to show each photo for 10 seconds
- **AND** mpv is told to fit the picture to the screen, not crop it, on a black background, unless an item says otherwise

#### Scenario: each photo fills the screen and each video is fitted whole
- **GIVEN** the TV portrait and the uploads `00001-a.jpg` (portrait), `00002-b.mp4` and `00003-c.png` (portrait)
- **WHEN** the box plays the tag `upload`
- **THEN** mpv is given each photo to fill the screen (`panscan=1.0` for that item)
- **AND** the video with no such option, so it is fitted whole

#### Scenario: a lone photo is held on screen, not reloaded
- **GIVEN** the TV portrait and the one upload `00001-a.jpg` (portrait)
- **WHEN** the box plays the tag `upload` and keeps running
- **THEN** mpv is given the photo once, to fill the screen and stay (`panscan=1.0,image-display-duration=inf`)
- **AND** it is never queued again while it is the only item

#### Scenario: a held photo gives way when something else is to play
- **GIVEN** the box holding the lone upload `00001-a.jpg`
- **WHEN** `00002-b.jpg` is uploaded
- **THEN** b plays next, straight away
- **AND** the queue is b, a, b, each shown for the usual time

#### Scenario: a photo that isn't the screen's shape is shown whole
- **GIVEN** the TV portrait and the landscape uploads `00001-wide.jpg` and `00002-wide.png`, both tagged `portrait`
- **WHEN** the box plays the tag `upload`
- **THEN** mpv is given each of them with no `panscan`, so each is shown whole

#### Scenario: a square photo plays either way, shown whole
- **GIVEN** the TV portrait and the uploads `00001-square.png` (square), `00002-broken.jpg` (not measurable), `00003-wide.jpg` (landscape) and `00004-tall.jpg` (portrait)
- **WHEN** the box plays the tag `upload`
- **THEN** square (with no `panscan`, shown whole) and tall are queued, and not broken or wide
- **AND** the box logs once that it is leaving broken out: `WARNING: Leaving out 00002-broken.jpg in #upload: it can't be measured. Tag it portrait or landscape to play it.`
- **AND** with the TV landscape, square and wide are queued, and not broken

#### Scenario: a photo stored on its side is measured the way it is shown
- **GIVEN** JPEGs stored 160 wide and 96 high with EXIF orientation 6 or 8, and one with orientation 1
- **WHEN** the box measures them
- **THEN** the ones with orientation 6 and 8 are 96 wide and 160 high (portrait), and the other 160 wide and 96 high
- **AND** a PNG is measured from its header, and a file that isn't a JPEG or PNG has no size

#### Scenario: a video's shape is measured the way it is shown
- **GIVEN** MP4s 1920 wide and 1080 high, one with a 90° rotation matrix, one with its `moov` after its `mdat`, and one with an audio track before the video
- **WHEN** the box measures them
- **THEN** the turned one is 1080 wide and 1920 high, and the others 1920 wide and 1080 high
- **AND** a file that isn't an MP4 has no size

### Requirement: Decodes HEVC videos in hardware
The box SHALL have mpv decode HEVC videos, which phones record, with the Raspberry Pi's hardware decoder, and SHALL keep every other codec, H.264 included, on software decoding without trying hardware first.

#### Scenario: the box decodes HEVC in hardware and H.264 in software
- **GIVEN** the shipped configuration
- **WHEN** the box starts mpv
- **THEN** mpv is told to use the `drm` hardware decoder for HEVC only

### Requirement: Plays the filters through mpv
While the clock is set, the box SHALL play what the filters' schedules and any override choose, as queued items in mpv, and SHALL switch as soon as that choice changes.

#### Scenario: the box plays the scheduled filter
- **GIVEN** the starting filters, a `halloween` folder with `fuzzy.mp4` and `mochi.mp4`, and the clock set
- **WHEN** the box runs at 6:00 PM on Tuesday, Oct 20, 2026
- **THEN** mpv's playlist is `halloween/fuzzy.mp4`, `halloween/mochi.mp4`, `halloween/fuzzy.mp4`, and fuzzy is playing

#### Scenario: the box switches filters when the schedule changes
- **GIVEN** the starting filters, a `halloween` folder with `fuzzy.mp4` and a `halloween/grownup` folder with `jump.mp4`, and the clock set
- **WHEN** the box runs at 7:29 PM and then at 7:30 PM on Oct 20, 2026
- **THEN** at 7:30 PM mpv's playlist is replaced with Halloween grownup's items, starting with `halloween/fuzzy.mp4` then `halloween/grownup/jump.mp4`

#### Scenario: a filter that comes back resumes at the item it was on
- **GIVEN** a `halloween` folder with `a.mp4`, `b.mp4` and `c.mp4`, and Halloween kid on `b.mp4` when an override to black starts
- **WHEN** the override ends and Halloween kid plays again
- **THEN** mpv's playlist starts with `halloween/b.mp4`

#### Scenario: an item added while playing is queued without a restart
- **GIVEN** Halloween kid playing from a `halloween` folder with only `a.mp4`
- **WHEN** `b.mp4` is added to the folder and the queue next needs topping up
- **THEN** `halloween/b.mp4` is queued after `halloween/a.mp4`

### Requirement: Keeps the next items queued
While a filter plays, mpv's playlist SHALL hold the playing item and the next two, so each follows the last without a gap, and SHALL drop items once they have played.

#### Scenario: the box keeps the next items queued
- **GIVEN** Halloween kid playing from a `halloween` folder with `a.mp4`, `b.mp4` and `c.mp4`
- **WHEN** five items in a row finish
- **THEN** after each one, mpv's playlist holds exactly three items, the first of them playing

### Requirement: Black when nothing should play, with filters
The box SHALL show black, with mpv stopped, when no filter is scheduled and while an override chooses black.

#### Scenario: the box shows black when nothing is scheduled
- **GIVEN** the starting filters, Halloween kid playing at 6:00 PM on Oct 20, 2026, and the clock set
- **WHEN** the box runs at 11:30 PM
- **THEN** mpv is stopped with an empty playlist
- **AND** the status is `black (nothing scheduled until Wed 5:00 AM)`

#### Scenario: the box shows black while an override chooses black
- **GIVEN** the starting filters, Halloween kid playing at 6:00 PM on Oct 20, 2026, and the clock set
- **WHEN** an override to black until cleared is written and the box runs again
- **THEN** mpv is stopped with an empty playlist
- **AND** the status is `black (override until cleared)`

### Requirement: Reports what it shows, naming the filter
The box SHALL write the current status line to `~/video-scheduler/status` and log it each time it changes, and SHALL log each item as it starts, naming the filter.

#### Scenario: the box writes what it is showing to the status file and the log
- **GIVEN** the starting filters and a `halloween` folder with `fuzzy.mp4`, and the clock set
- **WHEN** the box runs at 6:00 PM on Oct 20, 2026, twice
- **THEN** the status file holds `Halloween kid (scheduled until 7:30 PM)`
- **AND** the log has `Now showing: Halloween kid (scheduled until 7:30 PM)` once and `Halloween kid: playing fuzzy.mp4` once

### Requirement: Skips items mpv cannot play
When mpv fails to play an item, the box SHALL log it once and carry on with the next item.

#### Scenario: the box skips an item mpv can't play and logs it once
- **GIVEN** Halloween kid playing `halloween/bad.mp4` and then `halloween/good.mp4`
- **WHEN** mpv reports twice that `bad.mp4` failed to play
- **THEN** `ERROR: Skipping bad.mp4 in Halloween kid` is logged once
- **AND** `halloween/good.mp4` plays

### Requirement: Turns the picture for the way the TV faces
The box SHALL turn the picture by `rotate` from the configuration (270 as shipped) while the TV is portrait, and by `landscapeRotate` (0 as shipped) while it is landscape, as saved from the website; with nothing saved, the TV is portrait. When the saved way changes, the box SHALL turn the picture straight away without restarting, refit the item on screen for the new shape (or move on from it, when it no longer matches the TV), and queue the items behind it again for the new shape.

#### Scenario: the box turns the picture when the TV is turned to landscape
- **GIVEN** the TV portrait, playing the uploads `00001-tall.jpg` (portrait) and `00002-wide.jpg` (landscape), with tall on screen and filling it
- **WHEN** the TV is saved as landscape
- **THEN** mpv turns the picture by 0 degrees
- **AND** tall, no longer the TV's shape, gives way at once to wide, which fills the screen
- **AND** the box logs `Screen: landscape`
- **AND** when the TV is saved as portrait again, tall comes back, filling the screen

#### Scenario: a box started with the TV landscape turns the picture straight away
- **GIVEN** the TV saved as landscape
- **WHEN** the box starts
- **THEN** mpv turns the picture by 0 degrees before anything plays

### Requirement: Follows a tilt switch on the TV
While the tilt switch is switched on for the box on its website (off as shipped, and off when what is saved can't be read, logged once), the box SHALL read the pin `tiltGpio` from the configuration (17 as shipped) every second and, once the switch has held a new position for 2 seconds, save the way the TV faces as the website's buttons do, so the picture turns to match: the way saved on the website for a closed switch (portrait unless it was said to read the wrong way round), and the other way for an open one. A way chosen on the website SHALL stay until the switch next moves. Switched on, or told it reads the other way round, the box SHALL follow it afresh, saving what it reads once that has held for 2 seconds. Switched off, the box SHALL NOT read the pin. A switch that can't be read SHALL be logged once and otherwise ignored. Setup SHALL let the box read the pins.

#### Scenario: the box follows the tilt switch when the TV is turned
- **GIVEN** the tilt switch on, closed while portrait, the switch closed and the TV portrait
- **WHEN** the switch opens and stays open for 2 seconds
- **THEN** the box saves landscape, logs `Screen: landscape (from the tilt switch).`, and turns the picture by 0 degrees
- **AND** when it closes again for 2 seconds, the box saves portrait

#### Scenario: a tilt switch that flickers while the TV turns is ignored until it settles
- **GIVEN** the tilt switch on, the switch closed and the TV portrait
- **WHEN** the switch reads open for 1 second, then closed again
- **THEN** nothing is saved and the picture isn't turned

#### Scenario: the website's choice stays until the tilt switch moves
- **GIVEN** the tilt switch on and the switch closed (portrait)
- **WHEN** Landscape is chosen on the website and the switch stays closed
- **THEN** the TV stays landscape
- **AND** once the switch opens and closes again, it follows the switch

#### Scenario: a box with the tilt switch off never reads one
- **GIVEN** nothing saved about a tilt switch (as shipped), or it saved as off, and a pin that reads open
- **WHEN** the box runs
- **THEN** it never reads the pin, and the TV stays portrait
- **AND** with what is saved not JSON, it logs `WARNING: Couldn't read <videoRoot>/tilt.json: not reading a tilt switch.` once and reads no pin

#### Scenario: the box follows the tilt switch as soon as it is switched on
- **GIVEN** the tilt switch off, the TV portrait, and a pin that reads open
- **WHEN** the tilt switch is switched on and 2 seconds pass
- **THEN** the box saves landscape
- **AND** once it is switched off again, it stops reading the pin and leaves the TV as the website says

#### Scenario: a tilt switch that reads the wrong way round is followed the other way
- **GIVEN** the tilt switch on and said to read the wrong way round (closed while landscape)
- **WHEN** the switch is closed, then open for 2 seconds
- **THEN** the box saves landscape, then portrait
- **AND** told it reads the usual way round while it stays open, it saves landscape within 2 seconds

#### Scenario: a tilt switch that can't be read is logged once
- **GIVEN** the tilt switch on and a pin that can't be read
- **WHEN** the box runs for several seconds
- **THEN** it logs `WARNING: Couldn't read the tilt switch on GPIO17: ...` once, and the TV stays as it was

#### Scenario: the box reads the tilt switch with the pin pulled up
- **WHEN** the box reads the switch on GPIO17
- **THEN** it runs `gpioget --bias=pull-up --numeric GPIO17`
- **AND** takes `0` as closed, `1` as open, and anything else, or a failure, as unreadable

#### Scenario: setup lets the box read the tilt switch
- **WHEN** setup runs
- **THEN** it installs `gpiod` and adds the box's user to the `gpio` group

### Requirement: Puts each picture on the TV as soon as it is drawn
The box SHALL have mpv keep at most one drawn frame waiting to be shown, so a photo (drawn only once or twice) reaches the TV as soon as mpv draws it, rather than waiting until later frames push it out.

#### Scenario: the box sends each picture to the TV as soon as it is drawn
- **GIVEN** the shipped configuration
- **WHEN** the box starts mpv
- **THEN** mpv is told to keep at most one drawn frame waiting (`--swapchain-depth=1`)

### Requirement: Plays only what fits the TV
Of the items picked to play, the box SHALL play only those the TV's shape (portrait while the TV is portrait, landscape while it is landscape); square items SHALL play either way. An item's shape SHALL be the tag `portrait` or `landscape` when it has exactly one, otherwise its measured shape after its rotation. A shape tag SHALL NOT change how a photo is fitted.

#### Scenario: only items the TV's shape play
- **GIVEN** the uploads `00001-tall.jpg`, `00002-tall.mp4` (portrait), `00003-wide.jpg` and `00004-wide.mp4` (landscape)
- **WHEN** the box plays the tag `upload` with the TV portrait
- **THEN** only the tall photo and video are queued
- **AND** with the TV landscape, only the wide photo and video

#### Scenario: a shape tag decides which way an item plays
- **GIVEN** the uploads `00001-tall.jpg`, `00002-wide.mp4` tagged `portrait`, and `00003-wide.jpg`
- **WHEN** the box plays the tag `upload` with the TV portrait
- **THEN** the tall photo and the wide video are queued, the video with `panscan=0`
- **AND** with the TV landscape, only the wide photo

#### Scenario: a photo tagged with the other shape is shown whole
- **GIVEN** the TV portrait and the uploads `00001-wide.jpg` tagged `portrait` and `00002-tall.jpg`
- **WHEN** the box plays the tag `upload`
- **THEN** the wide photo is queued with `panscan=0` and the tall one with `panscan=1.0`

#### Scenario: an item tagged both portrait and landscape keeps its measured shape
- **GIVEN** the TV portrait and the uploads `00001-tall.jpg` and `00002-wide.jpg` tagged both `portrait` and `landscape`
- **WHEN** the box plays the tag `upload`
- **THEN** only the tall photo is queued

### Requirement: Items that can't be measured need a shape tag
An item whose shape can't be measured and that has no shape tag SHALL NOT play, and leaving it out SHALL be logged once.

#### Scenario: an item that can't be measured doesn't play until it has a shape tag
- **GIVEN** the TV portrait and the uploads `00001-broken.jpg` (not measurable) and `00002-wide.jpg` (landscape)
- **WHEN** the box plays the tag `upload`
- **THEN** nothing is queued, and the box logs once `WARNING: Leaving out 00001-broken.jpg in #upload: it can't be measured. Tag it portrait or landscape to play it.`
- **AND** once `00001-broken.jpg` is tagged `portrait`, it is queued

### Requirement: Shows black when nothing is the TV's shape
When none of the picked items is the TV's shape, the box SHALL show black, and log that once, until something is or the TV is turned back.

#### Scenario: with nothing the TV's shape, the screen is black
- **GIVEN** the uploads `00001-a.jpg` and `00002-b.mp4`, both portrait, playing on the TV portrait
- **WHEN** the TV is turned landscape
- **THEN** the screen goes black and nothing is queued
- **AND** the box logs `Nothing in #upload is landscape. Showing black until something is, or the TV is turned back.` once
- **AND** turned back to portrait, they play again

### Requirement: Keeps its address on the TV while something plays
While something plays and the address code is switched on, the box SHALL keep a QR code of its website's address (`http://<its IPv4 address>/`) on top of the picture in the viewer's bottom-right corner, left up from item to item without being redrawn. It SHALL also keep it up while the screen is black because nothing in what is playing (an override or a scheduled filter) is there or fits the TV, redrawing it there only for a new address. It SHALL take it away only when switched off, with no address, or on a black chosen on the website or by the schedule (nothing playing), and put it back straight away after a turn or being switched back on.

#### Scenario: the address code stays up while items play
- **GIVEN** the box at 10.0.0.25 with the address code on, playing the uploads a and b, 10 seconds each
- **WHEN** a starts, and a minute passes with a and b taking turns
- **THEN** mpv is told to draw the code of `http://10.0.0.25/` when a starts
- **AND** it is up every second of that minute, and is not drawn again as each item starts

#### Scenario: the address code sits bottom-right however the TV faces
- **GIVEN** a 1920×1080 panel and a 120-pixel code
- **WHEN** the picture is turned 0, 90, 180 or 270 degrees
- **THEN** the code is drawn 24 pixels in from the panel's bottom-right, bottom-left, top-left or top-right corner, in that order

#### Scenario: the address code is a QR code of the box's address
- **GIVEN** `qrencode`'s text output for `http://10.0.0.25/`
- **WHEN** the box makes the code
- **THEN** each dark module is black and each light one white, every module the same whole number of pixels, inside a white border two modules wide
- **AND** the whole code is at most 120 pixels square

#### Scenario: the address code follows a new address
- **GIVEN** the box showing the code of `http://10.0.0.25/`
- **WHEN** the router gives it 10.0.0.31 and the next item starts
- **THEN** the code drawn is of `http://10.0.0.31/`

#### Scenario: no address code without an address or when switched off
- **GIVEN** the box with no network address, or with the address code switched off
- **WHEN** an item plays
- **THEN** no code is drawn
- **AND** once it is switched back on, it is drawn within a second and stays up

#### Scenario: no address code on a black screen chosen on the website or by the schedule
- **GIVEN** the box showing the address code
- **WHEN** black is chosen under Play, or nothing is scheduled
- **THEN** the screen is black and the code is taken away straight away, and stays away

#### Scenario: the address code stays up on a black screen when nothing fits
- **GIVEN** the box showing the address code, playing portrait uploads
- **WHEN** the TV is turned landscape, so nothing playing fits and the screen goes black
- **THEN** the code is drawn again in the new corner straight away, and stays up without being redrawn
- **AND** a new address draws it again for that address, and no address takes it away
- **AND** with every upload removed, the code is up on the black screen from the start

#### Scenario: setup installs qrencode for the address code
- **GIVEN** a fresh box
- **WHEN** setup runs
- **THEN** it installs `qrencode`

### Requirement: Turns the picture over when it is flipped
The box SHALL turn the picture 180 degrees more than `rotate` (portrait) or `landscapeRotate` (landscape) while the picture is turned over for the way the TV faces, as saved from the website, separately for portrait and for landscape; with nothing saved, neither is turned over. When that changes, the box SHALL turn the picture straight away without restarting, keep the item on screen, and log `Screen: <way>, turned over (the picture turned <degrees> degrees).` A box started with the picture turned over SHALL turn it before anything plays. A saved setting that can't be read SHALL be logged once and treated as nothing turned over.

#### Scenario: the box turns the picture over when it is flipped on the website
- **GIVEN** the TV portrait, playing uploads
- **WHEN** the picture is saved as turned over for portrait
- **THEN** mpv turns the picture by `rotate` plus 180 degrees (90 as shipped), once
- **AND** the box logs `Screen: portrait, turned over (the picture turned 90 degrees).`
- **AND** the same item stays on screen and nothing is queued again
- **AND** when it is saved as not turned over, mpv turns the picture by `rotate` again

#### Scenario: a box started with the picture flipped turns it over straight away
- **GIVEN** the picture saved as turned over for portrait, and the TV portrait
- **WHEN** the box starts
- **THEN** mpv turns the picture by `rotate` plus 180 degrees before anything plays

#### Scenario: a flip for one way of the TV leaves the other alone
- **GIVEN** the picture saved as turned over for portrait only, and the TV landscape
- **WHEN** the box plays
- **THEN** mpv turns the picture by `landscapeRotate`
- **AND** when it is also saved as turned over for landscape, by `landscapeRotate` plus 180 degrees

#### Scenario: the box ignores a flip setting it can't read
- **GIVEN** the saved flip setting is not JSON
- **WHEN** the box plays for two seconds
- **THEN** the picture stays turned by `rotate`, and `WARNING: Couldn't read <videoRoot>/flip.json: not turning the picture over.` is logged once

### Requirement: Shrinks photos too big for the box's graphics
The box SHALL have mpv shrink a photo more than 4096 pixels wide or high (as measured, after its EXIF orientation) as it loads, to fit within 4096 × 4096 with its shape and orientation kept, since the Pi's graphics can't show a bigger picture. Photos up to 4096 on both sides, and videos, SHALL be loaded without this. The shrink and any flip SHALL go to mpv as one filter graph, length-quoted (`vf=%N%lavfi=[…]`) so its commas are kept.

#### Scenario: a photo too big for the box's graphics is shrunk as it loads
- **GIVEN** the TV portrait and the uploads `00001-huge.jpg` (4284 × 5712), `00002-a.jpg` (a small portrait photo) and `00003-b.mp4`
- **WHEN** the box plays the tag `upload`
- **THEN** mpv is given the huge photo with `vf=%60%lavfi=[scale=4096:4096:force_original_aspect_ratio=decrease]` after its `panscan`
- **AND** the small photo and the video without it

### Requirement: Flips back photos stored mirrored
The box SHALL show a JPEG stored mirrored (EXIF orientation 2, 4, 5 or 7) the way its orientation says, as the phone shows it. Since mpv takes only the turn from such a photo and drops the mirror, the box SHALL have mpv flip it top to bottom as it loads, before mpv's own turn. Photos with any other orientation SHALL be loaded without a flip.

#### Scenario: a photo stored mirrored is marked to be corrected
- **GIVEN** JPEG headers 160 × 96 with each EXIF orientation 1 to 8
- **WHEN** the box measures them
- **THEN** 2, 4, 5 and 7 are marked mirrored, and 1, 3, 6 and 8 are not
- **AND** 5 to 8 measure 96 × 160, the rest 160 × 96

#### Scenario: a photo stored mirrored is corrected as it loads
- **GIVEN** the TV portrait and the uploads `00001-mirrored.jpg` (portrait, stored mirrored) and `00002-a.jpg` (portrait)
- **WHEN** the box plays the tag `upload`
- **THEN** mpv is given the mirrored photo with `vf=%13%lavfi=[vflip]` after its `panscan`
- **AND** the other photo without it

