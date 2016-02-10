# Notes on code/tool for generative renoise tracks #

More or less.


Songs cannot contain code. Is this an absolute?   

Thought one: A tool that looks to see if a song contains a certain "sample" that is really code disguised as a wav file.

Then the code reads that sample and uses the code to direct the generative (or whatever) aspects of the song.

So, can code read samples?

Thought two: Read the song comments.  Set them to not show by default. Load them with some special script. Read the script and execute.

BTW, didn't you already do this? With the song-scripter thing?

In any event, the upside here is that a user can edit the comments to alter the dynamic behavior.

** Do idea two ! **

So we should have code that manages such scripting. 

## What code is it? ##

**RandyNoteColumn**  assumes there are assorted columns in a track, and will select a random track-column based on some params.
Or just stick to the first one? That's likely the default.

`The first column is assumed to be the default.  All the others are the randy columns.`

To set up the values you need to run the tool and manage the settings per song.    The song-settings are save in an XML file that is store in the Scripts/Tools/RandyWhatever folder, named after the song name in the comments.

** BeatMasher ** works via OSC and allows you to do some basic track manipulation.  It *seems* like it was created to alter a simple rhythm track with stuff like note rotation, altering BPM, adding notes.


** LoopComposer ** "lets you define a sequence of pattern-range loops." Says the README.

It, too, uses a tool-based editor, and saves stuff per-song in the tool's folder.  It's an XML file that stuffs the "composition" into a single element.

** Configgy ** will load and run some custom code if there is a lua file matching the song name.

** OSC Jumper ** uses OSC to set/jump in and around loops. It's sort like `LoopComposer` in that way, but driven by OSC.


That's a lot of code spread over multiple tools.  Thought one: Update those tools so that their core behavior could be used as a library in another tool.

Then, write a Rake task that assembles the `Generative` tool from these other files.  The goal is maintain code in one place.

Another option is to just bundle all this shit into on mega-tool and call it a day. 


## How would it work? ##


The "script" is kept in the comments.

There is a tool, "Generative" (for now), that has a "Play" menu item

When you hit this "Play" item the tool reads the script from the comments and starts the song.

The script would control the values for:
 * randy columns
 * loop ranges and how many times to loop
 * Other?

For example:

    Play an intro loop n(2,4) times
    While intro loop is playing use randy columns on track 3 to alter bass riffs
    While intro loop is playing use randy columns on track 4 to alter percussion
    While intro loop is playing gradullay fade up the volume from -inf to X db on track 5 (whatever that is).
      Code needs to know how to compute the increments to apply to track 5 volume based on loop size and loop count
    When max looping is reached for intro loop, play a mid part.
      Consider this a loop from  i to j of loop count 1 to make this conceptually simpler.
        That is, treat all playing as loop based, even if it is a loop of one pattern that is looped once
    While midpart is playing, use randy columns on a vocal track where the randy part selects a column to play for full patterns
      The idea is that there would be alternate vocal takes; we don't want random jumping amount takes mid-playing

    When the mid part "loop" has reached max loop count, play a bridge loop n(4,6)
      This would behave similar to the intro loop. Some columns have randy columns to liven up the music
    End somehow.   Basically define a final loop rnage, play n times, and call "stop" when max loop is reached.

There needs to be some sort of mini-language syntax that encodes these commands.
We need to indicate things like 
- loop range
- max loop count
- max loop count random range
- randy note params
  These need syntax that indicates what track, values for each column, and when the columns get re- selected (each tick; each patten; each pass of the loop)
- Track fx automation
  Needs to indicate when(in what loop), what track, what fx, what fx param, and how that param changes over time.

We already have syntax for loop composure.  And something gets written to disk for randy notes.



