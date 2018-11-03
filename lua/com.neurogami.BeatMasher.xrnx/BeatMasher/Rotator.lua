-- TODO See if there is some way to gra these direct from 
-- the rotator tool code in case they change on
-- an update.
--
local RANGE_WHOLE_SONG = 1
local RANGE_WHOLE_PATTERN = 2
local RANGE_WHOLE_PHRASE = 3
local RANGE_TRACK_IN_SONG = 4
local RANGE_TRACK_IN_PATTERN = 5
local RANGE_SELECTION_IN_PATTERN = 6
local RANGE_SELECTION_IN_PHRASE = 7

have_rotator = false

local function attempt_remove_menu(menu_name)
  renoise.tool():remove_menu_entry(menu_name)
end


function rotate_setup()
  package.path = "../com.renoise.PatternRotate.xrnx/?.lua;" .. package.path
  require "pattern_line_tools"
  require "main"
end


-- num pattern lines, mod number for selection, n is by who may lines we rotated
-- BUG: Sometimes returns 0, but there is never a line 0; must start at 1
function find_mod_copy_start_line( num_pattern_lines, mod, n)
  local lowest = 100
  local _t = 100
  
  -- This assumes that "every n lines" never includes the first line.
  for i=mod, num_pattern_lines, mod do
    print("Look at " .. i .. " + " .. n .. " % " .. num_pattern_lines )
    _t = (i+n) % num_pattern_lines 
    if _t < lowest then
      lowest = _t
    end
  end

  -- cannot return zero, so what does that mean?
  if (lowest < 1 ) then
    lowest = 1
  end  -- SEEMS SO SO HACKY
  return(lowest)
end


function attempt_rotate_setup()

  local res, err = pcall(rotate_setup)

  if (res) then
    have_rotator = true
    res, err = pcall( attempt_remove_menu, "Pattern Editor:Rotate..." )
    if res then
      print("Should have removed an extra Rotate menu")
    end
    print(TOOL_NAME, " seems to have loaded code from com.renoise.PatternRotate.xrnx")
  else
    have_rotator = false
    print("WARNING: ", TOOL_NAME, " Failed to load code from com.renoise.PatternRotate.xrnx" )
  end
end


rotate_handlers = {
  { 
    pattern = "/rotate/pattern", handler = function(track_num, lines)

      -- need a way to get the current pattern or something so that
      -- this works on the right stuff
      print("Rotate ",lines, " lines")

      --      local selected_track_index = song().selected_track_index
      local song = renoise.song
      if (track_num > -1 ) then
        song().selected_track_index = track_num
        local selected_track_index = song().selected_track_index
        print( "ROTATE: selected_track_index is now " , selected_track_index )
      end
      rotate(lines, RANGE_TRACK_IN_PATTERN, true)
    end 
  }, 

  {
    pattern = "/rotate/pattern/striped", handler = function(selected_track_index, lines, mod_num)

      print("Rotate pattern striped(selected_track_index=" .. selected_track_index .. " lines=" .. lines .. "; mod_num=" .. mod_num)

      local song = renoise.song

      song().selected_track_index = selected_track_index
      local selected_pattern_index   = renoise.song().selected_pattern_index
      local src_pattern_track   = renoise.song().patterns[selected_pattern_index].tracks[selected_track_index]


      --   clone the source pattern-track to the end of song

      local new_pattern_index = U.clone_pattern_track_to_end(selected_pattern_index, selected_track_index)

      -- This should set the song pointer to that new pattern
      song().selected_sequence_index = new_pattern_index

      rotate(lines, RANGE_TRACK_IN_PATTERN, true)
      song().selected_sequence_index = selected_pattern_index   

      local num_pattern_lines = #renoise.song().patterns[selected_pattern_index].tracks[selected_track_index].lines
      print( "num_pattern_lines = " .. num_pattern_lines .. "; mod_num = " ..mod_num)

      --   Then, in the rotated copy, we find the starting line for altered mod_num lines 
      local sline = find_mod_copy_start_line( num_pattern_lines, mod_num, lines)

      -- copy just the altered lines (i.e. every mod_num line from the starting line
      local temp_patt = song().patterns[new_pattern_index].tracks[selected_track_index]
      for i=sline,num_pattern_lines,mod_num do 

        print("Copy over line " .. i .. "; " , temp_patt:line(i) )
        song().patterns[selected_pattern_index].tracks[selected_track_index]:line(i):copy_from(  temp_patt:line(i) )
      end

      --   Then delete the cloned PT
      song().sequencer:delete_sequence_at(#song().sequencer.pattern_sequence)

      -- and go back to the original sequence
      song().selected_sequence_index = selected_pattern_index   
    end 
  }, 

  { 
    pattern = "/rotate/current", handler = function(lines)

      print("Rotate current track-pattern", lines, " lines")
      local song = renoise.song
      local selected_track_index = song().selected_track_index
      print( "ROTATE: selected_track_index is now " , selected_track_index, " lines = " .. lines )
      -- function rotate(shift_amount, range_mode, shift_automation)
        rotate(lines, RANGE_TRACK_IN_PATTERN, true)
      end 
    }, 
  }

