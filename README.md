# Renoise NG #

Assorted scripts and such for use with the [Renoise](http://renoise.com) DAW/tracker.

Likely candidates for inclusion here:

* Modified `GlobalOscActions.lua`
* Screens for use by the [Control](https://github.com/charlieroberts/Control) OSC/MIDI app
* Renoise tools or scripts or maybe custom instruments


## OscJumper

This is a Renoise tool.  

It runs its own OSC server with custom OSC handlers.

When you install the tool you will have a new Tools menu  item, "Neurogami OSC Jumper".

This item gives you two options. One is to set the OSC ports to be used (though there may be a bug in that you cannot use this to change the Renoise OSC server port; that may get removed), the other is to start the OSC Jumper OSC server.

Once this second OSC server is running you can send it a small number of OSC messages:

    /ng/pattern/into i i

    /ng/song/swap_volume i i

    /ng/loop/schedule i i 

The first message will move the current playback location to the pattern specified by the first integer.

Playback continues from the next relative line number.  For example, if the song is currently in patter 3, line 6, and you send the message `/ng/pattern/into 8 6` then playback jumps to patter 8 and picks up on line 7.

The second integer you send indicate then next pattern to schedule.  In that example, after pattern 8 has played playback will pick up at pattern 6.  If you pass a negative number than playback loops on the current pattern (in this example, pattern 8).

The second message is for swapping the volume levels of two tracks.  Suppose you have tracks 1 and 2, each  with a different, but compatible, funky bass line.   You would start your song with the volume on one of those tracks set to 0.  

Sending the message `/ng/song/swap_volume 1 2` would then swap volume levels of tracks 1 and 2.  The idea is to allow popping in some variations while playing patterns.  It's sort of like a fader switch except there's no fading, just switching.

The last message schedules a pattern loop range.     



## Raw MIDI

Another Renoise tool,  very simple.  It gives you a single text field so you can enter numeric MIDI note values.

This was driven by work done [using Renoise to send MIDI commands to a Processing sketch.](http://www.instructables.com/id/Scripting-Processing-with-MIDI/)

There was a need to enter specific note values.  Default Renoise note editing only lets you hand-enter notes of the form "C-4" (text-value format).  If you want to specifically enter a MIDI value of, say, 104 from the keyboard you need to know the octave to use, shift to that octave,  and then know what text-note to enter.  Doable but tedious.  


## Numbers

A Renoise instrument.  It's a set of spoken (in English) numbers.  This grew out of a specific need.  Some  [Control](https://github.com/charlieroberts/Control) + Renoise scripts were set up so that some backing tracks could be started, stopped, and modifier via OSC sent from a phone.  The idea was to have some decent backing tracks for recording jams and improvs.  

The scripting allowed for changing the BPM.  A goal was to just jam along for a while, record the results, then extract any usable riffs as samples.  The problem was in know the BPM at the time something was recorded.  The solution was to create an instrument of spoken numbers, and add an OSC handler that would "speak" the current BPM.  This would then end up on the recording. Problem solved.
