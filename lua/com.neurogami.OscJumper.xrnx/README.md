# OscJumper 

## Description

OscJumper is an OSC-drive tool for jumping around patterns in a song.

You can learn about OSC (Open Sound Control) [here.](http://osc.justthebestparts.com)

OscJumper understands the following OSC address patterns:


    /ng/loop/schedule ii

and

    /ng//pattern/into ii


If you have the [Rotate Pattern tool](http://www.renoise.com/tools/rotate-pattern) installed then OscJumper will also respond to

    /ng/rotate/track  ii

## The OSC commands

`/ng/loop/schedule` takes two integers, range start and range end.  It uses those values to schedule a loop using that range of a patterns.  The song will finish playing the current pattern then jump to the first pattern of the defined loop, and play from there.

`/ng/pattern/into` also takes two integers, a pattern number and "flag" number. 

When invoked, Renoise will immediately move playback the given pattern number. It maintains the same relative pattern line number so that the song's beat is not disrupted.

For example: Suppose your song has patterns of length 32.  It is currently in pattern 2, at the 10 line of that pattern when  `/ng/pattern/into 4 1` is invoked.  Playback will then move to line 11 of pattern 4.

If the second number is non-negative then Renoise will loop on pattern just jumped to.


`/ng/rotate/track` takes two integers, a track number and the number of lines to rotate.  It uses the code in the Rotate Pattern tool, which you must manually install if you want this to work.  

Rotation will be forward or backwards based on whether the lines number is positive or negative.  If you pass a negative track number then rotation occurs on whatever is the current track.


## Usage

Once installed, the tool will add a new item to the Tools menu,  for "Neurogami OscJumper." This in turn provide two submenu items.  "Configuration" will show a small dialog box where you can set the IP address and port numbers for the tool and for the internal Renoise OSC server.

The Renoise OSC port match whatever Renoise is using (typically port 8000). The OscJumper port number needs to be another port number (e.g 8001).

OscJumper needs to know the Renoise port number because OscJumper will pass through any OSC messages it does not know how to handle.  This allows you to send the default Renoise OSC message to the OscJumper OSC server.

Once configured you use the other submenu item, "Start the OSC server" to start the OscJumper OSC server.  


## Author

OscJumper was written by James Britt / Neurogami.

Source code can be found [here](https://github.com/Neurogami/renoise-ng/tree/master/lua/com.neurogami.OscJumper.xrnx).

Send questions and comments to james@neurogami.com


