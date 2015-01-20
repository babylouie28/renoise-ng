
local RANGE_WHOLE_SONG = 1
local RANGE_WHOLE_PATTERN = 2
local RANGE_TRACK_IN_SONG = 3
local RANGE_TRACK_IN_PATTERN = 4
local RANGE_SELECTION_IN_PATTERN = 5

have_rotator = false
have_randy = false

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
    print(TOOL_NAME  .. ": Seem to have loaded code from com.renoise.PatternRotate.xrnx")
  else
    have_rotator = false
    print("WARNING: " .. TOOL_NAME .. " failed to load code from com.renoise.PatternRotate.xrnx." )
    print("Error: ", err)
  end
end

function randy_setup()
  package.path = "../com.neurogami.RandyNoteColumns.xrnx/?.lua;" .. package.path
  require "RandyNoteColumns/Core"
end

function attempt_randy_setup()
  local res, err = pcall(randy_setup)

  if (res) then
    have_randy = true
    print(TOOL_NAME .. ": Seem to have loaded code from com.neurogami.RandyNoteColumns.xrnx")
  else
    have_randy = false
    print("WARNING: " .. TOOL_NAME .. " failed to load code from com.neurogami.RandyNoteColumns.xrnx." )
    print("Error: ", err)
  end

end

-- ********************* OSC Handlers **************************************

rotate_handlers = {

  { 
  pattern = "/rotate/track",
  docs = [[ Rotates the lines in the current pattern of the selected track. 
            Args: track_index, num_lines. ]],
  handler = function(track_index, num_lines)

    -- need a way to get the current pattern or something so that
    -- this works on the right stuff
    print("Rotate ",num_lines, " lines")

    --      local selected_track_index = song().selected_track_index
    local song = renoise.song
    if (track_index > -1 ) then
      song().selected_track_index = track_index
      local selected_track_index = song().selected_track_index
      print( "ROTATE: selected_track_index is now " , selected_track_index )
    end
    rotate(num_lines, RANGE_TRACK_IN_PATTERN, true)
  end 
}, 

}

randy_handlers = {

  {
    pattern = "/randy/clear_track_note_timer",
    docs = [[ Clears note-column soloing timer for the given track. 
              Args: track_index ]],
    handler = function(track_index)
      print("/randy/clear_track_note_timer ", track_index )
      RandyNoteColumns.clear_note_column_timers(track_index)
    end
  },
  {
    pattern = "/randy/add_track_note_timer",
    docs = [[ Creates a note-column soloing timer. 
        Args: track_index, timer_interval, trigger_percentage, solo_stop_percentage, solo_odds (...) ]],
    handler = function(track_index, timer_interval, trigger_percentage,  solo_stop_percentage, ... )

      local note_column_odds = {} 

      -- arg seems to be magic, in that the last value is the arg count.
      -- We do no want that.
      for i,v in ipairs(arg) do
        note_column_odds[i+1] = v 
      end

      RandyNoteColumns.assign_note_column_timer(timer_interval, trigger_percentage, track_index, note_column_odds, solo_stop_percentage)

    end 
  }, 

  {
    pattern = "/randy/solo_note_column",
    docs = [[ Selects the given track and mutes all but the given note column. 
      Args: track_index, note_column.]],
    handler = function(track_index, note_column)
      RandyNoteColumns.solo_note_column_volume(track_index, note_column)
    end
  }

}

