# Master Muter 

## Description

Tool to allow muting/unmuting of the master track via OSC.



## Usage

Once installed, the tool will add a new item to the Tools menu, for "Neurogami MisterMaster." 

This in turn provide two submenu items.  "Configuration" will show a small dialog box where you can set the IP address and port numbers for the tool and for the internal Renoise OSC server.

The Renoise OSC port should match whatever Renoise is using (typically port 8000). The Master Muter port number needs to be another port number (e.g 8001).

Master Muter needs to know the Renoise port number because Master Muter will pass through any OSC messages it does not know how to handle.  This allows you to send the default Renoise OSC message to the Master Muter OSC server.

Once configured you use the other submenu item, "Start Master Muter" to start the Master Muter OSC server as well as add a custom gainer device to the master track.

That master gainer is set to `-INF` (complete silence) and deactivated.

The tool listens for custom OSC messages on its own port.  It responds to these messages:


`/ng/master/mute`  will active the custom master gainer, muting the master track.



`/ng/master/unmute` will deactivate the custom master gainer, unmuting the master track.


`/ng/master/set_mute i` will set the "active" property of the custom master gain based on the value sent. 1 activates; anything else  deactivates.


Nothing should happen unless you start the tool, so it should not be adding this custom gainer to songs unless you tell it to.


## Author

Master Muter was written by James Britt / Neurogami.

Source code can be found [here](https://github.com/Neurogami/renoise-ng/tree/master/lua/com.neurogami.MisterMaster.xrnx).

Send questions and comments to james@neurogami.com

## Licence

MIT License.


Feed your head

Hack your world

Live curious



