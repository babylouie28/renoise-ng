# Beat Masher

Designed to handle special OSC messages sent by a [Control](http://charlie-roberts.com/Control/) application.

You should load up  asonf that has assorted percussion instruments for tracks one through five.

Instrument 16 (10 in hex) should be assigned the ["numbers" instrument](https://github.com/Neurogami/renoise-ng/tree/master/intruments).

The Control program is meant to manipulate the song to help generate different kinds of backing beats for use when jamming.

** VERY MUCH IN ALPHA. **




# Usage

Install tool.  Use the "Configure" menu to set the IP address and port values for the Renoise OSC server and for the OSC server to be used by Beat Masher. 

Start the Beat Masher OSC server.  

Use the Control app to stop/start/manipulate the current song.


# OSC Messages

These are the messages that can be sent from the Control app.


    /renoise/transport/start

    /renoise/transport/stop

    /renoise/song/bpm number

    /renoise/trigger/note_on     

    /renoise/song/edit/mode boolean

    /renoise/song/track/<number>/output_delay

    /renoise/song/track/<number>/postfx_volume


    /ng/song/track/clear track_number

    /ng/song/save_version

    /ng/rotate track_num num_lines

    /ng/song/load_by_id id_number [Think about this one]

    /ng/speak/bpm

    /ng/song/reset    [Calls undo a zillion times to try to put the song back to where it started)

    /ng/song/undo   [Calls undo once]

In practice an OSC client can send any Renoise OSC message since these are all passed on to Renoise itself.

The ones shown here are what the Control app will send.



# Author

James Britt / Neurogami - james@neurogami.com

# Licence

MIT License.



