--[[
TODO: Think about splitting this into files, each for handling note columns, tracks, and groups.

--]]
--=======================================================================
function print_pairs(t)
  for k,v in pairs(t) do
    print(k, " => ", v)
  end
end

--=======================================================================
-- Takes a list of ints, the number of lines in the pattern, 
-- and the current list of line numbers.
-- The new numbers are created by incrementing from 0
-- and adding each of the `inc_list` values.
--  E.g. 3,2 => 3,5,8,10,13
--  E.g. 3,2,5 => 3,5,10,13,15,20
--
-- The function makes no effort to check for negative increment values 
-- Returns that current list with the generated line numbers inserted, without duplicates
-- That list is unsorted.  
--=======================================================================
function sequence_from_inc_set(inc_list, lines_in_pattern, current_set)
  local inc = 0
  print("sequence_from_inc_set is  using current set:")
  print_pairs(current_set)

  for i=1,lines_in_pattern do 
    inc = inc + inc_list[1]
    if (inc > lines_in_pattern) then
      break
    end

    current_set[inc] = inc
    inc_list = U.wrap(inc_list, 1)
  end

  return current_set
end


--=======================================================================
-- Takes a list of ints, the number of lines in the pattern, 
-- and the current list of line numbers
-- The new numbers are base on whether any LINE_NUM % MOD_INT == 0
--  E.g 3,5 gives 3,5,6,9,10,12,15,18,20, ...
-- Returns that current list with the generated line numbers inserted, 
--    without duplicates
-- That list is unsorted.  
--=======================================================================
function sequence_from_mod_set(mod_list, lines_in_pattern, current_num_set)

  print("We have been passed current_num_set : ")
  print_pairs(current_num_set)

  for i=1,lines_in_pattern do 
    for k,v in pairs(mod_list) do
      if not (i <  v) then
        if ( (i%v == 0 )  ) then
          current_num_set[i] = i
        end
      end

    end
  end


  return current_num_set
end

--=======================================================================
Core = {}

Core.we_are_in_note_column  = false
Core.we_are_in_track        = false
Core.we_are_in_group        = false
Core.current_track          = nil




function clear_note_column_volumns(_col1, _col2) 

  local _ti = renoise.song().selected_track_index
  local _pi   = renoise.song().selected_pattern_index
  local _tp   = renoise.song().patterns[_pi].tracks[_ti]
  local lines_in_pattern = renoise.song().patterns[_pi].number_of_lines


  for i=1,lines_in_pattern do   
    _tp.lines[i].note_columns[_col1].volume_string = ''  
    _tp.lines[i].note_columns[_col2].volume_string = ''  
  end

end
--[[ *******************************************************************
Loop over each line in the applicable note columns.

Clear all volume settings.

Original plan was to keep vol if there was a note on that line,
but that now feels like it applies more to edge cases.
******************************************************************* --]] 
function clear_existing_note_volumes()

  local _ti = renoise.song().selected_track_index
  local _pi   = renoise.song().selected_pattern_index

  -- New for tracks/groups
  --  If this is nil we need to determine if we are in a track
  --  or a group, and behave accordingly
  local col1 = renoise.song().selected_note_column_index

  print("TRY working with note column 1 ", col1)

  if (not (col1 == nil ) ) then
    print("Working with note column 1 ", col1)
    local _co12 = renoise.song().selected_note_column_index + 1
    clear_note_column_volumns(col1, _co12)

  else
    print("We are not in a note column.  Where are we?")
  end

end -- func


-- ======================================================================
-- Assumes current selected note column and column to the right
-- FIXME Need error prevention: 
--  look for 
--    empty or nil values.
--    Out-of-range line numbers  (else it errors out)
--    Out of range volume values
--
--  NEW: Test that we are in a note column.  If not, decide how to proceed.
-- ======================================================================
function volume_swap_note_columns(max_vol1, max_vol2, lines_list)
  print("volume_swap_note_columns. lines_list:")
  rprint(lines_list)

  clear_existing_note_volumes()

  local _ti = renoise.song().selected_track_index
  local _pi   = renoise.song().selected_pattern_index
  local _co11 = renoise.song().selected_note_column_index
  local _co12 = renoise.song().selected_note_column_index + 1
  local _tp   = renoise.song().patterns[_pi].tracks[_ti]
  local _col1_active = false
  local lines_in_pattern = renoise.song().patterns[_pi].number_of_lines


  _tp.lines[1].note_columns[_co11].volume_string = max_vol1  
  _tp.lines[1].note_columns[_co12].volume_string = '00'

  local v = 0
  for i,l in ipairs(lines_list) do
    v = l + 1
    print(tostring(v))
    if ( v <= lines_in_pattern ) then
      if (_col1_active == true ) then
        _tp.lines[v].note_columns[_co11].volume_string = max_vol1  
        _tp.lines[v].note_columns[_co12].volume_string = '00'
      else
        _tp.lines[v].note_columns[_co11].volume_string = '00'  
        _tp.lines[v].note_columns[_co12].volume_string = max_vol2 
      end

      _col1_active =  not _col1_active 
    end
  end

end


--[[=====================================================================
Note: This will alter the pre-device chain volume, and that will remain
until something (i.e. another track volume fx) sets it back.

Some possible ideas:

Look to see if the track has a special Gain device 
named "SWAP_VOLUME_GAIN".  If so, then toggle that on/off in place
of setting any fx value.  

This allows you to:
  - Activate volume changes at any point in the track device chain
  - Keep the current track volume settings from being dicked around

There's an important difference in volumes. In a note column you
likely want a true maximum volume ("70" or something close)

For a track, since the x alters the initial pre-device volume, you
will want "C0".  

If you are pre-populating the volume fields with "70" then something
needs to account for this when swapping track volumes.

Options:

- Assume the vol values are really meant to be on a range of 0 to 100 %
  Maybe make that clear and assume a *percent* value is meant.
  Then scale note columns from 0 to 100, but tracks from -inf to 0

- When launching the GUI, see where we are (`set_location`) and pre-populate
  the volume values based on that.  So if in a track, the text fields get 'C0'


======================================================================--]]
function clear_volume_fx_in_track_line(track_index, pattern_index, line_index) 
  
  local max_fx_cols = renoise.song().tracks[track_index].max_effect_columns
  local fx_ns

  for i=1,max_fx_cols  do 
    fx_ns = renoise.song().patterns[pattern].tracks[track].lines[line_index].effect_columns[i].number_string 
    if (fx_ns == 'NG' ) then 
      return renoise.song().patterns[pattern].tracks[track].lines[line_index].effect_columns[i].amount_value
    end
  end
  return nil
end




--=======================================================================
function clear_existing_track_patern_volumes(track_index, pattern_index)
  local lines_in_pattern =  renoise.song().patterns[pattern_index].number_of_lines
  local track_pattern = renoise.song().patterns[pattern_index].tracks[track_index]


  for i=1,lines_in_pattern do   
    clear_volume_fx_in_track_line(track_index, pattern_index, i) 
    --for fi=1,max_fx_cols do
      -- clear_track_pattern_volume_fx(tp, i)
      --  tp.lines[i].note_columns[_col1].volume_string = ''  
      -- tp.lines[i].note_columns[_col2].volume_string = ''  
    -- end
  end

end


--=======================================================================
function clear_existing_group_volumes()
  -- need the current selected group track, and group track to the right
  -- Then need to run down the lines and check the main fx columns for
  -- any volume commands, and remove them.

end


function get_group_index(first_track_index) 

end




--=======================================================================
-- Use the index to get the next track.
-- If the track is a group, return that group track object
-- If the track is *in* a group, fnd that group and return that group object
-- If the track is not in a group returnn that track object
function get_next_track_pattern(pattern_index, track_index) 


  --[[

  ST = single track,  not in a group
  GT = Group Track
  PT = Plural Track, track in a group


  Possible scenarios:
  * We are in the last track of a group. The next track will be the group track. 

  This is an error

  * We are in a track in a group.  The next track is in the same group
  Return the next track-pattern

  * We are not in a group.  The next track is not in a group
  Return the next track-pattern

  * We are a plain track not in a group. The next track is in a group.
  IDEAL: Return the teack-pattern for the parent group of the that next track
  For now: Forget about identifying groups vs tracks

  * We are a group track. The next track is a track not in a group
  Return the next track-pattern

  * We are a group track. The next track is a track in a  group
  IDEAL: Return the teack-pattern for the parent group of the that next track
  For now: Forget about identifying groups vs tracks. Return next track


  Fri 26 May 2017 09:45:52
  Current plan: Assume we are are currently within  a track (and not in a specific note column.)

  Nw find the next track to right. If that track is a group track, find the *next* track.

  --]]

  local track_pattern = renoise.song().patterns[pattern_index].tracks[track_index]
  local next_track_pattern = renoise.song().patterns[pattern_index].tracks[track_index+1]

  --  if (track_pattern.type == renoise.Track.TRACK_TYPE_GROUP) then
  --    return(track_pattern)
  --  end

  local group_track = renoise.song().tracks[track_index].group_parent

  --  if (group_track == nil) then -- no parent group here
  --   return(track_pattern)
  -- end

  -- Need the PatternTrack object for this group
  return(next_track_pattern)
end

--=======================================================================
function volume_swap_tracks(max_vol1, max_vol2, lines_list)
  print("volume_swap_tracks. lines_list:")
  rprint(lines_list)


  local track_index = renoise.song().selected_track_index
  local _t2i = track_index + 1


  local pattern_index   = renoise.song().selected_pattern_index
  local tp   = renoise.song().patterns[pattern_index].tracks[track_index]

  local tp_next = get_next_track_pattern(pattern_index, track_index) 
  local track1_active = false
  local lines_in_pattern = renoise.song().patterns[pattern_index].number_of_lines

  clear_existing_track_patern_volumes(track_index,    pattern_index)
  clear_existing_track_patern_volumes(track_index+1,  pattern_index)

  local line_num = 0

  for i,l in ipairs(lines_list) do
    line_num = l + 1
    print(tostring(line_num))

    if ( line_num <= lines_in_pattern ) then
      if (track1_active == true ) then
        set_volume_line_track(tp, line_num, max_vol1)
        set_volume_line_track(tp_next, line_num, '00' )         
      else
        set_volume_line_track_pattern(tp, line_num, '00')
        set_volume_line_track_pattern(tp_next, line_num, max_vol2 )
      end

      track1_active =  not track1_active 
    end
  end

end


function set_volume_line_track_pattern(tp, line_num, max_vol1)

end


--=======================================================================
function Core.set_location()

  Core.we_are_in_note_column  = false
  Core.we_are_in_track        = false
  Core.we_are_in_group        = false

  if ( not (renoise.song().selected_note_column_index == nil ) ) then
    if ( not (renoise.song().selected_note_column_index == 0 ) ) then
      print("We are in a note column: ", renoise.song().selected_note_column_index)
      -- :(  Even if you are in the trck fx column this is still returning a note_colum_index
      -- :) BUt it is 0.   

      Core.we_are_in_note_column = true
      return
    end
  end

  Core.current_track  = renoise.song().selected_track

  if (Core.current_track.type == renoise.Track.TRACK_TYPE_GROUP ) then
    print("We are in a group track")
    Core.we_are_in_group = true
    return
  end

  -- OK, not a group, just a track

  print("We are in a normal track")
  Core.we_are_in_track = true


end

--=======================================================================
function Core.new_set_from_funct_string(function_str, current_set)


  local _pi   = renoise.song().selected_pattern_index
  local lines_in_pattern = renoise.song().patterns[_pi].number_of_lines


  local func_table = string.to_word_table(function_str)
  local func_char = table.remove(func_table, 1)

  U.str_table_to_int(func_table)
  local generated_line_table = {}
  local sorted_line_numbers = {}

  print("Dispatch on '" .. "'" .. func_char .. "'")

  if (func_char == "+") then
    generated_line_table = sequence_from_inc_set(func_table, lines_in_pattern, current_set)
  end

  if (func_char == "/") then
    generated_line_table = sequence_from_mod_set(func_table, lines_in_pattern, current_set)
  end
  for n in pairs(generated_line_table) do table.insert(sorted_line_numbers, n) end

  table.sort(sorted_line_numbers)

  return sorted_line_numbers
end


-- ======================================================================
Core.set_swap_values = function(gui)
  Core.set_location()

  local vol1 = gui.col1_vol
  local vol2 = gui.col2_vol
  local lines_list = string.int_list_to_numeric(gui.lines_list)

  if (Core.we_are_in_note_column) then
    volume_swap_note_columns( string.trim(vol1), string.trim(vol2), lines_list)
    return
  end

  if (Core.we_are_in_track) then
    volume_swap_tracks( string.trim(vol1), string.trim(vol2), lines_list)
    print("We need to swap volues for a pair of tracks ... ")
    return
  end

  if (Core.we_are_in_group) then
    print("We need to swap volues for a pair of groups ... Not quite ready.")

    volume_swap_tracks( string.trim(vol1), string.trim(vol2), lines_list)
    --    volume_swap_groups( string.trim(vol1), string.trim(vol2), lines_list)
    return
  end



end

return Core
