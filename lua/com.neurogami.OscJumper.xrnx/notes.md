# OSC Jumper #


### Some assumptions ###

The song is something designed for use with OSC Jumper.  That means there are "mirror" or alt tracks; not a real "song" structure; sectiions meant to be looped.



### Some actions that would be handy ###

Quickly soloing some set of tracks, then restoring the previous volume settings.  For example, you wan to just hear kick and a bass line, then jump back to whatever was playing.

Preparing pattern loops using a starting pattern row and number of patterns.  Then when the current pattern ends it jumps to the start of the defined loop.

Jump to the start of a pattern, giving a scratching effect.

Jump back N lines.


## Keeping it simple ##

The client (i.e. Leap or Kinect or whatever) needs a way to associate certain actions with pre-set messages.

IOW, you can't be specifiy the two tracks to swap with hand movements; there needs to be some action that is already defined to do `/ng/pattern/swap 4 5 10`.

This could be based off some controllable aspect of the gesture; finger count or Y or Y.

We could map X (lef/right) to some set of paired tracks, with the client UI changing color to indicate what pair would be affected.

If we kept that number small (4?) but used a decent range (two feet?) then you could move to a track-pair quickly without having to be super precise.  Then, if a track-pair were active, use a clear gesture (circle? ) to do the volume swap.

The two most useful actions are track swapping and pattern jumping/looping.


THe current loop call always loop on a single pattern.  Is there a way to a) change this value when setting up the jump, and b) use  a gesture or something to alter the number of patterns to be used for the loop?

Maybe a circle gesture that alters a visible number? Or height, with higher upping that number?


