The idea is to have  a set of OSC commands that will address a Renoise being mixed and another program (either another Renoise instance or Reaper or something) that can have volume muted/toggled.


One approach is to add a gainer to the Master track, set it to -INF, and uncheck it.
Then use OSC to enable it, thus muting the entire song.

Another approach might be to add a blank track to the start of the song, and use OSC to solo/unsolo it.

They both work.  Need to be sure that the solo-track trick does not allow sonic residue from other tracks.

It is, however, a much simpler approach (unless you have some existing stuff that is coupled to track numbers).

The next trick is to have a corresponding message sent to the other audio source.

If it is Renoise then it needs to be on another port.

Is there a way to set OSC port via tool? You can then use the at-runtime-config whatever loader thing.

Assume that the port change is magically handled.  Assume that the target song uses the default 8000 and the reference program uses 9000.


# Cool hack idea 

Can we use a MIDI device, such as the Launchpad, so send OSC by grabbing its MIDI and converting it?

Then the LP can be used to toggle audio among songs.


So: proxy app reads a config file that maps MIDI messages to sets of OSC messages.

Assuming the LP, then the buttons in the first grid row solo a given reference track.  

Assuming Renoise, then the columns might map to locations in a song.  

Having a way to jump around in a reference track would be nice, maybe even with some kind of looping.


** Thu Jul 23 11:14:15 MST 2015 **

Consider that you are unlikely to listen to an entire reference track. 

You really want to compare a section of a song for the sonic effects.

It might make more sense for each ref track to be a sequence of song excerpts.

You could then put more than one song on a track.

The Launchpad then is use to select a section to loop.  If you hit one grid button it just loops over that pattern.

Press two buttons and we use the "multi message" thing to define the loop range.

We might also use the scene buttons (or the top buttons) to toggle mono and stereo.

Maybe add that to the Master Muter code so that it adds a stero thing, sets it to mono, then deactivates.

Then when listening you can quickly toggle mono/steroe from the LP.


# Stuff to look at

    http://forum.renoise.com/index.php/topic/37420-please-fix-solo-functionality-on-the-send-tracks/

Seems you can have Renoise force "solo means only one thing is on at a time"


    http://forum.renoise.com/index.php/topic/28750-mute-all-tracks-short-cut/

There's some discussion there on muting master, and the idea of toggling a gainer set to -INF.



