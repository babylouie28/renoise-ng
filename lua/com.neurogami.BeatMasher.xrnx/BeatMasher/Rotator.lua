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
    pattern = "/rotate/pattern",
    handler = function(track_num, lines)

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
    pattern = "/rotate/pattern/striped",
    handler = function(selected_track_index, lines, mod_num)

      -- need a way to get the current pattern or something so that
      -- this works on the right stuff
      print("Rotate pattern striped(selected_track_index=", selected_track_index, " lines=", lines )

      local song = renoise.song


      song().selected_track_index = selected_track_index
      local selected_pattern_index   = renoise.song().selected_pattern_index
      local src_pattern_track   = renoise.song().patterns[selected_pattern_index].tracks[selected_track_index]


      -- This is more complex
      -- Code needs to 
      --   clone the source pattern-track someplace (end of song I guess

      local cloned_pattern_track = U.clone_pattern_track_to_end(selected_pattern_index, selected_track_index)

      --   rotate that cloned PT the given number of lines
      --  first set that new PT as the current focus
      ---- rotate(lines, RANGE_TRACK_IN_PATTERN, true)
      --   Then copy over just the lines that have changed to the original
      --   Then delete the cloned PT

      -- rotate(lines, RANGE_TRACK_IN_PATTERN, true)
    end 
  }, 

  { 
    pattern = "/rotate/current",
    handler = function(lines)

      print("Rotate current track-pattern",lines, " lines")
      local song = renoise.song
      local selected_track_index = song().selected_track_index
      print( "ROTATE: selected_track_index is now " , selected_track_index, " lines = " .. lines )
      -- function rotate(shift_amount, range_mode, shift_automation)
        rotate(lines, RANGE_TRACK_IN_PATTERN, true)
      end 
    }, 
  }

