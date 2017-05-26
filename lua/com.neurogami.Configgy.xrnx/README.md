# Configgy 


## Description

Renoise tool to load and execute specific Lua files based on the name of a loaded song.

## Usage

`Configgy` is triggered by the "song loaded" event of Renoise.  

It will look at the song comments for a name.

If there is no song name then nothing else happens.

If there is a song name then the tool looks for a special user-create folder named `UserConfig` that you must create by hand in the `Scripts` directory of you Renoise installation.  For example:


`~/.renoise/V3.0.1/Scripts/UserConfig`


Now the magic happens.  The tool looks in that directory for a Lua file that matches the song name. That Lua file needs to be the same as the song name but with spaces replaces replaced by underscores.

For example, if the song is named "Demo Tool Song" in the song comments then the matching Lua file needs to be named `Demo_Tool_Song.lua`.

If such a matching file is found the tool will create a new menu item under the "Tools" menu, "Neurogami Configgy".

If you click on that new menu item it will load that matching Lua file and attempt to invoke a function named `configurate`.

You must define this function on that matching Lua file.  What that function does is entirely up to you.

### Some history

This tool came about because Renoise was being used to send MIDI messages to an external application to trigger beat-matching visuals.

This required associating different instruments with different MIDI devices. When using such a song on just one machine it was fine to save these settings with the song.  However, work was being done on multiple machines, and each had different names for their MIDI devices.  This meant then each time the song was opened on a different machine all the MIDI associating had to be re-done by hand.

This became quite tedious.

Such instrument/MIDI settings can be done in Lua code using the Renoise song API.  Since each machine has its own Scripts folder a special code file could be placed on each machine to handle the MIDI configuration.  `Configgy` was created to manage the loading and executing of such a per-song, per-machine code file.


## Author

Configgy  was written by James Britt / Neurogami.

Source code can be found [here](https://github.com/Neurogami/renoise-ng/tree/master/lua/com.neurogami.Configgy.xrnx).

Send questions and comments to james@neurogami.com


## Licence

MIT License.


Feed your head

Hack your world

Live curious


