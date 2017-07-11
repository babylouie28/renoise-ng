# Neurogami Alternator

## Placeholder readme

Basic idea:  Like the SwapChop tool, but only works on a single fx column.

It should save all of the last-used values, and have a way to switch around some values.

Think of it as a more manual version of SwapChop.  Instead of assuming anything about column pairs, Alternator just works on a single column.  To get the same behavior as SwapChop you would re-run ALternator on antoehr column but switch around some values.

SwapChop assumed you wanted to alternate a series of volume values (basically, full, and 00).  The set of values would be "swapped" across the column pairs (when one was at full volum, the other would be 00).

Like SwapChop, Alternator would generate a series of line numbers and use them to apply a series of fx values.  

If you were, for example, alternating 70 and 00 over the lines 0 3 6 9 12 in one column, then you would (perhaps) want to alternate 00 and 70 over those same lines in another column.  SwapChop just assumed this, and assumed it was operating on adjacent note columns.  

### Possible GUI layout 

Mostly the same as SwapChop, with a text area for the set of line numbers, a field for a line-generating function,  and some sort of place for the fx values to alternate.

Likely plan: Use a single text field (as with the generator field).  Use it for space-delimited fx values.

Provide a button to rotate (i.e. shift around) these values.  If there are but two values then this effectively swaps them.

But you can use more than two; not sure how big this field should be.  Might plausibly allow for another kind of value generator so that this field an hold either literal fx commands or some notation to create values.  (A goal here might be to create a series of volume values that go from 00 to some max, over the number of lines to be used. E.g. `> 0 70`  `< 0 70`.  Or something. )

So we get something like this:

`
Values    [_______________________________________________________________] [< rotate] [ rotate > ]

Function  [_______________________________________________________________] [Generate]

Lines  
          |----------------------------------------------------------------|
          |                                                                |
          |                                                                |
          |                                                                |
          -----------------------------------------------------------------
           [Clear]   [Go] 

`

More or less


## Code flow


Like ChopSwap, it needs to see if GUI is already up.

** DONE ** It needs to load any previous values for all of the fields: Values, Function, Lines

** DONE ** It needs to watch for the ESC key to auto-close (and change nothing)


** DONE ** The Rotate buttons need to grab the values content, split on white space, rotate, then apply the updated text.

SwapChop *always* used line 0 (i.e. the first line).  The reasoning was that, given two columns, one of them had to be muted at the start.

Alternator will do the same unless there's a simple enough way to handle making this explicit while not breaking shit.  
(E.g., a line generator of `/ 3` will never have 0, unless you make an assumption about 0, then it will always have 0.)

Plausibly the Lines text should insert 0 and then allow for manually removing it.  This line set would then be saved for the next use.

** DONE ** Line generator functions include 0 in the results.  User has to edit the generated results aftwards before applying.

This means the code that *applies* the lines/values has to *not* assume 0; it needs to stick to the line number list.

** DONE** Tool needs to work on vol column of  note column AND in fx column of a track.

The behavior when applied to tracks is to automate the volume pre-devie chain.  Stuff like echos and revier will continue.

This is (pretty sure) the same as when automating note column volumn.

If you wanted to automate the volume post-fx, can you do that as well?  Seems not.

So, feature request:  If we have a track fx column selected, look to see if the track has a gainer named "ALTERNATOR".

If so, then enter automation values for that device instead of the pre-device chain volume.

Code would need to - iterate over all track devices; get names; if name match, make note if device index; know what volume value to use.

