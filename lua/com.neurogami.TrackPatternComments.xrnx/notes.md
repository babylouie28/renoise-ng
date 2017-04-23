# Thu 13 Apr 2017 18:13:08


Code flow

User acivates the menu on the track pattern.

    GUI.show_dialog runs

This builds the text window.  It also calls

     GUI.guid = TPC.find_nearest_commnent_guid()

This is where it gets tricky. Plan A was to avoid using a guid until we know a new comment
is to be created.  But it gets tricky.

Plan B would be to return the nearest guid in the track pattern but grab a new one if 
none are already there.

For Plan B we might want to have a globale table of no-comment guids.  
Some code could go through every fx line looking for guids that are not
matched to comments.  OR: Look at the comments and order the guids.  Any gaps
mean that guid can be reused.  But you still have to clean out the lingering guids.

`find_nearest_commnent_guid` finds and returns the guid closest to the current line, or nil.

GUI code then looks if guid is nil.  If so, then this is to be a new comment.

There's a notifier fired on every edit event.  But if we are guarding against creating
new but empty comments then we do not need this.  Or we use it to keep updating
some var holding he current text, but do not yet act on it.

Another notifier was added to catch when the dialog is closed.

This now calls 

     TPC.update_comments(GUI.guid, GUI.text)

This will return immediately if the guid is nil and text empty.

Otherwise it will grab the next guid if needed.

If this is a new guid  then an fx marker is added on the current line at the next free spot.

It should show a message if there is no room for a new fx marker.

Then the function updates the comments.

It is looking for comment demarcations that look like this:

    ..... Track-pattern comment .... NG40


How does this work?  The previous code made assumptions and tracks and ordering.
We no longer care.  How does the code grab all the comments?

When you add a comment you get this:

    ... Comments Track 2 ...
    ... Foobar ...
    This is a comment for Foobar

    It has a few lines.
    ...


Adding a new comment for `track01`



    ... Comments Track 2 ...
    ... Foobar ...
    This is a comment for Foobar

    It has a few lines.
    ...

    ... Comments Track 1 ...
    ... Track 01 ...
    Comments for the first track, which has no name
    (Well, Track01)
    ...



song().comments is a table of strings.  

How can we pack chunks of text such that we can:

- Never lose the non-TPC text
- Quickly find a guid-keyed chunk
- Replace guid-keyed chunks

Renoise Lua has some extra util functions;


  `
-- Find first match of 'value' in the given table, starting from element
-- number 'start_index'. Returns the first !key! that matches the value or nil
-- > examples: t = {"a", "b"}; table.find(t, "a") -> 1;  
-- >          t = {a=1, b=2}; table.find(t, 2) -> "b"  
-- >          t = {"a", "b", "a"}; table.find(t, "a", 2) -> "3"  
-- >          t = {"a", "b"}; table.find(t, "c") -> nil
table.find(t, value [,start_index]) -> [key or nil]

  `

What the previous code did was create a start marker based on track name or index, and
append a comment end marker (".....") at the end.

Then the code looks for the line that matches the first marker, and uses that location
to find the line number of the end marker.  The lines in-between are are the comments.

This is now in place for the new code.


#------------------------------------------------------------

Having to track pattern edits (moved, deleted, insertions) can be a drag

It seems you can add an fx command that is not tied to reality.

For example, if you recoring the automation of an fx value you get something like

    31 23

where one value indicates the device/parameter and the other the value for that parameter.

But you can manuall enter 

    99 34


even though it maps to no device or parameter.

It's a hack, but it might allow fr storing message IDs in the form fx column entries.

## Adding something to the fx column using Lua

Possible? Yes.

You can iterate over the columns  SORT OF.

      https://github.com/renoise/xrnx/blob/master/Documentation/Renoise.Song.API.lua
      line 764:
      -- Iterate over all note/effect_ columns in the song.
      renoise.song().pattern_iterator:note_columns_in_song(boolean visible_only)
        -> [iterator with pos, column (renoise.NoteColumn object)]
      renoise.song().pattern_iterator:effect_columns_in_song(boolean visible_only)
        -> [iterator with pos, column (renoise.EffectColumn object)]

There's similar stuff for iterating over such columns in a given track. And this:

    Line 816
    renoise.song().pattern_iterator:effect_columns_in_pattern_track(
      pattern_index, track_index, boolean visible_only)
      -> [iterator with pos, column (renoise.EffectColumn object)]

You can also index an effect column by index.


Line 1036 is interesting:

    renoise.song().patterns[].tracks[].lines[].note_columns[].volume_value
      -> [number, 0-127, 255==Empty when column value is <= 0x80 or is 0xFF,
                  i.e. is used to specify volume]
         [number, 0-65535 in the form 0x0000xxyy where
                  xx=effect char 1 and yy=effect char 2,
                  when column value is > 0x80, i.e. is used to specify an effect]
    renoise.song().patterns[].tracks[].lines[].note_columns[].volume_string
      -> [string, '00'-'ZF' or '..']


Can you overload the volumn column to store fx commands?  


This seems more direct (i.e. the fx columns)

    renoise.song().patterns[].tracks[].lines[].note_columns[].effect_number_value
      -> [int, 0-65535 in the form 0x0000xxyy where xx=effect char 1 and yy=effect char 2]
    renoise.song().patterns[].tracks[].lines[].note_columns[].effect_number_string
      -> [string, '00' - 'ZZ']

    renoise.song().patterns[].tracks[].lines[].note_columns[].effect_amount_value 
      -> [int, 0-255]
    renoise.song().patterns[].tracks[].lines[].note_columns[].effect_amount_string
      -> [string, '00' - 'FF']

Can you set these?


    renoise.song().patterns[1].tracks[1].lines[1].note_columns[1].effect_number_string = "ZZ"
    renoise.song().patterns[1].tracks[1].lines[1].note_columns[1].effect_amount_string = "19"

This works!  Oddly, it seems to set "ZZ 19" in the column *just before* the fx column.  

What is this? It's some *other* fx thing. 

** This is the per-note fx column! **

How do you read the whole-line fx columns?

      renoise.song().patterns[1].tracks[1].lines[1].effect_columns[1].number_string = "NG"
      renoise.song().patterns[1].tracks[1].lines[1].effect_columns[1].amount_string = "01"

Seems you can insert fx strings that are not meaningful to Renoise. (e.g. "NG01")

Plausibly then you can insert pattern notes ID numbers.  Notes can then be coupled to track name and fx "ID".

If you move patterns it stays related.  If you delete a pattern then the tool should run through all the patterns to  see what IDs have been elminited.




## Getting the current pattern number 

    song_pos.sequence
      -> [number]


    renoise.song().selected_pattern,

# A Plan

When adding a pattern comment an fx `guid` is inserted as well.
That guid is stored with the comment.  
This would allow multiple comments per pattern.  Maybe not a good idea (added complexity).

But the basic idea: 

Get the current track/pattern.
Find a free fx column on the first line of the pattern:
- Iterate over the fx columns on the first line to find an empty slot.  If none, add one.

** Can you add fx data to invisible columns? **

E.g.

    renoise.song().patterns[1].tracks[1].lines[1].effect_columns[100].number_string = "NG"

That fails, but `effect_columns[5]` works.

Still, it's tricky to just assum column N is available just because it's a large number.

** Seems the max number of fx coluns is 8 **

You can't assume much.  So, the plan might be: 

Go to line 2 or three (on the assumption that the first line of a pattern is liable to have an fx item) and start looking for a free column.

Or: Go to fx column 8 and start looking for the first line with a free slot.  Add the next guid there.

** Should guids be per track? **

Option 1: You store the current guid for each track.
Option 2: You go for global uniqueness.

2 means (techincally) fewer guids, but we should be able to go from 00 to FF  (255)

The global guid allows for moving a commment to another track.


## Sample working code ##

`

local track = 5
local pattern = 2
local line = 1

function find_next_free_fx_column(track, pattern, line) 
  local nothing = -1

 local fx_ns
  for i=1,8 do 
    -- fx_ns 
    fx_ns = renoise.song().patterns[pattern].tracks[track].lines[line].effect_columns[i].number_string 
    -- It seems that if an fx number slot is empty then it has a default string  of "00"
    print("fx_ns: " .. fx_ns)
    
    if (fx_ns == '00' ) then 
      return i
    end
  
  end
  return nothing
end

local free_fx_col = find_next_free_fx_column(track, pattern, line) 



print(free_fx_col)
line = 2
free_fx_col = find_next_free_fx_column(track, pattern, line) 
print(free_fx_col)
`

This looks at a line in a pattern in a track, and returns the first fx column that is empty.

Next we need a function to insert a guid at that free fx column.

`
if (free_fx_col > 0 ) then

      renoise.song().patterns[pattern].tracks[track].lines[line].effect_columns[free_fx_col].number_string = "NG"
end
`

