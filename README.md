# Renoise NG #

Assorted scripts and such for use with the [Renoise](http://renoise.com) DAW/tracker.

Likely candidates for inclusion here:

* Modified `GlobalOscActions.lua`
* Screens for use by the [Control](https://github.com/charlieroberts/Control) OSC/MIDI app
* Renoise tools or scripts or maybe custom instruments


## Renoise tools

Please look in the `lua/` folder for the different tools; each of these should have a `README.md` file describing what it does.

Most of these tools were first written for Renoise 2.8.  Most of those also happen to work with 3.1.0.  Some, though, required code changes that made them incompatible with 2.8.  There will be no effort to maintain two versions of any tool.  All tools should work with the latest version of Renoise.  If they work with earlier versions that's a bonus.


## Numbers

A Renoise instrument.  It's a set of spoken (in English) numbers.  This grew out of a specific need.  Some  [Control](https://github.com/charlieroberts/Control) + Renoise scripts were set up so that some backing tracks could be started, stopped, and modifier via OSC sent from a phone.  The idea was to have some decent backing tracks for recording jams and improvs.  

The scripting allowed for changing the BPM.  A goal was to just jam along for a while, record the results, then extract any usable riffs as samples.  The problem was in know the BPM at the time something was recorded.  The solution was to create an instrument of spoken numbers, and add an OSC handler that would "speak" the current BPM.  This would then end up on the recording. Problem solved.
