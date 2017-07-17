# Neurogami Alternator


The tool takes the values in the "Values" text field and inserts them as alternating volume fx values in the selected note column or track fx column.

The values are placed on the track pattern lines listed in the "Apply to lines" box.

You can hand-edit that list of line numbers, or use a special syntax to generate a sequence.

You must click the "Go" button to apply the values.

The "Values" field has two buttons (`<<` and `>>`) that rotates the values.

The tool saves the last used values.

The intended use was to alternate mute (`00`) and normal volume (e.g. `C0`).

Applied to two columns/tracks but with the values swapped you get a nice chopped sound.

Track fx column values are applied to the pre-device chain volume.

If the track has a Gainer device named `ALTERNATOR` then track fx values are applied to that gainer.  

In that case, the given value `0C` is replaced with `3F` (because of the differences in how `0db` is represented).

## Line number generation syntax


`+ i j k` means line numbers increment by i, then j, then k, then i, then j, etc.


For example: 

`+ 3 5` would give you `0 3 8 11 16 19 24 ...` up to the number to lines in the current pattern.

 `+ 3 2 5` would give you `0 3 5 10 13 15 20 23 25  ...` up to the number to lines in the current pattern.


`/ i j k` gives you all the lines evenly divisible by any of i, j, k, etc.

For example: 

`/ 3 5` would give you `0 3 5 6 9 10 12 15 18 20 21 ...` up to the number to lines in the current pattern.

`/ 6` would give you `0 6 12 18 24 30 ...` up to the number to lines in the current pattern.


**NOTE** `0` is _always_ included in the results of any line-generation function.


You should be able to use any number of integers with either of those commands.  (Well, so long as they fit in the text field.)

** You should not include an commas in your line-generating function. **

Each time you run a line-generation function the generated numbers are *added* to the current list. 

This allows you to construct a more complex sequence my combining different line-generation functions.

There is a `clear` button to clear the current list; you can also hand-edit that list to fine-tune the values.

You must click the `Go` button in order to apply the results.

## Stuff

The last-applied values are saved and reloaded the next time the tool is used.

This makes it easier to apply the same values to multiple tracks or note columns.

This tool was derived from [ChopSwap.](http://www.renoise.com/tools/neurogami-swapchop)

The goal was to make it easy to automate the swapping of mute and not-mute between two adjacent note columns or tracks.

It works, and is easy to use, but doesn't play nice when you want to swap volume on tracks or note columns that are not adjacent (or simply apply it to both a track and a note column).

`Alternator` avoids this by only acting on a single target. It looks to see if you have selected a note column or a track fx column and applies the appropriate automation command.

This is the reason for saving the last-used settings, and for having a way to "rotate" the volume values applied.

You can run `Alternator` on one track, go to another track, and rotate the fx values before applying the tool again.  This effectively mimics the behavior of `ChopSwap` (albeit with more steps).

Unlike `ChopSwap` you are not limited to two volume values, and you are not required to work with two adjacent tracks or columns.

## Special gainer behavior

When operating on a track, the fx value entered operates on the pre-device chain volume (the one all the way over on the left).

This means that any devices on that track may still be generating sounds after the root volume is set to `-INF`.

For example, reverb and delay.

If, however, the track has a gainer device renamed to `ALTERNATOR` then the fx automation is applied to that gainer.  

This allows you to automate the track device anyplace along your device chain.


## Watch for ...

Since the tool is inserting volume automation values you need to be mindful of whatever was the last value added to a track pattern.  

You will likely have to manually add an fx entry to reset the volume of a track.

This same caveat applies if you are using the special `ALTERNATOR` gainer device.
