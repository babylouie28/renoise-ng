# OSC Jumper 

## Description

OSC Jumper is an OSC-drive tool for jumping around patterns in a song.

You can learn about OSC (Open Sound Control) [here.](http://osc.justthebestparts.com)


## The OSC commands


    /ng/loop/schedule

     Marks a pattern loop range and  then sets the start of the loop as the next pattern to play.

    Args: range_start, range_end 

    /ng/pattern/into

     Instantly jumps from the current pattern/line to given pattern and relative next line.

    If the second arg  (stick_to) is greater than -1 it schedules that as the next pattern to play, and turns on

    block loop for that pattern.

    Args: pattern_index,  stick_to 

    /ng/sequence_pos

     Supposedly sends back to the OSC the current sequence position, but does not seem to be implemented.

    Args: none 

    /ng/rotate/track

     Rotates the lines in the current pattern of the selected track.

    Args: track_index, num_lines. 

    /ng/randy/clear_track_note_timer

     Clears note-column soloing timer for the given track.

    Args: track_index 

    /ng/randy/add_track_note_timer

     Creates a note-column soloing timer.

    Args: track_index, timer_interval, trigger_percentage, solo_stop_percentage, solo_odds (...) 

    /ng/randy/solo_note_column

     Selects the given track and mutes all but the given note column.

    Args: track_index, note_column.


## Usage

Once installed, the tool will add a new item to the Tools menu,  for "Neurogami OSC Jumper." This in turn provide two submenu items.  "Configuration" will show a small dialog box where you can set the IP address and port numbers for the tool and for the internal Renoise OSC server.

The Renoise OSC port match whatever Renoise is using (typically port 8000). The OSC Jumper port number needs to be another port number (e.g 8001).

OSC Jumper needs to know the Renoise port number because OSC Jumper will pass through any OSC messages it does not know how to handle.  This allows you to send the default Renoise OSC message to the OSC Jumper OSC server.

Once configured you use the other submenu item, "Start the OSC server" to start the OSC Jumper OSC server.  


## Author

OSC Jumper was written by James Britt / Neurogami.

Source code can be found [here](https://github.com/Neurogami/renoise-ng/tree/master/lua/com.neurogami.OscJumper.xrnx).

Send questions and comments to james@neurogami.com

## Licence

MIT License.


Feed your head

Hack your world

Live curious


