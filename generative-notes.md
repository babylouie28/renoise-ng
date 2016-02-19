** Thu Feb 18 13:33:17 MST 2016 **


There are problems detecting special events and states.

What the code seems to want to do is track when it is time to set the range for the next loop.

This needs to happen when the current loop has these conditions:

- has reached loop-count == `max_loops`
- is in the last pattern of the loop

When this is true then the code will tell Renoise to set new end points.  

The tricky part is then the loop index needs to increment a well.  

But the above conditions can hold true for several ticks of the clock; we do not want to keep incrementing the loop index.

So there are other conditions to track

- We have not already incremented the loop index to the loop-range after the one we are finishing

Empirically, the loop processing callback seems to get called once per line. Is this a coincidence?

The code has this:  `Generative.timer_interval = 100`

What happens if we set it lower?  You get more log entries, and multiple evaluation for the same line.

So: We can set loop points to the next loop range at any time that we are in the last pattern of the last pass of repeated loops.

We cannot update the loop counter until ... what?

There is function `Generative.set_next_loop()` that gets called when 

      if (Generative.current_pattern == Generative.current_range_end() ) then       
         if  Generative.current_loop_count >= max_loops
And `Generative.current_loop_count` gets incremented when `Generative.did_we_loop() ` returns true.

`Generative.did_we_loop() ` returns true when

     not Generative.current_pattern < Generative.current_range_end() 
      Generative.current_line = renoise.song().transport.playback_pos.line  
     if Generative.current_line < Generative.last_line then
        true

So if we are in the last pattern, and the current playback position is less than the last line?

** This makes no sense. **

How is this ever true? And yet it seems to work well enough for Loop Composer

It seems to work by coincidence, that loops end points are always higher than they were.

But if set a mid-song loop before and early pattern loop the looping still works correctly ....

In fact, it seems to happen right on the money, after the last loop pass and the jump to another pattern.

Why? :)

It doesn't help that Lua uses 1-based indexing but Renoise has shit starting at 0.

Would it help to somehow normalize everything? The thing is, if you look at a song you see pattern 0.




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


** Code/behavior organization **

Assume that the loop is the main item, sort of an object (in OOP terms).

So one approach to scripting is that the lines define loop objects and their behavior.

If we were doing this is real code we might want to define a loop in terms of the pattern range, and then set some properties

For example (Rubyish)

   intro = Loop.new 1, 4, [2..4], :end

This set the start and end patterns, a range for randomly selecting how many times to loop, and what loop to jump to when done.

But we also want track randy-column behavior.

So we could write

       L: intro,1,4,[2..4],vox
       L: vox,5,6,[1],bridge
       L: bridge,7,10,[1],outro
       L: outro, 11, 14,[2..5],end

Which defines four loops, with names, number of repetitions, and where to go next.


Then assign track behavior to loops.

     T: 3, intro, {stuf about randy notes}

This says that when loop "intro" is active then apply this behavior to track 3.

Basically we could treat these as tables of values, no?

** WHY NOT JUST START BY COPYING LOOP COMPOSER BUT READ SCRIPT FROM COMMENTS? **



Then you have at least something to play with.

** Sun Feb 14 19:49:42 MST 2016 **

Did that, it works, so there's a version that will execute the stolen LoopComposer code reading the script from the comments.

The next step is to define a way to add script commnds that indicate that other things are to happen while a given loop is looping.

Scripts righjt now do not indicate that they refer to loops.  That was assumed (since that was all it could do).

Possible steps:


- Name loops, store the name, trigger certain actions based on current loop and loop count.
- Create default loop names based on the range.  This removes the option to have the same 
  loop points but different behavior at different times.
- Something else

There is nothing to indicate the next loop to play;there is no `jump` command.

LC was designed to allow executing custom functions. Does this help?

Right now, loops are store in order.  When a loop is ending the code grabs the next loop def and sets it up so that Renoise jumps to that new loop.  So we could add add more data to that table of loop defs aside from the end points.

We need to know what the current loop table holds, and what the code does to extract info.

- We could use indentation to indicate that lines are meant to be treated as loop events
- we could append all such loop event commands to the end of each line

The latter idea might be easier since code right now seems to work line by line.

Step one: See where the code extracts line data, and how we can add extra commands to store with each loop entry.

It might be nice to have cusotm code for things like: randy columns, fx param shifting, muting columns.

This way we would have simpler loop script commands.

For example, a `randy` function would take a track name or index, and whatever args would ordinalrly be used in Randy Note Columns.

The code would need to know when a loop is first entered, or when a loop has just exited, so that it can turn this on or off.

Suppose we want to adjust the value of an fx? Fade in a track.  Assume we have a function `param_adjust` :

      param_adjust track_num, fx_index, param_index, start_value, end_value

How would this know what to do?  How can the code know when it has just entered a loop?

        renoise.song().transport.loop_pattern, _observable   -> [boolean]

What does this do? 

       https://github.com/mrVanDalo/stepp0r/blob/master/src/Layer/PlaybackPositionObserver.lua

Not actually what we want but might be useful.


Assume that we are going to use the current code, `Generative.did_we_loop()` and when that reports true we invoke some other code.

Or we need to track playback postion, pattern size, and loop count, and then adjust some value based on that.

We would need to know how to calcuate some percentage.  Some way of knowing a "max value" from zero .

If we are calling a function associated with a loop we might store these functions in a "current loop functions" table, and on each "tick" call all the functions.  And the functions magically know how to do stuff based on current values, such as where we are in the loop count, max number of times to loop, current line, pattern size.

If we wanted to move an fx param from 0.0 to 1.0 (or the reverse) over the duration of the total looping event we would need to know where we are in that loop set.

We know:


    Current line in current pattern
        renoise.song().transport.playback_pos.line  -- This is relative to the current pattern

    Current pattern
       renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]


    Generative.current_loop_count      
   

    Generative.current_range_start()
    Generative.current_range_end() 
    renoise.song().patterns[].number_of_lines
    max_loops = Generative.loop_list[Generative.current_loop][3]

In the timer function we can then look at 
- the current loop count
- the max loops
- the number of patterns in the loop
- number of lines in the each pattern

We assume that all patterns in the current loop have the same number of lines.

`complete_loop` means loop-range times max times to loop

If we have a three-pattern loop that is to loop 2 times we can do:

     current_pattern = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]
     lines_per_pattern = renoise.song().patterns[current_pattern].number_of_lines
     number_of_patterns = Generative.current_range_end() - Generative.current_range_start() 
     total_lines_in_complete_loop = number_of_patterns * max_loops

Then, we want to know where we are withing this range of `total_lines_in_complete_loop` so we can calculate a percentage


** ISSUE **

Current code was not concerned so much about the current status but with setting up loop points as needed.
So the timer code would check to see if the song was in the last pattern of the final pass of a loop, and if so
it would update loop point values.  This borks attempts to compare the actual current pattern and line against
the so-called "current" loop end points.

We need a way to track the in-fact actual current loop number (i.e. based on the lines of the script) so we can always know  the proepr values for the current loop points.  UNLESS WE CAN GET THESE FROM RENOISE!?


At any given moment in the timer function there are two possibilities:

- The loop points define the loop we are in
- The loop points define the loop we are soon to move to

The issue is, how do we know the end-points of the loop were are still in?

When the code detects that a) we are in the `max_loops` loop, and b) we are in the last pattern of that loop, it updates the loop points.

We need a one-time trigger event flag thing that marks "we have in fact now moved to a new loop".

How might that work?  

    http://files.renoise.com/xrnx/documentation/Renoise.Document.API.lua.html

Still can't get an observable to trigger on loop event.

Suppose we had a flag, `loop_redefined` that gets set to true when 

      Generative.current_pattern == Generative.current_range_end() 

and

          Generative.did_we_loop()


We find this on 125 of `Core.lua`. 

     Generative.loop_redefined = true

But if we have just entered a loop then we want to set that back to false
