# Randy Note Columns

## Description

Randy Note Columns works with a track's note columns.  It will set up a Renoise timer function that will randomly select a note column to play solo for that track.  The select note column will then stay solo for some random interval.


### Background 

Many years ago, in the time of Windows XP, there was a company named Sseyo (yes, spelled like that) who released a product called Koan.

Koan was a tool for generating music.  You provided assorted parameters (tempo, scale, odds for this or that change occurring), hit a button, and out came music.

This is a gross simplification.  The range of options was terrific; so much so that getting it produce decent results was a challenge.  Things tended towards either quite predictable or simply meandering.  (Not that these are always bad qualities ...)

There was one  feature that stood out for creating interesting backing tracks.  You could define, say, a drum pattern, but provide alternate takes (so to speak).  For these alternate takes you could assign the odds of each playing.  You might have a steady snare drum as the main track but provide some alternate takes that offered a few flourishes (rolls, rim hits).  When you played the piece there was a somewhat more natural result because of the periodic variation withing the more steady behavior.

Randy Column Notes attempts to provide a similar feature for Renoise.  It assumes that a given track has multiple column notes, but that only one note column should be active at a time; all other should be muted.  

The first column is assumed to be the default.  All the others are the randy columns and should be mute by default.

You can have as many of these sorts of track setups as you like.  Because of the "one column un-muted at a time" requirement these tracks cannot be polyphonic. 



## Usage

Set up a song.  Set up a track with multiple note columns.  Mute all but the first note column in that track.


ng-rnc001_med.png

![Example song](../../images/ng-rnc001_med.png "Example song with multi-column tracks")


Click on the track, then right-click to get the context menu.  

Click on "Neurogami Randy Note Columns"

You get a pop-up window for setting parameters.

## Author

Randy Note Columns was written by James Britt / Neurogami.

Source code can be found [here](https://github.com/Neurogami/renoise-ng/tree/master/lua/com.neurogami.RandyNoteColumns.xrnx).

Send questions and comments to james@neurogami.com

## Licence

MIT License.


Feed your head

Hack your world

Live curious



