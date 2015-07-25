# Mister Master 

## Description

Tool to allow manipulating the master track primarily towards making mixing your song easier.

When run it looks to add tow devices to the master track.  A gainer, and a stereo expander.

The gainer is set to `-INF` db - silence.  Then disabled.

The stereo expander is set to `L+R` mono and disabled.

A separate OSC server is then started.  You can then use custom OSC messages to toggle mute/unmute and stereo/mono

This is meant to be part of a larger set of tools (not part of Mister Master) intended to  simplify switching between your Renoise song and one or another reference track.

The program managing the reference tracks would need some means of muting/unmuting tracks and switching between mono and stereo.

Another tool is being developed separately to manage this via a second instance of Renoise, all managed by a Launchpad controller.


## Usage

Once installed, the tool will add a new item to the Tools menu, for "Neurogami MisterMaster." 

This in turn provide two submenu items.  "Configuration" will show a small dialog box where you can set the IP address and port numbers for the tool and for the internal Renoise OSC server.

The Renoise OSC port should match whatever Renoise is using (typically port 8000). The Mister Master port number needs to be another port number (e.g 8001).

Mister Master needs to know the Renoise port number because Mister Master will pass through any OSC messages it does not know how to handle.  This allows you to send the default Renoise OSC message to the Mister Master OSC server.

Once configured you use the other submenu item, "Start Mister Master" to start the Mister Master OSC server as well as add a custom gainer device to the master track.

That master gainer is set to `-INF` (complete silence) and deactivated.

The tool listens for custom OSC messages on its own port.  It responds to these messages:


`/ng/master/mute`  will active the custom master gainer, muting the master track.

`/ng/master/unmute` will deactivate the custom master gainer, unmuting the master track.

`/ng/master/set_mute i` will set the "active" property of the custom master gain based on the value sent. 1 activates; anything else  deactivates.

`/master/mono` will activate the custom stereo expander, set the master track to mono.

`/master/stereo` will deactivate the custom stereo expander, set the master track to stereo (or whatever it would otherwise be).

`/master/set_stereo i`  allows you to toggle the active state of the stereo expander. Passing `0` will enable the custom stereo expander. Anything else will disable the expander.

`/master/set_mono i`  allows you to toggle the active state of the stereo expander. Passing `1` will enable the custom stereo expander. Anything else will disable the expander.



Nothing should happen unless you start the tool, so it should not be adding this custom gainer to songs unless you tell it to.


## Author

Mister Master was written by James Britt / Neurogami.

Source code can be found [here](https://github.com/Neurogami/renoise-ng/tree/master/lua/com.neurogami.MisterMaster.xrnx).

Send questions and comments to james@neurogami.com

## Licence

MIT License.


Feed your head

Hack your world

Live curious



