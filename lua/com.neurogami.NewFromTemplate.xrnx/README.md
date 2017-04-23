# New from Template


## Description

Allows you to use a folder of songs as templates for new songs.  The tool will show a list of those songs.

You pick one, and provide the name for the new song file. 

The selected template song then gets copied over as a new song and loaded into Renoise.

## Usage

Once installed the tool should add a "Neurogami New from Template" item to the Files menu.  

This will have two sub-menus: Configuration, and New from Template.

You must configure the tool before using it to create files.

The Configuration menu allows you to set the directory that holds your template songs, and the directory where new  song files should go.

Template songs are just Renoise songs.  The tool works by making a copy of the selected template song and saving under a new name in the configured destination folder.

The name for the new file does not need to have the `.xrns` extension; the tool automatically adds it. 

Once the new song is successfully created Renoise opens it.


## Author

New from Template was written by James Britt / Neurogami.

Source code can be found [here](https://github.com/Neurogami/renoise-ng/tree/master/lua/com.neurogami.NewFromTemplate.xrnx).

Send questions and comments to james@neurogami.com


